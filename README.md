Note this script is Untested WIP (Work In Progress) and will likely brick your router DO NOT USE!!!!

# FreshTomatoAutoUpgrader
FrestTomatoAutoUpgrade
# Universal FreshTomato Daily Auto-Upgrader Script

A low-footprint, zero-dependency, automated deployment script written in POSIX-compliant shell for FreshTomato routers (ARM and MIPS). Designed to be ran via the built-in system scheduler once every 24 hours to automatically maintain network security patches without manual intervention.

## Architectural Safeguards

This script is built defensively with strict "fail-fast" gates to protect consumer-grade hardware from standard network and operational hazards:
* **Dynamic Environment Check:** Identifies the router chipset flavor (`K26ARM` vs `K26RT-N`) and board layout directly from active `nvram` registers.
* **Network Integrity Validation:** Leverages dynamic `nslookup` queries against upstream Anycast recursive nodes (`8.8.8.8`) to cross-reference IPs and block localized Man-in-the-Middle (MitM) DNS hijacking.
* **NTP Synchronization Lock:** Aborts execution instantly if the local system hardware clock has not established a real-world time anchor via network synchronization.
* **Resource Boundary Protection:** Monitors active system mount loops. Automatically routes decompression buffers to persistent external media (USB storage) if present, or enforces strict volatile memory buffer boundaries (>25MB free RAM) before initializing download blocks.
* **Cryptographic Signature Engine:** Automatically evaluates the host environment for the strongest native utility (`sha256sum` or `md5sum`), downloads the corresponding vendor manifest, and cancels flash sequence instantly on a single bit mismatch.
* **Anti-Rate Limiting Controls:** Uses browser User-Agent spoofing arrays combined with execution delay intervals (`sleep`) to naturally pass server rate thresholds and maintain low network impact.

## Installation via GUI Scheduler

1. Access your router's user dashboard via your browser.
2. Navigate to **Administration** ➔ **Scheduler**.
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
