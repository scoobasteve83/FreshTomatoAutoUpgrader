Note this script is Untested WIP (Work In Progress) and will likely brick your router. May have security implications and is only a proof of concept DO NOT USE IN CURRRENT FORM OR PRODUCTION ENVIORNMENT!!!!

Use of this auto upgrader requires a usb port on your router and a known working usb flash drive!

#CURRENT STATUS: UNTESTED BETA DO NOT USE MAY BRICK YOUR ROUTER! 

# FreshTomatoAutoUpgrader 2026 or Higher Versions ONLY!!!
FrestTomatoAutoUpgrade
# Universal Hardened Auto-Upgrader for Tomato64 & FreshTomato

A low-footprint, zero-dependency, automated deployment script written in POSIX-compliant shell for FreshTomato routers (ARM and MIPS). Designed to be ran via the built-in system scheduler once every 24 hours to automatically maintain network security patches without manual intervention.

## Architectural Safeguards



A zero-trust, automated public Proof-of-Concept upgrade script built specifically for routers running FreshTomato (32-bit MIPS/ARM) and Tomato64 (ARM64/x86_64). 

## Security & Hardening Architecture

This script implements robust mitigation layers to eliminate path injection vulnerabilities, man-in-the-middle exploits, and hardware bricking without modifying the firmware.

*   **Enforced TLS Verification:** Bypasses unsafe `-k` or `--insecure` parameters. The upgrade engine explicitly maps transfers through the router's read-only root certificate store (`/etc/ssl/certs/ca-certificates.crt`).
*   **Dynamic Multi-Server Cross-Routing:** Natively detects system architecture using `uname -m`. It targets the proper endpoint structures automatically—routing legacy hardware to `freshtomato.org/downloads/` and modern 64-bit boards to the `tomato64.org/files/` layout.
*   **Anti-Poisoning DNS Canary Filter:** Cross-references internal lookups with independent public resolvers (Google `8.8.8.8`) before running remote queries. Execution drops instantly if local cache anomalies or DNS manipulation are detected.
*   **`HDR0` Structural Integrity Auditing:** Inspects the first 4 uncompressed bytes of the extracted firmware binary to verify the presence of the mandatory Broadcom/MediaTek `HDR0` signature before initiating flash operations.
*   **Metadata Boundary Boundary Matches:** Evaluates structural byte limits encoded within the file headers against the physical storage footprint, completely eliminating partial download execution attempts.
*   **Absolute Path Execution Sandboxing:** Binds execution commands to explicit system locations (e.g., `/usr/bin/curl`, `/bin/grep`), neutralizing variable runtime overrides.

*   # INSTALLATION INSTRUCTIONS:
# 1. Log into your router's Web GUI (e.g., http://192.168.1.1)
# 2. In the left-hand sidebar menu, navigate to: 
#    Administration -> Scheduler
# 3. Scroll down to the "Custom Commands" or "Cron" settings section.
# 4. Paste this entire code block into the command entry text field.
# 5. Set your preferred execution intervals (e.g., Daily at 03:00 AM).
# 6. Click "Save" at the bottom of the page to apply the schedule.
#
# FILESYSTEM PLACEMENT REQUIREMENTS:
# * The main "FTAA.sh" script MUST be saved on the ROOT folder of your 
#   physically attached USB drive (e.g., /tmp/mnt/sda1/FTAA.sh)

## How to Test via Simulation Mode USB FLASH DRIVE REQUIRED IN ALL CASES!!!

By default, the script ships with **`SIMULATION_MODE=1`** enabled at the top of the file. This allows safe runtime testing across any target environment.

1. Copy the full script and place it in the root folder of your USB FLASH DRIVE FTAA.sh
2. In the router Web GUI, navigate to **Status > Logs** or open your favorite syslog tail viewer via SSH (`logread -f`).
3. Run the script manually over an SSH session or via **Tools > System Commands**.
4. Check the logs. A successful pass will output:
   `FTAA_SECURE_UPGRADER [STATUS] DRY-RUN SUCCESSFUL: Payload verified authentic. Flashing skipped...`
5. Once verified, change `SIMULATION_MODE=0` inside the script wrapper to arm live deployment automation.


## Installation via GUI Scheduler

1. Access your router's user dashboard via your browser.
2. Navigate to **Administration** ➔ **Scheduler**. The Schedular script only!!!
3. Under the **Custom Script** parameter interface, click **Enabled**.
4. Configure the temporal constraints to run once daily (e.g., set to an obscure time window like `Every Day` at `04:19 AM`). 
5. Copy the minified shell code block directly into the large textual command layout parameter box.
6. Click **Save** at the interface footer.

---

## ⚠️ LEGAL DISCLAIMER & LIABILITY LIMITATION

### 1. AS-IS / WORK IN PROGRESS STATUS
**THIS UTILITY IS COMPREHENSIVELY PROVIDED "AS IS" AND IS CONFIGURED PRIMARILY AS A PRIVATE WORK CONTEXT PROTOTYPE.** While the script contains robust fallback architectures, it has not undergone extensive, multi-tier device matrix testing across every historical Broadcom variant. It is fundamentally intended as a personal file and is **NOT RECOMMENDED FOR UNMODIFIED GENERAL PUBLIC PRODUCTION DEPLOYMENTS**. Extensive source code audits and environment-specific variations must be applied by any party choosing to execute it.

### 2. RISK ACKNOWLEDGEMENT & PROPERTY INTEGRITY
Automated firmware flashes over system memory blocks carry implicit operational hazards. By utilizing, copying, downloading, or deploying this script onto any network routing hardware, you explicitly acknowledge that:
* Low-level command writes bypass specific interface visual warnings.
* Scrambled or outdated local `NVRAM` tables may occasionally trigger manual clearing parameters (hard hardware resets) to re-establish post-flash stable states.
* Power interruptions or server structural metadata mutations mid-stream could result in total system block degradation (commonly referred to as "bricking").

### 3. EXCLUSION OF LIABILITY & DAMAGES
IN NO EVENT SHALL THE AUTHOR, CONTRIBUTOR, OR REPOSITORY OWNER BE HELD LIABLE TO YOU OR ANY THIRD PARTY FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, HARWARE PROPERTY BREACHES, DATA CORRUPTION, SYSTEM DOWNTIME, LOSS OF PROFITS, BUSINESS DISRUPTION, OR RECOVERY SERVICE FEES) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE) ARISING IN ANY WAY OUT OF THE USE OF OR INABILITY TO USE THIS UTILITY, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

**IF YOU CHOOSE TO DISTRIBUTE OR MODIFY THIS LOGIC PUBLICLY, YOU ASSUME ENTIRE AND EXCLUSIVE OPERATIONAL RESPONSIBILITY FOR THE RESULTING OUTCOMES.**
