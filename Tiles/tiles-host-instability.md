# Tiles host instability

*Tracks resource-starvation lock-ups on the Tiles cluster — Proxmox **hosts** wedging (2026-06-29) and, since, **guests** (VMs) wedging or stalling. Following the [[experiments-house-model|house-experiments]] style: **events logged in one place**, then **theories-about-causes** with evidence for/against, then disproven ideas and diagnostic next steps. A topic closes when confirmed findings fully explain the behaviour.*

Related: [[Tiles (proxmox)]], [[nuc-g3p-2]], [[nuc-g2p-1]], [[nuc-g2p-2]], [[alloy]], [[mimir]], [[loki]], [[guiding-principles]].

**Driving question:** is this *one* failure mode — a resource-squeezed box → memory/cache pressure → I/O stall → wedge — manifesting at whichever layer is tightest (the host on the single-box test cluster; the guest on the small prod VMs)? Or separate problems? Current lean: **one mechanism, several manifestations** (Theories T-B/T-C), not confirmed.

---

## Hardware / baseline facts

- **Two node sizes.** **g2p** (nuc-g2p-1, nuc-g2p-2): ~11.43 GB usable. **g3p** (nuc-g3p-1, nuc-g3p-2): [[GMKtec Nucbox G3 Plus N150 16GB]], 15.37 GB usable, N150 4-core, 512 GB NVMe. Plus metal: **lancer** (128 GB, ~61.5 GiB allocatable, joined 2026-07-04 ~20:10 UTC) and acebase.
- **Which VMs sit where (and share one NVMe).** nuc-g2p-1 = wk-1 (4 GB) + cp-1 (5 GB); nuc-g2p-2 = wk-2 (5.86 GB) + cp-2 (2.93 GB); nuc-g3p-1 = wk-3 (9.77 GB) + cp-3 (2.93 GB). Each prod g2/g3 box hosts **one worker + one control-plane (etcd) VM on a single disk.** [[nuc-g3p-2]] instead carries the **entire test cluster** ([[tiles-test-cp]] 5 GB + [[tiles-test-wk]] 8 GB = 13 / 15.37 GB) — the most-squeezed box in the fleet.
- **Host memory runs ~89 % steady** on the busy boxes (VM RAM preallocated; long-standing, recorded back in Feb 2026 — not a climbing value on its own).
- **The roomier worker (wk-3, 9.77 GB, on nuc-g3p-1) and its host have never appeared in an event.**

## ⚠️ Measurement-level caveat & monitoring gaps (important)

> **UPDATE 2026-08 — gap (a) is RESOLVED (#544, tiles PR #706).** The alloy LXC now bind-mounts the host's real `/proc`+`/sys` at `/host/proc`+`/host/sys` and points node_exporter there (`procfs_path=/host/proc`), so **host** `node_memory_*`/`Swap*` are now in Mimir (verified ~12/16 GB per node, not 0.537 GB). The memory blind-spot below is historical — for events after 2026-08 you *can* assess host memory from Mimir. (Host logs also now reach Loki via `{job="proxmox-journal"}` — #686.) The rest of this section is the state as investigated in 2026-06/07.

The `node_exporter` for each `nuc-*` **host** runs inside that host's **alloy LXC**, not on the host. `lxcfs` virtualises `/proc/meminfo` to the container cgroup, so:
- **LXC-level (not host):** all `node_memory_*` (MemTotal reads **0.537 GB** = the LXC cgroup), `Swap*`, network counters, likely vmstat OOM/fault counters.
- **Host-level (genuine):** `node_cpu_*` incl. **iowait** (`/proc/stat` not namespaced), **disk** stats (`/proc/diskstats`), **hwmon temps** (sysfs).

Consequence: any host memory/swap conclusion from these metrics is about the ~512 MB LXC, not the host — this invalidated an early wrong-level "memory is fine" reading. Other **monitoring gaps** — reachable on demand (`talosctl`, `pvesh`) but **not in Mimir**, so you can't alert / graph / historically correlate on them (*not* "can't see them"):
- **(a)** host node_exporter = LXC cgroup, not host memory — **issue #544 (RESOLVED 2026-08, tiles PR #706)**; host memory/swap now in Mimir.
- **(b)** etcd metrics **intentionally dropped** — none reach Mimir (revisitable choice, not an accident; minimal re-add set filed as **#568**).
- **(c)** a wedged/crashlooping guest goes **dark in Mimir during its own event** (its exporter stops), so the worst window is the least-observed.
- **(d)** **Grafana runs on wk-2**, so when a g2 box is stressed the dashboards 503 — observability degrades exactly under the stress it monitors.

---

## Events

*One row per incident; neutral observations (fidelity tier) below. Data source for B/C: Mimir via `mimir-gateway`, tenant `tiles`, plus operator Proxmox charts; A: Mimir, since Grafana was unavailable.*

| # | Date (UTC) | Where | Layer | Symptom | Severity | Recovery |
|---|---|---|---|---|---|---|
| **A** | 2026-06-29 | nuc-g3p-2 (host) | host | progressive scrape-timeout decline → full wedge (no SSH/API/metrics) | hard wedge | manual power-cycle next morning |
| **B** | 2026-07-03 | tiles-wk-1 (guest / nuc-g2p-1) | guest | every node-local service flapping → NotReady; **598-shim leak**; host & sibling VM fine | hard guest wedge | delayed `talosctl reboot`, cycled ~19:38 |
| **C** | 2026-07-04 | tiles-wk-2 + cp-2 (nuc-g2p-2) | guest | **mild** coupled I/O stall; Grafana restart-loop; no wedge | mild, ongoing | reboot requested (watching) |

### A — nuc-g3p-2 host hard wedge (2026-06-29)

- **Dropout ~14:20 UTC.** Last metrics ~14:20; unreachable thereafter. CI corroborates (plan-apply 12:24 succeeded, 14:54 failed). Recovered only after manual power-cycle ~Jun-30 morning; VMs auto-started (`on_boot`).
- **Progressive decline preceded it.** Scrape success (10 s timeout): 100 % → wobble late Jun-28 23:30–Jun-29 05:00 (dipped 60–87 %, recovered) → 100 % → **terminal decline from ~12:00** (83→60→57→50 %) → dead 14:20. Failing scrapes pegged at the 10 s timeout; good scrapes 0.04 s.
- **Isolated to g3p-2.** The other three hosts held 100 % scrape success over the same window — same NAS, same workload classes.
- **Host-level signals during the decline:** iowait ~3–8 % → **27–36 %**; disk op-latency → **~50 ms** (abnormal for NVMe); `nvme0n1` busy ~69 % (not pinned); context switches **fell** 20 k → 11 k/s (D-state blocking).
- **Not thermal:** coretemp 71–81 °C (this box runs hottest), **zero** throttle events; **NVMe temp flat ~45 °C**.
- Physical: warm, network-LED flicker (*non-diagnostic — normal traffic indicator*).

### B — tiles-wk-1 guest wedge (2026-07-03)

- **NotReady/unreachable ~22:15 UTC.** Kubelet stopped posting → `unreachable` taints. Progressive decline first: an `apid` blip ~3.7 h prior, then sustained flapping from ~2 h before — the **same *shape* as A, one layer down.**
- **VM alive, host healthy.** Talos `apid`/`machined` answered intermittently; [[nuc-g2p-1]] online (27 d uptime), API-responsive, sibling **cp-1 unaffected at the k8s layer**. Contained inside one guest — inverse topology of A.
- **Every node-local service flapping** `DeadlineExceeded`/`i/o timeout` on its *own* health check: `containerd`, `cri`, `kubelet:10248`, `apid:50000`, `machined.sock`, `registryd:3172`. Whole-guest starvation, not one failed service.
- **598 `containerd-shim` vs 3 live `pause` sandboxes, ~6,900 shim threads** (talos_processes — the decisive measurement). Kubelet log full of `CreatePodSandbox`/`StopPodSandbox` failing `cannot start a stopped process`. Normal is ~1:1 (confirmed on wk-2/wk-3, same Talos 1.13.0 / containerd 2.2.3).
- **odm/postgres OOM-killed (exit 137) ×4** at 08:54/09:34, BestEffort `resources:{}`, then stuck `Terminating` ~7 h; other pods `CrashLoopBackOff` with identical sandbox errors — downstream victims.
- **I/O stall host-isolated to nuc-g2p-1.** cp-1 hit **~50 % `io` "full" PSI** (VM-level, trustworthy) while wk-1 wedged; nuc-g3p-1's guests (wk-3, cp-3) stayed ≤3 %.
- **The I/O was read-dominated, and it was wk-1's — two independent instruments.** g2p-1 host diskstats **~360–410 MiB/s reads vs ~0.4 MiB/s writes**, `Dirty`≈1–3 MB, `Writeback`≈0 [Mimir]; independently, operator's Proxmox chart shows **wk-1 at 350–400 MiB/s reads** in both high-pressure windows. Different measurements (host aggregate vs wk-1-specific) that **corroborate** → wk-1 is essentially all the host reads.
- **cp-1 was not memory-pressured** [Mimir]: `MemAvailable` ~2.6 GB, `Cached` ~2.7 GB, flat; own writes ~250–300 KB/s. A memory-fine VM doing negligible I/O that still stalls ~50 % is a **victim of shared-disk contention.**
- **Off-transition:** wk-1's reads *and* cp-1's stall both ended at the ~19:38 reboot — removing wk-1 removed cp-1's stall.
- **Recovery quirk:** the operator `talosctl reboot` showed **no effect for ~15 min** (bootID unchanged, 599 shims — the reboot path runs through the starved `machined`/`apid`), then cycled ~19:38 (bootID `27403c37…`→`acf28c46…`, shims→~1:1, guest mem 90 %→68 %). No Proxmox action — the delayed graceful reboot landed. (Keep a host-side `qm reset` as the faster fallback.)
- **Defense-in-depth absent:** capacity−allocatable is a flat **484 MiB on all workers** (Talos default); only runtime guard is default `evictionHard: memory.available<100Mi`; no tuned override existed (**PR #560** adds a prod-only 512 MiB — see T-B).

### C — tiles-wk-2 + cp-2 / nuc-g2p-2 mild coupling (2026-07-04)

- **Same coupling signature, milder, on the *other* g2 box.** `io` "full" PSI: wk-2 and cp-2 elevated *together* (current ~0.12, 12 h-peak ~0.21–0.26) while recovered g2p-1 and g3p-1 stayed ≤0.02–0.04. cp-2 is the co-located etcd node. Onset ~2026-07-03 22:00 UTC, persisting. **~half the intensity that wedged wk-1** (~0.5+).
- **Warming, not wedging.** All 7 nodes Ready; **no shim leak** on any worker (talos_processes ~1:1).
- **Grafana (on wk-2) in a restart loop — it's being OOM-killed** [kubectl + wk-2 dmesg]. Grafana reached **58 restarts**; the wk-2 kernel log shows **Talos's node OOM manager repeatedly SIGKILLing its cgroup** (pod `a872ee9f`) 20:40→21:10 UTC. *(Correction: I earlier called this "a kubelet kill on failed health-check, not an OOM" — wrong. The readiness-probe `context deadline exceeded` timeouts are a *symptom* of the same memory pressure; the kills are OOM.)* So the Mimir/Grafana 503s throughout this investigation are a symptom of wk-2 **memory** pressure (blind spot (d)).
- **Direct memory-pressure evidence [wk-2 dmesg].** Talos's node OOM manager (PSI-based) fired **repeatedly 2026-07-04 20:40→21:10 UTC**, culling whichever cgroup thrashed worst — a rotating kill across the *scheduled workload*: grafana (58 restarts), alloy-metrics-0 (49), mimir-ingester-1 (40), argocd-repo (32), mimir-kafka-0 (30), cilium-operator (25). *(These aren't a hand-placed "baseline" — they're mobile workload the scheduler happened to put here; the only true per-node baseline is the DaemonSets, alloy/cilium/nfs. The OOM manager just kills whoever's worst, so **victim identity ≠ culprit**.)* Separately, a *kernel* per-cgroup-**limit** OOM killed `alloy` at 2026-07-03 06:37 (anon-rss 252 MB, via a page-fault charge). No firings since 21:10 (settled; IO stall ~0.008 by 21:18). So wk-2's stress is **confirmed node memory pressure**; the victims are whatever workload was resident, not the (already-killed, BestEffort ~200 MB) jupyter singleuser.
- **Where the unpack memory lands — containerd, unkillable [talosctl cgroups, wk-2].** The `podruntime/runtime` cgroup (the CRI containerd) shows **current 519 MiB but a peak of 3.6 GiB** — **no limit** (`MemMax: max`), memory-*protected* (`MemLow` 392 MiB / `MemMin` 196 MiB), and a critical process the OOM killer won't pick. Steady-state `kubepods` sits at 4.2 / 5.3 GiB max with pods **within their requests** (grafana 685/req 768, mimir-ingester 244/req 300, kafka 238/req 256 MiB). So the node tips on a **transient in containerd** (an image unpack) — unattributed to any pod, unkillable — not on chronic pod over-commit. (Couldn't pull the read/write split — Grafana/Mimir 503'd — but the cgroup route gives the mechanism anyway.)
- **wk-2 tenancy:** mimir-ingester (writes) + mimir-kafka + grafana + argocd-application-controller + alloy-metrics on a tight 5.86 GB (94 %) box, plus the intermittently-spawned jupyterhub singleuser. cp-2 is 2.93 GB (95 %).
- **No traveling culprit from B.** Only per-node DaemonSets overlap between wk-2-now and wk-1-during-B (on every node — not meaningful). The one schedulable workload on wk-1 during B (odm postgres) is back on wk-1. **The jupyter singleuser is a wk-2 tenant and was never on wk-1.**
- **Recovery was *not* prompt after the notebook kill, and the OOM victims were the baseline stack.** Per the wk-2 dmesg, Talos OOM kills ran until **21:10 UTC — ~1 h+ *after* the singleuser was killed (~20:00)** — then stopped; IO "full" PSI ~0.008 by 21:18, Grafana held Ready from 21:11, bootID unchanged (no reboot). So the earlier "killing the notebook calmed it → support for T-B1" read is **withdrawn**: the pressure persisted well past the kill and fell on mimir/kafka/grafana/alloy, not jupyter. It muddies T-B1-vs-baseline rather than resolving it (see Theories).

---

## Conclusions (cross-cutting, load-bearing)

1. **Only the resource-squeezed boxes fail** — g3p-2 (whole test cluster) and the g2 boxes (worker + CP VM on one disk). The roomier nuc-g3p-1 and its guests have never appeared. [A, B, C]
2. **The signal is I/O stall — read-dominated, with D-state / iowait** — not thermal, not NAS, not drive overheating (all disproven). [A, B]
3. **On the shared-NVMe g2 boxes, one guest's I/O stalls the co-tenant** even when the co-tenant is memory-fine. [B, C]
4. **Observability degrades under the stress it monitors** — Grafana lives on wk-2 and flaps; Mimir/Grafana were unavailable during *both* B and C. Don't co-locate the monitor with the monitored. [B, C]
5. **No single root cause is confirmed.** The metrics did the *elimination*; the mechanism is still theory.

---

## Theories (causes) — evidence for / against, across events

**Framing — one mode or several?** *Leaning one.* A, B, C are all on the squeezed boxes, all show read-I/O / iowait / D-state stall with a progressive-decline shape, all isolated to the tight node. They differ in *layer* (A killed the whole host; B/C are guest-level with the host fine) and *coupling direction* (A = one box dies; B/C = one guest stalls its co-tenant). The parsimonious read: **the same memory/cache-pressure → read-thrash mechanism, surfacing at whichever layer is tightest.** *Against:* A has no in-guest/k8s data (host wedge), so the shim-leak escalation (T-D) is unobserved there; it could be a distinct host-only path. Not settled.

- **T-A — Tightness is the predisposition (framing, not a trigger).** The boxes that fail are the squeezed ones; it explains *which* nodes, not *what fires*. Strongly supported (Conclusion 1); by itself names no mechanism.

- **T-B — Memory/cache pressure → reclaim/refault → read-I/O thrash (the core mechanism). *Leading, not confirmed.*** With anonymous memory unevictable (no swap), the kernel reclaims clean file cache (binaries, layers) and immediately re-faults it → sustained reads. *For:* wk-1's ~400 MiB/s reads / ~0 writes / `Dirty`≈0 is the textbook clean-page evict+refault fingerprint [B]; the kernel OOM of postgres (exit 137) proves anon genuinely exhausted [B]; A's host-level iowait rise + ~50 ms op-latency + D-state fit the same at the host layer. *Against / gaps:* **not one refault counter was measured** — wk-1's exporter was dark (blind spot (c)); the reads-only shape also fits a large *sequential-read* workload (which wouldn't OOM); A's host memory was never measured (blind spot (a)). *Discriminator (unrun):* per-node `pgmajfault` / memory-PSI / `workingset_refault` during an event.
  - **T-B1 — the spike source: the jupyter big-image unpack, charged to containerd. *Leading; mechanism evidenced.*** The jupyterhub singleuser's **~4.1 GiB** (compressed/stored) image is unpacked by the **CRI containerd** (`podruntime/runtime`), whose cgroup **peaked at a measured 3.6 GiB** [C, talosctl `memory.peak`] — decompression buffers + page cache for the written layers, charged to *containerd, not the pod*, in an **unattributed, reclaim-protected (`memory.low` 392 MiB / `memory.min` 196 MiB), unkillable** cgroup with **no limit**. *(3.6 GiB is a working-set high-water, mostly **reclaimable** page cache — not a hard requirement; the elastic cache grew because RAM was free and the cgroup is protected from reclaim. On a tight node that displaces the pods' working sets instead of being given back → OOMs. The unmeasured hard demand is the anon decompression buffers; get it from `memory.stat` anon-vs-file during a spawn.)* On a tight node that multi-GB transient is node pressure the OOM manager can only relieve by killing *innocent* kubepods pods (grafana/mimir…). *For:* the 3.6 GiB containerd peak; the datascience image is by far the largest unpack on the node; **mimir-ingester & kafka are flat ~200–350 MiB over 7 days** [Mimir] and steady-state pods are *within* requests, so the scheduled workload did **not** creep into the cliff — it's a spike; operator spawned it on-and-off all day. *Two earlier "against" points — both retracted:* (1) "the OOM victims were the [mislabelled "baseline"] stack, not jupyter" — victim identity is meaningless when the culprit sits in unkillable containerd, so the killer takes whatever kubepods pods are worst; (2) "pressure persisted ~1 h past the kill" — over-allocation aftermath (page-cache re-warm) persists (cf. bare-metal SSH-lockouts for hours), not counter-evidence. *Corollary:* **no per-pod request/limit catches this** — the memory is in containerd, not a pod; the fix is *placement* (lancer) or pre-pull, **not** pod tuning. *Not in Mimir (but visible on demand):* cadvisor doesn't scrape the containerd cgroup (empty in Mimir), so this transient isn't alertable/graphable — but `talosctl cgroups` shows it directly (that's how the 3.6 GiB was found). See **#576**. *On B:* wk-1 was rebooted *while still hung*, so the datascience image *not* being cached there is consistent with an **interrupted** unpack (caused the wedge, then wiped before it finished/cached) — B may be the *same* mechanism, not a separate mystery. B's exporter was dark (under-instrumented); with two events (B, C) it's not worth reconstructing. *Still open:* timestamp the peak to a spawn (watch `podruntime/runtime` live).

- **T-C — Cross-guest coupling through the shared host NVMe. *Observed; mechanism-of-which-aspect unconfirmed.*** One guest's read thrash saturates the box's single disk → the co-tenant stalls though memory-fine. *For:* cp-1 ~50 % stall while memory-comfortable and doing ~no I/O [B]; the **19:38 off-transition** (remove wk-1 → cp-1 recovers) is the nearest thing to a controlled test; a **second independent instance** on the other g2 box (wk-2/cp-2) [C]. *Against:* "saturated → caused" is a strong inference, not a measured link, and the reboot changed everything about wk-1 at once (isolates wk-1-as-cause, not *which* aspect — reads are the obvious one). The thermal-throttle / NAS-stall variants of the original coupling idea are untested/killed.

- **T-D — containerd-shim leak → full wedge (the escalation from "slow" to "dead"). *Observed at B only.*** Under a runtime that can't complete teardown, churning pods leak a shim per cycle → 598 shims (memory + ~6,900 threads + containerd bookkeeping) starve everything. *Direction unresolved:* **leak→wedge** (a reaper bug) vs **wedge→leak** (I/O stall stops teardowns, which leak the shims — a feedback loop). The clean 1:1 on the two identical, healthier nodes argues against a universal version bug and **leans wedge→leak**, but a churn-*triggered* containerd 2.2.3 / Talos 1.13.0 bug the roomier nodes haven't hit is not excluded. C stayed below this; A has no k8s data.

- **T-E — the co-tenant victim is a control-plane/etcd node (raises the stakes). *Plausible, unconfirmed.*** On both g2 boxes the co-stalled guest is a CP/etcd node (cp-1, cp-2); etcd WAL fsync is savagely latency-sensitive (its ~250–300 KB/s writes fit WAL), so the coupling could push etcd past its election timeout → API unavailability — a control-plane event masquerading as "a worker fell over." *Against:* etcd is unmonitored (blind spot (b)); no fsync/leader data exists. Argues against co-locating a tight worker with an etcd VM on one disk.

---

## Disproven / weakened (one place)

- ~~Shared NAS / NFS bottleneck.~~ [A] The other three hosts mount the same NAS and stayed 100 %. Shared cause → shared symptom; it wasn't shared.
- ~~CPU thermal throttle / NVMe overheating.~~ [A] Zero throttle events; drive temp flat ~45 °C.
- ~~Alloy LXC ran out of RAM / "host memory is fine."~~ [A] Both were LXC-level (wrong instrument); host memory was never measured (blind spot (a)).
- ~~CNI/Cilium failed to deploy.~~ [B] Cilium ran 3+ days; it and every pod fail identically because the runtime is wedged — victim, not cause.
- ~~The odm postgres is the trigger (pin it / give it requests).~~ [B] Default-scheduled, BestEffort, OOM-killed *because* it's the most-expendable process — its death is downstream of node pressure. Host-level-only OOM is the intended posture for it.
- ~~The jupyter singleuser caused wk-1's episode — *"disproven" because its image wasn't cached on wk-1.*~~ **Reopened, and the exclusion retracted:** wk-1 was rebooted *mid-hang*, so an **interrupted** unpack leaves no cache yet could still be the culprit — so B can't be excluded as the same jupyter/containerd mechanism as C. (It also can't be confirmed — B's exporter was dark. Not worth chasing; C carries the case.)
- ~~The `flight-analysis` Job is a heavy ODM-class trigger.~~ [C] It's a **~1 GB, resourced, headless notebook-eval cron that ran twice** — benign (agent's over-read of the name).
- ~~The failure is dirty-writeback / wired-page accumulation~~ (the write-behind mode). [B] `Dirty`≈1–3 MB, `Writeback`≈0 across cp-1/wk-2/wk-3 — a real and *distinct* mode (opposite fingerprint: writes + climbing dirty, hits write-mostly jobs like mimir), watch-listed but disproven here.
- ~~g3p-2 is the largest node with ~10 GB idle prod is starved of.~~ Withdrawn: two node sizes; g3p-2 is one of *two* 15.37 GB nodes; its Proxmox "used" figure may be largely reclaimable cache.

---

## Open questions & next steps

**Durable fixes (point the same way):**
- [ ] **Get heavy / big-image workloads off the tight VMs → lancer (128 GB).** Pin the jupyterhub singleuser (KubeSpawner `singleuser` nodeSelector/affinity) and any real ODM run to lancer, so a 12 GB unpack doesn't blow a 4–6 GB node's cache. (Tests + fixes T-B1.)
- [ ] **Move Grafana (and consider a mimir component) off wk-2** so monitoring survives when a g2 box is stressed (blind spot (d)).
- [ ] **Decide swap/OOM policy deliberately** — modest swap/zram and/or `earlyoom`/tuned `evictionHard` so pressure degrades gracefully. **PR #560** raises `evictionHard: memory.available` 100 Mi→512 Mi (prod); a *starting point*, not derived — the right value must exceed the node's real non-anon working set (unmeasured).
- [ ] **Don't co-locate a tight worker with an etcd/CP VM on one disk** if T-E holds (revisit VM placement on the g2 boxes).

**Instrumentation (close the blind spots):**
- [ ] **Host memory into the existing LXC node_exporter** — point `--path.procfs` at the host bind-mount, not the lxcfs `/proc`. **Issue #544 (open).** No new instrumenter.
- [ ] **Re-add the minimal etcd set** (`etcd_disk_wal_fsync_duration_seconds`, `_backend_commit_`, `server_leader_changes_seen_total`, `server_has_leader`; ~100 series). **Issue #568.** Detector for T-E, not a fix.
- [ ] **Standing metric: `containerd-shim` count per node** — a shim leak (T-D) is invisible to pod/deployment dashboards.

**Diagnostics on recurrence (discriminate the theories):**
- [ ] **Before any reset:** `talos_processes` (shim vs pause count, T-D) and map leaked shims' `-id <sandboxID>` → pod via `crictl ps -a` before the reset wipes it.
- [ ] **Catch a spawn live** (T-B1): write spike + IO stall at the KubeSpawner create timestamp, then the read/refault tail.
- [ ] **Pull `pgmajfault` / memory-PSI / per-pod read bytes** during an event (T-B): high refault → thrash; one pod's sequential reads → workload.
- [ ] **Get the g2p-2 read/write split** *before* Grafana falls over (or via a Mimir path not fronted by the stressed Grafana): reads → refault (as B); writes → the write-behind mode.
- [x] **C did *not* need a reboot** — it self-recovered after the singleuser was killed / spawns stopped (Event C), stress fading to baseline over ~1 h with bootID unchanged. A point for the unpack-spike reading. Still watch whether stress returns on the next spawn.
- [ ] **On a host wedge (A-type):** console (not SSH) before power-cycle — `dmesg` / `echo m > /proc/sysrq-trigger`; and `journalctl -k` for OOM-killer / `nvme I/O timeout` / hung-task traces (persistent journald survives the reboot).
- [ ] **Retroactive:** look for a big-image pull on wk-1 ~2026-07-03 13:30 (a *different* image than datascience) — tests T-B1 for B.

**To gather:**
- [ ] Inventory the operator's "few related maybe problems": date, host, symptom (wedge vs slow vs reboot), self-recovered vs power-cycled — then check each against Mimir for this signature (progressive scrape-timeout, iowait/read rise, no thermal throttle).

---

## Notes on method (what worked, what I got wrong)

- **Compare all peers on the same metric+window.** The single best discriminator throughout: it killed the NAS theory in A (shared cause → shared symptom; it wasn't), and localised B/C to one box (identical software, only one node sick → not a universal bug).
- **Read in-guest state, not just dashboards.** The 598-shim count (talos_processes) was the decisive B measurement; the earlier "workload-footprint / reservation" line missed it entirely.
- **Watch the measurement level.** Half of A's memory analysis accidentally measured a 512 MB LXC not the 15 GB host; summed per-process RSS double-counts shared pages (the 598 shims summed to 7.7 GiB inside a 3.8 GiB VM — physically impossible, so only the *count* is signal, not the sum).
- **"Confirmed" is a load-bearing word; keep observations and theories apart.** I over-called the IO-coupling / refault story "confirmed" when only the *observations* were — corrected: observations sit in Events with sources; mechanisms sit in Theories with unrun discriminators. None of T-A…T-E is in a confirmed state. The scaffold caught this *because the operator pushed back*.
- **Provenance discipline.** The ~360–410 MiB/s is host-aggregate (Mimir); the 350–400 MiB/s is wk-1-specific (Proxmox) — corroborating *because* independent, which is only a virtue kept labelled.
- **When a claim keeps flipping, find the discriminating observation.** I flip-flopped twice on whether a bigger eviction buffer helps; the kernel OOM (proving `available` cratered) settled it. Re-arguing the mechanism didn't.
- **The proxy fails exactly when you need it (P5).** Grafana on the stressed node means the dashboards die during the incident — the same reason Mimir/Grafana were down in both A and B. Under-instrumentation (no etcd, no host memory) is why T-E stays a *maybe*.
