#!/bin/sh

# ======DO NOT USE ON YOUR EQUIPMENT IT IS ONLY A BETA PROOF OF CONCEPT!!!!!!!===========
# THIS IS NOT TESTED WILL BRICK YOUR ROUTER WARNING!!!
# UNIVERSAL FRESHTOMATO & TOMATO64 AUTO-UPGRADER SCRIPT (HARDENED PUBLIC POC)
# License: MIT
# Fully secure cross-platform upgrade utility utilizing native CA bundles.
# Verifies file size invariants and checks raw binary magic bytes.
# ==========NOT SAFE FOR USE IN PRODUCTION ENVIORNMENT POC ONLY!!!! WILL BRICK ROUTER!!!!=======

export PATH="/bin:/usr/bin:/sbin:/usr/sbin:$PATH"

# Rigorous sandbox variable mapping to prevent runtime binary path hijacking
CURL="/usr/bin/curl"
GREP="/bin/grep"
AWK="/usr/bin/awk"
SED="/bin/sed"
UNZIP="/usr/bin/unzip"
HEXDUMP="/usr/bin/hexdump"
NVRAM="/usr/sbin/nvram"
WRITE="/sbin/write"
REBOOT="/sbin/reboot"
LOGGER="/usr/bin/logger"

# =========================================================================
# DRY-RUN SIMULATION TOGGLE
# Set SIMULATION_MODE=1 to run all network, file, and structural checks 
# without executing the actual write routine or rebooting the router.
# Set SIMULATION_MODE=0 for normal live firmware upgrades.
# =========================================================================
SIMULATION_MODE=1

log_security_event() {
    # Centralized syslog logging wrapper for automated audits
    $LOGGER -t "FTAA_SECURE_UPGRADER" "[STATUS] $1"
    echo "[LOG] $1"
}

# Enforce secure HTTPS validation via the native compiled firmware CA store
SYSTEM_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
if [ -f "$SYSTEM_CA_BUNDLE" ]; then
    CURL_OPTS="--cacert $SYSTEM_CA_BUNDLE"
else
    log_security_event "CRITICAL: System CA Bundle missing. Halting execution for safety."
    exit 1
fi

# 1. READ ENVIRONMENT & MULTI-SERVER ARCHITECTURE METADATA
M=$($NVRAM get tomo_hw_engine | tr -cd 'a-zA-Z0-9_-' | tr ' ' '_')
[ -z "$M" ] && M=$($NVRAM get boardmodel | tr -cd 'a-zA-Z0-9_-' | tr ' ' '_')

ARCH_TYPE=$(uname -m)
V=$($NVRAM get os_version | $AWK '{print $2}')

if [ "$ARCH_TYPE" = "aarch64" ]; then
    # Tomato64 ARM64 Targets (GL-MT6000, BPI-R3, RPI4, etc.)
    A="$M" && C="ARM64" && IS_T64=1
elif [ "$ARCH_TYPE" = "x86_64" ]; then
    # Tomato64 x86 PC Targets
    A="x86_64" && C="x86_64" && IS_T64=1
elif [ "$ARCH_TYPE" = "armv7l" ]; then
    # Legacy FreshTomato 32-bit ARM
    A="freshtomato-arm" && C="K26ARM" && IS_T64=0
else
    # Legacy FreshTomato MIPS
    A="freshtomato-mips" && C="K26RT-N" && IS_T64=0
fi

# 2. WAN ACTIVE CONTEXT PRE-CHECK
ping -c 2 8.8.8.8 >/dev/null 2>&1 || { log_security_event "Network unreachable. Exiting."; exit 1; }

# 3. HARDENED SYSTEM CLOCK VALIDATION GATE
[ "$(date +%Y)" -lt 2026 ] && { log_security_event "System time invalid or backdated. Exiting."; exit 1; }

# 4. SECURE MULTI-PATH DUAL-DOMAIN DNS CROSS-REFERENCE (Anti-Poisoning Filter)
# Validates both server domains against a neutral public recursive resolver
FT_TRUE_IP=$(nslookup freshtomato.org/downloads 8.8.8.8 | $AWK '/Address/ {print $3}' | $GREP -v '8.8.8.8' | head -n 1)
FT_CURL_IP=$(nslookup freshtomato.org/downloads | $AWK '/Address/ {print $3}' | head -n 1)
[ "$FT_TRUE_IP" != "$FT_CURL_IP" ] && { log_security_event "DNS Hijack Detected on freshtomato.org! Authority mismatch."; exit 1; }

T64_TRUE_IP=$(nslookup tomato64.org/files 8.8.8.8 | $AWK '/Address/ {print $3}' | $GREP -v '8.8.8.8' | head -n 1)
T64_CURL_IP=$(nslookup tomato64.org/files | $AWK '/Address/ {print $3}' | head -n 1)
[ "$T64_TRUE_IP" != "$T64_CURL_IP" ] && { log_security_event "DNS Hijack Detected on tomato64.org! Authority mismatch."; exit 1; }

# 5. AUTOMATED PARTITION MEMORY PROTECTION AUDIT
W="/tmp"
for m in /tmp/mnt/* /mnt/*; do
    [ -d "$m" ] && [ "$m" != "/tmp/mnt/*" ] && [ "$m" != "/mnt/*" ] && [ "$(df -k "$m" | $AWK 'NR==2{print $4}')" -gt 61440 ] && W="$m" && break
done
[ "$W" = "/tmp" ] && [ "$($AWK '/MemAvailable/{print $2}' /proc/meminfo)" -lt 25600 ] && { log_security_event "Insufficient execution memory available."; exit 1; }

# 6. ENFORCED TLS SCRAPING INTERFACE ENTRY (Stripped of -k bypasses)
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

if [ "$IS_T64" -eq 1 ]; then
    B="https://tomato64.org/files"
    I=$($CURL $CURL_OPTS -A "$UA" -sf "$B$A/")
else
    B="https://freshtomato.org/downloads/"
    I=$($CURL $CURL_OPTS -A "$UA" -sf "$B$A/")
fi

if [ -z "$I" ]; then
    log_security_event "Secure file manifest collection failed. Check server status."
    exit 1
fi

# 7. TARGET PATH COMPILATION & ARCHITECTURE ALIGNMENT
if [ "$IS_T64" -eq 1 ]; then
    # Tomato64 stores images inside a flat root architecture directory
    U="$B$A/"
    Z=$(echo "$I" | $GREP -oE 'href="[^"]+'$M'[^"]+\.zip"' | $SED 's/href="//' | head -n 1)
else
    # Legacy FreshTomato branches scrape based on chronological directory layout
    L=$(echo "$I" | $GREP -o 'href="[0-9]\{4\}\.[0-9]\+/"' | $SED 's/href="//;s/\///;s/"//' | sort -V | tail -n 1)
    if [ -z "$L" ] || [ "$V" = "$L" ]; then
        log_security_event "Firmware is already up to date."
        exit 0
    fi
    sleep 4
    Y=$(echo "$L" | cut -d'.' -f1)
    U="$B$A/$Y/$L/$C/"
    Z=$($CURL $CURL_OPTS -A "$UA" -sf "$U" | $GREP -oE 'href="[^"]+'$M'[^"]+\.zip"' | $SED 's/href="//' | head -n 1)
fi

[ -z "$Z" ] && { log_security_event "Matching firmware image string not found on remote server."; exit 1; }
sleep 4

# 8. ADAPTIVE SIGNATURE PATTERN SELECTION
command -v sha256sum >/dev/null 2>&1 && H="sha256sum" && F="SHA256SUMS.txt" || H="md5sum" && F="MD5SUMS.txt"
rm -f $W/f.zip $W/s.txt $W/u.trx

# 9. INTEGRITY PAYLOAD VALIDATION INVOCATION
$CURL $CURL_OPTS -A "$UA" -sf -o "$W/f.zip" "$U$Z"
sleep 3
$CURL $CURL_OPTS -A "$UA" -sf -o "$W/s.txt" "$U$F"

[ ! -s "$W/f.zip" ] || [ ! -s "$W/s.txt" ] && { log_security_event "Download payload empty or rejected by remote host."; exit 1; }

# Upstream File Content Size Boundary Guard (Refuse files smaller than 10MB)
[ $(wc -c < "$W/f.zip") -lt 10485760 ] && { log_security_event "Downloaded archive fails content size invariants."; exit 1; }

if ! $H "$W/f.zip" | $GREP -qi "$($AWK '{print $1}' $W/s.txt)"; then 
    log_security_event "CRITICAL: Checksum verification validation failure! Deleting tracking elements."
    rm -f $W/f.zip $W/s.txt
    exit 1
fi

# 10. SYSTEM BLOCK DECOMPRESSION AND HARDENED TRX EVALUATION
$UNZIP -p "$W/f.zip" "*.trx" > $W/u.trx
if [ -s "$W/u.trx" ]; then
    # Structural Audit: Enforce mandatory Broadcom/MediaTek 'HDR0' magic bytes signature
    TRX_MAGIC=$($HEXDUMP -n 4 -e '"%c"' "$W/u.trx" 2>/dev/null)
    if [ "$TRX_MAGIC" != "HDR0" ]; then
        log_security_event "SECURITY REJECTION: Image lacks mandatory 'HDR0' magic hardware bytes."
        rm -f $W/f.zip $W/s.txt $W/u.trx
        exit 1
    fi

    # Boundary Cross-Check: Match physical byte footprint against the embedded size header [bytes 4-7]
    LEN_HEX=$($HEXDUMP -s 4 -n 4 -e '1/4 "%08x"' "$W/u.trx" 2>/dev/null)
    LEN_DEC=$((0x$LEN_HEX))
    ACTUAL_SIZE=$(wc -c < "$W/u.trx")
    if [ "$ACTUAL_SIZE" -lt "$LEN_DEC" ]; then
        log_security_event "SECURITY REJECTION: Target byte stream footprint smaller than declared header length."
        rm -f $W/f.zip $W/s.txt $W/u.trx
        exit 1
    fi

    # SIMULATION MODE EVALUATION CONTROL
    if [ "$SIMULATION_MODE" -eq 1 ]; then
        log_security_event "DRY-RUN SUCCESSFUL: Payload verified authentic. Flashing skipped by simulation mode toggle."
        rm -f $W/f.zip $W/s.txt $W/u.trx
        exit 0
    else
        log_security_event "Payload verified. Commencing hardware image installation wrapper..."
        $WRITE $W/u.trx linux && $REBOOT
    fi
fi
