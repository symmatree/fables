# ArduPilot configuration (Rekon10)

[Back to index](README.md) | [Flight platform hardware](flight-platform.md) | [Ground station / radio](ground-station.md)

FC-side settings for the **TBS Lucid H7** build. The FC is the source of truth for values; this doc is the **rationale and wiring context**.

**Config now lives in the coordinator repo, decomposed by subsystem:** coordinator [`ardupilot/`](https://github.com/symmatree/coordinator/blob/main/ardupilot/README.md) holds the ground-truth Mission Planner export (`rekon10-methodi.param`) plus [`inputs/*.param`](https://github.com/symmatree/coordinator/blob/main/ardupilot/inputs) -- one commented fragment per subsystem, overrides only, each param carrying its rationale and provenance. **Those fragments are authoritative for the actual values;** the tables and `PARAM = value` mentions in this doc are for context and can lag -- when they disagree, trust the fragment. Section pointers below name the specific fragment.

Handset and ELRS profile (Boxer, rates, Model Match, switch table): **[ground-station.md](ground-station.md)**. EdgeTX model export: **[`config/MODELS/model01.yml`](config/MODELS/model01.yml)** (**Rekon10**, model id **10**).

Firmware: **Copter 4.7.0** `arducopter_with_bl.hex` for **TBS_LUCID_H7** from `https://firmware.ardupilot.org/Copter/stable-4.7.0/TBS_LUCID_H7/arducopter_with_bl.hex` (upgraded from 4.6.3 on 2026-07-27).

## Frame

* `FRAME_CLASS = 1` (Quad)
* `FRAME_TYPE = 1` (X)

## Serial ports

Values: [`inputs/20-serial.param`](https://github.com/symmatree/coordinator/blob/main/ardupilot/inputs/20-serial.param). Wiring: [flight-platform.md](flight-platform.md). The table below is the wiring map for context; the fragment is authoritative for `PROTOCOL` / `BAUD`.

| Port | Parameters | Wired |
|------|------------|--------|
| SERIAL0 | `PROTOCOL = 2`, `BAUD = 115` | USB |
| SERIAL1 | `PROTOCOL = -1` | Unused |
| SERIAL2 | `PROTOCOL = 5`, `BAUD = 115` | Holybro F9P Rover Lite -- sole GNSS on the mast (UART + I2C compass). Was M100 Pro on this same port. |
| SERIAL3 | `PROTOCOL = 42`, `BAUD = 115` | Walksnail MSP (TX3/RX3 only; VTX power is other FC pads, not UART3) |
| SERIAL4 | `PROTOCOL = 2`, `BAUD = 1500` | Coordinator (Pi 4B, VIO) -- MAVLink2 companion link, now cabled (1.5 Mbaud) |
| SERIAL6 | `PROTOCOL = 2`, `BAUD = 460` | Matek ELRS R24-TD (see [ground-station.md](ground-station.md); `model01.yml` header `modelId` **10**) |
| SERIAL7 | `PROTOCOL = -1` | Unused |
| SERIAL8 | `PROTOCOL = 16` | ESC ribbon |
| SERIAL9 | `PROTOCOL = 2`, `BAUD = 115` | Unused |

*Wiring resolved 2026-07 from the recorded pigtail pads + the param export ([`ardupilot/`](https://github.com/symmatree/coordinator/blob/main/ardupilot/README.md) in coordinator), which agree with the [flight-platform.md](flight-platform.md) table. An earlier plan to move the F9P to SERIAL7 was abandoned -- it stayed on SERIAL2 (the old M100 port), and SERIAL7 is unused.*

**SERIAL2 (F9P):** Sole GNSS on the mast -- Holybro F9P Rover Lite. `SERIAL2_BAUD = 115200` in the export; **460800** was the earlier SparkFun-breakout plan, not a promise for Rover Lite. `GPS1_COM_PORT` follows this UART.

### RTCM / RTK

Profile and headroom: [ground-station.md](ground-station.md), [rekon-design.md](rekon-design.md).
Corrections delivery path and the leading no-RTK-failure theory: coordinator [`docs/rtk-corrections-path.md`](https://github.com/symmatree/coordinator/blob/main/docs/rtk-corrections-path.md).

## ESC (AM32, Lucid 4in1)

Hardware and target name: [flight-platform.md](flight-platform.md#esc). ArduPilot side:

* **DShot:** [Pass-through](https://ardupilot.org/copter/docs/common-blheli32-passthru.html) to **AM32** (web **[am32.ca](https://am32.ca/)** or desktop) requires the autopilot to use a **DShot** motor protocol (**`MOT_PWM_TYPE`**, not normal PWM). Without DShot, you may get a link to the configurator but **not** reliable per-motor access.
* **Passthrough:** **`SERVO_BLH_AUTO = 1`** turns on pass-through for outputs already set as **Motor1..Motor4** (**`SERVO1_FUNCTION`**..**`SERVO4_FUNCTION`** on a quad). Reboot after changing **`MOT_PWM_TYPE`** / **`SERVO_BLH_AUTO`**. Follow the wiki order: props **off**, flight battery **on**, safety switch as configured, **disconnect Mission Planner** (USB stays), then open the ESC tool.
* **Telemetry:** The **TBS FC--ESC harness** includes a **UART** to the FC as **`SERIAL8`** (**`SERIAL8_PROTOCOL = 16`** ESC telemetry in the export; **`SERIAL8_BAUD`** typically **115** = 115200). That line is for **telemetry** (and passthrough to AM32), separate from the **four DShot** motor command paths in the same harness.
* **Bench alternative:** Mission Planner **Initial Setup** / **Optional Hardware** / **Motor Test** (props off, follow prompts) to check spin order and direction once checks allow.

NOTE: Once you remap the servo/motor mappings using SERVO1_FUNCTION - SERVO4_FUNCTION, that changes the order IN THE AM32 CONFIGURATOR as well as in ardupilot. (We are connecting through the FC passthrough so the actual ESC we are talking to is changed as a result of that mapping.) If you try to treat the AM32 as using the physical numbering from the ESC you will be VERY confused.


### Choices (flight impact, not just passthrough)

**`MOT_PWM_TYPE`** sets how the FC drives the ESCs **on every armed flight**, not only during AM32 sessions. **Normal PWM** (**0**) avoids DShot but breaks the [passthrough](https://ardupilot.org/copter/docs/common-blheli32-passthru.html) workflow and is a poor match for **AM32** on this stack. **DShot** gives digital throttle commands (no classic PWM endpoint calibration), predictable timing, and access to ESC tooling.

| Choice | Recommendation | Why |
|--------|----------------|-----|
| DShot rate | **DShot600** first; **DShot300** if you ever see ESC sync or noise issues | **600** is the usual default for **4in1** + AM32: fast enough for control, widely stable. **300** is slightly more conservative on marginal wiring. |
| **`SERVO_BLH_AUTO`** | **1** while using the AM32 / BLHeli passthrough path; **0** for day-to-day flight once ESC settings are saved | **AUTO** gates **passthrough** to the PC; **DShot** itself comes from **`MOT_PWM_TYPE`**, not from this flag. |
| Motor direction | **`SERVO_BLH_RVMASK`** in ArduPilot **or** direction in AM32 (not both fighting) | Same physics as BF: wrong direction means wrong torque in stabilize. Fix before props on. |
| **Pole count** | **`SERVO_BLH_POLES`** = your **motor** pole count (export shows **14** -- confirm on the motor datasheet) | Wrong poles skew **eRPM** / telemetry and **harmonic notch** if fed from ESC RPM. |
| RPM into ArduPilot | **UART only** -- **`SERIAL8`** ESC telemetry. Keep **`SERVO_BLH_BDMASK = 0`** | **Bi-directional DShot** is an **optional** alternate RPM path on the motor wires; you do **not** need it if UART telemetry works. Avoid turning on **both** without a reason. The [IMU harmonic notch](https://ardupilot.org/copter/docs/common-imu-notch-filtering.html) is now **on and tuned** off this ESC-RPM feed (**`INS_HNTCH_ENABLE = 1`**, `MODE = 3`, `FREQ = 58.8`, 1st harmonic; done post-hover over the May 31 - Jun 10 notch flights below). See [`inputs/50-esc-motors-notch.param`](https://github.com/symmatree/coordinator/blob/main/ardupilot/inputs/50-esc-motors-notch.param). |

**Design record:** **`MOT_PWM_TYPE`** = **DShot600** (baseline). RPM for logging / notch from **`SERIAL8`** unless you later prove UART is insufficient and switch deliberately.

All **`MOT_PWM_*`**, **`SERVO_BLH_*`**, **`SERIAL8_*`**, motor **`SERVO*_FUNCTION`**, and the harmonic-notch set: **[`inputs/50-esc-motors-notch.param`](https://github.com/symmatree/coordinator/blob/main/ardupilot/inputs/50-esc-motors-notch.param)** (motor endpoints in [`62-radio-cal.param`](https://github.com/symmatree/coordinator/blob/main/ardupilot/inputs/62-radio-cal.param)).

## RC and FC aux mapping

**Which switch maps to which RC channel** (and EdgeTX **`destCh`** indexing): **[ground-station.md](ground-station.md)** and **[`config/MODELS/model01.yml`](config/MODELS/model01.yml)**. This section is **FC parameters only** -- no duplicate of the RadioMaster / EdgeTX mix table.

**Why Land on SD, not RTL:** much of this flying is **under canopy** and near **structure**. **RTL** means climb-then-go-home and is **actively dangerous** in that environment unless you have planned for **open sky**, a **safe home**, and **clearance above obstacles**. **SD** / **CH7** is **Land** only (**`RC7_OPTION = 18`**). Use **RTL** only when you have explicitly chosen that path (for example open-field work or a failsafe policy you have deliberately set and tested), not as the default "get out" on this switch.

| Channel | FC parameters |
|---------|-----------------|
| CH5 | **`RC5_OPTION = 153`** (arm/disarm on latch **L3**; gate and mixes in [ground-station.md](ground-station.md) / **`model01.yml`**) |
| CH6 | **`FLTMODE_CH = 6`**. **`FLTMODE1` / `FLTMODE4`** = **Loiter (5) / AltHold (2)** toward-to-away on **SB** ([ground-station.md](ground-station.md)); AltHold is the preferred degraded-VIO fallback. `FLTMODE6` is currently **0 (unbound)** -- was Sport, unbound with autotune mode on 2026-06-19. |
| CH7 | **`RC7_OPTION = 18`** (**LAND Mode** on **SD**; [aux functions](https://ardupilot.org/copter/docs/common-auxiliary-functions.html)). |
| CH8 | **`RC8_OPTION = 30`** (*Lost vehicle sound*: **GEPRC** / FC buzzer **while CH8 is high**, i.e. while **SF** is held for the arm gate). |
| CH9 | **`RC9_OPTION = 36`** (Relay4). **`RELAY4_PIN = 83`**, **`RELAY4_FUNCTION = 1`** (Lucid HD VTX BEC). **`RELAY4_DEFAULT = 0`** (VTX **cold** at power-up -- the bench-heat-friendly state; safe since the 2026-07-27 rail fix, see note below). CH9 / **SA** controls it when disarmed, and the Boxer **arm gate forces CH9 high (VTX on) while armed** ([ground-station.md](ground-station.md)) -- arming powers the VTX, no manual step. |

**`RELAY4_DEFAULT = 0` -- ELRS boot interaction, RESOLVED 2026-07-27.** `RELAY4_DEFAULT` is the relay's startup state (**0 = Off, 1 = On, 2 = No change**). `0` leaves the VTX cold at boot -- the state we want for bench heat. There *used* to be a hard blocker here: with `RELAY4_DEFAULT = 0` the Matek R24-TD would fail to acquire the handset and drop into **WiFi / web-config mode within a few seconds** of power-up. It was cleanly isolated to this one parameter (antennas untouched between failing and working boots), so it was real -- but the cause was the RX witnessing a **5 V-rail boot transient**, not the relay logic. **The fix (hardware): move the ELRS RX VCC from the 5 V rail to 4V5**, isolating it from that transient. A `RELAY4_DEFAULT = 0` boot now brings the RX up cleanly -- links, respects the VTX switch, no web-flash -- **scope/bench-verified 2026-07-27**. So `RELAY4_DEFAULT = 0` is the correct, current value and the old "must stay 1" workaround is retired. Debug ledger: `facts/claude-transcripts/2026-07/2026-07-27-120208-electrical/electrical-debugging.md` ("G1 RESOLVED"); as-built rails in [flight-platform.md](flight-platform.md). Value: [`inputs/60-rc-modes-relay.param`](https://github.com/symmatree/coordinator/blob/main/ardupilot/inputs/60-rc-modes-relay.param).

The arm-gate mix in [`config/MODELS/model01.yml`](config/MODELS/model01.yml) **forces CH9 high (VTX on) whenever armed** (via the L1-L3 latch; [ground-station.md](ground-station.md)), so flight is unaffected regardless of the boot default -- arming powers the VTX and it can't drop mid-flight.

Notes:

- **Bench heat:** `= 0` brings the VTX up cold (the friendly bench state). When it *is* energized, **radio on, SA toward-safe** drives Relay4 off ([ground-station.md](ground-station.md)), or put **airflow** on the VTX for longer sessions.
- **Polarity confirmed:** switch off -> goggles go black, on -> VTX top gets hot, so `RELAY4_INVERTED = 0` is correct and `= 0` really does de-energize.
- **Mechanism (now supported).** The failure was at ELRS **RF link-acquisition** -- architecturally independent of the FC serial and the VTX rail, so the "separate" 5 V (ELRS) and switched 9 V (VTX) rails must have shared a boot transient. Runtime Relay4 toggling never disturbed ELRS; only the boot default did. Picture: through the ~1-2 s early-init window GPIO 83 sits in its power-on-reset state before ArduPilot asserts `RELAY4_DEFAULT`; the 9 V BEC caps charge then **dump** when the relay is asserted off, and the coupled **dip on the 5 V / RX rail** landed in the RX's acquisition window (counted as rapid power-cycles -> enter WiFi). Moving the RX to 4V5 took it off that rail -- which is why the rail move fixed it, consistent with the transient picture.

**`RELAY2_DEFAULT` / `RELAY3_DEFAULT`** (pins 81/82) are still **1** and undocumented here -- left alone, but they also come up energized at boot.

### ELRS telemetry on the radio

Telemetry keys and screens live in **`model01.yml`** (e.g. **RSNR**, **FM**, RSSI/LQ fields). [ground-station.md](ground-station.md) describes the ELRS profile and handset setup.

## Compass and GPS (Holybro F9P Rover Lite)

* `GPS1_TYPE` / `GPS1_COM_PORT` / `SERIAL2_*`: match bench and FC wiring (RTK integration threads -- bench-baud thread **A**, tracker not yet written).
* `COMPASS_*`: integrated compass on the F9P I2C bus; `COMPASS_ORIENT` after outdoor cal (**E**). M100-era **Yaw270** / `COMPASS_ORIENT = 6` in export is **historical** only.

**Wall clock / RTC:** Do not rely on ArduPilot learning UTC from this GNSS path alone (same class of issue as M100 bench -- [flight-platform-build-log.md](flight-platform-build-log.md)). Payload cameras use the shared **DS3234** SQW PPS ([arm-pods.md](arm-pods.md), [central-hub.md](central-hub.md)); steering that RTC from GNSS time when fixes are good is a separate integration task.

## Battery monitoring

Mission Planner **Initial Tune** (with **6S Li-ion** selected) set most **`BATT_*`** metering and voltage thresholds. Full **`BATT_*`** / **`MOT_BAT_*`** set: **[`inputs/70-battery.param`](https://github.com/symmatree/coordinator/blob/main/ardupilot/inputs/70-battery.param)**. Battery monitor is **ESC telemetry (`BATT_MONITOR = 9`)** off a calibrated AM32 build (the FC analog current input is arc-blown); details in [flight-platform.md](flight-platform.md).

**Failsafe actions (operator choice, not Initial Tune):** **`BATT_FS_LOW_ACT = 1`** (**Land** on low pack) and **`BATT_FS_CRT_ACT = 1`** (**Land** on critical) -- Land is the correct action under canopy (RTL is not). Low uses **`BATT_LOW_VOLT`**; critical uses **`BATT_CRT_VOLT`**. (`BATT_LOW_TIMER = 0` in the current export.)

**From the current export (Initial Tune thresholds):** **`BATT_ARM_VOLT = 19.2`**, **`BATT_LOW_VOLT = 18.6`**, **`BATT_CRT_VOLT = 18`** (about **3.18 / 3.10 / 3.00 V per cell** on **6S**). Those are a **reasonable first pass** for Li-ion; **`BATT_CRT_VOLT = 18`** is toward the **low** end for sustained load on some packs. If the FC hits **critical Land** earlier than you expect under sag, raise **`BATT_CRT_VOLT`** slightly (and re-export) rather than fighting it in the air.

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
* **Compass cal:** Onboard F9P compass after mast mount (tracker **E**).
* **ELRS RX:** Match Boxer (**3.6.3** per [ground-station.md](ground-station.md)). [ExpressLRS web flasher](https://expresslrs.github.io/web-flasher/).
* **Walksnail VTX:** Match goggles (e.g. **39.44.5**).
* **AM32 ESC:** **## ESC (AM32, Lucid 4in1)** above; [AM32 firmware repo](https://github.com/am32-firmware/AM32).

### Pre-arm: Mission Planner UI vs ArduPilot (Copter)

Mission Planner **Initial Setup** / **wizard** text is **shared across vehicle types** and often mentions **ailerons**, **elevator**, **rudder**, or other **fixed-wing** steps. **Ignore that** for this **Copter** quad -- it is not your checklist.

**What actually blocks arming** comes from **ArduPilot Copter**, not that screen. With USB or telemetry connected:

* **Flight Data** tab -- **Messages** (or the scrolling message area on the HUD). Look for **`PreArm:`** / **`Arm:`** / **`STATUSTEXT`** lines (GPS, EKF, compass, RC cal, battery, throttle, fence, etc.). While disarmed, failing checks are often repeated about every **30 s** (see [Pre-Arm Safety Checks](https://ardupilot.org/copter/docs/common-prearm-safety-checks.html) -- message/cause/solution table for **Copter**).

**Checks:** **`ARMING_CHECK`** bitmask; **`ARMING_SKIPCHK`** is for bench only -- [doc](https://ardupilot.org/copter/docs/common-prearm-safety-checks.html#disabling-the-pre-arm-safety-check).

## Tuning

### Logs

HQProp 3-bladed props were fine with the default tune, the only downside was a "chirp" on certain attitude changes. This is the 5/29 6pm flight.

Airscrew 2-bladed props showed substantial oscillation in stabilize mode, visible and audible. This is the 5/31 morning flight.

Reverting INS filter settings to [this commit](https://github.com/symmatree/fables/commit/7553a7698d2c789b8b7906041552deec3c3070be) got me back to slightly chirpy flight, still with the two-bladed prop. This is the 5/31 afternoon flight.

----

Subsequent 2-bladed flight lost control and crashed; follow-up (perhaps with
loose prop) spin in flat circles until it completely augured in and broke a
2-bladed prop, so we're back to the 3-bladed HQProp ones again.

----

26-06-08

Steady hover flight, althold and loiter:

* Checked RATE outputs for oscillation per [methodic](https://ardupilot.github.io/MethodicConfigurator/TUNING_GUIDE_ArduCopter.html#711-check-for-motor-output-oscillation)
* Ditto the RATE Des (desired) no visible oscillations
* The ESC RPM values are pretty clean, they hunt up and down a little but it doesn't look like oscillation as such.
* Motor temps seem fine; starting around 35 degrees and slowly going up to 50C (122F)
* One weird thing: two motors are about 5300 RPM and two are at maybe 6100. I suspect this is fore/aft imbalance forcing uneven speeds to stay level.
* PM group: Zero long loops, rock solid at 400 Hz main loop rate.
* VIBE: VibeX is 3-6, VibeY is 2-5. VibeZ is 3-6 except a big spike at touchdown during landing. The guidance from [methodic docs](https://ardupilot.github.io/MethodicConfigurator/TUNING_GUIDE_ArduCopter.html#81-notch-filter-calibration) is 

> According to common ArduPilot forum knowledge, and quoting @xfacta:
> Vibrations over 30 are very bad
> Vibrations over 20 are causing issues even if you don’t know it yet
> Vibrations over 15 are in a grey area - it could go either way - check clipping, it must be zero
> Vibrations below 10 are good

![initial results](init-260608-notch.png)

> Use as little notch filter bandwidth and attenuation as possible. Noise levels below -50dB are considered good enough. Do not use notch filters to reduce noise below that level as it introduces unwanted signal lag.

So we start below 50 dB except for a couple of spikes, and after filtering we are substantially below. We could probably drop the second set of notches and only do the primary harmonic but maybe not. Anyway our out of the box filter
on first and second harmonic does just fine.

### Single Notch, Loop rate

Switching to a single notch but increasing to evaluate a loop rate (updating the notch at 400 Hz rather than at 200 Hz or something) is still really nice and hopefully lower latency. It held up with some control twitches - at roughly the same total energy input, but twitching the loiter target back and forth horizontally, and commanding a flat spin. Gemini argues for a vertical climb test to get the RPM up into the 15k range where the primary motor harmonic would overlap with its guess of a 250 Hz and 310 Hz frame resonance (based on the higher motor harmonics being smeared out somewhat below and above their natural rates).

![Vibration from accel](1-notch-vibe.png)

Very low; under 10 was simply "good" with no further comment, versus nuanced descriptions above that.

![Rates](1-notch-rates.png)

No oscillation visible in the rates, you can clearly see my commanded twitches in the second half of the flight. 

![RPM](1-notch-rpm.png)

Still a systemic gap between (0, 1) and (2, 3) which I think is just an off-center weight fore and aft.


-----

QuickTune pass one. Strictly reduced a few values from the initials.
Checked in as commit 27edae822d4aea576cf6c345b62af4b5aa400256. Was a pretty
still day but the failure mode from not enough wind is supposed to be too aggressive a tuning not too cautious a one, so I think this is reasonably clean. I suspect what happened is that it tried to increase each one, decided it was a failure, and dropped by the target percentage which ended up slightly below where it started. which I'm fine with.

Note that it didn't really "do" anything, basically just hovered there, whined a little, and moved on with updates in Messages.

----

Autotune cycle 1:

### Roll

Tests:

* The resulting ATC_ANG_RLL_P parameter value is smaller than 4.5
* The resulting ATC_RAT_RLL_D parameter value is equal to the AUTOTUNE_MIN_D parameter value (AUTOTUNE_MID_D = 0.0005)

Results

* ATC_ANG_RLL_P,18.37906 (up from 4.5)
* ATC_RAT_RLL_D,0.004112592 (up from 0.0031)
* ATC_RAT_RLL_I,0.08487533 (down from 0.101)
* ATC_RAT_RLL_P,0.08487533 (down from 0.101)
* ATC_ACCEL_R_MAX,127035.2 up from 116700

Both Roll checks pass, D is 10x the min value, no reason to disbelieve this.


----

### Vertical bounce

I refuse to call it a "punchout". Attempted settings: 
max v accel to 2.5 m/s2 and max speed at 10 m/s, so it would wind up to full throttle.
Over 12s it climbed from 1m to 78.5m, average speed of 6.45 m/s.
Throttle rose from 0.12 to a peak of 0.35 about halfway through the climb, then I backed out of it then rolled back in to a second peak of 0.31. Last 18m or so of climb were after the throttle was dropping quickly toward idle.

![Vertical bounce graphs](260613-vertical-bounce.png)

Over just that climb period, the motor fundamental frequency rose to peaks of ~154 Hz and then 148 Hz on the second lower spike, from a hover at about 100 Hz. Notch tracks the noise really nicely. The second harmonics are visible but dimmer. It seems like there's more distributed noise until the throttle starts to climb, then it converges on a few sharper lines.

VibeX got up to 15 a few times but no clipping.

Limited to just the climb period where the rising throttle swept the fundamental frequency up 50 Hz, post-filter noise highest peak is -75 dB, oddly for the Y channel in particular. So even during this aggressive climb it was still at quite desirably low levels of noise.

### Pitch tuning

I completed this but switched modes before landing, which seems to have lost it. I could recover
it from the logs I think, or I'll just re-run in the still air tomorrow morning if it doesn't rain.

Second iteration:

* ATC_ACCEL_P_MAX,138192.4 from 116700
* ATC_ANG_PIT_P,23.45685 from 4.5
* ATC_RAT_PIT_D,0.004828416 up slightly from 0.0035
* ATC_RAT_PIT_I,0.04900767 down from 0.10125
* ATC_RAT_PIT_P,0.04900767 down from 0.10125

This sets off none of their red flags in [the section](https://ardupilot.github.io/MethodicConfigurator/TUNING_GUIDE_ArduCopter.html#952-pitch-axis-autotune). They say the quality of the tune is proportional to the ATC_ANG_RLL_P, ATC_ANG_PIT_P, and ATC_ANG_YAW_P parameters for their respective axis and that's the 23.4, so I won't worry that RAT I and P are less than for roll. This could also just reflect that it's much easier to roll than to pitch, just from the weight distribution.

---

### Yaw tuning

ATC_ANG_YAW_P is barely over their 4.5 cap but I'm okay with that. other values tightened up.

probably should rerun but not now. I ran YawD for giggles, it also set some values.

### Retune and overall

It all seems fine? final values aren't the defaults and aren't on the limits for all of them, so nominally it converged. I'm not sure that the "raise X% until oscillation and then drop Y%" doesn't produce a systematic drift if you repeat it, but that's fine.

## EKF3 source mixing (altitude and vertical velocity)

Verified against ArduPilot source (`AP_NavEKF3_PosVelFusion.cpp`, `AP_NavEKF_Source.cpp`).

**Altitude position (`EK3_SRC1_POSZ`) -- hard mutex.** `selectHeightForFusion()` is a strict `if / else if` chain that sets exactly one `activeHgtSource` per tick. Only one sensor's measurement feeds the EKF altitude correction at any moment. Options: `1` = Baro (default), `3` = GPS, `2` = RangeFinder, `6` = ExtNav/VIO. If the active source drops out (GPS timeout, range out of range, etc.) it falls back to Baro automatically. There is no "blend baro and GPS altitude based on quality" path -- pick one.

**Vertical velocity (`EK3_SRC1_VELZ`) -- can fuse multiple simultaneously, but currently doesn't.** `useVelZSource()` returns true for any source that appears in any of the three source sets (SRC1/2/3) **only when** `EK3_SRC_OPTIONS` bit 0 (`FUSE_ALL_VELOCITIES`) is set. **Current config: `EK3_SRC1_VELZ = 3` (GPS), `EK3_SRC_OPTIONS = 8`.** That `8` is **bit 3 (`SRC_PER_CORE`)**, not bit 0 -- bit 0 was briefly `1` but was reverted to `0` in the 4.7.0 upgrade, so multi-source VelZ fusion is presently **off** (only the active set's VelZ fuses). `SRC_PER_CORE` runs each EKF core on a different source set (core 0 = GPS/SRC1, core 1 = VIO/SRC2) so the VIO lane is computed and logged every flight without control -- the coordinator #160 counterfactual. GPS vertical velocity is fused (SRC1 = GPS), gated by `EK3_GPS_VACC_MAX = 0.15 m` (reject GPS VelZ when reported VACC exceeds 0.15 m).

**To add VIO vertical velocity alongside GPS** you would need **both** `EK3_SRC2_VELZ = 6` (ExtNav) **and** `FUSE_ALL_VELOCITIES` (bit 0) set in `EK3_SRC_OPTIONS` -- with bit 0 currently off, setting `SRC2_VELZ` alone would not fuse both. SRC2 velocity is deliberately left off regardless: the VIO lane is **position-only** (velocity-only ExtNav is unsupported upstream). Full source-set config and the VISO/ExtNav tuning: [`inputs/40-ekf-vio.param`](https://github.com/symmatree/coordinator/blob/main/ardupilot/inputs/40-ekf-vio.param) and coordinator [`docs/ardupilot-extnav-fusion.md`](https://github.com/symmatree/coordinator/blob/main/docs/ardupilot-extnav-fusion.md).

**Barometer propwash offset.** In-flight analysis of loiter-around (2026-06-19) shows BARO reads ~1.2 m higher than GPS-normalized altitude during hover, converging toward zero as throttle drops on descent. Cause: low-pressure region under the props inflates the barometer. The offset is systematic (not random noise) and tracks throttle, with std ~0.5 m across the flight. `EK3_ALT_M_NSE = 2.0` accommodates this within the EKF noise budget. Switching `EK3_SRC1_POSZ` to GPS would trade the propwash bias for GPS vertical noise; at RTK float/fixed quality that is likely a better trade for precision altitude work. `EK3_GPS_VACC_MAX` would then gate when GPS altitude is accepted (the same threshold already gates GPS VelZ).