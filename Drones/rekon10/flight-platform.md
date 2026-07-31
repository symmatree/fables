# Flight platform (as-built reference)

[Back to index](README.md) | [Build log](flight-platform-build-log.md) | [ArduPilot configuration](ardupilot.md)

This doc covers Flight stack, power path into the ESC, FPV link hardware, and radio receiver on the airframe. Excludes VIO / coordinator (see [central-hub.md](central-hub.md), [oak-d-mount.md](oak-d-mount.md))

## Frame

**Rekon FPV Rekon10 Pro Long Range Frame Kit - 10"** (fore-and-aft arm struts; not the V2 kit). [GetFPV product page](https://www.getfpv.com/rekon-fpv-rekon10-pro-long-range-frame-kit-10.html). Local graphic: [attachments/Rekon_FPV_Rekon10_Pro_Long_Range_Frame_Kit_-_10_graphic_info.webp](attachments/Rekon_FPV_Rekon10_Pro_Long_Range_Frame_Kit_-_10_graphic_info.webp).

Wheelbase **455 mm**, 30.5 mm FC pattern, 19 mm motor pattern. TPU in the kit fits Walksnail and rear GPS / dual FPV antenna layout well.

## FC / ESC mechanical stackup

* **ESC orientation:** TBS Lucid Gorilla **long axis side-to-side** (option 1a). Mid plate drilled for **four Gorilla-pattern** through holes (2.2 mm carbide, drill press); adapters mounted **side-to-side** on the ESC.
* **ESC to frame (final spacer tier):** **Two M2 washers + one M2 nut** between ESC and carbon **mid plate** (clears top plate without shims; room for motor wires soldered to **underside** ESC pads). Earlier **two M2 nuts + two M2 washers** tier was too tall (see build log).
* **Load path (conceptually top to bottom):** M2 **countersunk** screws through upper 30.5 mm Gorilla adapter (unthreaded M2 holes), ESC board, **spacer tier (2x M2 washer + 1x M2 nut)**, **mid plate (carbon)**, then **washer + nut** on the threads below the plate. First dry-fit used **M2x14** countersunk screws with a taller spacer tier; the **final** stack uses the **reduced** ESC spacer tier above so the top plate clears.
* **FC:** **M3x12** through isolation bobbins into **threaded** 30.5 mm adapters, with **two M3 washers** under each bobbin.
* **Bulk cap:** **Rubycon YXJ** 50 V **1000 µF**, 16 x 25 mm, across ESC input with short leads and 28 AWG pigtails into battery pad joint.
* **Dielectric:** **Kapton** on ESC motor pad regions (top and bottom), on mid plate under ESC footprint, on top plate underside over FC connector zone

## Flight controller

**TBS Lucid H7 Flight Controller - ICM42688** -- [TBS product page](https://www.team-blacksheep.com/products/prod:lucid_h7?srsltid=AfmBOoqm1P3rKUduaVLpS7PoSnZ1OvNZD1bLFvPFrDRYj9yclz82P66P), [ArduPilot hardware doc](https://ardupilot.org/copter/docs/common-tbs-lucidh7.html). Manual: [attachments/tbs-lucid-manual.pdf](attachments/tbs-lucid-manual.pdf). Gorilla pattern PDF: [attachments/tbs-gorilla-mounting-pattern.pdf](attachments/tbs-gorilla-mounting-pattern.pdf).

**Firmware flashed:** `https://firmware.ardupilot.org/Copter/stable-4.6.3/TBS_LUCID_H7/arducopter_with_bl.hex`

Default UART to SERIAL mapping is in the Lucid manual (ArduPilot column). **This aircraft's wiring** is summarized in the serial table below and in [ardupilot.md](ardupilot.md).

**VTX power:** Lucid **RELAY4** on **GPIO 83** controls the **9/12 V BEC** rail for HD VTX. Full ArduPilot relay / RC options: [ardupilot.md](ardupilot.md).

FC Connections:

* RADIO pigtail
  * green - T6
  * yellow - R6
  * red - 4V5 (moved from 5V; lets the RX power/link on USB)
  * black - G
* COORD pigtail
  * green - T4
  * yellow - R4
  * red - N/C
  * black - G
* VTX pigtail
  * red - 9V
  * grey - R3
  * white - T3
  * black - G
* GPS pigtail (4 pin)
  * green - T2
  * yellow - R2
  * red - 4V5
  * black - G
* GPS pigtail (3 pin)
  * red - DA1
  * yellow - CL1
  * black - N/C
* BEEP pigtail
  * red - 5V
  * yellow - Buz-
  * black - G
* RANGE pigtail
  * green - DA2
  * yellow - CL2
  * red - 5V
  * black - G
* SH1106 - 4-pin female Dupont; **inline AMS1117 LDO (5V -> 3.3V) on the VCC line**
  * green - DA1 (I2C1 SDA, shared with GPS compass)
  * yellow - CL1 (I2C1 SCL)
  * orange - 3.3V (from the inline LDO, fed from FC 5V)
  * brown - G
  * Enabled in ArduPilot as `NTF_DISPLAY_TYPE = 2` (sh1106)
* 470 µF 50V capacitor
  * positive - Vbat
  * negative - G
* ESC - TBS-provided cable

### Power rails (measured 2026-07-27; 6S pack, VTX off unless noted)

| Rail | Measured | Feeds / notes |
|------|----------|---------------|
| Vbat | 23.74 V | pack (470 uF cap) |
| 5V | 5.1 V | buzzer, RANGE pigtail, SH1106 LDO input |
| 4V5 | 4.76 V | GPS, RADIO (RX) |
| 3V3 | 3.268 V | logic breakout -- do not use for external device power |
| 9V (VTX) | ~9 V on / 0.4 V off | RELAY4-switched |
| PC1 (current sense) | 9.92 V, fixed | analog sensor dead (over-range); superseded by ESC telemetry -- see below |

**Battery monitor: ESC telemetry (`BATT_MONITOR=9`).** The FC's analog current input
(PC1 / `BATT_CURR_PIN=11`) is dead -- arc-blown at first bring-up, stuck at a fixed ~9.9 V
(above the ADC's ~3.6 V range), reporting a constant false current. Instead of the analog
channel, battery **voltage and current now come from ESC serial telemetry** (SERIAL8), using a
**custom-calibrated AM32 build** (see [ESC / Firmware](#firmware) and
[`esc-firmware/`](esc-firmware/README.md)). With the calibrated firmware the ESC readout tracks a
meter within ~1 % on voltage and reads ~0 A at rest. Voltage / capacity failsafes are active
(`BATT_LOW_VOLT=18.6`, `BATT_CRT_VOLT=18`, `BATT_CAPACITY=8000`). The current **scale** is left at
the AM32 generic value, so mAh is good to ~+/-15 % -- enough for low-voltage / low-capacity
"land now" detection, not precise energy accounting.

## Serial ports (as wired)

| UART | SERIAL | Device | Protocol (ArduPilot) | Baud | Notes |
|------|--------|--------|----------------------|------|-------|
| USB | SERIAL0 | -- | MAVLink2 (2) | 115200 | USB console (bench Mission Planner) |
| 2 | SERIAL2 | Holybro F9P Rover Lite | GPS (5) | 115200 | also I2C compass |
| 3 | SERIAL3 | Walksnail VTX | MSP DisplayPort (42) | 115200 | JST to **TX3/RX3** for data only; VTX power on other FC pads |
| 4 | SERIAL4 | Coordinator (Pi 4B, VIO) | MAVLink2 (2) | 1500000 | Companion VIO link; cabled and active at 1.5 Mbaud (as-flown 2026-07-09) |
| 6 | SERIAL6 | Matek ELRS R24-TD | MAVLink2 (2) | 460800 | Boxer MAVLink; [ground-station.md](ground-station.md) |
| 7 | SERIAL7 |  -- | None | 115200 | Unused |
| 8 | SERIAL8 | ESC | ESC telemetry (16) | auto | FC ribbon |
| OTG2 | SERIAL9 | -- | 115200 | -- | 

**Mission Planner param export:** Full list in git as **[`config/rekon10-methodi.param`](config/rekon10-methodi.param)**

### ELRS model match

**R24-TD** + **Boxer** use **Receiver Number 10** with **model match** so the Rekon ELRS profile (**MAVLink** on **SERIAL6**) cannot arm against the wrong EdgeTX model. Details: [Receiver](#receiver-matek-elrs-r24-td), **[ground-station.md](ground-station.md)**.

## ESC

**TBS Lucid 60A 3-6S AM32 4-in-1 ESC - Gorilla 39x16** -- [TBS](https://www.team-blacksheep.com/products/prod:lucid_4in1), [GetFPV 22303](https://www.getfpv.com/tbs-lucid-60a-3-6s-am-32-4-in-1-esc-gorilla-39x16.html). **AM32** firmware, target: `tbslu6s4in1`

### Firmware

* [AM32 Online Configurator](https://am32.ca/)
* [AM32 Firmware](https://github.com/am32-firmware/AM32)

initial: self report as F421, EEPROM v2, TBS_6S_4IN1_F421, version 2.16.

Flashed v2.20 using web configurator, pushed default config: EEPROM v3. 

Settings (non-default):

* 900 KV, 14 poles
* Beeper volume 3
* Running brake level 9 for all that propeller inertia

**Calibrated current/voltage telemetry (custom build).** Stock `TBS_6S_4IN1_F421` leaves the
current/voltage constants on generic fallbacks that read badly here (voltage ~1.44x low; a
~80 A/ESC zero-throttle current phantom). Fixed with a 3-constant patch to `Inc/targets.h` built
from the v2.20 tag -- `TARGET_VOLTAGE_DIVIDER 158`, `CURRENT_OFFSET 1600`, `MILLIVOLT_PER_AMP 20`
(scale still generic) -- flashed to all 4 ESCs via ArduPilot passthrough (`SERVO_BLH_AUTO=1`).
Reproducible build env, patch, and hex: [`esc-firmware/`](esc-firmware/README.md). Full
derivation in [coordinator#117](https://github.com/symmatree/coordinator/issues/117).

### Hardware

* XT60 input from harness
* **1000 µF** Rubycon YXJ across input; motor leads; FC ribbon.

## Motors and props

**Motors:** **iFlight Helion 10 3110 900KV** (also sold as Xing2 3110 900KV). Datasheet PDF: [attachments/Helion-10-3110-900KV-EN.pdf](attachments/Helion-10-3110-900KV-EN.pdf).

**Props:** **Master Airscrew MR Series 10x4.5 2-blade** -- one pair **CW** and one **CCW** ([MR series](https://www.masterairscrew.com/pages/mr-drone-propellers)). Rotation reference: [attachments/Multirotor_prop_direction_3DR.pdf](attachments/Multirotor_prop_direction_3DR.pdf). Other props available, will test multiple variants.

### Thrust and power (expected)

The table below is from the **Helion 3110 / 900KV** datasheet for **HQ 10 x 5 x 3** three-blade props at **~109 degC**.

| Throttle % | Voltage (V) | Current (A) | Thrust (g) | Power (W) | Efficiency (g/W) |
|------------|-------------|-------------|------------|-------------|-------------------|
| 50 | 24.91 | 9.95 | 789 | 247.9 | 3.18 |
| 60 | 24.36 | 16.38 | 1191 | 399.0 | 2.98 |
| 70 | 23.73 | 23.85 | 1639 | 566.0 | 2.90 |
| 80 | 23.18 | 34.58 | 2193 | 801.6 | 2.74 |
| 90 | 22.58 | 46.85 | 2768 | 1057.9 | 2.62 |
| 100 | 21.86 | 49.85 | 2906 | 1089.7 | 2.67 |

**Battery:** **GAONENG GNB 6S 22.2V 8000mAh 10C XT60 Li-ion** (Samsung 21700), model **GNB80006S10R** -- [manufacturer page](https://www.gaoneng.shop/products/gaoneng-gnb-6s-22-2v-8000mah-10c-xt60-li-ion-battery-made-with-samsung-21700). Continuous label **80 A**; current limiting in ArduPilot is still important (see [ardupilot.md](ardupilot.md)). Long design notes on C-rate and alternate packs live in the [build log](flight-platform-build-log.md).

## Receiver (Matek ELRS R24-TD)

**MATEKSYS ExpressLRS 2.4GHz True Diversity (ELRS R24-TD)** -- [manufacturer](https://www.mateksys.com/?portfolio=elrs-r24-td). Photos: [attachments/R24-TD_1.jpg](attachments/R24-TD_1.jpg), [attachments/R24-TD_3.jpg](attachments/R24-TD_3.jpg).

**Mount:** Starboard, behind/outboard of stack, just forward of Walksnail VTX, **VHB**. Antenna routing: see [flight-platform-build-log.md](flight-platform-build-log.md) (tail vertical between VTX V-antennas; horizontal on rear power zip-tie tail).

Connected to FC via 1.25mm JST pigtail to allow easier reflashing. On 5V (FC BEC) not 4V5 (USB) to allow for TD drawing a little more power.

**WiFi / OTA:** Receiver on **ExpressLRS 3.6.3**, joined to **house WiFi** for Web UI and updates. LAN address **10.0.4.65** (DHCP reservation; hostname **rekon-rx.local.symmatree.com**). Summary: [rekon-rx](../../kb/rekon-rx.md).

**ArduPilot / ELRS:** [ardupilot.md](ardupilot.md). **Ground radio:** [ground-station.md](ground-station.md).

3.6.3 Firmware flashed with Serial, w/ receiver baud override to 460800 in Compatibility Options.

In WebUI, checked Enabled Model Match, set id 10.

From LUA:

`RM RP4TD 2400`

* Protocol MAVLink
* Target SysId: 1
* Source SysId: 255
* Rx Mode: Diversity
* Tlm power: MatchTX
* 3.6.3 288efe

From WebUI:

* Serial protocol: MAVLINK
* Model match: enabled, id 10
* Force telemetry off: unchecked

## FPV (Walksnail Avatar HD Pro Kit)

**Caddx / Walksnail Avatar HD Pro Kit - 32GB w/ Dual Antennas** -- [product page](https://www.caddxfpv.com/products/walksnail-avatar-hd-pro-kit-dual-antenna). Local docs: [attachments/walksnail-vtx.webp](attachments/walksnail-vtx.webp), [attachments/Avatar_V2_DUAL_kit_Quickstart_Guide.pdf](attachments/Avatar_V2_DUAL_kit_Quickstart_Guide.pdf), [attachments/Goggles_X_User_Manual_EN_V1.2.pdf](attachments/Goggles_X_User_Manual_EN_V1.2.pdf).

Direct soldered provided pigtail (plug on VTX): **TX3/RX3** for MSP DisplayPort; Lucid **9 V @ 2A** BEC.

**Open: heavy pixelation investigation (2026-07).** Symptom is macroblocking on the goggle feed (digital link -- not analog static). Bench view at **unarmed / low TX power** was **clean**, which clears the encoder/camera/sensor and the short-duration case, but does **not** exercise the two prime suspects, both of which only appear armed/outdoors:

- **Power / brownout at full TX.** The VTX runs off a **9 V @ 2A = 18 W** BEC; a Walksnail Avatar HD Pro at high TX power + recording can approach that ceiling. If it's marginal, expect macroblocking that **tracks throttle** (pack sag) or steps with **TX power level** -- not with range.
- **Thermal throttling.** Full TX power = more heat; degradation that **grows over a soak** while stationary points here. (Bench thermal protection is via SA / airflow now that `RELAY4_DEFAULT` must stay `1` -- see [ardupilot.md](ardupilot.md).)

Test-flight read (arm -> throttle up -> hover): if pixelation **correlates with throttle / TX power** -> power or ESC EMI; if it's **constant or grows with time-on** -> thermal or RF link. Vibration under motors is also the most likely thing to re-open a marginal **micro-U.FL** VTX antenna in the crowded rear bay (antennas were reseated this session -- the hoped-for fix). Interference from the Coordinator / Pi Zero / USB hub was ruled out **at idle** only; the OAK-D on **USB3** is a broadband noise source that needs a pass with the VIO stack **actively streaming**, not just powered.

## GNSS and compass (Holybro F9P Rover Lite)

* **Module:** Holybro **F9P Rover Lite** (ZED-F9P); **adapter board** to **4-pin UART + 5 V** and **2-pin I2C (SCL/SDA)**; optional **USB-UART** dongle or **Holybro USB-C** for u-center on the bench.
* **FC UART:** **SERIAL2** (3.3 V RX/TX) -- match `SERIAL2_*` and module baud after bench (**A**). (The F9P sits on the old M100 port SERIAL2; the earlier SERIAL7 plan was abandoned. Matches the serial table above and [ardupilot.md](ardupilot.md).)
* **RTCM corrections path:** Base station -> ntrip (tiles) -> mavproxy (tiles) -> house WiFi -> `boxer-txbp` backpack (UDP) -> ELRS MAVLink uplink -> ArduPilot -> `GPS_RTCM_DATA` forwarded to the F9P on SERIAL2. Current Rekon profile is **333 Hz Full, 1:2 telemetry** with about **13211 baud** telemetry budget reported on the radio.

RTCM messages set in [tiles](https://github.com/symmatree/tiles/pull/516) to `1005(10),1074,1084,1094,1124,1230(10)`

**Canonical:** the full hop-by-hop path, rates, and the recurring ELRS-backpack failure mode (it silently anchors to the first GCS that answers) live in coordinator [`docs/rtk-corrections-path.md`](https://github.com/symmatree/coordinator/blob/main/docs/rtk-corrections-path.md).

## Rangefinder

**Benewake TFS20-L** not yet installed. ArduPilot params: [ardupilot.md](ardupilot.md).

Connection path (to deal with tricky, small-pitch surface-mount interface):

* A06SUR06SUR32W152B 6" 06SUR-32S - to - 06SUR32S jumper wire
* BM06B-SURS-TF Conn Header SMD 6POS 0.8mm
* PA0101 LGA-14 to DIP-14 SMT Adapter ([ProtoAdvantage](proto-advantage.com)) - cut in half to be a 6-pin 0.8mm to 2.54mm pitch changer
* soldered patch cables to FC

## Buzzer and power accessories

**GEPRC Super Buzzer** -- FC buzzer pads to the buzzer through the **provided plug pigtail** (connectorized, not bare splice). **Port** frame side, mirror of RX placement, VHB, button reachable. **Working** (audible when the radio/FC path triggers it).

## Batteries

**Primary flight pack:** **GAONENG GNB 6S 22.2V 8000mAh 10C XT60 Li-ion** (Samsung 21700), **GNB80006S10R** -- link above; ~904 g, XT60.

**iFlight XT60 Anti Spark Filter Module** -- inline XT60 [attachments/Anti%20Spark%20Filter%20Instruction_20240918.pdf](attachments/Anti%20Spark%20Filter%20Instruction_20240918.pdf). Always plug / unplug the battery side of this module.
