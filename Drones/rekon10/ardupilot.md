# ArduPilot configuration (Rekon10)

[Back to index](README.md) | [Flight platform hardware](flight-platform.md) | [Ground station / radio](ground-station.md)

FC-side settings for the **TBS Lucid H7** build. Parameter list: **[`config/rekon10-ardupilot.param`](config/rekon10-ardupilot.param)** (Mission Planner full list load/save keeps git and the aircraft aligned).

Radio side for this model: **[`config/MODELS/model01.yml`](config/MODELS/model01.yml)** (EdgeTX **Rekon10**, model id **10**) plus narrative in **[ground-station.md](ground-station.md)** (Boxer, ELRS **MAVLink**, **333 Hz Full**, telemetry **1:2**, 16ch rate switch mode, Receiver Number **10**).

Firmware: **Copter 4.6.3** `arducopter_with_bl.hex` for **TBS_LUCID_H7** from `https://firmware.ardupilot.org/Copter/stable-4.6.3/TBS_LUCID_H7/arducopter_with_bl.hex`.

## Frame

* `FRAME_CLASS = 1` (Quad)
* `FRAME_TYPE = 1` (X)

## Serial ports

Values from **`rekon10-ardupilot.param`**. Wiring: [flight-platform.md](flight-platform.md).

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

## RC, switches, remaining FC work

**Where to set (Mission Planner):** **Config** > **Full Parameter List** (use search for each name). After editing, **Write Params** to the FC, then **Save to File** and commit **[`config/rekon10-ardupilot.param`](config/rekon10-ardupilot.param)** so git matches the aircraft.

Authoritative EdgeTX layout: **[`config/MODELS/model01.yml`](config/MODELS/model01.yml)**. In that file, **`mixData[].destCh`** is **zero-based output index** (**0** = **CH1** on the wire). Sticks are **I0..I3** on `destCh` **0..3**. Aux mixes:

**Why Land on SD, not RTL:** much of this flying is **under canopy** and near **structure**. **RTL** means climb-then-go-home and is **actively dangerous** in that environment unless you have planned for **open sky**, a **safe home**, and **clearance above obstacles**. **SD** / **CH7** is **Land** only (**`RC7_OPTION = 18`**). Use **RTL** only when you have explicitly chosen that path (for example open-field work or a failsafe policy you have deliberately set and tested), not as the default "get out" on this switch.

| `destCh` | Channel | `model01.yml` (mix names / logic) | FC action |
|----------|---------|-----------------------------------|-------------|
| 4 | CH5 | **Arm Lo** / **Arm Hi** (**`L3`**) | **`RC5_OPTION`** for arm/disarm -- see **Arm / disarm on CH5** below. |
| 5 | CH6 | **FltMod**: **SB**, `weight: -100` | **`FLTMODE_CH = 6`**. SB low / mid / high map to **`FLTMODE1` / `FLTMODE4` / `FLTMODE6`**. Export: **Loiter (5) / AltHold (2) / Sport (13)** (toward-to-away). Switch labels: [ground-station.md](ground-station.md). |
| 6 | CH7 | **Land**: **SD**, `weight: -100` | **`RC7_OPTION = 18`** (**LAND Mode** in Mission Planner; [aux functions](https://ardupilot.org/copter/docs/common-auxiliary-functions.html)). SD low selects Land on this channel ([ground-station.md](ground-station.md) SD row). |
| 7 | CH8 | **Buzzer** (PWM): **SF**, `weight: +100` | **Handset blip:** `customFn` in **`model01.yml`** plays **Bp1** on **SF2** (momentary pressed), **L3**, and **!L3** -- short sound when you start the arm gate and when armed state toggles. **FC:** leave **`RC8_OPTION = 0`** here; ArduPilot still uses the aircraft buzzer for its own tones (**NTF_***). Do **not** map **30** (Lost vehicle sound) to SF -- that alarm runs while the channel stays high. |
| 8 | CH9 | **VTX** (**SA**) plus **VTX On** (`MAX` REPL when **`L3`**) | **`RC9_OPTION`** = **Relay4** (numeric **36** in Copter **4.6.3**; confirm in MP). Matches **`RELAY4_PIN = 83`**. |

### Arm / disarm on CH5

Mission Planner **Arm/Disarm** options: **41** (legacy), **153** (Copter 4.2+, no [AirMode](https://ardupilot.org/copter/docs/airmode.html) coupling from the arm switch), **154** (with AirMode on the arm switch in ACRO/Stabilize). For **Copter 4.6.3** this build uses **`RC5_OPTION = 153`** unless you deliberately want **154**. **`L3`** is the sticky latch from **`logicalSw`** in **`model01.yml`** (see table note above).

**Arm gate in YAML (`logicalSw`):** first entry **AND** `SE2,SF2`; second **AND** `SE0,SF2`; third **STICKY** with `def: "L1,L2"` (feeds **`L3`** to mixes). **`switchWarning`** at end of file: SA up, SB down, SD up, SE up.

**Relay (already in param):** `RELAY4_PIN = 83`, `RELAY4_FUNCTION = 1` (Lucid HD VTX BEC).

**Still default in `rekon10-ardupilot.param`:** `RC5_OPTION` through `RC9_OPTION` are **0**. In **Full Parameter List** set **`RC5_OPTION = 153`**, **`RC7_OPTION = 18`** (Land on **SD** / **CH7**), **`RC9_OPTION = 36`** (Relay4). **`FLTMODE_*`** for **SB** is already in the export. Re-export **`rekon10-ardupilot.param`** after **Write Params**. Repo **`.gitattributes`** uses **`text eol=crlf`** for this file so Mission Planner exports on Windows do not create line-ending-only diffs.

### ELRS telemetry on the radio

Telemetry keys and screens live in **`model01.yml`** (e.g. **RSNR**, **FM**, RSSI/LQ fields). [ground-station.md](ground-station.md) describes the ELRS profile and handset setup.

## Compass and GPS (M100)

* `COMPASS_ORIENT = 6` (**Yaw270**)
* `GPS1_TYPE = 1`, `GPS1_RATE_MS = 200`

This section refers to the **HGLRC M100 Pro** module on this airframe: bench USB tests have shown a non-RTK **3D fix** and successful compass calibration, but FC wall-clock / RTC time is still not set from GNSS in this setup. Details: [flight-platform-build-log.md](flight-platform-build-log.md).

## Battery monitoring

**Where:** Same Mission Planner **Config** > **Full Parameter List** as the RC section.

* `BATT_MONITOR = 4`
* `BATT_VOLT_MULT = 10.8903`
* `BATT_CAPACITY = 8000`

Tune **`BATT_*`** low/critical/arm and **`MOT_BAT_*`** for the **6S Li-ion** pack (many entries may still be default **0** in the export); **Write** and re-export **`rekon10-ardupilot.param`** when done.

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
* If you only care when an arm attempt fails: **`ARMING_OPTIONS`** bit **1** can change when messages are sent (see same doc).

**Parameters:** **`ARMING_CHECK`** selects which checks run (bitmask). **`ARMING_SKIPCHK`** can skip specific failures for bench only -- [doc warns](https://ardupilot.org/copter/docs/common-prearm-safety-checks.html#disabling-the-pre-arm-safety-check) against flying with checks disabled.
