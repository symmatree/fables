# Tiles host instability

*Tracks Proxmox host lock-ups / unresponsiveness on the Tiles cluster. One confirmed hard wedge so far ([[nuc-g3p-2]], 2026-06-29); other possibly-related incidents to be catalogued. Following the [[experiments-house-model|house-experiments]] style: neutral facts, theories with evidence for/against, and diagnostic next steps. A topic closes when confirmed findings fully explain the behaviour.*

Related: [[Tiles (proxmox)]], [[nuc-g3p-2]], [[alloy]], [[mimir]], [[loki]], [[guiding-principles]].

---

## Scope

On 2026-06-29 the Proxmox host [[nuc-g3p-2]] became fully unresponsive ("wedged" — powered, but no SSH, no API, metrics stopped). It recovered only after a manual power-cycle the following morning. The host carries the **entire test cluster** ([[tiles-test-cp]] + [[tiles-test-wk]]) on a single box, so it is the most resource-squeezed node in the fleet.

Open question (drives this doc): **is this selective to nuc-g3p-2, or a general fleet failure mode?** A few other possibly-related problems have been observed anecdotally but are not yet catalogued here (see *Other possibly-related incidents*).

## Hardware / baseline facts

- [[nuc-g3p-2]]: [[GMKtec Nucbox G3 Plus N150 16GB]] — Intel N150 (4 cores), 16 GB RAM (15.37 GB usable), 512 GB NVMe. BIOS: High Performance power profile, EC Turbo Control Mode on, fan Automatic, Wake-On-Power → S0.
- VMs on it: [[tiles-test-cp]] (5 GB) + [[tiles-test-wk]] (8 GB) = **13 GB of 15.37 GB allocated to VMs**, plus host + the alloy LXC.
- Host memory runs at **~89%** as a steady state (13.64 / 15.37 GB measured 2026-06-30; [[nuc-g3p-2]] kb doc recorded 89.1% back in Feb 2026 — long-standing, not new). Per operator: **VM RAM is preallocated**, so this ~89% is a static floor, not a climbing value.
- The other three hosts ([[nuc-g2p-1]], [[nuc-g2p-2]], [[nuc-g3p-1]]) run the prod cluster with more headroom per node.

## ⚠️ Measurement-level caveat (important)

The `node_exporter` for each `nuc-*` host **runs inside that host's alloy LXC**, not on the Proxmox host. `lxcfs` virtualises `/proc/meminfo` to the container cgroup, so:

- **LXC-level (not host):** all `node_memory_*` (MemTotal reads as **0.537 GB** = the LXC cgroup, not 15.37 GB), `SwapTotal`/`SwapFree`, network counters (container veth), and likely vmstat OOM/fault counters.
- **Host-level (genuinely):** `node_cpu_*` incl. **iowait** (`/proc/stat` is not namespaced), **disk** stats (`/proc/diskstats`), and **hwmon temps** (sysfs).

Consequence: any memory/swap conclusion drawn from these metrics is about the ~512 MB alloy LXC, **not** the host. Host memory/swap must come from Proxmox (`pvesh`/RRD) or the host shell. This invalidated an earlier (wrong-level) "memory is fine" reading during the investigation.

(Data source for the analysis below: Mimir queried directly via `mimir-gateway`, tenant `tiles`, since Grafana was unavailable.)

---

## Open issues

### nuc-g3p-2 hard wedge — 2026-06-29

**Confirmed (neutral data points):**

- **Dropout at ~14:20 UTC 2026-06-29.** Last metrics datapoint ~14:20; host fully unreachable thereafter. Plan-apply CI jobs corroborate: a run at 12:24 UTC succeeded (host up), a run at 14:54 UTC failed against it (host down). Recovered only after a manual power-cycle ~2026-06-30 morning; VMs auto-started (`on_boot`).
- **Progressive unresponsiveness preceded the wedge.** node_exporter scrape success (`up`, scrape timeout 10 s): 100 % through Jun 28 → first wobble late Jun 28 ~23:30 to Jun 29 ~05:00 (dipped to 60–87 %, recovered) → stable 100 % 05:30–11:30 → **terminal decline from ~12:00** (83 → 60 → 57 → 50 %) to dead at 14:20. On failing scrapes `scrape_duration_seconds` pegged at the 10 s timeout; successful scrapes were 0.04 s. So the host intermittently could not answer a trivial HTTP request for over an hour before dying.
- **Isolated to nuc-g3p-2.** Over the same window, nuc-g2p-1, nuc-g2p-2, nuc-g3p-1 held **100 % scrape success** — they mount the same NAS and run the same workload classes.
- **Host-level resource signals during the decline:** iowait rose from ~3–8 % baseline to **~27–36 %**; average disk op-latency rose to **~50 ms** (abnormal for NVMe); `nvme0n1` busy fraction peaked ~69 % (not pinned); context switches **fell** (~20 k → ~11 k/s, consistent with tasks blocked in uninterruptible/D-state).
- **CPU thermal normal:** coretemp 71–81 °C (warm — this host runs hottest in the fleet), **zero** package/core throttle events. **NVMe temp flat ~45 °C** throughout.
- **Physical inspection:** host warm, network LED flickering. *(LED flicker = normal traffic indicator; not diagnostic. Do not read meaning into it.)*

**Current theories:**

- **(T1) Host memory overcommit → OOM / reclaim-livelock.** *Plausible, unconfirmed.* The host runs ~89 % memory with ~1.7 GB headroom and (believed) no swap; with no swap cushion, any allocation past the headroom goes straight to OOM-kill or reclaim livelock — which matches the can't-SSH hard wedge and leaves no clean metrics (the box can't report during a livelock, explaining the data gap at the end). It fits the isolation: g3p-2 is the most-squeezed host, so it would tip first. *Evidence against:* VM RAM is **preallocated**, so the ~89 % is a steady floor with **no known spike vector** — OOM needs something to consume the headroom, and none is identified. No host-level *historical* memory was available to check for a climb. (The LXC-level OOM counter read 0, but that is the wrong level and terminal events are uncaptured.)
- **(T2) Local storage (NVMe) latency/stall.** *Host-level correlate; cause-vs-symptom unresolved.* iowait to ~36 % and disk op-latency to ~50 ms during the decline, with falling context switches (D-state blocking), are genuine host-level signals consistent with the storage path intermittently stalling. *Evidence against:* NVMe temp was normal (not a thermal-throttle of the drive); disk was ~69 % busy, not saturated; a comparably-loaded host (nuc-g2p-1) hit iowait spikes of 23–27 % and stayed 100 % healthy — so iowait magnitude alone is not sufficient. The latency could be a *symptom* of memory reclaim rather than a cause (see T3).
- **(T3) Reclaim-driven I/O (unifies T1+T2).** *Speculative.* Host memory pressure → page-cache eviction → re-fault reads from NVMe → iowait and disk-latency rise → stalls. Ties both host-level signals to one mechanism. *Evidence against:* inherits T1's missing spike vector.
- **(T4) Single-node-whole-cluster under-provisioning (framing, not a mechanism).** g3p-2 carries the logical memory + I/O of the entire test stack ([[mimir]], [[loki]], etcd, [[alloy]]) on one box. This is expected to be tolerated, but it makes g3p-2 the tightest node and the first to fail under any of T1–T3. Explains *why g3p-2 specifically* without itself naming the trigger.

**Disproven:**

- ~~Shared NAS / NFS bottleneck.~~ The other three hosts mount the same NAS and ran 100 % scrape success through the entire window. A shared-storage stall would have been fleet-wide; it was not.
- ~~CPU thermal throttle.~~ Zero throttle events; temps below Tjmax.
- ~~NVMe overheating.~~ Drive temp flat ~45 °C across the event.

**Weakened / measurement-confounded:**

- ~~Alloy LXC ran out of RAM.~~ The alloy LXC was ~90 % *free* (~56 MB of 537 MB used) — but that is LXC-level and says nothing about host pressure. "Alloy exhausted its cgroup" is not supported; "alloy contributed to *host* pressure" is simply untested (wrong instrument).
- ~~"Memory is fine / ruled out."~~ Withdrawn: that reading was from the LXC-level exporter. Host memory is tight and was never tested at the host level historically.

**Next steps (diagnostic / observation):**

- [ ] **(Observation)** Pull the host kernel journal for the wedge window and the late-Jun-28 wobble: `journalctl -k --since "2026-06-29 11:30" --until "2026-06-29 14:30"` on nuc-g3p-2. Look for OOM-killer invocations (→ T1), `nvme nvmeX: I/O timeout` / controller resets (→ T2), or `task blocked for more than 120 seconds` hung-task traces. Each points a different direction. Survives the reboot if journald is persistent.
- [ ] **(Observation)** Confirm host swap config on all four hosts: `swapon --show`, `free -h`, zram status. T1 hinges on whether swap is disabled.
- [ ] **(Instrumentation, fixes the blind spot)** Measure memory/swap/network at the **host** level, not only inside the alloy LXC — run node_exporter on the Proxmox host, or scrape Proxmox `pvestatd`/RRD. Without this, host memory pressure is invisible to monitoring.
- [ ] **(Observation)** Capture Proxmox host RRD history (`pvesh get /nodes/nuc-g3p-2/rrddata --timeframe day`) to see host memory + I/O across the event (tests T1's "did host memory climb?").
- [ ] **(Diagnostic, on recurrence)** Before power-cycling a wedged host, attempt **console** (not SSH) access to capture `dmesg`/`top`/`echo m > /proc/sysrq-trigger` state. Most valuable evidence is lost on reboot.
- [ ] **(Diagnostic, interventional)** Reduce g3p-2 pressure and watch for recurrence: lower a test VM's RAM, or migrate one test VM off g3p-2, and observe whether the scrape-timeout wobbles return. Tests T4 / T1.
- [ ] **(Config, after journal findings)** Decide swap/OOM policy deliberately — a modest swap or zram, and/or `earlyoom`, so memory pressure degrades gracefully instead of hard-wedging. Gate on what the journal shows.

### Other possibly-related incidents

**Confirmed:**

- (none catalogued yet)

**To gather:**

- [ ] **(Observation)** Inventory the "few related maybe problems" already observed (operator). For each: date/time, host, symptom (hard wedge vs slow vs reboot), and whether it recovered on its own or needed a power-cycle. Then check each against Mimir (scrape `up` per host, iowait, temps) to see if they share nuc-g3p-2's signature (progressive scrape-timeout decline; host-level iowait rise; no thermal throttle) or look different.
- [ ] **(Analysis)** Once ≥2 events exist: is the failing host always g3p-2 (→ hardware/host-local or its single-node-whole-cluster role), or spread across hosts (→ a general Talos/Proxmox/workload pattern)?

---

## Notes on method

- The single most useful discriminator here was **comparing all four hosts** on the same metric and window: it cleanly killed the NAS theory (shared cause → shared symptom; it wasn't shared).
- Watch the **measurement level** of every metric. Half of the memory analysis was accidentally measuring a 512 MB LXC, not the 15 GB host, and briefly led to the opposite conclusion. Confirm what each exporter actually sees before trusting a number (see caveat above).
- No confirmed root cause yet. The metrics performed the *elimination* (not NAS, not thermal, isolated to g3p-2) but do not contain the verdict; the host kernel journal is the missing evidence.
