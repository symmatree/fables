# Flight platform (as-built reference)

[Back to index](README.md) | [Build log](flight-platform-build-log.md) | [ArduPilot configuration](ardupilot.md)

Flight stack, power path into the ESC, FPV link hardware, and radio receiver on the airframe. Excludes VIO / coordinator (see [central-hub.md](central-hub.md), [oak-d-mount.md](oak-d-mount.md)) and the F9P mast ([gps-mount.md](gps-mount.md)).

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

Other connections:

* **470 µF** on FC VBatt.
* **Buzzer** pads to **GEPRC Super Buzzer**.
* **I2C1:** M100 Pro **QMC5883L** compass
Pending:

* Second voltage sense from payload UBEC per [central-hub.md](central-hub.md).
* Rangefinder pigtail from SMT adapter board

## Serial ports (as wired)

| UART | SERIAL | Device | Protocol (ArduPilot) | Baud | Notes |
|------|--------|--------|----------------------|------|-------|
| USB | SERIAL0 | -- | MAVLink2 (2) | 115200 | Unused (coordinator) |
| 2 | SERIAL2 | HGLRC M100 Pro GPS | GPS (5) | 115200 | Direct to FC pads; 3D fix + compass cal (see build log) |
| 3 | SERIAL3 | Walksnail VTX | MSP DisplayPort (42) | 115200 | JST to **TX3/RX3** for data only; VTX power on other FC pads |
| 4 | SERIAL4 | -- | Rangefinder (9) | 115200 | Unused |
| 6 | SERIAL6 | Matek ELRS R24-TD | MAVLink2 (2) | 460800 | Boxer MAVLink; [ground-station.md](ground-station.md) |
| 7 | SERIAL7 | -- | GPS (5) | 460800 | Unused |
| 8 | SERIAL8 | ESC | ESC telemetry (16) | auto | FC ribbon |

**Bring-up (cross-subsystem):** **M100** on SERIAL2 / I2C1: **3D fix**, compass cal, UART path (see build log). **Walksnail** UART + power **wired**; **VTX never powered**; **goggles** firmware current (expect VTX FW via goggles when linked). **ELRS** on SERIAL6: **MAVLink**, **R24-TD** **3.6.3**, bound to Boxer; link + telemetry OK; WiFi **10.0.4.65** / **rekon-rx.local.symmatree.com** ([rekon-rx](../../kb/rekon-rx.md)). **Model match:** [ELRS model match](#elrs-model-match). Per-subsystem detail: sections below and [ardupilot.md](ardupilot.md).

**Mission Planner param export:** Full list in git as **[`config/rekon10-ardupilot.param`](config/rekon10-ardupilot.param)**. This repo's **`.gitattributes`** marks that path **`text eol=crlf`** (alongside EdgeTX YAML under `Drones/rekon10/config/`) so CRLF exports from Mission Planner on Windows do not produce whole-file diffs against LF-only clones. A **facts** superproject checkout also sets the same behavior for the submodule path `fables/Drones/rekon10/config/` via **facts** `.gitattributes`.

### ELRS model match

**R24-TD** + **Boxer** use **Receiver Number 10** with **model match** so the Rekon ELRS profile (**MAVLink** on **SERIAL6**) cannot arm against the wrong EdgeTX model. Details: [Receiver](#receiver-matek-elrs-r24-td), **[ground-station.md](ground-station.md)**.

## ESC

**TBS Lucid 60A 3-6S AM32 4-in-1 ESC - Gorilla 39x16** -- [TBS](https://www.team-blacksheep.com/products/prod:lucid_4in1), [GetFPV 22303](https://www.getfpv.com/tbs-lucid-60a-3-6s-am-32-4-in-1-esc-gorilla-39x16.html). **AM32** firmware, target: `tbslu6s4in1`

* [AM32 Online Configurator](https://am32.ca/)
* [AM32 Firmware](https://github.com/am32-firmware/AM32)

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

**Battery for planning:** Main pack is **GAONENG GNB 6S 22.2V 8000mAh 10C XT60 Li-ion** (Samsung 21700), model **GNB80006S10R** -- [manufacturer page](https://www.gaoneng.shop/products/gaoneng-gnb-6s-22-2v-8000mah-10c-xt60-li-ion-battery-made-with-samsung-21700). Continuous label **80 A**; current limiting in ArduPilot is still important (see [ardupilot.md](ardupilot.md)). Long design notes on C-rate and alternate packs live in the [build log](flight-platform-build-log.md).

## Receiver (Matek ELRS R24-TD)

**MATEKSYS ExpressLRS 2.4GHz True Diversity (ELRS R24-TD)** -- [manufacturer](https://www.mateksys.com/?portfolio=elrs-r24-td). Photos: [attachments/R24-TD_1.jpg](attachments/R24-TD_1.jpg), [attachments/R24-TD_3.jpg](attachments/R24-TD_3.jpg).

**Mount:** Starboard, behind/outboard of stack, just forward of Walksnail VTX, **VHB**. Antenna routing: see [flight-platform-build-log.md](flight-platform-build-log.md) (tail vertical between VTX V-antennas; horizontal on rear power zip-tie tail).

Connected to FC via 1.25mm JST pigtail to allow easier reflashing. On 5V (FC BEC) not 4V5 (USB) to allow for TD drawing a little more power, and the GPS already being on 4V5.

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

## GNSS and compass (HGLRC M100 Pro)

**HGLRC M100 PRO GPS** (u-blox M10, **QMC5883L** compass) -- [HGLRC product page](https://www.hglrc.com/products/hglrc-m100-pro-gps). Manual / pinout family: [attachments/m100-5883-gps.pdf](attachments/m100-5883-gps.pdf), diagram [attachments/hglrc-M100-5883.webp](attachments/hglrc-M100-5883.webp).

Direct soldered to **UART2** + **I2C1** + **Lucid 4V5** (not 5V pad) + **GND**, **direct solder** to FC pads. **Harness colors do not follow pin order** -- solder by silk / manual pin names.

**I2C1:** M100 Pro **QMC5883L** compass, address **0x0D** (13 decimal). Calibrated in Mission Planner; **Yaw270** / `COMPASS_ORIENT = 6`.

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
