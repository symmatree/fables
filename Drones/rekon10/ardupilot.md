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

Rekon10 ELRS profile is currently **333 Hz Full** with telemetry ratio **1:2** ([ground-station.md](ground-station.md)), which reports about **13211 baud** telemetry throughput budget on the handset. Final RTCM message mix and resulting traffic volume are not designed yet; practical target is to keep RTCM in a low-single-digit kilobaud envelope so MAVLink has comfortable margin on the same link. [rekon-design.md](rekon-design.md), [gps-mount.md](gps-mount.md).

## RC, switches, remaining FC work

**Where to set (Mission Planner):** **Config** > **Full Parameter List** (use search for each name). After editing, **Write Params** to the FC, then **Save to File** and commit **[`config/rekon10-ardupilot.param`](config/rekon10-ardupilot.param)** so git matches the aircraft.

Authoritative EdgeTX layout: **[`config/MODELS/model01.yml`](config/MODELS/model01.yml)**. In that file, **`mixData[].destCh`** is **zero-based output index** (**0** = **CH1** on the wire). Sticks are **I0..I3** on `destCh` **0..3**. Aux mixes:

| `destCh` | Channel | `model01.yml` (mix names / logic) | FC action |
|----------|---------|-----------------------------------|-------------|
| 4 | CH5 | **Arm Lo** (`MAX` ADD `weight: -100`) then **Arm Hi** (`MAX` REPL `weight: 100`, **`swtch: "L3"`**) | Set **`RC5_OPTION = 153`** (Arm/Disarm). **`L3`** is the sticky latch from the third `logicalSw` entry (see below). |
| 5 | CH6 | **FltMod**: **SB**, `weight: -100` | Set **`FLTMODE_CH = 6`**. SB low / mid / high map to **`FLTMODE1` / `FLTMODE4` / `FLTMODE6`** (ArduPilot six-band PWM convention for a 3-pos switch). Current export: **Loiter (5) / AltHold (2) / Sport (13)** toward-to-away to match safe-to-manual semantics (not the Betaflight ANGLE/HORIZON/ACRO labels on the switch silk). Human-readable switch labels are in [ground-station.md](ground-station.md) (SB row). |
| 6 | CH7 | **Land**: **SD**, `weight: -100` | Set **`RC7_OPTION`** to **RTL** or **Land** (or another return option) using the **dropdown** in Mission Planner for that parameter -- **CH7** is **SD**; pick one behavior and stick with it ([ground-station.md](ground-station.md) SD row). |
| 7 | CH8 | **Buzzer**: **SF**, `weight: +100` | Mostly radio-side: `customFn` plays **Bp1** on **SF2**, **L3**, and **!L3** in the same YAML. Add an FC option only if you need ArduPilot to react on CH8. |
| 8 | CH9 | **VTX** (**SA**) plus **VTX On** (`MAX` REPL when **`L3`**) | Set **`RC9_OPTION`** to **Relay4** in the MP dropdown (numeric is **36** in Copter **4.6.3**; confirm in your build). Matches **`RELAY4_PIN = 83`**. |

**Arm gate in YAML (`logicalSw`):** first entry **AND** `SE2,SF2`; second **AND** `SE0,SF2`; third **STICKY** with `def: "L1,L2"` (feeds **`L3`** to mixes). **`switchWarning`** at end of file: SA up, SB down, SD up, SE up.

**Relay (already in param):** `RELAY4_PIN = 83`, `RELAY4_FUNCTION = 1` (Lucid HD VTX BEC).

**Still default in `rekon10-ardupilot.param`:** `RC5_OPTION` through `RC9_OPTION` are **0**. Apply the table above in **Full Parameter List**: **`RC5_OPTION = 153`** (Arm), **`RC7_OPTION`** = RTL or Land (your choice from dropdown), **`RC9_OPTION`** = Relay4 (see row above). **`FLTMODE_CH`** and **`FLTMODE1` / `FLTMODE4` / `FLTMODE6`** are already set for **SB**; **SB** is flight modes only -- **SD** on **CH7** is **`RC7_OPTION`** only. Re-export **`rekon10-ardupilot.param`** after changes. Repo **`.gitattributes`** forces **`text eol=crlf`** for this file so Windows Mission Planner exports do not create line-ending-only diffs.

### ELRS telemetry fields on the radio (`model01.yml`)

Telemetry entries currently present in the Rekon10 EdgeTX model, with matching telemetry screens:

- `1RSS`: Receiver antenna/path 1 RSSI, reported in dBm.
- `2RSS`: Receiver antenna/path 2 RSSI, reported in dBm.
- `RQly`: Receiver-side link quality (percent).
- `RSNR`: Receiver-side signal-to-noise estimate (dB-class SNR metric).
- `TRSS`: Transmitter-side RSSI (radio module view), reported in dBm.
- `TSNR`: Transmitter-side signal-to-noise estimate (TX side view).
- `TQly`: Transmitter-side link quality (percent).
- `TPWR`: Current transmitter output power level.
- `ANT`: Active/selected antenna or diversity state indicator.
- `RFMD`: RF mode / packet-rate mode indicator currently in use.
- `FM`: Reported flight mode value exposed through telemetry.

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
