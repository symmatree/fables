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

- **Not thermal *by sensor temperature*, which is weaker than it sounds.** At 16x
  the write latency of its sibling the NVMe sensors read 45.85 / 45.85 / 46.85 C
  against the healthy box's 44.85 / 44.85 / 46.85, and CPU 72 C against 73 C. But
  the drive's own thermal-management counters are very active: `smartctl -x` on
  2026-10-07 showed **Thermal Temp. 1: 958,337 transitions over 142.1 h** and
  **Thermal Temp. 2: 208,967 over 32.7 h**, with zero time at the Warning (90 C) or
  Critical (95 C) composite thresholds. TMT1/TMT2 are separate, lower and
  host-configurable, so the controller has been entering a reduced-performance
  state constantly at temperatures the hwmon sensor reports as unremarkable.
  Sampled twice 94 minutes apart, TMT2 was accumulating at ~3.6x its lifetime rate
  at 45-46 C with the drive only 3.7% busy. **`nuc-g3p-1`'s TMT counters have never
  been read**, and that one comparison would settle whether equal sensor
  temperatures mean equal thermal behaviour.
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

**SMART says the device does not consider itself to be failing** (`smartctl -x`,
2026-10-07, full output on tiles#816):

```
Percentage Used:                 10%
Available Spare:                 100%   (threshold 1%)
Media and Data Integrity Errors: 0
Error Information Log Entries:   0      ("No Errors Logged")
Critical Warning:                0x00
Data Units Written:              26,151,611 [13.3 TB]
Power On Hours:                  9,033
Unsafe Shutdowns:                17 of 38 power cycles
```

Zero media errors, no spare consumed, nothing in the 64-entry error log, 10%
endurance used. Notably the FLUSH/WRITE timeouts in the host journal produced **no
device-side error entries at all** -- the commands did not fail, they did not
complete in time. That is the signature of a slow drive rather than a broken one,
and it supports the cache/GC reading over device failure.

It also quantifies the load change: 13.3 TB over 9,033 power-on hours is a lifetime
average of **~35 GB/day**, against the 49-100 GiB/day this host has run since
2026-09-16. The recent load is several times what the drive has averaged across its
life.

**What is still unmeasured:** `nuc-g3p-1`'s TMT transition counters (same
`smartctl -x`, no extra tooling) to test whether the two models throttle at
different thresholds; and `lspci -vv` to rule out a PCIe link that has trained
down.

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
