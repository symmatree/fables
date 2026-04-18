# ArduPilot configuration (Rekon10)

[Back to index](README.md) | [Flight platform hardware](flight-platform.md) | [Ground station / radio](ground-station.md)

FC-side settings for the **TBS Lucid H7** build. The FC is the source of truth; **[`config/rekon10-ardupilot.param`](config/rekon10-ardupilot.param)** is the last export committed from Mission Planner (**Write Params**, **Save to File**, then git) so the repo matches what was on the FC at export time.

Handset and ELRS profile (Boxer, rates, Model Match, switch table): **[ground-station.md](ground-station.md)**. EdgeTX model export: **[`config/MODELS/model01.yml`](config/MODELS/model01.yml)** (**Rekon10**, model id **10**).

Firmware: **Copter 4.6.3** `arducopter_with_bl.hex` for **TBS_LUCID_H7** from `https://firmware.ardupilot.org/Copter/stable-4.6.3/TBS_LUCID_H7/arducopter_with_bl.hex`.

## Frame

* `FRAME_CLASS = 1` (Quad)
* `FRAME_TYPE = 1` (X)

## Serial ports

Wiring: [flight-platform.md](flight-platform.md). Serial **`PROTOCOL`** / **`BAUD`** below match the last committed export.

| Port | Parameters | Wired |
|------|------------|--------|
| SERIAL0 | `PROTOCOL = 2`, `BAUD = 115` | USB |
| SERIAL1 | `PROTOCOL = -1` | Unused |
| SERIAL2 | `PROTOCOL = 5`, `BAUD = 115` | M100 Pro (UART + I2C1 compass) |
| SERIAL3 | `PROTOCOL = 42`, `BAUD = 115` | Walksnail MSP (TX3/RX3 only; VTX power is other FC pads, not UART3) |
| SERIAL4 | `PROTOCOL = 9`, `BAUD = 115` | Unused |
| SERIAL6 | `PROTOCOL = 2`, `BAUD = 460` | Matek ELRS R24-TD (see [ground-station.md](ground-station.md); `model01.yml` header `modelId` **10**) |
| SERIAL7 | `PROTOCOL = 5` | Unused |
| SERIAL8 | `PROTOCOL = 16` | ESC ribbon |
| SERIAL9 | `PROTOCOL = 2`, `BAUD = 115` | Unused |

**SERIAL7:** F9P on the mast at **460800** when fitted (`SERIAL7_BAUD = 460`).

### RTCM / RTK

RTCM over the ELRS link is not finalized. Profile and headroom: [ground-station.md](ground-station.md), [rekon-design.md](rekon-design.md), [gps-mount.md](gps-mount.md).

## RC and FC aux mapping

**Which switch maps to which RC channel** (and EdgeTX **`destCh`** indexing): **[ground-station.md](ground-station.md)** and **[`config/MODELS/model01.yml`](config/MODELS/model01.yml)**. This section is **FC parameters only** -- no duplicate of the RadioMaster / EdgeTX mix table.

**Why Land on SD, not RTL:** much of this flying is **under canopy** and near **structure**. **RTL** means climb-then-go-home and is **actively dangerous** in that environment unless you have planned for **open sky**, a **safe home**, and **clearance above obstacles**. **SD** / **CH7** is **Land** only (**`RC7_OPTION = 18`**). Use **RTL** only when you have explicitly chosen that path (for example open-field work or a failsafe policy you have deliberately set and tested), not as the default "get out" on this switch.

| Channel | FC parameters |
|---------|-----------------|
| CH5 | **`RC5_OPTION = 153`** (arm/disarm on latch **L3**; gate and mixes in [ground-station.md](ground-station.md) / **`model01.yml`**) |
| CH6 | **`FLTMODE_CH = 6`**. **`FLTMODE1` / `FLTMODE4` / `FLTMODE6`** = **Loiter (5) / AltHold (2) / Sport (13)** toward-to-away on **SB** ([ground-station.md](ground-station.md)). |
| CH7 | **`RC7_OPTION = 18`** (**LAND Mode** on **SD**; [aux functions](https://ardupilot.org/copter/docs/common-auxiliary-functions.html)). |
| CH8 | **`RC8_OPTION = 30`** (*Lost vehicle sound*: **GEPRC** / FC buzzer **while CH8 is high**, i.e. while **SF** is held for the arm gate). |
| CH9 | **`RC9_OPTION = 36`** (Relay4). **`RELAY4_PIN = 83`**, **`RELAY4_FUNCTION = 1`** (Lucid HD VTX BEC). |

### ELRS telemetry on the radio

Telemetry keys and screens live in **`model01.yml`** (e.g. **RSNR**, **FM**, RSSI/LQ fields). [ground-station.md](ground-station.md) describes the ELRS profile and handset setup.

## Compass and GPS (M100)

* `COMPASS_ORIENT = 6` (**Yaw270**)
* `GPS1_TYPE = 1`, `GPS1_RATE_MS = 200`

This section refers to the **HGLRC M100 Pro** module on this airframe: bench USB tests have shown a non-RTK **3D fix** and successful compass calibration, but FC wall-clock / RTC time is still not set from GNSS in this setup. Details: [flight-platform-build-log.md](flight-platform-build-log.md).

## Battery monitoring

Mission Planner **Initial Tune** (with **6S Li-ion** selected) set most **`BATT_*`** metering and voltage thresholds. Full **`BATT_*`** / **`MOT_BAT_*`** list: **[`config/rekon10-ardupilot.param`](config/rekon10-ardupilot.param)**.

**Failsafe actions (operator choice, not Initial Tune):** **`BATT_FS_LOW_ACT = 0`** (warn only on low pack) then **`BATT_FS_CRT_ACT = 1`** (**Land** on critical). Low uses **`BATT_LOW_VOLT`** with **`BATT_LOW_TIMER`** (**10** s hold in export) before the warning state; critical uses **`BATT_CRT_VOLT`**.

**From the current export (Initial Tune thresholds):** **`BATT_ARM_VOLT = 19.1`**, **`BATT_LOW_VOLT = 18.6`**, **`BATT_CRT_VOLT = 18`** (about **3.18 / 3.10 / 3.00 V per cell** on **6S**). Those are a **reasonable first pass** for Li-ion; **`BATT_CRT_VOLT = 18`** is toward the **low** end for sustained load on some packs. If the FC hits **critical Land** earlier than you expect under sag, raise **`BATT_CRT_VOLT`** slightly (and re-export) rather than fighting it in the air.

## Rangefinder (future)

**Not fitted.** Plan: **Benewake TFS20-L** on **I2C1**, address **0x10**:

```
RNGFND1_TYPE = 45
RNGFND1_ADDR = 16
RNGFND1_MIN_CM = 20
RNGFND1_MAX_CM = 1500
RNGFND1_ORIENT = 25
```

UART fallback if I2C fails: `RNGFND1_TYPE = 8` at 115200 on SERIAL4. [ArduPilot TFS20-L doc](https://ardupilot.org/copter/docs/common-benewake-tf02-lidar.html).

## Mission Planner and other tools

* **Accel / level cal:** Lucid **"V"** on pad side **up**. [flight-platform-build-log.md](flight-platform-build-log.md).
* **Compass cal:** Onboard for M100.
* **ELRS RX:** Match Boxer (**3.6.3** per [ground-station.md](ground-station.md)). [ExpressLRS web flasher](https://expresslrs.github.io/web-flasher/).
* **Walksnail VTX:** Match goggles (e.g. **39.44.5**).
* **AM32 ESC:** [AM32 configurator](https://github.com/am32-firmware/AM32); FC passthrough when available.

### Pre-arm: Mission Planner UI vs ArduPilot (Copter)

Mission Planner **Initial Setup** / **wizard** text is **shared across vehicle types** and often mentions **ailerons**, **elevator**, **rudder**, or other **fixed-wing** steps. **Ignore that** for this **Copter** quad -- it is not your checklist.

**What actually blocks arming** comes from **ArduPilot Copter**, not that screen. With USB or telemetry connected:

* **Flight Data** tab -- **Messages** (or the scrolling message area on the HUD). Look for **`PreArm:`** / **`Arm:`** / **`STATUSTEXT`** lines (GPS, EKF, compass, RC cal, battery, throttle, fence, etc.). While disarmed, failing checks are often repeated about every **30 s** (see [Pre-Arm Safety Checks](https://ardupilot.org/copter/docs/common-prearm-safety-checks.html) -- message/cause/solution table for **Copter**).

**Checks:** **`ARMING_CHECK`** bitmask; **`ARMING_SKIPCHK`** is for bench only -- [doc](https://ardupilot.org/copter/docs/common-prearm-safety-checks.html#disabling-the-pre-arm-safety-check).
