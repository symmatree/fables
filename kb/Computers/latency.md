using [microsoft's latte tool](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-test-latency?tabs=windows) (download binary from [github](https://github.com/microsoft/latte/releases/latest/download/latte.exe)), massive differences:

Summary: wired is 0.131ms of latency, wifi is 2.9ms. Still very good but it seems plausible this is meaningful for smoothness of RDP. Update: Wow, wired on namaste is better but still much higher than bifrost, someone has an amazing network stack.
### Namaste wifi (wifiman speedtest)
Measured from the study. WifiMan reports   
* Signal: -45 dBm
* PHY Mode: WiFi 5, MIMO 3x3
* Band: 5 GHz 40 MHz
Connected to lower-attic-UAP-AC-PRO
Wifiman reports 10-40ms latency to 8.8.8.8
## Namaste wired (anker dongle), wifiman speedtest 2026-03-13
* down: 508.3 Mbps
* up: 910.7 Mbps
* Latency 13 ms
* Jitter 2 ms
* Link Speed GbE
## Lancer wired, wifiman speedtest 2026-03-13
* Down: 793.1 Mbps
* up: 978.6 Mbps
* Latency 11 ms
* Jitter 1 ms
* Link Speed 10GbE
### Namaste wifi to lancer
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
From lancer (receiver side):
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

### Namaste wired to lancer
Ran Cat5 to the breakfast nook, should be 1Gb.
From namaste (initiator):
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
From lancer (receiver side):
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

On rerun (I was wondering if it was still "slightly" on wifi), namaste:
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
and lancer
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
### Bifrost wired to lancer
From bifrost (initiator):
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
and from lancer (receiver):
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
