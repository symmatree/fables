[Intel 12th Twin Lake N150--NucBox G3 Plus Mini PC](https://www.gmktec.com/products/nucbox-g3-plus-enhanced-performance-mini-pc-with-intel-n150-processor)

Wifi 6
BT 5.2
2500 Mbps LAN ?
Dual 4k output
Intel i226V LAN 2.5G

Bought 2x 16 GB RAM / 512 GB SSD 2025-09-07 ($170 apiece)

BIOS Setup
* Set power to High Performance
* Set date
* Change Wake On Power to S0 State (auto-power-on after outage)
* Under CPU Power Management, enable EC Turbo Control Mode
* Showing 48C with 2100 RPM fan
* Fan in Automatic Mode
* Disabled SATA controller (since nothing attached)
* Leaving Network PXE Boot disabled for now
* NVMe shows 512GB , TWSC something
* Attempt Secure Boot is disabled
* Quiet Boot disabled
* Setup Prompt Timeout to 10s

## Storage: the drives fall off a cliff under sustained write (hypothesis)

These shipped with cheap OEM 512 GB NVMe -- storage and memory are where GMKtec
makes its margin at this price. **Working hypothesis, not confirmed:** the drive
has a pseudo-SLC write cache, and once sustained write volume exceeds what it can
fold down into TLC/QLC during idle time, write latency collapses by two to three
orders of magnitude and stays there while the load continues. Recovery needs a
quiet period, not a reboot.

**The practical rule this gives you: judge write load by cumulative volume per
day, not by instantaneous MiB/s.** 0.5 MiB/s reads as nothing on a dashboard and
is 43 GiB/day sustained. That is the mistake to avoid when deciding whether a
workload is "light" for one of these boxes.

### What was observed on [[nuc-g3p-2]]

Daily writes to `nvme0n1`, from Mimir (`increase(node_disk_written_bytes_total[1d])`):

| period | nuc-g3p-2 | nuc-g3p-1 |
|---|---|---|
| to 2026-09-15 | 6.6 - 13.3 GiB/day | 40 - 46 GiB/day |
| from 2026-09-16 | 49 - 100 GiB/day | 40 - 46 GiB/day |

The step on 09-16 coincides with the tiles-test VMs being recreated on that host.
Write latency stayed normal for eight days (0.47 - 0.60 ms through 09-23), then
broke on **09-24** and climbed over the following weeks -- daily means reaching
28 ms, with half-hour means of 200 - 538 ms before the host wedged on 10-05.
Two wedge episodes in 30 days (09-25, recovered after about two hours; 10-05,
host dropped off the network and out of the Proxmox cluster), both with
`nvme nvme0: I/O tag ... timeout, aborting req_op:WRITE` in the host journal.

As of 2026-10-15, degraded again: write 8.2 ms and **read 48.8 ms**, against
`nuc-g3p-1` at 0.52 ms and 0.21 ms.

**The two drives are not the same model**, which weakens that comparison. From
`node_nvme_info`:

| host | model | serial | firmware |
|---|---|---|---|
| nuc-g3p-1 | `TWSC TSC3AN512E6-F2T60S` | TTSMA253SX05660 | SN13076 |
| nuc-g3p-2 | `TWSC TSC3AN512-F2T60S` | TTSMA254AX18375 | SN13076 |

Same firmware, an `E6` suffix on the healthy one, and serial prefixes from
different batches. So "identical hardware, one sick one healthy" is not available
as a control -- anything that differs per model (TMT thresholds, cache sizing,
NAND bin) is unexcluded.

### What this is not

- **Thermal: measured on both drives, and it does not track the stall.** Full
  `smartctl -x` from both hosts, 2026-10-16:

  | | g3p-1 (healthy) | g3p-2 (degraded) |
  |---|---|---|
  | Thermal Temp 1 transitions | **11,965,897** / 1297 h | 1,029,085 / 159 h |
  | Thermal Temp 2 transitions | 80,137 / 9.4 h | **237,945** / 37.6 h |
  | Warning Comp. Temp Time (>90 C) | **5 min** | 0 |
  | Current temperature | 47 C | 42 C |

  The healthy drive has 12x the TMT1 transitions and 8x the time throttled, has
  exceeded the 90 C warning threshold where the degraded one never has, and runs
  5 C hotter. g3p-2 has more TMT2 (the heavier throttle) but less TMT1 and less
  total throttle time. Whatever these counters are describing, it is not the
  stall. Thresholds themselves are unread -- `nvme-cli` is not installed on either
  host, so Get Features 0x10 is unavailable.
- **Not instantaneous load.** Latency moved about 40x while throughput stayed
  inside 0.2 - 1.3 MiB/s with no correlation.
- **Not the kernel.** Both boxes ran 7.0.6-2-pve throughout the degradation;
  `nuc-g3p-1` only moved to 7.0.14-20-pve on 2026-10-06/07, a fortnight after the
  divergence started.

### Caveats on the hypothesis

`nuc-g3p-1` sustains 40 - 46 GiB/day at 0.5 ms indefinitely, so volume alone is not
sufficient -- g3p-2's range is only 1.5 - 2.3x its sibling's. Either the peaks cross
a threshold the steady rate does not, or the two drives differ in wear or model, or
both mechanisms are in play.

Read latency being as bad as write latency does not by itself argue against a
write-side mechanism: `read_time / reads_completed` includes queueing, so reads
sitting behind very slow writes look slow without the read path being impaired.

### SMART, both drives side by side (2026-10-16)

| | g3p-1 (healthy) | g3p-2 (degraded) |
|---|---|---|
| Model | `TWSC TSC3AN512E6-F2T60S` | `TWSC TSC3AN512-F2T60S` |
| Firmware | SN13076 | SN13076 |
| Percentage Used | 10% | 10% |
| Available Spare | 100% | 100% |
| Media and Data Integrity Errors | 0 | 0 |
| Error Information Log Entries | 0 | 0 |
| Critical Warning | 0x00 | 0x00 |
| Power On Hours | 9,239 | 9,216 |
| Data Units **Written** | 10.3 TB | 13.9 TB |
| Data Units **Read** | 34.3 TB | **254 TB** |
| Power Cycles | 29 | 39 |
| Unsafe Shutdowns | 8 | 18 |

Neither drive reports anything wrong with itself: no media errors, no spare
consumed, empty error logs, no critical warnings, and **identical 10% endurance
used** at nearly identical power-on hours. The FLUSH/WRITE timeouts in g3p-2's
host journal left no device-side error entries at all -- the commands did not
fail, they did not complete in time.

The only large asymmetry is reads: **254 TB against 34.3 TB, 7.4x.** Writes differ
by 1.35x over the drives' whole lives, which is consistent with the 1.5-2x daily
figures but is far too small for write volume to be the distinguishing feature on
its own. Power cycles and unsafe shutdowns track the wedge history rather than
explaining it.

### What none of this establishes

The two hosts are not a controlled pair, and the measurements above do not make
them one:

- **The workloads are not comparable.** g3p-2 carried an entire self-contained
  cluster, latterly a crash-looping one; g3p-1 carries one production control
  plane and one worker. 254 TB of reads is as well explained as the *consequence*
  of a slow device -- page-cache refault against high-latency storage -- as its
  cause. Nothing here orders those.
- **The drives are different models**, so anything that varies by revision (NAND
  bin, controller tuning, cache sizing, thermal setpoints) is uncontrolled.
- **Physical siting is uncontrolled.** Position on the desk, airflow and
  neighbours all differ and none of it is recorded.
- **Virtualization is an additional and particular stress**, and both hosts have
  been running guests throughout, so it is not a variable that has been varied.

So the honest state is that no mechanism is established. pSLC exhaustion, early
thermal throttling, read-disturb, a worse drive revision and plain workload
asymmetry are all live, and the measurements narrow none of them to one.

The operator's read, recorded as his: **even odds that this drive never complains
again once it is carrying an ordinary worker's load**, and roughly **60/40 that it
never complains again if the host is stood up as bare-metal Talos** rather than a
hypervisor -- on the reasoning that if something is sitting near the edge of a
tolerance, virtualization is an extra stress of a particular kind.

### Why that host had an unusual profile

`nuc-g3p-2` carried an entire self-contained cluster on one disk: a control plane
with its own etcd plus a worker holding the write-heavy tier of a full LGTM stack
(Mimir ingester WAL, the `mimir-kafka` ingest buffer, the compactor, and Loki's
WAL, all on node-local `local-path` volumes). On the production cluster those same
components are spread across three workers on three disks, and no production host
carries both a control plane and that storage tier.

It is the combination that matters, not any single component: `tiles-wk-2` holds
the Mimir compactor, `mimir-kafka` and an ingester today and writes 23.8 GiB/day
without trouble. What `nuc-g3p-2` had was the whole set *plus* a control plane with
its own etcd, which took it from the quietest host in the fleet to the busiest.

Per-VM measurement, 2026-10-15, from the guests' own node_exporter (GiB/day): the
three production control planes write 31.9 / 28.8 / 20.9 -- clustered, because they
are three members of one etcd cluster fsyncing the same raft entries -- while the
workers scatter 23.8 / 9.5 / 6.9 according to what happens to live on them. Those
reconstruct the host totals to within a consistent ~3.2 GiB/day of Proxmox itself
plus the Alloy CT. So a host's write floor is set by having an etcd member, and a
worker-only host skips it.

Tracked in tiles#816.
