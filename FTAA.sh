#!/bin/sh
# =========================================================================
# UNIVERSAL FRESHTOMATO AUTO-UPGRADER SCRIPT (Public Release Edition)
# License: MIT (Without Warranty)
# =========================================================================
export PATH="/bin:/usr/bin:/sbin:/usr/sbin:$PATH"

# 1. READ ENVIRONMENT METADATA DYNAMICALLY
M=$(nvram get tomo_hw_engine | tr ' ' '_')
[ -z "$M" ] && M=$(nvram get boardmodel | tr ' ' '_')
A="freshtomato-arm" && C="K26ARM"
[ "$(uname -m)" != "armv7l" ] && A="freshtomato-mips" && C="K26RT-N"
V=$(nvram get os_version | awk '{print $2}')

# 2. WAN ACTIVE CONTEXT PRE-CHECK
ping -c 2 8.8.8.8 >/dev/null 2>&1 || exit 1

# 3. HARDENED SYSTEM CLOCK VALIDATION GATE
[ "$(date +%Y)" -lt 2025 ] && exit 1

# 4. SECURE MULTI-PATH DNS CROSS-REFERENCE (Anti-Poisoning Filter)
TRUE_IP=$(nslookup freshtomato.org 8.8.8.8 | awk '/Address/ {print $3}' | grep -v '8.8.8.8' | head -n 1)
CURL_IP=$(nslookup freshtomato.org | awk '/Address/ {print $3}' | head -n 1)
[ "$TRUE_IP" != "$CURL_IP" ] && exit 1

# 5. AUTOMATED PARTITION MEMORY PROTECTION AUDIT
W="/tmp"
for m in /tmp/mnt/* /mnt/*; do
 [ -d "$m" ] && [ "$m" != "/tmp/mnt/*" ] && [ "$m" != "/mnt/*" ] && [ "$(df -k "$m" | awk 'NR==2{print $4}')" -gt 61440 ] && W="$m" && break
done
[ "$W" = "/tmp" ] && [ "$(awk '/MemAvailable/{print $2}' /proc/meminfo)" -lt 25600 ] && exit 1

# 6. DISGUISED SCRAPING INTERFACE ENTRY (Using Verified Target Path)
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
B="https://freshtomato.org/downloads/"
I=$(curl -A "$UA" -sfk "$B$A/")
[ -z "$I" ] && exit 1

L=$(echo "$I" | grep -o 'href="[0-9]\{4\}\.[0-9]\+/"' | sed 's/href="//;s/\///;s/"//' | sort -V | tail -n 1)
[ -z "$L" ] || [ "$V" = "$L" ] && exit 0
sleep 4

# 7. CHIPSET TARGET DIRECTORY LOOKUP LOOP
Y=$(echo "$L" | cut -d'.' -f1)
U="$B$A/$Y/$L/$C/"
Z=$(curl -A "$UA" -sfk "$U" | grep -oE 'href="[^"]+'$M'[^"]+\.zip"' | sed 's/href="//' | head -n 1)
[ -z "$Z" ] && exit 1
sleep 4

# 8. ADAPTIVE SIGNATURE PATTERN SELECTION
command -v sha256sum >/dev/null 2>&1 && H="sha256sum" && F="SHA256SUMS.txt" || H="md5sum" && F="MD5SUMS.txt"
rm -f $W/f.zip $W/s.txt $W/u.trx

# 9. INTEGRITY PAYLOAD VALIDATION INVOCATION
curl -A "$UA" -sfk -o "$W/f.zip" "$U$Z"
sleep 3
curl -A "$UA" -sfk -o "$W/s.txt" "$U$F"
[ ! -s "$W/f.zip" ] || [ ! -s "$W/s.txt" ] && exit 1

if ! $H "$W/f.zip" | grep -qi "$(awk '{print $1}' $W/s.txt)"; then rm -f $W/f.zip $W/s.txt; exit 1; fi

# 10. SYSTEM BLOCK DECOMPRESSION AND FLASH INITIATION
unzip -p "$W/f.zip" "*.trx" > $W/u.trx
[ -s "$W/u.trx" ] && write $W/u.trx linux && reboot
