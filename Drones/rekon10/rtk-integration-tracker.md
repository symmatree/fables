# RTK integration tracker (Rekon10 + Holybro ZED-F9P)

[Back to index](README.md)

More detail lives in [ardupilot.md](ardupilot.md), [gps-mount.md](gps-mount.md), [ground-station.md](ground-station.md), [flight-platform.md](flight-platform.md).

Hardware: **Holybro ZED-F9P**; **adapter board** from module connector to **4-pin UART + 5 V** and **2-pin I2C (SCL/SDA)**; **USB-UART dongle** with **female** header for that 4-pin side. Bench path: u-center on the PC; **try adapter stack first**, fall back to **Holybro USB-C** direct cable.

**Bench and airframe**

- [ ] **A** u-center: adapter + USB-UART, then **Holybro USB-C** if needed. Bench satellite fix. UART baud noted; match `SERIAL7_*` and F9P when wiring the FC.
- [ ] **B** On **one** I2C bus: cut/replace **two** hard-soldered wires with a **2-pin harness** to the F9P. Record which bus (silk + [flight-platform.md](flight-platform.md)); sync [`config/rekon10-ardupilot.param`](config/rekon10-ardupilot.param) when it settles.
- [ ] **C** Drone powered, **VTX off**, **USB to FC only**: 3D fix and good enough for **Loiter** per prearm; **compass present** in Mission Planner (**no** compass cal yet).
- [ ] **D** If **C** is good: top plate off, **four holes** in the **rear** of the top plate for the mast, mount antenna and strain-relief leads, reassemble; repeat **C** indoors (VTX still off) to confirm GPS + compass still there.
- [ ] **E** **Outside:** full compass calibration; re-export params when good.

**WiFi ground station** (do **F** as soon as it helps; **ideally before outdoor cal E** so you are not USB-tethered for that.)

- [ ] **F** Mission Planner: turn off or soften the **full config/param refresh on connect** that floods the RF link (note the exact option). **RadioMaster Boxer / ELRS:** MAVLink over **WiFi** (handsets already join WiFi -- [ground-station.md](ground-station.md) for ports, `boxer-tx.local`, etc.). Goal: laptop for checks and telemetry **without** USB to the drone or the radio.

**NTRIP / cluster / corrections**

- [ ] **G** **Attic** Windows PC: fixed antenna, surveyed / stable position in u-center, **NTRIP server** running today -- when clients need it, store host, port, mountpoint, auth **outside git**. (This is the feed the house already has; we are not inventing the base story here.)
- [ ] **H** **Talos** on new hardware, join **Tiles prod**; pass **USB** from that GNSS path into a **pod** running an **NTRIP caster** toward the cluster or LAN as designed.
- [ ] **I** **Separate** from **H** if possible: a **MAVLink proxy** that talks toward the **RadioMaster / ELRS** side: push **RTCM** to the drone, **fan out / echo** MAVLink so **Mission Planner** (and anything else) can attach over the network -- drone can hold RTK-related state with **laptop off**, laptop still connects OTA when you want. Pick tooling (MAVProxy-class, router, etc.); pull NTRIP from **G** or **H**; mind telem budget ([gps-mount.md](gps-mount.md)).
