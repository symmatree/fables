# Network latency and speed-test results

Measurements use [Microsoft's Latte tool](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-test-latency?tabs=windows) (TCP RTT; download: [GitHub](https://github.com/microsoft/latte/releases/latest/download/latte.exe)) and WiFiMan / app speed tests. Raw Latte output is in the [Appendix](#appendix-raw-latte-output).

## Summary tables

### WiFiMan / app speed tests (throughput and internet latency)

| Machine | Connection | Date | Down (Mbps) | Up (Mbps) | Latency (ms) | Jitter (ms) | Link |
|--------|------------|------|-------------|-----------|--------------|-------------|------|
| Bifrost | Wired (onboard) | — | 866 | 946 | 8 | 0 | GbE |
| Namaste | Wi-Fi | — | 237.5–283 | 283–347.5 | 15–17 | 1 | WiFi 5 |
| Namaste | Wired (Anker dongle) | 2026-03-13 | 508.3 | 910.7 | 13 | 2 | GbE |
| Lancer | Wired | 2026-03-13 | 793.1 | 978.6 | 11 | 1 | 10GbE |

Lancer is also reported in [[Lancer]] as 833.3 down / 967.5 up, 9 ms latency, 2 ms jitter (same day or similar conditions).

### Latte TCP RTT: initiator to Lancer (10.0.128.51)

All tests: TCP, 4-byte message, blocking send/receive, default socket buffers; receiver = Lancer (basement, wired to basement-us-48-g1).

| Initiator | Connection | Latency (µs) | Latency (ms) | Iterations |
|-----------|------------|--------------|--------------|------------|
| Bifrost | Wired (onboard, attic-us-24-250w) | ~132 | **0.13** | 65,000 |
| Namaste | Wired (Anker USB dongle, Cat5 breakfast nook) | ~1310–1338 | **~1.31–1.34** | 65,100 |
| Namaste | Wi-Fi (UAP-AC-Pro) | ~2921 | **~2.92** | 65,000 |

So: wired onboard (Bifrost) is **~0.13 ms**; wired via USB dongle (Namaste) is **~1.3 ms** (~10× higher); Wi-Fi (Namaste) is **~2.9 ms** (~22× higher than Bifrost). Still fine for RDP, but the gap is meaningful for smoothness and interactivity.

---

## Comparison and characterization

### Patterns

1. **Bifrost has the lowest latency** (~132 µs to Lancer) despite being an older 2018 desktop (i7-8700K) and connected via the **attic** switch (attic-us-24-250w). Lancer is on the basement switch (basement-us-48-g1). So the path is Bifrost ↔ attic switch ↔ … ↔ basement switch ↔ Lancer. Sub-second RTT is expected for wired LAN; Bifrost's result is in the normal "good wired" range.

2. **Namaste wired (Anker dongle) is ~10× higher than Bifrost** (~1.3 ms vs ~0.13 ms). Namaste is also 2018-era (i5-8350U laptop) but has **no built-in Ethernet**; when "wired" it uses an Anker USB Ethernet dongle and Cat5 to the breakfast nook. The ~1.3 ms RTT is consistent with **USB Ethernet adapter overhead**, not with cable or switch aging.

3. **Namaste Wi-Fi is ~2.2× worse than Namaste wired (dongle)** (~2.9 ms vs ~1.3 ms). That matches the usual Wi-Fi vs wired penalty (extra buffering, retransmits, and protocol overhead).

4. **Throughput (WiFiMan)** is consistent with link types: Bifrost and Lancer near 1 Gbps; Namaste wired (dongle) ~500–910 Mbps (often limited by USB bus or dongle); Namaste Wi-Fi ~240–350 Mbps (WiFi 5, 5 GHz). Lancer's 10 GbE port is effectively capped by the 1 GbE path to the rest of the LAN.

### Are the differences due to hardware aging or to configuration?

**Conclusion: the large latency differences are due to *connection type and adapter* (USB dongle, Wi-Fi), not to hardware aging.**

- **Bifrost**: Oldest of the three (2018) but **onboard GbE** on a desktop motherboard (PCIe-attached NIC). That gives the best latency. No sign of "aging" in the numbers.
- **Namaste**: Same era (2018 laptop) but when "wired" it's **USB Ethernet**. Public benchmarks and Q&A (e.g. Super User, XDA) show that USB Ethernet dongles often add **~1–2 ms** RTT vs onboard NICs (e.g. 0.47 ms onboard vs 1.9 ms for a TP-Link USB-C dongle in one test). Your ~1.3 ms on Namaste wired fits that pattern. So the ~10× gap vs Bifrost is **configuration** (dongle + possibly USB host), not the laptop's age.
- **Lancer**: Newest (2025), 10 GbE, basement. It's the fixed receiver in these tests; its latency is not in question. Its throughput is limited by the 1 GbE network path.

So: **Bifrost's "amazing" network stack is simply onboard Ethernet vs USB and Wi-Fi.** No need to attribute it to driver magic or newer silicon; the main factor is the absence of USB and wireless in the path.

### Network path context (for future refinement)

- **Bifrost**: 10.0.98.1 → attic-us-24-250w → (uplink to core) → … → Lancer. If you ever reconstruct the full path (e.g. via UniFi topology or traceroute), you could confirm hop count and that latency is dominated by the first/last mile (NIC and switch port).
- **Namaste**: Wi-Fi → 2nd-floor-uap-ac-pro (or lower-attic-UAP-AC-PRO in one test); wired → Anker dongle → Cat5 → breakfast nook (switch/port TBD). Different subnets (e.g. 10.0.98.x vs 10.0.128.x) are normal; routing through the gateway (Morpheus) doesn't change the conclusion that endpoint adapter type dominates RTT.

---

## Questions, suggestions, and feedback

- **Anker dongle model**: Recording the exact Anker USB Ethernet model (and chipset, if visible in Device Manager) would help compare with published benchmarks and future tests.
- **Namaste at desk**: If Namaste is often used wired in the breakfast nook for RDP, a **Thunderbolt dock with integrated Ethernet** (instead of a USB dongle) may yield lower latency; some users report dock Ethernet close to onboard (e.g. 0.56 ms vs 0.47 ms in one comparison). The X1 Yoga 3rd may have Thunderbolt; worth checking.
- **Re-run Latte from Lancer → Bifrost**: Running Latte with Lancer as initiator and Bifrost as receiver would confirm symmetry and rule out any one-way bias.
- **RDP smoothness**: The doc's note that "this is meaningful for smoothness of RDP" is consistent with the numbers: 0.13 ms is effectively imperceptible; 1.3 ms is usually fine; 2.9 ms may be noticeable in highly interactive use. No change needed for "correctness," but if you want the smoothest RDP from the laptop, prefer wired (ideally via a low-latency dock) over Wi-Fi when possible.

---

## Appendix: raw Latte output

Below is the original Latte dump for each scenario (initiator and receiver sides where recorded).

### Namaste Wi-Fi to Lancer

From Namaste (initiator side):

```
Protocol      TCP
SendMethod    Blocking
ReceiveMethod Blocking
SO_SNDBUF     Default
SO_RCVBUF     Default
MsgSize(byte) 4
Iterations    65000
Latency(usec) 2920.80
CPU(%)        6.8
CtxSwitch/sec 5864      (17.13/iteration)
SysCall/sec   9187      (26.83/iteration)
Interrupt/sec 4506      (13.16/iteration)
```

From Lancer (receiver side):

```
C:\Windows\System32>c:\users\symmetry\latte -a 10.0.128.51:9090 -i 65000
Protocol      TCP
SendMethod    Blocking
ReceiveMethod Blocking
SO_SNDBUF     Default
SO_RCVBUF     Default
MsgSize(byte) 4
Iterations    65000
Latency(usec) 2921.10
CPU(%)        1.7
CtxSwitch/sec 12077     (35.28/iteration)
SysCall/sec   18859     (55.09/iteration)
Interrupt/sec 10832     (31.64/iteration)
```

### Namaste wired (Anker dongle) to Lancer

Ran Cat5 to the breakfast nook, should be 1Gb.

From Namaste (initiator):

```
C:\Users\symmetry\Downloads>latte -c -a 10.0.128.51:5005 -i 65100
Protocol      TCP
SendMethod    Blocking
ReceiveMethod Blocking
SO_SNDBUF     Default
SO_RCVBUF     Default
MsgSize(byte) 4
Iterations    65100
Latency(usec) 1309.71
CPU(%)        5.9
CtxSwitch/sec 8363      (10.95/iteration)
SysCall/sec   15028     (19.68/iteration)
Interrupt/sec 7677      (10.06/iteration)
```

From Lancer (receiver):

```
C:\Users\symmetry>latte -a 10.0.128.51:5005 -i 65100
Protocol      TCP
SendMethod    Blocking
ReceiveMethod Blocking
SO_SNDBUF     Default
SO_RCVBUF     Default
MsgSize(byte) 4
Iterations    65100
Latency(usec) 1309.84
CPU(%)        0.9
CtxSwitch/sec 11755     (15.40/iteration)
SysCall/sec   12582     (16.48/iteration)
Interrupt/sec 11497     (15.06/iteration)
```

On rerun (to confirm not still on Wi-Fi), Namaste:

```
Protocol      TCP
SendMethod    Blocking
ReceiveMethod Blocking
SO_SNDBUF     Default
SO_RCVBUF     Default
MsgSize(byte) 4
Iterations    65100
Latency(usec) 1338.13
CPU(%)        5.5
CtxSwitch/sec 7296      (9.76/iteration)
SysCall/sec   7188      (9.62/iteration)
Interrupt/sec 7116      (9.52/iteration)
```

and Lancer:

```
C:\Users\symmetry>latte -a 10.0.128.51:5005 -i 65100
Protocol      TCP
SendMethod    Blocking
ReceiveMethod Blocking
SO_SNDBUF     Default
SO_RCVBUF     Default
MsgSize(byte) 4
Iterations    65100
Latency(usec) 1338.25
CPU(%)        1.0
CtxSwitch/sec 12327     (16.50/iteration)
SysCall/sec   14649     (19.60/iteration)
Interrupt/sec 11681     (15.63/iteration)
```

### Bifrost wired to Lancer

From Bifrost (initiator):

```
Protocol      TCP
SendMethod    Blocking
ReceiveMethod Blocking
SO_SNDBUF     Default
SO_RCVBUF     Default
MsgSize(byte) 4
Iterations    65000
Latency(usec) 131.93
CPU(%)        4.4
CtxSwitch/sec 21868     (2.89/iteration)
SysCall/sec   46399     (6.12/iteration)
Interrupt/sec 36887     (4.87/iteration)
```

From Lancer (receiver):

```
Protocol      TCP
SendMethod    Blocking
ReceiveMethod Blocking
SO_SNDBUF     Default
SO_RCVBUF     Default
MsgSize(byte) 4
Iterations    65000
Latency(usec) 131.94
CPU(%)        3.8
CtxSwitch/sec 70671     (9.32/iteration)
SysCall/sec   45834     (6.05/iteration)
Interrupt/sec 62430     (8.24/iteration)
```

### WiFiMan / speed-test notes (raw)

- **Namaste Wi-Fi (WiFiMan)**: Signal -45 dBm; PHY WiFi 5, MIMO 3x3; 5 GHz 40 MHz; connected to lower-attic-UAP-AC-PRO. WiFiMan reported 10–40 ms latency to 8.8.8.8.
- **Namaste wired (Anker dongle), WiFiMan 2026-03-13**: down 508.3 Mbps, up 910.7 Mbps, latency 13 ms, jitter 2 ms, link speed GbE.
- **Lancer wired, WiFiMan 2026-03-13**: down 793.1 Mbps, up 978.6 Mbps, latency 11 ms, jitter 1 ms, link speed 10GbE.
