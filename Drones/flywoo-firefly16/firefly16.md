# Flywoo Firefly16

[GOKU F405 HD 1S 5A ELRS AIO V2.0 For DJI O4 / walksnail / HDZero](https://flywoo.net/products/goku-f405-hd-1s-1s-5a-elrs-aio-for-dji-o4-walksnail-hdzero)

8MB of Betaflight Blackbox onboard storage.

Onboard 4in1 ESC. 5A continuous, 8A peak

## Firmware

ESC firmware	
O_H_5_48KHz_V0.19.hex Bluejay firmware


App 2025.12.2
Firmware 4.5.1 BTFL
Target: FLWO/FLYWOOF405S_AIO(STM32F405)

* Binding phrase set through Wifi, successfully bound

## EdgeTX model and channel mapping

EdgeTX model file: [`../rekon10/config/MODELS/model02.yml`](../rekon10/config/MODELS/model02.yml), ELRS Receiver Number **16**, Link Mode **Normal (CRSF)**. Boxer-wide settings (e.g. stick calibration, `currModel`): [`../rekon10/config/RADIO/radio.yml`](../rekon10/config/RADIO/radio.yml).

The Firefly16 and Rekon10 share a common switch layout on the Boxer. See the [ground-station docs](../rekon10/ground-station.md) for the multi-model management overview (binding phrase, Receiver Number, Model Match).

**ELRS profile (Receiver Number 16, configured via Lua script on the Boxer):**

| Setting | Value | Notes |
|---------|-------|-------|
| Packet Rate | 250 Hz | Sufficient for Betaflight |
| Telem Ratio | 1:8 | Betaflight needs less telemetry than ArduPilot |
| Switch Mode | Hybrid | 8 channels, good resolution |
| Link Mode | Normal (CRSF) | Standard Betaflight protocol |
| Model Match | OFF (enable after first bind) | Locks receiver to Receiver Number 16 |
| Dynamic Power | ON | Reduces power when close, ramps up as needed |

**Channel mapping (CRSF AETR):**

| Channel | Source | Betaflight AUX | Function |
|---------|--------|---------------|----------|
| CH1 | Roll / Aileron (right horiz) | -- | Stick axis |
| CH2 | Pitch / Elevator (right vert) | -- | Stick axis |
| CH3 | Throttle (left vert) | -- | Stick axis |
| CH4 | Yaw / Rudder (left horiz) | -- | Stick axis |
| CH5 | Arm (L3 sticky gate) | AUX1 | ARM mode |
| CH6 | Flight mode (SB 3-pos) | AUX2 | ANGLE / HORIZON / ACRO |
| CH7 | Airmode (SD) | AUX3 | AIR MODE |
| CH8 | Buzzer warning (SF raw) | AUX4 | BEEPER |
| CH9 | VTX power (SA, gated on arm) | AUX5 | USER2 (PINIO -- 9V rail) |

## Betaflight configuration

Configured in Betaflight Configurator over USB. **`diff all`:** [`config/BTFL_cli_FIREFLY-WH16_FLYWOOF405S_AIO.txt`](config/BTFL_cli_FIREFLY-WH16_FLYWOOF405S_AIO.txt). Factory snapshot: [`config/factory-diff-all.txt`](config/factory-diff-all.txt).

### Modes tab

All mixes use `weight: -100` so the CRSF channel convention is: toward
pilot = low (~1000 us), away = high (~2000 us). See ground-station.md for
the raw switch behavior on the Boxer.

| Mode | AUX channel | Range (us) | Notes |
|------|-------------|-----------|-------|
| ARM | AUX1 (CH5) | 1800-2100 | High = armed (L3 active) |
| ANGLE | AUX2 (CH6) | 900-1200 | SB toward pilot (safe) |
| HORIZON | AUX2 (CH6) | 1300-1725 | SB mid |
| AIR MODE | AUX3 (CH7) | 1800-2100 | SD away = Airmode on |
| BEEPER | AUX4 (CH8) | 1800-2100 | SF held = buzzer sounds |
| USER2 | AUX5 (CH9) | 900-1200 | SA toward = low = USER2 active = 9V off |

ACRO is the default when no angle/horizon mode is active (SB away, no mode range matched on AUX2).

### FLYWOOF405S_AIO: no software-switchable 9V rail (corrected 2026-07)

**The VTX 9V cut does not work on this board, and can't be made to.** The earlier plan -- free `PC8` from Motor 8, drive it as `PINIO2`, and cut the 9V rail from USER2/SA -- was built on a **board mismatch**. Both authoritative pin maps for the FLYWOOF405S_AIO define **no PINIO and no VTX power-enable pin**; `PC8` is just a motor output. Nothing on this board gates the 9V rail, so no config/`resource`/`pinio_config` change cuts it.

* Flywoo's own Betaflight config defines **`PC8` = `MOTOR8_PIN`**, no PINIO: [`configs/FLYWOOF405S_AIO/config.h`](https://github.com/betaflight/config/blob/master/configs/FLYWOOF405S_AIO/config.h) ([raw](https://raw.githubusercontent.com/betaflight/config/master/configs/FLYWOOF405S_AIO/config.h)).
* ArduPilot's hwdef for the **exact** board, [`FlywooF405S-AIO/hwdef.dat`](https://github.com/ArduPilot/ardupilot/blob/master/libraries/AP_HAL_ChibiOS/hwdef/FlywooF405S-AIO/hwdef.dat), also defines **no PINIO** and never references `PC8`; VTX is **USART6 data only** (SmartAudio/MSP, not power).
* The `PB5`=PINIO1 / `PC8`=PINIO2 idea came from a **different** board, [`FlywooF405HD-AIOv2/hwdef.dat`](https://github.com/ArduPilot/ardupilot/blob/master/libraries/AP_HAL_ChibiOS/hwdef/FlywooF405HD-AIOv2/hwdef.dat) (the HD-AIO v2, which *does* have switchable rails). Cross-applying it to the F405S was the error.
* Context / others hitting the same wall: [iNavFlight/inav#10716](https://github.com/iNavFlight/inav/issues/10716), [IntoFPV: Flywoo Goku F405 HD 9V VTX switch](https://intofpv.com/t-flywoo-goku-f405-hd-9v-vtx-switch-issue).

**Bench result (consistent):** USER2 / SA toggled the box correctly but **9V never cut** -- because there is no enable on the rail for any pin to drive. Treat the 9V as **hardware, always-on**. A routed-but-unexposed enable would be all cost and no benefit, so it isn't expected to exist; only a physical solder-jumper on the board's own wiring sticker could hard-disable it (worth an eyeball, not counted on). The apply snippet [`config/vtx-9v-pinio-apply.cli`](config/vtx-9v-pinio-apply.cli) is retained only as a **dead-end record** -- it does not cut power.

**Recovery approach instead (the actual goal -- find this beeper-less micro before the VTX overheats lying in grass):**

* **Motor DShot beacon** -- already configured (`beacon RX_LOST` / `RX_SET`, `beeper_dshot_beacon_tone = 3`): radio off, or the BEEPER switch, chirps the motors while the pack is connected. Free, no weight -- try first. Limits: needs the pack still connected and FC alive; muffled by grass.
* **Self-powered finder buzzer** (own cell, ~100 dB, auto-alarms when it loses main power) for the browns-out / pack-off case the motor beacon can't cover. Needs a `BZ-` + 5V pad -- confirm against *this* board's wiring sticker before soldering.

Contrast [rekon10/ardupilot.md](../rekon10/ardupilot.md): the Lucid board *does* have a relay-switched VTX BEC (`RELAY4`) -- but on rekon10 the 2026-07 finding is that `RELAY4_DEFAULT` must **stay 1**: flipping it to off-at-boot breaks the ELRS boot link (a BEC-enable / GPIO interaction), so it cannot "simply" be defaulted off there.

### Ports tab

From [`config/BTFL_cli_FIREFLY-WH16_FLYWOOF405S_AIO.txt`](config/BTFL_cli_FIREFLY-WH16_FLYWOOF405S_AIO.txt) (`# serial`): **two** UART lines are set for this quad.

```txt
serial 2 64 115200 57600 0 115200
serial 3 131073 115200 57600 0 115200
```

| Port (Configurator) | Role |
|---------------------|------|
| **UART3** | CRSF **Serial RX** to onboard ELRS |
| **UART4** | **MSP** and **VTX MSP** to the HD VTX |

Decode if needed:

* [cli.c](https://github.com/betaflight/betaflight/blob/master/src/main/cli/cli.c) (`cliSerial`, search `legacy configuration where UART1`)
* [serial.h](https://github.com/betaflight/betaflight/blob/master/src/main/io/serial.h) (`serialPortFunction_e`)

### Receiver tab

Protocol: **CRSF** with **Serial-based receiver**. Physical link: **UART3** to the onboard **ELRS** (UART, not SPI). Module **ELRS 3.x**; Boxer **3.6.3** per [ground-station docs](../rekon10/ground-station.md).
