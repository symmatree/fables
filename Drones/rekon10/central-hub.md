# Central hub / power distribution

[Back to index](README.md)

Central power and data distribution, built around the **Coordinator** (Raspberry Pi 4B). Maybe housed in the base / back of the oak-d mount or in a separate backpack. Unit as a whole has a lot of connections that we should pre-route for access before locking things down.

## Components

### USB 2.0 hub

* Data to/from Pi Zeros (camera logical sync, NTP, telemetry)
* Power to Pi Zeros (from barrel jack, doesn't load down the Coordinator)

Currently I only have one unit but we need to plan for 2x just for the horizontal ring of 8 cameras, plus the upward pair from the vertical ring (see [arm-pods.md](arm-pods.md)).

Powered USB 3.0 4-port hub: Amazon Basics B00DQFGH80. 

* Input: 5 V from BEC. 
* Barrel jack, original supply is 5V @ 2.5A; tip-positive, ring-negative. 
* Outputs: power + data to each Pi Zero; upstream data port to central bridge Pi (4B).

#### Alternative: data-only hub links + 5 V injected at each Zero

**Idea:** Use small bare-PCB 4-port USB 2.0 hub boards (DIY / AliExpress class), remove the Type-A sockets, and run **D+, D-, and GND** only to each Pi Zero's USB data path. Deliver **5 V + power GND** separately (GPIO 5 V pins on the Zero, or a short parallel harness), fed from the same **stripboard / UBEC** budget you already plan. The hub still needs **one** 5 V feed at its own input for the hub IC and terminations; that can be soldered to the stripboard rail instead of a barrel jack if you want to drop barrel pigtails.

**Why it can fit this design:** You are **not** on a single-cable-per-Zero model today. Each pod already needs a **PPS + signal-ground** pair from the hub area ([arm-pods.md](arm-pods.md)), so adding explicit **5 V + power GND** (or reusing a careful common ground strategy at the pod) does not explode connector count the way it would for a "USB only" airframe.

**What you might actually save:** Mostly **mass and volume** of retail USB cables and hub output connectors, and **one failure mode** (floppy micro-USB plugs in vibration) if you replace them with soldered pigtails or board-to-board links. You might also delete **barrel-to-hub** adapters by wiring hub VIN straight to the distribution board. You do **not** remove the need for **four** logical USB 2.0 trees if you stay with one Coordinator host (four 4-port hubs for 16 Zeros, or two for the current 8-camera ring).

**Costs / risks:**

* **Labor and reliability:** Hand-wiring D+/D- from hub PCB to 16 Zeros is fussy; strain relief and conformal coat matter more than with molded cables. A bad stub length or GND reference can cause **enumerate / drop-out** under EMI.
* **Hub quality:** Anonymous 2.0 hub silicon varies; retail hubs are sometimes better shielded. Budget bench time (vibration + motors running) before committing.
* **USB gadget without VBUS:** Zeros in **g**adget mode normally get **5 V from the cable**. Powering from the header while using the micro-USB port **only** for data is standard enough, but **verify** on the bench that `dwc2` peripheral / gadget mode enumerates reliably with your exact hub and wiring (some stacks care about VBUS sense; fix with known device-tree / `config.txt` patterns if needed).
* **Current path:** The UBEC and wiring must still deliver the **sum** of Zero + camera + SD + WiFi peaks; splitting power off USB does not reduce that total. It can **reduce** concern about **back-powering** the Coordinator or weird interactions between hub port power and the Pi 4B upstream port, if you prefer the hub to be "data plus local hub rail only" with Zeros fed from a single avionics 5 V bus you control.

**Summary:** Reasonable **optional** refinement, not a slam-dunk simplification: you trade **retail cable + connector** bulk for **custom harnessing** and **bench risk**. Keep the **Amazon Basics** path as the conservative baseline until a bare-hub prototype proves stable next to ESC noise and prop vibration.

### Central Raspberry Pi (currently a 4B)

Call this the central or MAVLink Pi so we don't freak everybody out if we go back to a Raspberry Pi 5 at some point.

* Runs VIO along with the OAK-D (has internal IMU)
* Bridges pi zeros to each other (virtual network adapters over USB)
* Serves NTP to pi zeros; disciplines the shared **DS3234** from GNSS/MAVLink time when available
* Listens to MAVLink to FC for pose and time hints
* Sends position estimates over MAVLink to FC
* Sends depth field-based obstacle-distance messages to the FC

### 10A 5V UBEC

Has its own capacitor wired to its input side.

Hardware source: Castle Creations CC BEC 2.0 from ReadyMadeRC.

* Peak current 14A
* For 4.75-7.0V output: 9A continuous
* Default setting 5.25V

TODO: I'd like to get voltage off its output and current from the input. The matek sensor is ridiculous since we draw maybe 2A on the upstream side, we need like a 5A sensor. Gemini says a unidirectional ACS724 with 5A or 10A should be perfect.

### PPS distribution board

Uses a buffer IC in DIP package to remove load on the [**DS3234**](https://www.sparkfun.com/sparkfun-deadon-rtc-breakout-ds3234.html) **SQW** line (1 Hz), not the GNSS module.

- **Camera pod connectors:** 2-wire JST SM (20 AWG): signal ground, 3.3 V PPS (from buffer). JST SM housings must be **zip-tied/anchored to the frame** to prevent pendulum vibration from fatiguing wires.
- **Upward pair (NNW + NNE):** Two additional PPS outputs needed for the early vertical-ring cameras ([arm-pods.md](arm-pods.md), *Upward-looking cameras*). The SN74AHC125N is a **quad** buffer; the horizontal-ring 8 Zeros already need **two** buffer chips (or the Coordinator shares the raw line and 8 buffered outputs go to 8 Zeros). The upward pair adds 2 more buffered outputs -- plan for a total of **10 Zero PPS lines + 1 raw Coordinator line**, requiring **three** quad buffer ICs (12 outputs, 2 spare) or **two** hex buffers.
- **Hub ports:** The upward pair gets the **first vertical-ring USB hub** -- a small 4-port unit with two ports used now and two spare for future vertical-ring cameras. This hub's upstream port connects to a free USB 2.0 port on the Coordinator.

### 5V distribution board

Sends around 5V. Hopefully the ElectroCookie traces carry power well, but we don't need a ton.

Board reference: ElectroCookie snappable stripboard from Amazon.

---

## Connections (end-to-end endpoints)

### Pi 4B

* Power from payload 5V rail (stripboard) via usb-c pigtail (20 AWG, Amazon)
* Data from OAK-D into USB 3.0
* Data from TBS Lucid FC USB port (confirm 2.0 or 3.0)
* Data from USB hub into USB 2.0 port (hub's USB-A upstream port)

## Stripboard 5V distribution

* 5V in from UBEC
* Barrel jack to OAK-D (dimensions in datasheet, pigtails acquired)
* Barrel jack to USB-hub (unknown dimensions) for initial set of 4 cameras
* Protect for barrel jack to second USB-hub (unknown dimensions)
* Power to rpi 4b (usb-c pigtail, 20 AWG)
* UBEC-output-sensing voltage to FC 2nd-voltage pin

## Stripboard PPS distribution

One per macro-pod of 4 Zeros/cameras. Could be a single board if it's not inconveniently large, but my instinct is that we'll put this next to the usb hub for the same macro-pod.

* **PPS-in** from **DS3234 SQW** (one RTC breakout at the hub; SPI/I2C to Coordinator for discipline from GNSS when available)
* TODO: Firm up buffer chip wiring and power, make sure we're at right levels for RPi
* 2-wire PPS (after buffer) and signal ground to each pi zero
* Connector reference: VISDOLL JST SM connector kits (Amazon)


### PPS signal buffering

Driving many GPIO pins from a single weak **SQW** output would degrade edge sharpness due to capacitive loading.

**Buffer:** 3.3 V quad buffer, **SN74AHC125N** (or 74LVC125A). Powered from the Coordinator's 3.3 V rail (~20 uA quiescent, negligible load).

**Topology:** All buffer inputs tied in parallel to the raw **DS3234 SQW** line (zero phase skew, ~12-16 pF total input capacitance per quad chip -- trivial for the RTC). The Coordinator may share the raw SQW line for chrony; buffered outputs go to the Pi Zeros. With 8 horizontal-ring Zeros + 2 upward-pair Zeros = **10 buffered outputs** needed, requiring **three** SN74AHC125N quad chips (or two hex-buffer equivalents). Two spare outputs remain.

Do not daisy-chain a "preamp" gate -- it adds cascaded propagation delay and unnecessary skew. Parallel is strictly better.

### USB hub

* 5V from BEC/stripboard via barrel jack (dimensions to be discovered)
* Upstream port to central bridge Pi's USB 2.0

### UBEC

* Power input: XT60 to upstream splitter
* Power output: 5V to stripboard rails for distribution
* Castle Link USB Programming Kit V3 (ReadyMadeRC) is the service/programming tool for CC BEC configuration
