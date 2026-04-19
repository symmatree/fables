# Flight platform build log

[Back to index](README.md) | [As-built flight platform](flight-platform.md) | [ArduPilot configuration](ardupilot.md)

Chronological notes: Gorilla drilling, stack iterations, bench bring-up, and wiring discovery. **Canonical wiring, serial map, and final FC/ESC stack recipe** are in [flight-platform.md](flight-platform.md). **ArduPilot parameters** are in [ardupilot.md](ardupilot.md) and [config/rekon10-ardupilot.param](config/rekon10-ardupilot.param).

**Bring-up phases:** Cursor plan `~/.cursor/plans/rekon_flight_stack_bring-up_b564811b.plan.md`.

### Mission Planner config (early notes)

Flashed latest

* Frame type V (deadcat) - but Gemini argues this should be X even so. NEED TO VERIFY.
* Performed 3-axis accelerometer config. Note that the main image in the Lucid manual is misleading, the FC is upside down as pictured. The "V" on the side with the pads should be up, not the electronics.

## Physical Stackup (exploration)

Damn Gorilla mount makes this messy. Simplest stack with clearance for everything is 3mm proud and would require maybe 1mm of clearance above it. The top plate is 3.25mm thick; I need to capture the camera verticals (they mate into slots) so either I build an adapter for them, or I can shim at most maybe 2mm to still capture a little.

The too-tall-but-with-clearance stackup:

* Short screws through carbon fiber into bottom adapters. Washers under their heads for both standoff and carbon nicety.
* M2x16 countersunk going upward through Gorilla-spaced holes
* ESC sits on those
* Washer then nut on each M2, followed by second (top) adapter, then another washer and nut. (Top washer required because we're going over a countersunk hole with a flat nut)
* Bolt coming DOWN to 30.5mm holes in the second adapter. From top down: button-head, isolation bobbin, nut (spacer), 30.5mm-spaced holes in adapter

Motivation:

* Bottom adapter almost touches the motor solder-points from below so we must solder ESC from above
* Nut-and-washer spacer on ESC before second adapter gives generous standoff on top for soldering to ESC
* Nut on 30.5mm adapter lifts FC ports out of conflict with M2 nuts and extra bolt length

Each gorilla adapter is approx 4.5mm vertically.

Having ESC with M1 to back-right (Betaflight convention) puts the gorilla "long axis" fore-and-aft, which isn't great (less clearance for a capacitor, for one thing) but rotating 90 puts the USB port right on top of a bolt. We could avoid THAT if we used a countersunk bolt coming down from above, but then it's unclear what would capture its threads at the bottom. I guess we could drill gorilla holes through the frame, so it could go down to a nut on the outside. If we did that we could actually drop the bottom adapter and probably save some height with a shorter standoff than the adapter ends up being.

CHOSEN: So option 1a: ESC with long axis side-to-side. drill gorilla holes, screw going down through top adapter, esc, nut/washers for spacing, carbon fiber, washer, nut. Solder motors to underside of ESC since the adapter wouldn't be blocking them. Would save a little on the underside (from 4.5mm of standoff to just enough for solder and breathing). Would save 2mm of spacer on top of ESC. FC could save another 2-2.5mm with removed spacers since USB would be over countersunk not bolt.

IMPOSSIBLE: Option 1b: ESC with long axis fore-and-aft, drill gorilla holes. Same but CAN (plastic) becomes limit instead of USB. Doesn't work because the holes would fall in a cutout in the existing panel.

NO: Option 2: Don't drill holes. Hmm. ESC long-axis fore-and-aft. Remove nut spacer between adapters, maybe 2 washers instead. Skip washer on top of adapter. Trim adapter bolts down slightly to flush. Shim FC up until CAN plastic is JUST clear of adapter and doesn't transmit vibration. Okay experimentally this requires 4 washers under each bobbin; with 3 the CAN plug grounds out and the VTX is fully inaccessible. So 4 washers rather than 1x 2.5mm nut, very much a wash I'm afraid.

----

## Practical build log

**Bring-up safety:** Keep **props off** until the bring-up plan calls for props (hover). Phased execution and params: Cursor plan `rekon_flight_stack_bring-up_b564811b.plan.md` (not duplicated in a second checklist file in this repo).

### Gorilla holes (curse you TBS)

* Dismounted top plate, standoffs, unscrewed mid plate from arms (total disassembly basically except for the Walksnail mount).
* Tape over the upper side of the middle plate, cut out little holes for the existing screws to avoid fouling the threads
* Screwed the adapters on, mounted side-to-side
* 2mm transfer punch fit very nicely through the threaded adapter holes. Did NOT hammer it, just spun it around a few times to mark the masking tape.
* Removed adapters, mounted on drill press table on top of a scrap of sacrificial 1/8 plywood I had around (and sanded down lightly just to even it out a little)
* Clamped at both ends against wooden blocks under the table and the masking tape-covered CF on top.
* Walked the drill press belt up to the top speed, around 3k rpm I believe
* Chucked the tiny 1/8" shaft end 2.2mm carbide cutter, slid the plate around to get it perfectly lined up with the pinprick in the masking tape
* Added a drop of distilled water using an oral syringe (this squirted more than I meant, all four times!) for cooling
* Pecked my way through until I could feel the change to wood
* Unclamped, wiped off the carbon slurry from the board and the backing plate
* Repeat for the other 3 holes

This worked very nicely. One hole had very slight tearout around the edges, you can feel a ridge on one side of the hole and just see it, but it's negligible and would disappear under a bolthead or washer. I think that was one of the last holes and I probably increased my drilling speed. I could also use hardboard as I planned, the hard smooth surface might give a tighter backing than the slightly rough plywood, but I didn't want to break up a big sheet which is all I had around. Also possibly tape on the backside as well, or a deep-throated clamp that could bear closer to the actual point of drilling. (My clamps that are small enough for their feet to not interfere with the drill press, and their heads to fit between the table and bench, are all too short to reach the center of the table, though they were pretty close.)

### Remounting

With the holes drilled I did a dry fit. The first pass was too tall, recording here for reference:

#### TOO TALL SETUP

The ESC part of the stack:

* countersunk M2x14 coming down through the upper 30.5mm adapter (the M2 holes are unthreaded)
* no washer, straight on the ESC board
* nut, washer, nut, washer as a spacing and load distribution stack
* Mid-plate of the frame (carbon fiber)
* washer, nut
* approx 1-2 threads exposed

Resulting character:

* This is mounted with the motor pads on the front and back of the ESC
* Battery and capacitor come off the right side, FC connector on the LHS
* 4mm of clearance between floor and lower motor pads
* There's a "cellar" hole (probably for bottom-mounted battery connector?) with a little clearance on the forward side, but the rear edge is even with the edge of the ESC so anything using that to go under the ESC would be right against the motor wires if not interfering with them. So we probably need to route everything around the standoffs and not over or under the stack.

I believe this is an M14 if that counts threaded depth but not the countersink, which seems right.

The 2x nut, 2x washer tier was to space the underside of the ESC up enough to allow motor wires to the bottom side pads, since the adapter blocks the topside pads for one pad of each motor. We *could* put just those on the bottom and the middle ones on top but that would require clearance on both sides so I'll do the soldering carefully instead.

With the adapter used as intended this way, the Gorilla-hole top is basically flush (some of the bolts don't sit down fully in the countersink is all). The other holes (30.5mm) are threaded so we can build from the top unlike the earlier awkward sandwich.

FC mounting:

* M3x12 coming down through the isolation bobbins
* 3x M3 washers as spacers
* into threaded adapters
* bolts end up 1/2 to 1 thread exposed
* bolts are clear of the motor pads but close; any shorter stack should consider M3x10 instead, or just grinding off like 1mm

The USB-C port is the closest-to-interfering on the bottom of the FC. With the 3x washers on each post, it has 1.4mm of free air over the metal adapter. (I'm not worried about electrical connection, since it should be grounded anyway, but I don't want it to transmit vibration.) I do actually bottom out against the adapter when I try to plug in, Google believes we have to either back off the bolts to allow access or use a slim-line adapter, since not enough will fit. But it shouldn't pass vibration at least.

The 3 washers are providing 1.7mm of height.

Net-net, this gets me to 20mm of total height to the top of the button-head M3s. The "20mm" standoffs are measuring at 19.8mm which is why this was still grounding out. We need to recover a little more height.

----

#### Planned Just Right stack

ESC: we had 4mm of space directly coming from 2x M2 washer and 2x M2 nut. Measured separately

* M3 washer 0.5mm
* M3 nut 1.7mm

I don't think the washer is REQUIRED for mating to the CF, we have the nut which is reasonably large, and it's not balsa or something that would crush. So options are

* Keep 2 nuts, 3-3.2mm total
* 1 nut + 1 washer, 2mm total
* 1 nut + 2 washers, 2.5mm total

The motor wires are **1.5 mm** with at least a little **solder** on top, plus **Kapton** over the joint (roughly the same **extra thickness** we would have budgeted for **conformal**). So a **2 mm** ESC spacer tier (**1 nut + 1 washer**) is **probably too tight in height** for wire + solder + that insulation stack -- **2.5 mm** might fit; **3--3.2 mm** hopefully not needed.

Savings: 1mm?

FC: three washers isn't enough for the USB to be usable but it's too much for the stack. It protrudes below the bobbins so we need SOME. Measured at 1.4mm of space with 1.7mm of spacers (since it extends past). We definitely don't need this much space, 2 washers is the conservative choice. We might need to drop to M3x10 for the bolts so they don't protrude.

That would save 0.6mm (1 FC washer) + 1.7mm (1 ESC nut) which ought to be enough maybe. We could try to eke out an ESC washer as well, or a second FC washer, but both are getting riskier. **Kapton** on the frame and over ESC joints adds dielectric clearance **without** cure time or solvent trapped under compression; tradeoffs are **tape edges**, possible **lift**, and **abrasion** in service vs a bonded coating.

**Insulation / assembly sequence (as adopted -- Kapton, not conformal):** Solder motor leads to the **underside** ESC pads with **minimum** joint height (good wetting, no cold blobs). **Kapton:** apply **narrow** strips covering **top and bottom** of the motor pad areas on the ESC (joints and adjacent pad metal) after a **superficial isopropyl** clean. Add **Kapton on the mid plate** over **most of the ESC footprint** where conductors could otherwise bear on carbon fiber. Add **Kapton on the underside of the top plate** over the zone that sits above **FC connectors / solder-side** clearance concerns. **Optional once the FC is fully wired:** Kapton on the **top** of the FC -- on the Lucid the **top is mostly a flat pad field** (active parts on the **underside**), so this is mainly dielectric vs the carbon plate; still **do not cover** any **baro vent / foam** path if it appears on that face.

**Notes:** Treat tape as **backup** insulation, not a license for zero clearance -- peeled edges and vibration can still expose copper. Press tape down well; do not bury connectors you must probe or unplug. Bench **continuity** from each phase to frame before flight if stack clearance stays tight.

### Dry-fit: reduced washer stack clears top plate (no shims)

Dry-fit verified that **two M3 washers under the FC** and **two M2 washers plus one M2 nut under the ESC** leave enough vertical room that the **top plate fits without any shims**. This aligns with the "Just Right" direction (fewer spacers than the earlier too-tall stack).

**Still open:** Final **fully wired** check that **FC leads, battery, and signal harness** clear the plate and standoffs (motor wires now in place with **Kapton**). Height clearance alone never proved routing.

### ESC bulk capacitor (50 V, 1000 µF) and battery pads

Used the **physically larger** **Rubycon YXJ** 50 V 1000 µF electrolytic (**YXJ** on the can), **16 x 25 mm**, **0.032 Ω** ESR per datasheet / supplier listing (treated as the **better / more reputable** option in the parts bin).

* Cut the capacitor leads **short**.
* **28 AWG** pigtails: stripped about **7 mm**, wrapped around the remaining cap leg, soldered, then **heat-shrink** up to the insulated part of the pigtail.
* Other end of each pigtail trimmed to about **1 cm**, routed so that end sat **under the main battery leads** while those were soldered to the ESC (shared pad / joint, not a separate guess at a stress point).

### Frame: arms, mid-plate, motors (first mount)

Reassembled **arms and mid-plate**, then mounted **motors for the first time**. Used the **fore-and-aft struts** to tie the arms on each side; that **locked the geometry** together with the **two through-bolts per arm** clamping each arm between **bottom and mid plate**.

**Threadlocker:** One drop of **blue (removable) Loctite** on **every** frame and **motor mount** bolt. **Not** used on **propeller** hardware. After **overnight** cure, expectation is **negligible** continued off-gassing near props vs the amount that would matter for prop plastic or balance.

### Soldering station: Hakko FX-888D calibration mistake (battery leads)

While attempting to solder **battery leads** to the ESC, the iron was used with a **wrong calibration entry** (a known foot-gun on the FX-888D UI): instead of **changing the set temperature** to ~842 F, **calibration was used to assert the tip was already at 842 F** while the display still showed something like **750 F** (true tip temperature likely lower still, e.g. ~650 F, not rigorously measured). After correcting the **set temp** back toward 842 F, behavior was still untrusted because the **calibration offset** remained wrong.

**Resolution (done):** **Factory default reset**; station now used in **Celsius** at **440 C** for large pads. **Wetting improved a lot** for battery and motor work -- **not perfect, acceptable** for the build.

**Archival (pre-reset planning):** Optional inverse-calibration hedge if reset had cleared **settings** but not **tip offset**; **IR gun** unreliable on shiny tips without emissivity / matte target; **DMM thermocouple** only within probe **max temp** and good contact.

### Solder and flux (vendors) + poor wetting on battery pads

**Suppliers / products (for anyone matching this setup):**

* **Solder:** Maiyum **63/37** tin-lead, **rosin core**, **0.8 mm** diameter.
* **Flux:** Chip Quik **CQ4LF** liquid flux, **no-clean**, pen applicator.
* **Also on hand:** Several-year-old **rosin** flux in a **needle** bottle -- may be past best performance if solvents crept out or the resin oxidized; treat as **backup** until checked (flow, smell, residue) or replaced.

**Iron:** Hakko FX-888D with a **relatively large chisel** tip; not really **angled** to maximize flat contact, but a **small solder bridge** on the tip is used to **conduct heat** into the joint (normal habit).

**What went wrong (battery leads / large ESC pads):** Solder **would melt** but did **not wet or adhere** properly to the pad: could **tin** the pad yet still **scrape** the metal off with the iron as if the joint were **slushy** rather than fluid and shiny. Adding the **leads**, the wire solder and pad solder did **not merge** -- the leads **sat** on the pad, heat could be applied, but releasing **iron pressure** lifted the wire instead of leaving a **single frozen fillet**. Likely contributors: **miscalibrated / low actual tip temperature**, marginal **thermal coupling** (chisel angle / pad mass), and possibly **flux** or **pad finish**.

**After factory reset and ~440 C:** wetting **much better**; joints **usable** though not **showroom** quality.

### Motors to ESC and Kapton isolation (build progress)

With the iron trusted again: **motor wires** soldered to the **underside** ESC pads, then **superficial isopropyl** cleanup. **Narrow Kapton** over the **top and bottom** of the motor pad regions on the board. **Kapton on the mid plate** under **most of the ESC footprint**. **Kapton on the underside of the top plate** where **FC-side connectors and leads** need clearance from carbon. **Conformal coating** dropped for this stack in favor of the tape approach (see **Insulation / assembly sequence** under *Planned Just Right stack* above).

### Battery to ESC, FC ribbon, USB bring-up; VBatt multimeter mistake; checks

**Stack power:** Battery into ESC (with bulk cap and **female XT60** on leads per earlier log), FC connected to ESC ribbon, **USB** to PC. Mission Planner connects; **IMU0 / IMU1** messages appear as expected.

**Baro:** Flight Data > Messages may **not** print **DPS310** / **DPS368** by name; baro still OK if **altitude** responds (e.g. light puff on baro port) or **SCALED_PRESSURE** in MAVLink Inspector updates.

**VBatt calibration:** Used MP battery calibration vs multimeter reading; **`BATT_VOLT_MULT`** moved from **11** to **10.8903**.

**Multimeter accident (VBatt pads, wrong mode):** Intended **VBatt** vs adjacent **GND** on the FC; meter was in **ohms / resistance** mode instead of **DC voltage**. **Spark** and **soot / charring**: heavy on **SDA-2** (I2C2 data), and on the **GND** that shares the **470 uF VBatt cap** land (lost some solder on that GND; joint still serviceable -- **reflow** GND cap when convenient).

**Verification after fixing the meter:** Unplugged, confirmed pack voltage in **DC V**, reconnected battery + USB. FC **appears normal** in MP.

**I2C checks (idle, no device on I2C2 yet):** **SDA-2**, **SCL-2**, **SDA-1**, **SCL-1** all read **~3.3 V** vs GND (same as each other). Soot on **SDA-2** masked the reading until cleaned through; finish with **IPA** and gentle brushing rather than scraping, before any wire goes to **I2C2**.

**HD VTX / DJI-style pigtail (Lucid, wire order + power + Walksnail):** Order is along the **ribbon from the wire that sits furthest from the molded connector corner to the wire at the corner** (avoids ambiguous left/right on top vs bottom of the board).

| # (far to corner) | Signal | Insulation color |
|-------------------|--------|------------------|
| 1 | **VSW** (switched rail; **not** a simple **9 V** BEC in this measurement) | red |
| 2 | GND | black |
| 3 | **TX3** (MSP DisplayPort, FC transmits) | white |
| 4 | **RX3** (MSP DisplayPort, FC receives) | grey |
| 5 | GND | brown |
| 6 | **RX1** (S.Bus) | yellow |

**Measured (cut pigtail, strip red + black, FC on battery):** Red behaved as **VSW**, **not** as stable **~9 V** suitable for naive Walksnail power. Using the DJI ribbon would have meant **only two** wires were realistically usable for a clean Walksnail hookup without relay / GPIO games, so the **Lucid DJI pigtail was not used** for the VTX.

**As built:** **Walksnail kit pigtail** (**JST** lead) **soldered straight to the FC** (appropriate **power + GND** and **UART3** / **TX3-RX3** pads) instead of splicing two wires into the DJI harness.

**Walksnail VTX pigtail (factory diagram):** Power **red**, **GND** black. UART: **white** = **UART RX** (to **FC TX**), **grey** = **UART TX** (to **FC RX**). When using **FC UART3** pads, **white-white** and **grey-grey** to Lucid **TX3**/**RX3** if colors align. Diagram: [attachments/walksnail-vtx.webp](attachments/walksnail-vtx.webp). Swap TX/RX if MSP/OSD is dead. Kit and goggles PDFs: [flight-platform.md](flight-platform.md#fpv-walksnail-avatar-hd-pro-kit).

**Unused / spare:** Lucid **DJI-style** ribbon (cut or left unterminated for VTX). On that harness, **RX1 / S.Bus** (yellow) and extra **GND** (brown) were already irrelevant to Walksnail; cap or heat-shrink if the tail remains in the build.

### M100 Pro GPS, FC mount, ELRS antennas, rangefinder deferred

**HGLRC M100 Pro harness:** The **insulation color order along the cable does not match** the connector **pin order** in the HGLRC manual (which agrees with the labels on the board). Colors are in reverse order, esp black and red are NOT power.

**Compass (USB-only bench, Mission Planner):** **I2C1** -- **QMC5883L** at **13** (**0x0D**). **Setup > Mandatory Hardware > Compass** -- **Onboard Magnetic Calibration**, **Default** fitness, bench rotation; MP **accepted**, **reboot**. **Yaw270** autodetected.

**GPS (USB, indoor bench):** **Kitchen table**, near windows, **another floor + attic** above (weak sky). Map: credible lat/lon. **gpsstatus=3**, **gpshdop=1**, **gpsh_acc=0.704**, **gpsv_acc=1.037**, **gpsvel_acc=0.05** -- **UART2** / **M100** / ArduPilot GPS path OK.

**GPS time / RTC (observed):** **Full Parameter List** **gps-time** shows **1970** (diagnostic). **SYSTEM_TIME** MAVLink: same stuck epoch; **time_boot_ms** advances. **BRD_RTC_TYPES** at stock (**GPS** bit set).

**ArduPilot Copter 4.6.3 reference (why RTC may stay unset despite 3D):** [send_mavlink_gps_raw](https://github.com/ArduPilot/ardupilot/blob/Copter-4.6.3/libraries/AP_GPS/AP_GPS.cpp) (~L1384--1387): **GPS_RAW_INT.time_usec** = **`last_fix_time_ms*1000`** (boot-relative, not Unix). [update_instance](https://github.com/ArduPilot/ardupilot/blob/Copter-4.6.3/libraries/AP_GPS/AP_GPS.cpp) (~L984--990) + [time_epoch_usec](https://github.com/ArduPilot/ardupilot/blob/Copter-4.6.3/libraries/AP_GPS/AP_GPS.cpp): **`set_utc_usec`** only if 3D and **`time_epoch_usec()!=0`**; needs **`time_week!=0`**. [UBLOX PVT / TIMEGPS](https://github.com/ArduPilot/ardupilot/blob/Copter-4.6.3/libraries/AP_GPS/AP_GPS_UBLOX.cpp) (~L1743--1768): **`time_week`** from **NAV-TIMEGPS** when **`valid & 0x02`** (u-blox **weekValid**); **NAV-PVT** sets iTOW / **`time_week_ms`**, not **`time_week`**. [AP_RTC::set_utc_usec](https://github.com/ArduPilot/ardupilot/blob/Copter-4.6.3/libraries/AP_RTC/AP_RTC.cpp) (~L54, ~L77): rejects UTC before **2022-01-01**. **Next:** **NAV-TIMEGPS** on UART, **`valid`** includes **0x02**.

**Time sync:** **Not** treating **"push time from Mission Planner / GCS each session"** as an acceptable end state (session-dependent, behavior changes with vs without laptop). **Current:** RTC still unset on this bench setup (see above). **Future stack** (GNSS, PPS, F9P, coordinator, etc.) and how it will discipline the FC clock are **TBD** -- not documented here as done or decided.

**Power:** M100 Pro is wired to the Lucid **4V5** rail (not **5V**) after checking it is within the module **3.6--5.5 V** input spec. This means it can get a **GPS fix from USB-only** FC power (no main flight battery).

**FC:** Board **secured** in final stack position (mounting complete for flight stack wiring phase).

**ELRS R24-TD antennas:** One **vertical** at the **tail**, placed **between** the two **V-shaped Walksnail VTX** antennas. Second **horizontal** out the **side**, mounted on the **tail** of the **zip tie** that **strain-relieves** the **rear power lead** to the **rear standoff**. **Board mount:** starboard, behind/outboard of stack, ahead of VTX, **VHB** -- see [flight-platform.md](flight-platform.md#receiver-matek-elrs-r24-td).

**GEPRC Super Buzzer:** Port side, symmetric to RX, **VHB**, button reachable -- see [flight-platform.md](flight-platform.md#buzzer-and-power-accessories).

**Rangefinder (TFS20-L):** **Not soldered yet.** Factory leads are **very fine** with an outer that feels almost **woven**; **insulation does not strip** cleanly like normal hookup wire (hard to separate jacket from conductor without damage). Defer until a workable technique (hot strip, chemical, replacement pigtail, or vendor guidance). When installed, params in [ardupilot.md](ardupilot.md).

### Matek ELRS R24-TD: firmware 3.6.3 and house WiFi (2026-04-15)

Updated the **Matek R24-TD** to **ExpressLRS 3.6.3** and got it onto **house WiFi** (connection had been **fragile** earlier, so minimal churn on the network side). **DHCP reservation** at **10.0.4.65** -- awkwardly **in the middle of the LAN range**, but chosen to **avoid reworking** addressing while things were still touchy. DNS name **rekon-rx.local.symmatree.com** points at that address. Public kb stub: [rekon-rx](../../kb/rekon-rx.md).

### RC link breakthrough after FT232H reflash + parameter churn (2026-04-17)

Reflashed the **Matek R24-TD** over USB using an **FT232H**, then iterated through ELRS / ArduPilot parameter tweaks and telemetry discovery work.

Also ran the Boxer's own **on-radio calibration** flow this morning (internal stick/pot calibration). This explains the `config/RADIO/radio.yml` calibration deltas; those edits are **radio-local calibration state**, not direct RF-link behavior changes. That handset calibration was done before Mission Planner FC-side radio calibration.

Observed result: Mission Planner **Radio Calibration** now shows **green moving channel bars** for the Rekon10 model (first successful FC-side RC input indication in this build thread).

Current interpretation: RF link quality had improved earlier (including better dual-antenna behavior after physical rework), but this step is the first clear confirmation that RC data reaches the FC.

### First flight (2026-04-19): outdoor hop, mishap, log alignment

**Preflight / mode:** **Loiter** would not arm (GPS / pre-arm unhappy despite a **3D**-class indication on the HUD at times). Flew in **Stabilize**; the **DataFlash** `MODE` line at arm matches **ModeNum 0** for the powered segment, with **no mode change** during the hop.

**What happened (pilot + DVR + attitude log):** After arm, roughly **four seconds** of mostly straight climb, a **slight right** tendency, then a **strong right bank** on the order of **sixty degrees** while **roll and pitch sticks stayed flat** in `RCIN` (**C1**/**C2** on trim). A few seconds later the craft was **lower bank** but **picking up sideways speed and height**; the pilot **disarmed in the air**. DVR: **sharp forward tumble** (nose through vertical), a **brief upright** moment, then **on edge in mud** with **props buried**.

**Log artifact:** Mission Planner **DataFlash download** over USB (no SD pull). On-disk name reflected unset RTC (**`1980-01-12 14-29-50.bin`**). **Armed segment ~7.6 s** in that file.

**Explanation (as far as the log goes, not a court verdict):** This does **not** look like **pilot roll or pitch stick** driving the event: **`ATT.DesRoll`** (radians in the log; **~56 deg** at the spike) **does not** line up with **flat `RCIN.C1`**. **`ATT.Roll`** then runs out to **~80 deg** while **`DesRoll`** is already back near **zero** -- **attitude diverging from commanded lean**, not a sustained stick command. Around that same era, **`XKF4`** shows the **`GPS` diagnostic field** stepping **8 -> 0** on both EKF cores with **`SV` rising** -- **EKF / GPS trust or validity changed hard at essentially the same time** as the large **`DesRoll`** spike. **`MSG`** in the same session includes **EKF3 mag / yaw alignment** traffic, consistent with **compass / yaw / estimator stress**, not a clean GNSS story.

**Hypothesis (explicitly uncertain):** The stack may have **acquired a fix or finished a configuring path**, **or** a **timeout / autoconfig path failed**; **either way**, a **sudden change in whether GPS data is treated as valid for the EKF** is **plausible** and matches the **`GPS` field in `XKF4` flipping to zero** at the spike. **Loiter was already locking you out**, so **deep GPS diagnosis did not happen in the field** -- that stays **bench work (P6 and P7)**.

**Multi-axis desired attitude at the DesRoll spike:** On the **`ATT` sample at peak `|DesRoll|`**, **`DesRoll`** is about **+56 deg** (from radians in the `.bin`) while **`DesPitch`** is about **-11 deg** -- **roll and pitch demands do not line up as a single coordinated bank**, which fits **haywire** feel. **`DesYaw`** in **`ATT`** is a **yaw angle / heading-style field (degrees)**, not the same kind of **body lean** as **`DesRoll` / `DesPitch`**; treat **yaw** next to them as **heading solution churn**, not a third **stick-rate** axis unless you also check **`RATE`** or **RC yaw**.

**GNSS quality over the armed segment (same log):** **`GPS` `NSats`** ranges **10 to 17**; **`HDop`** ranges **1.82 to 4.02** -- consistent with **satellite count dropping** and **HDOP rising** at times during the hop, even if a single 100 ms slice near the spike can look flat.

**VIBE:** In flight, **motor-related vibration** tends to look **similar across axes** and **between IMU0 and IMU1**. The **ground impact** reads as a **directional** impulse (one horizontal axis and **Z** dominate briefly) rather than **uniform** prop energy -- useful contrast when scanning **`VIBE`** for **flight vs crash**.

**Damage:** **Mud on props**; no broader airframe note from this flight.

**Longer log narrative:** When Task **P1** lands in [telemetry-and-logging.md](telemetry-and-logging.md), point the detailed **PreArm chain**, plots, and verdict there; this section stays the **build-log chronicle**.
