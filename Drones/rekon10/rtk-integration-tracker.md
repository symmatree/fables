# RTK integration tracker (Rekon10 + Holybro F9P Rover Lite)

[Back to index](README.md)

More detail lives in [ardupilot.md](ardupilot.md), [gps-mount.md](gps-mount.md), [ground-station.md](ground-station.md), [flight-platform.md](flight-platform.md).

Hardware: **Holybro F9P Rover Lite** (ZED-F9P + integrated compass); **adapter board** from module connector to **4-pin UART + 5 V** and **2-pin I2C (SCL/SDA)**; **USB-UART dongle** with **female** header for that 4-pin side. Bench path: u-center on the PC; **try adapter stack first**, fall back to **Holybro USB-C** direct cable. Replaces **M100 Pro** on the FC; **no** second mission-payload GPS. Multicamera PPS is **DS3234 SQW**, not GNSS PPS ([gps-mount.md](gps-mount.md), [central-hub.md](central-hub.md)).

**NTRIP / cluster / corrections**

- [ ] **G** **Attic** Windows PC: fixed antenna, surveyed / stable position in u-center, **NTRIP server** running today -- when clients need it, store host, port, mountpoint, auth **outside git**. (This is the feed the house already has; we are not inventing the base story here.)
- [ ] **H** **Talos** on new hardware, join **Tiles prod**; pass **USB** from that GNSS path into a **pod** running an **NTRIP caster** toward the cluster or LAN as designed.
- [ ] **I** **Separate** from **H** if possible: a **MAVLink proxy** that talks toward the **RadioMaster / ELRS** side: push **RTCM** to the drone, **fan out / echo** MAVLink so **Mission Planner** (and anything else) can attach over the network -- drone can hold RTK-related state with **laptop off**, laptop still connects OTA when you want. Pick tooling (MAVProxy-class, router, etc.); pull NTRIP from **G** or **H**; mind telem budget ([gps-mount.md](gps-mount.md)).
