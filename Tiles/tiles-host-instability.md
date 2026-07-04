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

### Within-VM runaway (guest-level wedge) — tiles-wk-1, 2026-07-03

*A distinct failure mode at the **guest** layer, catalogued here because it can be **coupled** to host degradation and presents almost identically from the outside (progressive scrape-timeout decline, then a node that is powered but not answering). First observed on [[tiles-wk-1]] (VM 7221 on [[nuc-g2p-1]]) 2026-07-03; diagnosed live. Method notes at the end — including the wrong turns, logged on purpose.*

**Confirmed (neutral data points):**

- **wk-1 went NotReady/unreachable 2026-07-03 ~22:15 UTC** (18:15 local). Kubelet stopped posting status → `node.kubernetes.io/unreachable` taints. Progressive decline preceded it: a single `apid` health blip ~3.7 h earlier, then sustained flapping from ~2 h before the cutover — the same *shape* as the g3p-2 decline, one layer down.
- **The VM was alive the whole time; the host was healthy.** Talos `apid`/`machined` answered intermittently throughout. [[nuc-g2p-1]] was online (27 d uptime), API-responsive, and its other guest (tiles-cp-1) was unaffected. Contained inside one guest — the inverse topology of the [[nuc-g3p-2]] host wedge.
- **Every node-local service flapped the same way.** `containerd`, `cri`, `kubelet` (`127.0.0.1:10248/healthz`), `apid` (`:50000`), `machined` (`machine.sock`), `registryd` (`:3172`) all cycling `DeadlineExceeded` / `i/o timeout` on their *own* health checks — a whole-guest starvation signature, not one failed service.
- **In-guest process snapshot (the decisive measurement): 598 `containerd-shim` processes against 3 live `pause` sandboxes, ~6,900 shim threads.** Normal is ~1 shim per sandbox (confirmed on the sibling nodes below). The kubelet log was full of `CreatePodSandbox` / `StopPodSandbox` failing with `cannot start a stopped process` / `sandbox container … is not running`.
- **Isolated to wk-1.** wk-2 and wk-3 run identical Talos v1.13.0 / containerd 2.2.3 and showed a normal ~1:1 shim:sandbox ratio — not a fleet-wide accumulation. (wk-2 *did* flap NotReady once earlier the same day, 13:54 UTC, and recovered on its own.)
- **Downstream victims, not causes.** `odm/postgres` (BestEffort, `resources:{}`) was OOM-killed (exit 137) ×4 at 08:54/09:34 UTC and then stuck `Terminating` ~7 h (the wedged runtime could not reap it). Cilium and every other pod were `CrashLoopBackOff`/`Error` with the identical sandbox errors.
- **No tuned kubelet self-defense.** capacity−allocatable is a flat **484 MiB on all three workers regardless of total RAM** (Talos default); the only runtime guard is the kubelet default `evictionHard: memory.available<100Mi` (~100 MiB). No `systemReserved`/`kubeReserved`/`evictionHard` override existed in the running MachineConfig or `tf/` repo. *(PR #560 adds a prod-only 512 MiB `memory.available` override — defense-in-depth for the memory-pressure mode, not for the shim leak.)*
- **A graceful in-guest reboot was badly delayed but did eventually fire.** An operator `talosctl reboot` of wk-1 showed **no effect for ~15 min** — bootID unchanged, 599 shims intact, kubelet still silent at the ~8- and ~15-min marks — because the request runs through `machined`/`apid`, the very services being starved. It *did* then cycle at ~19:38 local (bootID `27403c37…`→`acf28c46…`, shims back to ~1:1, guest memory 90 %→68 %); the operator did nothing in Proxmox, so this was the delayed graceful reboot landing, **not** a hard reset. Lesson: on a guest-thrash wedge the in-guest reboot path is starved and slow — keep a host-side `qm reset` ready as the faster fallback, but it is not strictly required.
- **The IO stall was host-isolated to nuc-g2p-1 [Mimir].** Over the decline+wedge window both guests on [[nuc-g2p-1]] showed severe IO pressure — cp-1 at ~50 % `io` "full" PSI (VM-level, trustworthy), wk-1 wedged — while both guests on [[nuc-g3p-1]] (wk-3, cp-3) stayed ≤3 %. Same NAS, same workload classes; the differentiator is the host box.
- **The IO was read-dominated, and it was wk-1's — two independent instruments.** nuc-g2p-1 host diskstats: **~360–410 MiB/s reads vs ~0.4 MiB/s writes**, `Dirty`≈1–3 MB, `Writeback`≈0 [Mimir `node_disk_*` / `node_memory_Dirty|Writeback`, `instance="nuc-g2p-1"`]. Independently, the operator's **Proxmox VM chart shows wk-1 doing 350–400 MiB/s reads** in both high-pressure windows. *These are different measurements* (host aggregate from Mimir vs wk-1-specific from Proxmox); they **corroborate** — the agreement means wk-1 accounts for essentially all the host reads, leaving only a small residual for cp-1 + the alloy LXC + host OS.
- **cp-1 was not memory-pressured [Mimir].** cp-1 `MemAvailable` ~2.6 GB and `Cached` ~2.7 GB, flat all window; its own writes ~250–300 KB/s [operator, Proxmox]. A memory-comfortable VM doing negligible IO that still stalls ~50 % is a **victim of shared-disk contention**, not the source.
- **Off-transition at the reboot.** wk-1's read load and cp-1's IO stall both ended at the ~19:38 wk-1 reboot [Mimir + operator]. Removing wk-1 removed cp-1's stall — the nearest thing to a controlled test in this event.
- **Instrumentation gaps, by cause (three, not one bucket).** (a) wk-1's own node-exporter/cadvisor series are absent for the wedge window (~13:00–00:00 UTC) because its exporter was crashlooping — a *transient* gap. (b) etcd metrics are **intentionally dropped** — none reach Mimir, a revisitable *choice*, not a blind spot. (c) The host node_exporter reports the LXC cgroup, not the host (**issue #544**, open). So wk-1's anon/cache split during the event and any etcd impact went unmeasured — the first by accident, the other two by decision.

**Current theories:**

- **(G1) containerd-shim leak / runaway — leading.** Crashlooping pods cycle sandboxes every ~10 s; under a runtime that can't complete teardown, each cycle leaks a shim; 598 shims (memory + ~6,900 threads + containerd bookkeeping) starve the node until every service misses its deadlines. *For:* the measured 598:3 ratio; the kubelet log's continuous sandbox create/teardown failures; the timeout signature is node-wide, not tied to any one workload. *Unresolved — direction:* **leak→wedge** (a reaper bug lets shims pile up, which then starves the node) vs **wedge→leak** (something starves the node first, teardown starts failing, and that leaks the shims — a feedback loop). The clean 1:1 on the two identical, higher-RAM nodes argues against a simple universal version bug and leans toward wedge→leak, but a churn-*triggered* bug the bigger nodes simply haven't hit is not excluded.
- **(G1b) A specific fail-looping *workload* seeds the leak, and recurs when it fail-loops again — the middle case between "instant 598" and "one-off."** *Operator hypothesis, plausible.* Not every crash is equal: a pod that repeatedly spawns and fails to tear down cleanly leaks a shim per cycle, accumulating over hours, and will do it again whenever that workload re-enters its fail loop. Prime suspect: the **jupyterhub per-user singleuser pod** — it is new, and KubeSpawner creates/culls it on a different lifecycle (dynamic spawn on login, idle-cull) than the static workloads, i.e. exactly the create/destroy churn that leaks shims if teardown fails; its image is also the ~4 GB datascience-notebook. *For (operator testimony, strong):* the operator was spawning/killing this singleuser **on-and-off all day** trying to get it working — ~4 GB image, real RAM per spawn. That on/off pattern matches the intermittent read spikes (07:00, 08:00) and the ~13:30 sustained window; each spawn pulls/faults the big image and grows anon. The leaked shims were generic `-id <sandboxID>`, consistent with repeated short-lived sandboxes. *To close:* not yet *measured* on wk-1 (its exporter was dark), so the singleuser→reads→leak chain is operator-identified and timeline-consistent but not shown in per-pod data; the sandbox→pod mapping (next steps) would close it.
- **(G2) Cross-guest coupling through the shared host disk — now *observed*, direction corrected.** The original framing here was *host degradation → guests*; the metrics show the reverse path: **one guest's IO saturates the shared host NVMe and stalls the other guest.** wk-1's ~350–400 MiB/s reads saturated nuc-g2p-1's disk; cp-1 (memory-fine, doing ~nothing) stalled ~50 %; both cleared when wk-1 rebooted. *Support:* the 19:38 off-transition (cause removed → effect gone). *Still a theory, not fact:* "saturated → caused" is a strong inference, not a measured causal link, and the reboot changed *everything* about wk-1 at once — it isolates wk-1-as-cause but not *which* aspect (reads are the obvious one). The thermal-throttle and NAS-stall variants of the original G2 remain untested here.
- **(G3) wk-1's read load is memory-reclaim refault thrash.** *Suggested, NOT confirmed — flagged because this was earlier over-called "confirmed."* *For:* reads ≫ writes, `Dirty`≈0, and a real **kernel OOM kill** (postgres exit 137) — the OOM proves anon genuinely exhausted; with anonymous memory unevictable, file cache is the only reclaim target, so it churns (evict → refault → evict). *Against / gap:* **not one refault was measured** — no `pgmajfault`, memory-PSI, or `workingset_refault` for wk-1 (its exporter was dark). The same reads-only signature also fits a large *sequential-read* workload (dataset scan / restore / image pull), which would **not** OOM — so the OOM leans anon-thrash, but the discriminator (per-pod refault/read counters) is unrun.
- **(G4) cp-1's stall is etcd WAL-fsync contention.** *Plausible, unconfirmed.* cp-1 is a control-plane/etcd node; its ~250–300 KB/s writes fit etcd WAL, and etcd fsync is savagely latency-sensitive, which would explain ~50 % stall on tiny IO. *Against:* etcd metrics are **intentionally dropped**, so no fsync/commit-latency/leader-change data exists to confirm it (the minimal set that would is in Next steps). If real, a thrashing worker can degrade etcd on a co-located control-plane VM — a control-plane-availability risk in its own right, and an argument against co-locating a tight worker with an etcd node on one disk.

**Weakened / disproven (diagnostic wrong-turns included deliberately):**

- ~~CNI/Cilium failed to deploy.~~ Cilium had run 3+ days; it and every pod fail identically because the runtime is wedged. Victim, not cause. (This was the initial framing and it was wrong.)
- ~~The ODM postgres workload is the trigger — pin it / give it a request+limit.~~ Not pinned (default-scheduled), BestEffort `resources:{}`, OOM-killed precisely because it is the most-expendable process. Its death is expected under *any* node memory pressure and is downstream; sizing or a reservation on it would not have prevented a shim runaway. **No req/limit change is indicated** — BestEffort with host-level-only OOM is the intended posture.
- ~~The flat 484 MiB reservation should scale with node RAM.~~ Still holds: the per-node "system floor" (kubelet/containerd/cilium) is roughly *fixed* regardless of node RAM, so a flat reservation is defensible and needn't scale.
- ~~A bigger kubelet eviction buffer wouldn't help this event.~~ **Retracted — my error, twice-flipped** (helps → "won't help because `available` stays high during thrash" → helps). It doesn't stay high: the kernel OOM kill proves `available` *cratered*, so a fatter, earlier-tripping buffer (100 Mi → e.g. 512 Mi–1 Gi, PR #560) would have evicted a BestEffort pod **gracefully before the kernel OOM and before cache starved to the thrash point.** Caveat: the buffer only averts the thrash if its value exceeds the node's genuine non-anon working set, which we haven't measured — so 512 MiB is a starting point, not a derived number. It targets the anon-exhaustion/OOM mode, **not** the shim leak (which no buffer stops).
- ~~g3p-2 is the largest node / ~10 GB sits idle on it that prod is starved of.~~ Withdrawn: there are two node sizes and g3p-2 is one of *two* 15.37 GB nodes; its Proxmox host "used" figure may be largely reclaimable cache, so the idle-headroom claim rested on an uninterpreted number.
- ~~The failure is dirty-writeback / wired-page accumulation~~ (the write-behind mode: dirty pages can't be dropped until written back, so under slow/uncontrolled writeback they wire RAM until a write-mostly job dies). **Not this event:** `Dirty`≈1–3 MB, `Writeback`≈0 across cp-1/wk-2/wk-3 through the window [Mimir]. A real and *distinct* mode — opposite fingerprint (writes + climbing dirty, hits write-mostly jobs like mimir) — separately watch-listed, but disproven here.

**Next steps (diagnostic / observation):**

- [ ] **(On recurrence, before any reset)** `talos_processes` on the wedged node; count `containerd-shim` vs `pause`. This is the discriminator pod-level monitoring cannot see. Also pull the kubelet log for sandbox create/teardown failures.
- [ ] **(Identifies the seed — tests G1b)** Map the leaked shims to their pods before the reset wipes the evidence: the leaked shim args carry `-id <sandboxID>`; resolve those via `crictl ps -a` / the containerd `k8s.io` namespace to see whether they cluster to one workload lineage (jupyterhub singleuser?) or are spread across the crashloopers. Most-valuable evidence, lost on reset.
- [ ] **(After wk-1 is reset)** Watch wk-1's `containerd-shim` count over time, and **correlate any climb with pod-churn events** — especially KubeSpawner singleuser spawn/cull on jupyterhub. Settles at ~1:1 → one-off runaway (G1). Climbs with a specific workload's cycling → G1b (fix that workload / its teardown). Climbs with no workload churn → a real reaper bug in containerd 2.2.3 / Talos 1.13.0 to reproduce and file upstream.
- [ ] **(Recovery procedure)** A guest-thrash wedge does **not** clear via `talosctl reboot` (starved API path); use a host-side `qm reset` / Proxmox reset. Capture `talos_processes` first (above).
- [x] **(Tested G2 — partial)** Pulled nuc-g2p-1 host diskstats + cp-1 PSI/memory once Mimir returned: read-saturated disk, cp-1 stalled-but-memory-fine, g3p-1 clean (see Confirmed / G2). Host **coretemp not yet checked** → the thermal-throttle variant is still untested.
- [ ] **(Distinguishes G3 from a sequential-read job)** On recurrence capture wk-1 `node_vmstat_pgmajfault` / `node_pressure_memory_*` / per-pod `container_memory_working_set_bytes` + read bytes: high major-fault/refault → refault thrash; one pod's large sequential reads → workload, not thrash.
- [ ] **(Host-memory gap — issue #544, open)** Plumb host `/proc/meminfo` into the *existing* alloy-LXC node_exporter (point `--path.procfs` at the host bind-mount instead of the lxcfs-faked `/proc`). No new instrumenter.
- [ ] **(Tests G4 — only if the detection is wanted)** etcd metrics are intentionally dropped. Minimal set to confirm/deny fsync-contention: `etcd_disk_wal_fsync_duration_seconds` + `etcd_disk_backend_commit_duration_seconds` (2 histograms) and `etcd_server_leader_changes_seen_total` + `etcd_server_has_leader` (2 low-card series), ×3 CP nodes ≈ **~100 series**. Why: a disk-contention event that pushes fsync past the election timeout takes the API down and nothing else measures it. A *detector*, not a fix — skip if the contention is solved at the source.
- [ ] **(Trigger — operator-identified)** The jupyterhub singleuser pod (huge ~4 GB image, real RAM, spawned on-and-off all day) is the near-certain grower; timeline matches. Confirm on recurrence via per-pod working-set/read bytes. The durable fix is that workload's *maturity over time* (a realistic request once its steady-state is known) — not a lever available on command, and not worth a synthetic 4 h job to force.
- [ ] **(Tune, don't guess)** #560's 512 MiB eviction buffer is a *starting point*, not a derived value; the right number depends on the per-node system+working-set footprint from the above.
- [ ] **(Standing instrumentation)** Track `containerd-shim` process count per node as a cheap metric — a shim leak is invisible to pod/deployment dashboards.
- [ ] **(Watch)** wk-2 is the busiest small worker and flapped NotReady the same day; most likely next occurrence.

**Notes on method (what worked, what I got wrong):**

- The decisive step was reading **in-guest process state** (`talos_processes`), not reasoning from resource dashboards. The 598-shim count is a direct measurement; the entire earlier "workload-footprint / memory-reservation" line of argument missed it and pointed at the wrong cause.
- **Comparing all three identical workers** was again the key discriminator — the same move that killed the shared-NAS theory in the g3p-2 event. Identical software, only wk-1 leaking → not a universal bug.
- **Watch measurement level and interpretation** (this doc's standing lesson, earned again). Proxmox host "used" may include reclaimable cache; summed per-process RSS double-counts shared pages (the 598 shims summed to 7.7 GiB inside a 3.8 GiB VM — physically impossible, so the *sum* is meaningless and only the *count* is signal). Several early conclusions were anchored to numbers whose meaning had not been pinned; those are the withdrawn items above. No observations were retracted; several theories were killed — the intended shape.
- **"Confirmed" is a load-bearing word, and I misused it.** I called the IO-coupling / refault-thrash story "confirmed" when only the *observations* (read rates, cp-1 stall, off-transition) were confirmed and the *mechanism* (refault thrash, saturated→caused) was theory. Corrected in place: observations carry sources; mechanisms sit in G2–G4 with their unrun discriminators. The scaffold exists to catch exactly this promotion-of-a-detail, and it worked *because the operator pushed back* — not on its own.
- **Provenance discipline.** The ~360–410 MiB/s is host-aggregate from Mimir; the 350–400 MiB/s is wk-1-specific from Proxmox — I initially blurred them into one "wk-1" number. They corroborate *because* they are independent instruments, which is only a virtue if kept labelled.
- **Twice-flipped on the eviction buffer** (helps → won't help → helps). The resolution came from taking the kernel OOM kill seriously as evidence that `available` had cratered. When a claim keeps flipping, hunt for the observation that discriminates instead of re-arguing the mechanism.
- **A near-miss the metrics can't see (yet):** if G4 holds, the read thrash was one kubelet-eviction-tunable away from stalling etcd on a co-located control-plane node — a control-plane event masquerading as "a worker fell over." Under-instrumentation (no etcd metrics, no host memory) is why that stays a *maybe*.

---

### Other possibly-related incidents

**Confirmed:**

- **Guest-level within-VM runaway on [[tiles-wk-1]] (2026-07-03)** — catalogued above under *Within-VM runaway (guest-level wedge)*. A different layer from the g3p-2 host wedge, but it shares the progressive-decline signature and is the first candidate for host↔guest coupling (G2).

**To gather:**

- [ ] **(Observation)** Inventory the "few related maybe problems" already observed (operator). For each: date/time, host, symptom (hard wedge vs slow vs reboot), and whether it recovered on its own or needed a power-cycle. Then check each against Mimir (scrape `up` per host, iowait, temps) to see if they share nuc-g3p-2's signature (progressive scrape-timeout decline; host-level iowait rise; no thermal throttle) or look different.
- [ ] **(Analysis)** Once ≥2 events exist: is the failing host always g3p-2 (→ hardware/host-local or its single-node-whole-cluster role), or spread across hosts (→ a general Talos/Proxmox/workload pattern)?

---

## Notes on method

- The single most useful discriminator here was **comparing all four hosts** on the same metric and window: it cleanly killed the NAS theory (shared cause → shared symptom; it wasn't shared).
- Watch the **measurement level** of every metric. Half of the memory analysis was accidentally measuring a 512 MB LXC, not the 15 GB host, and briefly led to the opposite conclusion. Confirm what each exporter actually sees before trusting a number (see caveat above).
- No confirmed root cause yet. The metrics performed the *elimination* (not NAS, not thermal, isolated to g3p-2) but do not contain the verdict; the host kernel journal is the missing evidence.
