using [microsoft's latte tool](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-test-latency?tabs=windows) (download binary from [github](https://github.com/microsoft/latte/releases/latest/download/latte.exe)), massive differences:

Summary: wired is 0.131ms of latency, wifi is 2.9ms. Still very good but it seems plausible this is meaningful for smoothness of RDP.
### Namaste wifi to lancer
Measured from the study. WifiMan reports   
* Signal: -45 dBm
* PHY Mode: WiFi 5, MIMO 3x3
* Band: 5 GHz 40 MHz
Connected to lower-attic-UAP-AC-PRO
Wifiman reports 10-40ms latency to 8.8.8.8

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
