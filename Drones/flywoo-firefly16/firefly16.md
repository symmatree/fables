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

**USER2 / PINIO polarity:** `pinio_config = 1` (inverted) on the Flywoo Goku F405S AIO.
Default pin state (USER2 not active) = HIGH = 9V rail on. USER2 active = LOW = 9V
rail cut. So low channel value (SA toward pilot) activates USER2 and cuts VTX power.
The arm gate overrides CH9 high while armed, keeping VTX on regardless of SA position.

### FLYWOOF405S_AIO: default pin map and 9V PINIO

Official Betaflight board config (no PINIO lines; note **`PC8` is `MOTOR8`** in the stock timer map):

* [Betaflight `configs/FLYWOOF405S_AIO/config.h` (browse)](https://github.com/betaflight/config/blob/master/configs/FLYWOOF405S_AIO/config.h)
* [same file raw](https://raw.githubusercontent.com/betaflight/config/master/configs/FLYWOOF405S_AIO/config.h)

* [ArduPilot `FlywooF405HD-AIOv2/hwdef.dat`](https://github.com/ArduPilot/ardupilot/blob/master/libraries/AP_HAL_ChibiOS/hwdef/FlywooF405HD-AIOv2/hwdef.dat) (**`PB5`** **PINIO1**, **`PC8`** **PINIO2** in that file)

* [iNavFlight/inav#10716](https://github.com/iNavFlight/inav/issues/10716), [IntoFPV: Flywoo Goku F405 HD 9V VTX switch](https://intofpv.com/t-flywoo-goku-f405-hd-9v-vtx-switch-issue)

* [Oscar Liang: GOKU F405 1-2S 12A AIO build](https://oscarliang.com/flywoo-goku-f405-2s-aio-fc-v2-3inch-toothpick-build/)

**CLI: free `PC8` from Motor 8, assign PINIO2, keep USER1/USER2 box mapping**

**Observed (bench):** **USER2** / **SA** and **AIR MODE** / **SD** match Modes as intended (**USER2** on with **SA** toward pilot, off when away). **9V** to the VTX did not cut when **USER2** was on -- treat as **PINIO / hardware**, not radio mapping.

Snippet file (paste into Betaflight Configurator CLI, check for errors, reboot so resources apply): [`config/vtx-9v-pinio-apply.cli`](config/vtx-9v-pinio-apply.cli).

After reboot, run **`resource show all`** and find the line for pin **`C08`** (format is `C08: <owner>`). It should be **`PINIO 2`**. Betaflight does not print a separate **`MOTOR 8`** line; freeing **`resource MOTOR 8 NONE`** shows up as **`C08`** no longer being a motor output. Modes tab should still use **USER2** on **AUX5** with **900--1200 us** for cut when disarmed (see table above). If **9V** sense is inverted vs **USER2**, adjust **`pinio_config`** (Betaflight docs).

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
