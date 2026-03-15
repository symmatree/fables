# 10" Macro Long Range: Rekon 10 Pro + swappable top payload

One ArduPilot-based 10" quad: **Rekon 10 Pro** frame, large XING motors, 2-blade 10x4.5 props. **Raspberry Pi 5 (4 GB) + OAK-D** stay mounted most of the time (dismount for crawler/sled). **RTK (F9P + antenna) is hard-mounted as close as possible to the OAK-D** so RTK and VO (from OAK-D via Pi 5) don't fight when both feed the FC (same rigid reference); **the mast is always mounted**. We **add upward cameras** when needed (under-canopy / panos). Underpod carries downward/side cameras and connects via umbilical. Focus: capacity, low noise, open config (ArduPilot, own on/off-board code).

---

## Platform

- **Frame:** **Rekon 10 Pro 455 mm** (original / lightweight Long Range variant). **Chosen** — available from US sources (GetFPV, Next FPV, Amazon, etc.); prefer one or two vendors for the build. See **Original vs V2** below for comparison (we're not taking V2). **Stack:** FC 30.5×30.5 mm (M3), 20 mm cavity (Z), no published max footprint (X/Y); plates 3/2/3 mm; standoffs 20/18/30 mm in kit.
- **Rekon 10 Pro: Original vs V2 (reference; we chose 455 mm)**

  **Availability (check at order time):** The 455 mm frame has been listed as "Rekon10 PRO Long Range Frame Kit" at Rekon FPV, GetFPV, Next FPV, Amazon; some retailers have shown it sold out. The 474 mm frame is listed as "HGLRC Rekon10 PRO V2 10-inch long-range Frame" at Rekon FPV ($109.99). (Both product titles include "long-range"; we don't have evidence that "Long Range" means only the 455 mm variant.) Confirm stock when ordering.

  **Side-by-side:**

  | | **455 mm variant** (no "V2" in product name) | **V2** (474 mm, "V2" in product name) |
  |---|:---|:---|
  | **Wheelbase** | 455 mm | 474 mm |
  | **Frame weight** | ~397 g (kit) | 567 g ±5 g (frame + antenna mounts, screws, anti-slip pads) |
  | **Top / middle / bottom plate** | 3 mm / 2 mm / 3 mm | 2 mm / 3 mm / 3 mm |
  | **Arms** | 8 mm | 8 mm |
  | **FC mounting** | 30.5×30.5 mm (M3) | 30.5×30.5 and 20×20 mm (M3) |
  | **Stack cavity (top–middle)** | 20 mm (documented) | 20 mm (per typical listings; confirm on V2 product page) |
  | **Structure** | Optional 2 mm reinforcement bars (kit dependent) | Triangular reinforcement structure (built in) |
  | **Front / camera** | Carbon | CNC aluminum front (stronger, better camera protection) |
  | **Antenna** | You mount yourself | Detachable vertical antenna mounts (ELRS dual-frequency style) |
  | **Other** | Dual battery (top/bottom) | RGB lighting option; marketed for DJI O4 |

  **Why is V2 heavier (~170 g)?** (1) **Larger frame** — 474 mm vs 455 mm and larger overall footprint (498×327 mm vs smaller). (2) **Triangular reinforcement** — extra carbon structure for stiffness and noise suppression. (3) **CNC aluminum front** — metal nose instead of carbon. (4) **Integrated antenna mounts and hardware** — the 567 g explicitly includes antenna mounts, screws, anti-slip pads; the 455 mm frame's ~397 g is often "frame kit" with standoffs/screws too, so compare like-with-like when you can.

  **What you get for the weight:** Stiffer, quieter platform (triangular structure); better camera protection (CNC front); vertical ELRS antenna mounting without DIY; O4-ready if you ever switch. **Do we want it?** For this build (ArduPilot, WalkSnail, payload): stiffness and clean antenna mounting are pluses; the extra ~170 g costs payload or flight time. We don't need O4. So it's a real trade: lighter and simpler (455 mm variant) vs stiffer and more integrated (V2). If you don't know which frame you were looking at in past evaluations, the table above is the place to line them up — same row = same dimension so you can see the difference at a glance.
- **Frame reinforcement bars (optional):** Some Rekon 10 Pro frame kits (455 mm variant product listings and part lists) include **2x 2 mm rack protection / reinforcement bars** that run parallel to the body between the motor mounts. They appear in some product photos and part lists but not others; inclusion may vary by retailer or batch. Installation is likely **optional** — add for stiffness and arm protection, omit for weight or clearance. Confirm kit contents when ordering; decide fit vs payload/antenna layout.
- **Antenna mounting (455 mm, our plan):**  
  - **WalkSnail (FPV) — 2× VTX antennas:** Put the **two** WalkSnail VTX antennas in the **angled TPU mounts at the stern** that Rekon provides (same stern area as air unit mount A/B).  
  - **ELRS (telemetry/control) — 2× R24-TD antennas:** **Matek R24-TD** (true diversity, 2.4 GHz, still under ~$50; gives better chance of getting a control signal through in an emergency). Mount the two ELRS antennas on **zip-tie "tails" with heatshrink tubing**: **one antenna out to the side**, **one straight up**. **Compatible with RadioMaster Boxer** (or any 2.4 GHz ELRS transmitter): true diversity is receiver-side only (two antennas on the craft); the handset needs no special support.  
  - **RTK helical** stays on the mast (center/top), not at the stern.  
  - **V2 variant:** Has integrated detachable vertical antenna mounts (ELRS style); we're on 455 mm with the above plan.
- **Battery (6S, single pack):** **Chosen — iFlight Fullsend 6S 8000 mAh Li-ion** (not LiPo; matches other iFlight components). **Specs:** 42×64×147 mm (W×D×L), ~840 g, 6S2P EVE INR21700-40PL, 17.5C, XT60H-F, 177.6 Wh. Frame supports **dual battery (top and bottom)**; design can take two packs **end to end** along the body. **Top deck fit with Pi 5 + OAK-D at front:** Frame overall **476×298 mm** (body length × width); kit includes 20×250 mm straps. One 8000 mAh pack is **147 mm** along its long axis, so a single pack on top uses ~147 mm of the 476 mm length, leaving **~330 mm** along the body for stack (center) and payload at the front — **Pi 5 + OAK-D at the front should fit with the 8 Ah pack on top**. Two 8000 mAh packs end-to-end would be 294 mm; that fits within 476 mm but may need a longer strap or different strap layout than the supplied 250 mm; for now we run **one pack on top**. Verify at build: pack orientation (147 mm along body), strap placement, and clearance to mast/Pi 5/OAK-D. Belly pod + second pack later = open item.
- **Motors / props:** Large **XING** motors (3110/3314 class), **2-blade** 10x4.5 (e.g. HQProp 10x4.5 or Gemfan 1050 bi-blade).
- **FC:** **Matek H7A3-SLIM** (ArduPilot MATEKH7A3, 30.5 mm, 6 UARTs, 11 PWM, OSD). **ESC:** **iFlight Blitz E80 Pro** (4-in-1, 80 A cont. / 100 A burst, 2–8S, DShot, BLHeli_32, telemetry, ~65 g, 35x35 mm). **30x30 to 35x35 mounting adapter** included in E80 Pro G2 "w/ cover" bundle (e.g. GetFPV) for 30.5 mm stacks. **One combined link** for telemetry and RC (see below); no separate telemetry radio and RC radio.
- **Flying:** Waypoint missions first; minimal manual control (arming/override). **WalkSnail Avatar HD Pro** for control feedback (see BoM); ground = goggles or VRX + screen.
- **Payload power:** **10A 5V UBEC** (input must support **6S**; 2–6S or similar is fine). **Pi 5** via **GPIO 5V pins** from UBEC (no barrel jack; Pi 5 uses USB-C for desktop power but GPIO 5V is standard for embedded/drone use). **OAK-D** via **barrel jack** (pigtailed from UBEC). Part TBD — Matek does not make a 10A unit; see BoM "Payload UBEC options" for candidates.

### Combined link: one radio on the vehicle for telemetry and control

**Handset** (**RadioMaster Boxer**) = the device in your hands that you use to send commands: sticks, switches, arm, override. That is the primary command device for the pilot.

**GCS (ground control station)** = the software (e.g. Mission Planner, QGroundControl) and the device it runs on (laptop, tablet). Used for mission planning, parameters, and telemetry; it can also send MAVLink commands when connected. The "physical box" for GCS is a laptop or tablet — separate from the handset.

**Architecture we want (and why)**  
One link. Sticks and telemetry on the **same** link. You do **not** buy another radio for the GCS. The **handset is the only ground-side radio**. It carries (1) your stick/switch input to the vehicle and (2) MAVLink (telemetry and commands) on that single RF link. If you want to see telemetry on a laptop or tablet (GCS), you connect the GCS to the **handset** (USB or the handset's WiFi backpack) — the GCS is just a client of the handset, no extra radio. One radio on the vehicle (ELRS receiver), one radio on the ground (the handset). Reasons: minimize radios and antennas, one link for the most critical traffic, no separate "telemetry radio" to buy or mount.

**How we get that:** **ELRS in MAVLink mode**. One ELRS receiver on the craft, one ELRS transmitter in the handset (Boxer). Same RF link carries RC and MAVLink. GCS (laptop/tablet) connects to the handset via USB or Backpack WiFi to display telemetry and send MAVLink commands — no second link, no second radio.

Handset data (sticks, switches) can go over MAVLink (e.g. MANUAL_CONTROL); ELRS in MAVLink mode carries both RC and MAVLink natively on one link, so we use that. It's a quirk of the ecosystem that the traditional "telemetry" link (MAVLink over SiK) wasn't the one carrying pilot input; ELRS in MAVLink mode fixes that.

### Ground station transmitter (RadioMaster Boxer ELRS)

**Role:** Handset for RC (arming, override, minimal manual) and, when using **ELRS as the combined link**, the same link carries MAVLink to the GCS (Mission Planner, QGC via USB or Backpack WiFi). So: **one link** = RC + telemetry; no separate telemetry modem.

**Boxer + ELRS receiver = combined link.** Set ELRS to **MAVLink mode**; the receiver feeds one FC UART with both RC and MAVLink. GCS connects to the Boxer (USB or TX Backpack WiFi). No RFD900x or other second radio.

**RadioMaster Boxer: no 915 MHz internal.** RadioMaster does **not** offer a 915 MHz internal ELRS module for the Boxer. The Boxer is sold with one of three **internal** RF options, all 2.4 GHz–centric:

| Version | What it is | Use for us |
|--------|------------|-------------|
| **CC2500 (FCC)** | Single 2.4 GHz chip. Protocols: FrSky, Futaba SFHSS, Hitec, Radiolink, Esky, Corona. | No. No ELRS. |
| **4in1 (FCC)** | Multi-Protocol (MPM): multiple 2.4 GHz chips; DSM, Flysky, FrSky, etc. | No. No ELRS. |
| **ELRS (FCC)** | Internal ExpressLRS, **2.4 GHz only**. Up to 1W FCC. | **Yes.** Boxer ELRS = 2.4 GHz combined link (RC + MAVLink). For 915 MHz use external module (e.g. Bandit Micro 915 MHz). |

**2.4 GHz vs 915 MHz:** 915 MHz has better propagation; 2.4 GHz has higher data rate (better for MAVLink), lower latency, and no external module. For a **combined link**, **Boxer 2.4 GHz ELRS** is a good fit: one radio on the vehicle, one link for telemetry and control.

### Other frame options (reference)

| Frame | Link | Wheelbase | Weight (est.) | Notes |
|-------|------|-----------|---------------|--------|
| **Nazgul XL10 V6** | [Frame kit](https://shop.iflight.com/xl10-v6-10-inch-fpv-frame-Pro1967) | 420 mm | ~343 g | True-X; 16/19 mm motor; 30.5 / 20x20 stack; 7 mm arms. |
| **Helion 10** | [Frame kit](https://shop.iflight.com/) (search "Helion 10 frame") | 418 mm | — | A-frame, aero shell; same class as full Helion 10 build. |
| **CX10 ECO** | [Frame kit](https://shop.iflight.com/CX10-ECO-Frame-kit-Pro2081) | 452 mm | ~383 g | 6 mm arms; 16/19 mm motor; 30.5 stack; Chimera series. |

**Full builds as reference (not our stack):**
- **[Nazgul XL10 V6 6S](https://shop.iflight.com/XL10-V6-6S-Pro1974)** (BNF, ~$540): 420 mm wheelbase, **XING2 3314 900 KV** motors, **HQ 10x4.5x3** (tri-blade), BLITZ F722, 55 A ESC, ~860 g without battery. ~40 min hover with 6S 8000 mAh Li-ion. Same 10x4.5 pitch we want, but tri-blade; we prefer 2-blade. Frame is the [Nazgul XL10 V6](https://shop.iflight.com/xl10-v6-10-inch-fpv-frame-Pro1967) above.
- **[Chimera CX10 ECO 6S](https://shop.iflight.com/Chimera-CX10-ECO-6S-Pro2067)** (BNF, ~$347): 452 mm wheelbase, **XING-E 3314 900 KV** motors, **HQ 10x4.5x3** (tri-blade), BLITZ ATF435, 55 A ESC, ~810 g without battery, ~1706 g with 6S 8000 mAh. ~20 min hover; payload 1.5–2.5 kg. Lighter/cheaper ECO build; frame is the [CX10 ECO](https://shop.iflight.com/CX10-ECO-Frame-kit-Pro2081) above.
- **[Helion 10 O4 6S HD](https://shop.iflight.com/Helion-10-O4-6S-HD-Pro2325)** (BNF, ~$930) and **[Helion 10 O4 6S HD RTF](https://shop.iflight.com/Helion-10-O3-6S-HD-RTF-Pro2134)** (Commando 8 + DJI Goggles 3, ~$1,570): 418 mm wheelbase, **3110 900 KV** motors, **GEMFAN 1050** props, BLITZ F7, DJI O4, ~1072 g without battery, ~1912 g with 6S 8000 mAh, 23–30 min. We want **Matek H7A3-SLIM** (ArduPilot) and **2-blade** (e.g. 10x4.5), not BLITZ (Betaflight) or tri-blade.

---

## Propellers

- **Size/pitch:** **10x4.5** (10" diameter, 4.5" pitch). Low pitch keeps current draw limited and gives a softer "woosh" sound.
- **Candidates:** **HQProp 10x4.5** bi-blade; **Gemfan 1050** bi-blade. (Many Gemfan "1050" listings are 10x5 tri-blade; confirm bi-blade 10x4.5 or equivalent if you want direct comparison.)
- **Bi-blade:** Fewer blades = better efficiency and less drag in forward flight, which suits long-range and waypoint cruise; tri-blade adds thrust and authority at the cost of higher current.

---

## Motor, battery, and prop: why 3110, KV 900–1100, 6S

Summary of the criteria and tradeoffs so you can choose or sanity-check parts.

**Stator size (3110)**  
- Format **XXYY** = stator outer diameter (mm) x stator length (mm). So **3110** = 31 mm diameter x 10 mm length.  
- This size class can spin 10" props without overloading: enough torque and thermal mass for 10" at moderate RPM. Smaller (e.g. 2814) can work but 3110 is a common match for 7–10" long-range/cinelifter.  
- Bigger stator diameter = more torque for the same KV; longer stator = more copper and power handling. 3110 is in the "sweet spot" for 10" on 6S.

**KV (900–1100)**  
- **KV = RPM per volt** (no-load). So at 6S nominal 22.2 V: 900 KV → ~20k RPM, 1100 KV → ~24.4k RPM.  
- **Lower KV** = lower no-load RPM, **higher torque per amp**. For a given prop, lower KV draws less current at the same thrust (and runs cooler). Too low and you may lack headroom for climb or wind.  
- **Higher KV** = more RPM, more current for the same thrust, more heat. 900–1100 on 6S with 10" keeps the system in a range where efficiency is good (often best around 40–60% throttle) and you are not constantly at max current.  
- Rule of thumb: same *power* with higher voltage needs lower KV. So 6S uses lower KV than 4S for the same prop size.

**Battery: what "S" is, and 4S vs 6S vs 8S**  
- **S = cells in series.** Each LiPo cell is ~3.7 V nominal (~4.2 V full). So: **4S** ≈ 14.8 V nominal, **6S** ≈ 22.2 V, **8S** ≈ 29.6 V.  
- **Same power** at higher voltage = **lower current** (P = V × I). So 6S draws less current than 4S for the same thrust; 8S draws less than 6S.  
- **4S:** Lower voltage. To spin a 10" prop at useful RPM you need **higher KV** motors (e.g. 1400–1700 KV). That means **higher current** for the same thrust → more voltage sag, hotter motors/ESCs, and you need a higher C-rating pack. Lighter pack for same capacity (fewer cells) but the system runs at higher amps. Common for smaller quads; for 10" LR it's the exception.  
- **6S:** Sweet spot for 10" LR. **Lower KV** (900–1100) keeps current down, less sag, cooler run, and the 3110 + 10x4.5 combo is well matched. Huge choice of 6S packs and ESCs. This is the standard for your class.  
- **8S:** Higher voltage → **even lower KV** (e.g. 700–800) and lower current for the same power. Theoretically more efficient and easier on the pack, but: (1) pack is heavier (more cells) for the same capacity; (2) many ESCs/FCs are 6S‑max unless you pick 8S‑rated parts; (3) less common for 10" so fewer off‑the‑shelf motor recommendations. Makes more sense for very heavy lifts or 12"+ where you want to minimize current.  
- **Flight time** depends on **total energy (Wh)**, not S. A 6S 5000 mAh pack (111 Wh) has the same energy as a 4S 7500 mAh (111 Wh); the benefit of 6S is *how* that energy is delivered (lower current, less sag, often better efficiency in the mid-throttle band), not more Wh per cell.

**Low pitch (4.5)**  
- Lower pitch loads the motor less at a given RPM than high pitch: less thrust per revolution but also **lower current** and less risk of overcurrent. So 10x4.5 limits peak and cruise current compared to e.g. 10x5 or 10x6.  
- Softer, "woosh" sound comes from lower tip speed and less aggressive bite.  
- Tradeoff: for pure cruise at one speed, a higher pitch can sometimes be more efficient (same thrust at lower RPM); but for a versatile waypoint platform with climb and margin, 4.5 is a good compromise and keeps the system within a comfortable current envelope.

**Practical takeaway**  
- **3110 900–1100 KV, 6S, 10x4.5 bi-blade** = enough thrust for 10" + payload, good efficiency in the mid-throttle range, limited current draw, and a quiet profile. Lock exact motor model and prop (HQProp 10x4.5 vs Gemfan 1050 bi-blade) after checking availability and any test data.

---

## Payload packages

### 1) Upper-side positioning package (RTK + OAK-D, always on)

- **Role:** RTK GNSS for precise position (clear sky view) and **visual odometry** to the FC; VO is useful even in the far field. **F9P + OAK-D hard-mounted together** (same rigid reference) so RTK and VO don't fight when both feed the FC. Color + depth from OAK-D for stitching and under-canopy mapping.
- **Contents:**  
  - **RTK:** F9P on SparkFun breakout (ZED-F9P, 7 g), **helical antenna** on mast, PCB ground plane under antenna. **Power:** F9P from payload UBEC — 5V and GND to breakout VCC/GND (SparkFun ZED-F9P accepts 3.3–5.5 V; use same 5 V rail as Pi 5/OAK-D or a small 3.3 V regulator if required by your breakout). **Connection:** F9P → FC on UART (SERIAL3) for nav; **F9P → Pi 5 on Qwiic/I2C** for fine-grained GPS status/telemetry (signal strengths, lock quality, etc.) that the Pi 5 logs and/or forwards. F9P message sets per interface so UART and I2C streams don't collide. See "GPS (F9P), FC, and Pi 5" under Onboard communications.  
  - **Mast:** ~10 cm rigid mount (no fold). **TPU + epoxy** to secure to base board; top piece to mate **ground plane** and **helical antenna**. Always mounted. **Ground plane:** PCB, est. 30 g; mounts at top of mast. **Antenna:** **SparkFun GNSS L1/L2/L5 Helical (Locking SMA)** (25 g, GPS-30249). **ANN-MB-00** (ceramic, 173 g) only if needed for debugging.  
  - **OAK-D:** Camera/processor; VO to FC via Pi 5 (see [ArduPilot OAK-D VIO guide](https://ardupilot.org/copter/docs/common-vio-oak-d.html)); color/depth for off-board processing. Est. 115 g.
- **Rekon TPU GPS mount (stern):** The frame kit can include a **TPU GPS mount at the stern**, angled **slightly below horizontal**. We **don't use it for RTK** here because **co-location**: the stern is far from the OAK-D (payload area); RTK and VO need to be on the same rigid reference. We **stick with the mast** (antenna up, F9P/antenna/ground plane in one assembly near the OAK-D).

### 2) Downward-ish and upward image capture (underpod + swappable top)

- **Underpod:** Shell for weather protection; downward/side cameras (and optionally interface or storage). **Umbilical:** power from UBEC, trigger from FC; maybe telemetry (position) or just record on trigger and align by frame count later. See "Underpod" section.
- **Start (certain):** Two cameras on Pi 5's two CSI ports: **2× [SparkFun Raspberry Pi Camera Module 3](https://www.sparkfun.com/raspberry-pi-camera-module-3.html)** (SEN-21331) — 76° FOV (standard lens), 12 MP Sony IMX708, CSI-2, autofocus, HDR; **~$33 each**. **Native on Pi 5** (no driver or voltage issues). **Expansion (revisit):** Underpod / upper array — muxer vs CamArray vs USB Shield not decided; see Underpod "Multi-camera expansion."
- **Upper (added for under-canopy / panos):** Upward-facing cameras (e.g. four at ~45 deg for canopy-from-below or pano); mast stays on for RTK.
- **Use cases:** **Overhead:** RTK + mast + underpod (down/side cams). **Under-canopy / panos:** add **upward cameras**; OAK-D + underpod + upward cams + RTK. Open question: how much pano on a **global trigger** (all cams fire together)?

---

## Underpod (shell, cameras, umbilical)

- **Role:** Weather-protected shell under the fuselage; holds downward/side-looking cameras and optionally interface or storage logic.
- **Umbilical:** At least **power** (from UBEC) and **trigger line** (from FC). Optionally telemetry (e.g. current position) — or underpod may just **record on trigger** with no high-res GPS timestamp and we align by **frame count** later.
- **Coordinate frame / trigger:** **Certain for first pass:** the **two cameras directly on the Pi 5** (two CSI ports). **Maybe:** triggering the **OAK-D** as well, if we can still run it at high rate for visual odometry. Beyond that, multi-camera expansion (underpod, upper array) needs a revisit — see "Multi-camera expansion" below.
- **Multi-camera expansion (revisit):** The **muxer** concept is not settled. Options: **(1) CamArray** — simultaneous trigger, but packs all feeds at **1/4 resolution** (tiling). **(2) Muxer** — **sequential** trigger/readout (not simultaneous); simultaneous trigger with sequential readout would be ideal but may not be available. **(3) USB Shield** — converts to USB stream, also **1/4 resolution** tiling. So: only the two direct Pi 5 cameras are certain; OAK-D trigger is a possibility if VO rate is preserved; any lower/upper array beyond that depends on choosing among CamArray vs muxer vs USB Shield (and accepting sequential capture or 1/4 res where applicable).

---

## Compute, storage, and power

- **Companion:** **Raspberry Pi 5 (4 GB)** (two CSI camera ports, M.2 via HAT+, 2× USB 3.0). Start with **2× SparkFun Raspberry Pi Camera Module 3** (76° FOV, 12 MP IMX708) — **native on Pi 5**, no driver or voltage issues. VO from OAK-D via Pi 5 (see [ArduPilot OAK-D VIO guide](https://ardupilot.org/copter/docs/common-vio-oak-d.html) — lists Pi 4 / Pi 5 as supported). No USB hub for now. Software stack: **ROS containers** and/or **MQTT + containers**; see Observability below for logging/telemetry. **Tradeoff vs Jetson Nano (previously planned):** Pi 5 has no CUDA GPU; if on-board neural inference beyond OAK-D's Myriad X VPU is ever needed, that path is closed. Pi 5 CPU (quad A76 @ 2.4 GHz) is faster than Jetson Nano CPU (quad A57 @ 1.43 GHz) for non-GPU workloads.
- **Storage:** **[Raspberry Pi SSD Kit for Raspberry Pi - 512 GB](https://www.sparkfun.com/raspberry-pi-ssd-kit-for-raspberry-pi-512gb.html)** (KIT-26688, ~$85; includes NVMe SSD + M.2 HAT+). Connects via Pi 5's PCIe 2.0 x1 lane — **no USB port consumed**, so OAK-D gets full USB 3.0 bandwidth to itself. 50K/90K IOPS (4KB random read/write). Stacks directly on the Pi 5 (M.2 HAT+ sandwiches above or below board); mechanically solid (screw-mounted, no cable to flex). Can boot OS from NVMe (no microSD needed). Monitor temperature; consider heatsink on the SSD if sustained writes are heavy.
- **Power:** **10A 5V UBEC** (6S-capable input; part TBD). Power **Pi 5 via GPIO 5V pins** from UBEC (standard for embedded/drone use; bypasses PMIC but avoids a USB-C cable). Power **OAK-D from barrel jack** (pigtailed from UBEC). Underpod gets power from same UBEC via umbilical (see Underpod). **Peak current:** OAK-D can pull **1.5 A**; Pi 5 pulls **~2–3 A** typical under load (~3 A with two CSI cameras + OAK-D orchestration + NVMe writes); official Pi 5 PSU is 5 A but that includes peripherals and margin.

**Observability / logging (Pi 5).** Plan: run an **Alloy** (Grafana Alloy) pod (or equivalent) on the Pi 5 to collect host and container logs and metrics and **push to Tiles** (shared Mimir + Loki backend) when WiFi is available. Degrades gracefully when we lose WiFi in the field — buffering or dropping metrics as needed; optionally **onboard logging** (e.g. to NVMe) so we keep logs regardless. This is **higher-volume** than the telemetry radio (ELRS/MAVLink); the radio stays for control and essential telemetry. Rich GPS status (from F9P over I2C), container metrics, and app logs go via Alloy/WiFi or to local storage.

---

## Weight budget (by unit)

Weights are estimates; verify with actual parts. **Terms:** **Platform** = frame + motors + props + FC + ESC + ELRS + WalkSnail (no battery, no payload). **Aircraft without battery** = platform + payload. **AUW** = aircraft with battery. See example totals below.

| Unit | Item | Weight (g) | Notes |
|------|------|------------|--------|
| **Platform** | **Frame** | **397** | Rekon 10 Pro 455 mm (kit with standoffs/screws). |
| | **Motors** | **208** | 4× XING 3110/3314 class, ~52 g each. |
| | **Props** | **68** | 4× 10x4.5 bi-blade, ~17 g each. |
| | **FC** | **25** | Matek H7A3-SLIM. |
| | **ESC** | **65** | iFlight Blitz E80 Pro 4-in-1. |
| | **Stack hardware** (adapter, screws, wiring) | **35** | 30×30 to 35×35 adapter, FC–ESC harness. |
| | **ELRS receiver** (Matek R24-TD + antennas) | **8** | True diversity RX. |
| | **WalkSnail Avatar HD Pro** (Avatar HD Pro Kit) | **32** | Camera 10 g, VTX 19 g, antenna 3 g. Camera 19×19×24 mm; VTX 33×33×10.5 mm. 6–25.2 V from flight pack or BEC. |
| **Payload** | **Pi 5 + power** | | |
| | Raspberry Pi 5 (4 GB) + active cooler | 60 | ~46 g board + ~15 g cooler (est); verify. |
| | M.2 HAT+ + 512 GB NVMe SSD | 18 | HAT+ PCB ~10 g + M.2 2230 SSD ~3 g + standoffs ~5 g. |
| | 10A 5V UBEC (6S-capable input; part TBD) | 18 | Placeholder; actual 18–36 g per unit. GPIO 5V to Pi 5; barrel to OAK-D; umbilical to underpod. See BoM options. |
| **Upper positioning (RTK + OAK-D)** | F9P breakout (SparkFun ZED-F9P) | 7 | Mast always on. |
| | OAK-D unit | 115 | VO via Pi 5; color/depth. |
| | Antenna: SparkFun GNSS L1/L2/L5 helical (Locking SMA) | 25 | GPS-30249; ANN-MB-00 (173 g) for debug only. |
| | PCB ground plane | 30 | |
| | Mast (10 cm rigid: TPU + epoxy; top adapter) | 15 | |
| **Lower array** (not in first pass; interface TBD) | 1x HQ camera + glass lens | 50 | Good Arducam or RPi module; -70 deg along travel. |
| | 3x Pi cams (plastic lenses) | 9 | 3 g each; sides/back at -70 deg. |
| | Interface: muxer vs CamArray vs USB Shield | TBD | Revisit: muxer = sequential; CamArray/USB Shield = 1/4 res tiling. See Underpod. |
| | CSI ribbons, standoffs, screws | 41 | |
| | Maltese cross mount (3D-print) | 30 | |
| **Upper array** (not in first pass; interface TBD) | 4x Pi cams at 45 deg | 12 | 3 g each; canopy-from-below. |
| | Interface: muxer vs CamArray vs USB Shield | TBD | Same tradeoffs as lower array. |
| | Mount | 30 | Lighter than lower (no heavy lens). |
| **Structure** (not in first pass) | Mounts, wiring, payload plate | 60 | Placeholder; measure at build. |

### WalkSnail Avatar HD Pro (control feedback)

- **On the aircraft:** **WalkSnail Avatar HD Pro** (Avatar HD Pro Kit): camera 19×19×24 mm (10 g), VTX 33×33×10.5 mm (19 g), antenna 3 g — **32 g total**. 1080p60, H.265, ~22 ms latency, up to ~4 km; 6–25.2 V input (typically from flight pack or separate BEC).
- **Antenna placement:** **WalkSnail (2×):** In the **angled TPU mounts at the stern** (Rekon). **ELRS / telemetry-control (2×):** **Matek R24-TD** (true diversity); mount on **zip-tie tails with heatshrink** — **one antenna out to the side, one straight up**. Keep all four clear of the Pi 5 heatsink and the RTK mast (and helical).
- **OSD overlay (preserve and use):** WalkSnail uses **MSP DisplayPort** — the FC sends **semantic** OSD (elements + positions) over serial; the goggles/VRX render it. The overlay is **not baked** into the video. Live view and DVR both keep OSD as a **logical layer**; the goggles/VRX record video and OSD/telemetry data separately, so you can re-render, change, or strip the overlay in post (e.g. walksnail-osd-tool). Use ArduPilot OSD_TYPE = 5 (MSP_DISPLAYPORT) and a dedicated UART (e.g. SERIAL5_PROTOCOL = 42) so this capability is preserved.
- **Ground side (choose one):**
  - **Goggles:** WalkSnail **Avatar HD Goggles L** (single 4.5" 1080p60, 75° FOV) or **Avatar HD Goggles X** (premium). Receiver is built in; no separate VRX.
  - **Screen:** WalkSnail **Avatar VRX** (standalone receiver, HDMI out). Power the VRX (7–25.2 V), plug HDMI into any monitor or small screen. No goggles required.
- Add air unit + antennas to the weight budget when fitting; ground receiver is not on the craft BoM.
- **FPV mounting compatibility (Rekon 10 Pro 455 mm variant):**  
  - **Camera:** Frame has a **20×20 mm** camera mount on the front/nose (per retailer specs and product pages). WalkSnail Avatar HD Pro uses a **Micro Camera Pro** (19×19×24 mm, M2 screws); 20×20 nose mounts are standard for this class, so the camera **should mount directly** on the frame nose.  
  - **VTX:** By Rekon design the air unit (VTX) mounts in the **air unit mount A and B** at the **stern** (rear), not on top of the stack. DJI O3 air unit uses **25.5 mm** mounting holes (per multiple sources). WalkSnail Avatar HD Pro VTX is **33×33×10.5 mm** with **20×20 and 25.5×25.5** hole patterns — confirm whether the Rekon stern mounts match one of these or need an adapter. **Mount method open:** use the frame's TPU mounts (if supplied), hard-mount to carbon, or print an adapter; decide at build time. **Cable length:** Camera at nose, VTX at stern; the included camera–VTX MIPI cable is ~12–14 cm. Nose-to-stern on the 455 mm frame may exceed that; builders using a rear air unit on this frame have used a **longer MIPI cable** (e.g. 200 mm for DJI O3). Confirm WalkSnail cable options or extension for nose–stern run at build time.

### Example totals

| Config | Units | Sum (g) | Notes |
|--------|--------|---------|--------|
| **Platform (no battery, no payload)** | Frame + motors + props + FC + ESC + stack + ELRS + WalkSnail | 397+208+68+25+65+35+8+32 = **838** | |
| **Payload (base / first pass)** | Pi 5 + cooler + NVMe kit + UBEC + upper positioning (F9P+OAK-D+helical+ground plane+mast) only | 60+18+18 + 7+115+25+30+15 = **288** | No lower array, no structure in first pass. |
| **Aircraft without battery (first pass)** | Platform + payload base | **838 + 288 = 1,126 g** | |
| **+ Battery (6S 8000 mAh Li-ion)** | | +840 | iFlight Fullsend; AUW ≈ **1,966 g**. |
| **+ Lower array + structure (later)** | Add lower array + structure | +204 | 50+9+14+41+30+60; when you add underpod hardware. |
| **+ Upper array (under-canopy)** | Add upper (4 cams + interface + mount) | +56 | 12+14+30; interface TBD (muxer/CamArray/USB Shield). |

---

## Power budget

**Payload (5 V from UBEC):** All values are estimates; measure in use to confirm. Payload is powered by a **10A 5V UBEC** (6S-capable input; part TBD) (50 W max).

| Component | Voltage | Current (A) | Power (W) | Notes |
|-----------|---------|-------------|-----------|--------|
| **Raspberry Pi 5 (4 GB)** | 5 V (GPIO pins) | ~1.5–3 typ; **to ~3.5 A peak** | ~8–15 typ; to ~18 W peak | GPIO 5V from UBEC; quad A76 @ 2.4 GHz; includes NVMe + 2× CSI camera load. |
| **OAK-D** | 5 V (barrel) | ~0.8–1 typ; **to 1.5 A peak** | ~4–5 typ; to ~7.5 W peak | Barrel from UBEC; not USB-powered. |
| **NVMe SSD (via M.2 HAT+)** | 3.3 V (from Pi 5 PCIe) | — | ~0.5–1 | Powered by Pi 5 PCIe rail; included in Pi 5 current above. No USB port consumed. |
| **Underpod / lower array** | 5 V (umbilical) | ~0.3–0.5 | ~1.5–2.5 | When used; cameras + logic. |
| **Upper array** | 5 V (or 3.3 V on CSI) | ~0.2–0.3 | ~1–1.5 | 4x Pi cams + interface (TBD); when swapped in. |
| **F9P breakout** | 3.3 / 5 V | <0.1 | <0.5 | Negligible on payload UBEC if fed from same 5 V. |

**Platform (from flight pack 6S or BEC):**

| Component | Voltage | Current (A) | Power (W) | Notes |
|-----------|---------|-------------|-----------|--------|
| **FC (Matek H7A3-SLIM)** | 5 V (from ESC BEC) | ~0.1–0.2 | ~0.5–1 | FC + receiver; BEC from Blitz E80 Pro. |
| **WalkSnail Avatar HD Pro** | 6–25.2 V (flight pack or BEC) | ~0.5–1 typ | ~4–10 | Air unit (camera + VTX); check spec for exact range. |
| **Motors (via ESC)** | 6S (22.2 V nom) | Variable (throttle) | Variable | Not a steady load; ESC draws from pack. |

**Payload example totals (5 V UBEC):** Base (Pi 5 + OAK-D; NVMe power included in Pi 5) ~2.5–4.5 A (~12–23 W). + F9P + underpod ~3–5 A (~15–25 W). Under-canopy config ~3.5–6 A (~18–30 W). OAK-D up to 1.5 A + Pi 5 up to ~3.5 A = 5 A for the two alone at peak; add F9P + underpod/upper and first-pass peak is ~5.5–6.5 A (~28–33 W). **Headroom:** 10A 5V UBEC (50 W) leaves **~3.5–4.5 A / ~17–22 W** margin at first-pass peak; expanded configs stay well under 10 A. USB bandwidth is no longer shared between OAK-D and storage (NVMe is on PCIe).

---

### Payload vs platform capacity (Rekon 10 Pro, XING 3110/3314, 10x4.5 2-blade, 6S)

Rough check that we stay in the comfort zone.

- **Thrust:** 3110/3314 900 KV on 6S with 10" props: with **10x4.5 bi-blade** expect **~2,700–3,200 g per motor** → **~11–13 kg total** for four motors.
- **From weight table (first pass):** Platform **838 g** + payload base **288 g** = **1,126 g without battery**. With 6S 8000 mAh Li-ion (~840 g) → **AUW ≈ 1,966 g**.
- **Thrust-to-weight:** 11 kg / 1.97 kg ≈ **5.6:1**; 13 kg / 1.97 kg ≈ **6.6:1**. Hover well below 50% throttle; plenty of margin. LR target at least 2:1; we're well above.
- **With lower array + structure (+204 g):** **1,330 g without battery**, AUW **~2,170 g** (T/W still ~5.1–6.0:1). With upper array too (+56 g): **1,386 g without battery**, AUW **~2,226 g** (T/W ~4.9–5.8:1). All configs stay in comfortable T/W range.
- **Weight headroom:** First-pass payload **288 g**; re-run T/W if total payload goes past ~700 g or you add a second pack. That leaves **~400 g** payload headroom before re-check; thrust margin is large.

**Verdict:** After Pi 5 + NVMe swap (from Jetson Nano + SanDisk USB SSD): **weight** — first pass **1,126 g without battery**, **AUW ~1,966 g**, T/W 5.6–6.6:1; expanded configs still 4.9–5.8:1. **Power** — first-pass peak ~5.5–6.5 A on 10 A UBEC (~3.5–4.5 A margin). Both budgets have comfortable headroom; re-run weight if payload > ~700 g or second pack added.

---

## Mission combos (reminder)

- **Always on:** Pi 5 + OAK-D + **RTK + mast** (hard-mounted together so they don't fight). Underpod with down/side cams. Dismount only for crawler or sled use.
- **Add when needed:** **Upward cameras** for under-canopy or panos (mast stays on for RTK).
- **Under-canopy:** OAK-D + underpod + upward cams + RTK; "peel the onion" — fly mapped area to edge, collect more, process off-board.
- **Pano:** Open question — how much pano on a global trigger (all cams fire together)?

---

## Decided vs to specify (before locking more parts)

**Decided / assumed:** Frame **Rekon 10 Pro 455 mm** (original LR; US sources, 1–2 vendors). **Battery: iFlight Fullsend 6S 8000 mAh Li-ion** (single pack on top; room for Pi 5 + OAK-D at front). FC Matek H7A3-SLIM (ArduPilot). ESC iFlight Blitz E80 Pro (6S, DShot, BLHeli_32). Combined link: **Matek R24-TD** ELRS receiver (2.4 GHz, **true diversity**, 2 antennas; zip-tie tails + heatshrink: one side, one up) for RC + MAVLink. WalkSnail 2× VTX antennas in stern angled TPU mounts. Payload power 10A 5V UBEC; Pi 5 via GPIO 5V; OAK-D via barrel jack. RTK F9P (ZED-F9P); mast always on; helical antenna. OAK-D for VO + depth; **Raspberry Pi 5 (4 GB)**, two CSI camera ports, NVMe via M.2 HAT+. Underpod with umbilical (power + trigger); start with two cams on Pi 5, expand later. Prop class 10x4.5 bi-blade; motor class 3110/3314, 900–1100 KV; 6S.

**To specify (incl. flight stack):** Battery placement and strap vs Pi 5/OAK-D/mast (verify at build). Exact motor model (XING 3110 vs 3314, KV); exact prop (HQProp 10x4.5 vs Gemfan 1050 bi-blade). Payload: Pi 5 thermal solution (active cooler + propwash vs passive heatsink; verify under load); structure/underpod build and measured weight. FPV: WalkSnail antenna mount location (clear of heatsink, RTK mast, ELRS); ground choice (goggles vs VRX + screen). Stack: E80 Pro G2 w/ cover bundle includes 30x30 to 35x35 adapter (fits Rekon 10 Pro 30.5 mm).

---

## Bill of Materials (BoM)

Accumulating list of components. Bundled vs bought separately not distinguished; add part numbers or links as you lock choices. **Cables and connectors** are called out in their own subsection (battery, UBEC, UART/serial between FC and peripherals, WalkSnail power and extended MIPI, Qwiic, underpod umbilical); confirm connector types and pinouts at build.

**First-pass build (for shopping carts / price checks):** Platform (frame, FC, ESC with G2 bundle, adapter if not in bundle, motors, props, battery, XT60→XT90 adapter, 60 A fuse, optional XT60 Y), payload power (UBEC + barrel pigtail for OAK-D + UBEC-to-GPIO wiring for Pi 5 + UBEC input tap; if Castle BEC add Castle Link for voltage set), compute (Pi 5 4 GB, ~$60), storage ([RPi SSD Kit 512 GB](https://www.sparkfun.com/raspberry-pi-ssd-kit-for-raspberry-pi-512gb.html) KIT-26688, ~$85; NVMe + M.2 HAT+), positioning, cameras (2× [SparkFun RPi Camera Module 3](https://www.sparkfun.com/raspberry-pi-camera-module-3.html) SEN-21331, 76° FOV 12 MP, ~$33 ea), cables (UART/CRSF/Qwiic/barrel/trigger; WalkSnail extended MIPI), FPV (WalkSnail Avatar HD Pro kit + extended cable), RX (Matek R24-TD), ground (Boxer or equivalent). Zip ties and heatshrink for antenna tails and wiring. Lower/upper array and structure are not first pass. **Already owned (omit from buy list):** OAK-D (original), F9P (from SparkFun GPS-RTK-SMA Kit); Ardusimple ground plate.

**Platform / flight stack**
- Rekon 10 Pro frame **455 mm** (original LR; chosen; US sources). Confirm kit includes 2x 2 mm reinforcement bars if desired; fit optional.
- Matek H7A3-SLIM flight controller (ArduPilot MATEKH7A3, 30.5 mm, 6 UARTs, 11 PWM, AT7456E OSD)
- iFlight Blitz E80 Pro 4-in-1 ESC (80 A / 100 A burst, 2–8S, DShot, BLHeli_32, telemetry, 35x35 mm, ~65 g). **We need the 30x30 to 35x35 mounting adapter** for the Rekon 10 Pro 30.5 mm stack; the **E80 Pro G2 "w/ cover" bundle** (e.g. GetFPV, FPV Faster) includes: 30x30 to 35x35 adapter, **XT90 10AWG connector**, 10AWG voltage and ground wires, Amass XT90E-M adapter, FC connecting wire, iFlight Filter Module V1, 2× UPL 470 µF 50V capacitors, hardware. Official iFlight shop lists only "1 x Wiring set" — confirm bundle contents when buying. **Battery connection:** ESC side is **XT90** (10AWG); our pack is **XT60H-F**. See Cables and connectors for adapter. **Clearance:** ESC is 35×42 mm; some 10" builders (e.g. XL10) find it too large; verify X/Y fit on Rekon 10 Pro (adapter may only work with ESC on top).
- 30x30 to 35x35 mounting adapter (required for Blitz E80 Pro on 30.5 mm stack; verify included in ESC kit or source separately)
- Combined link: **Matek R24-TD** ELRS receiver (on craft, 2.4 GHz, **true diversity**, 2 antennas; still under ~$50; better chance of control signal in emergency) + antennas. Mount ELRS antennas on **zip-tie tails with heatshrink**: **one out to the side, one straight up**. Match transmitter (e.g. Boxer ELRS). Required — one radio on the craft for RC + MAVLink.
- Motors: XING 3110/3314 class, KV TBD
- Propellers: 10x4.5 bi-blade (HQProp or Gemfan 1050 bi-blade, TBD)
- Main battery: **iFlight Fullsend 6S 8000 mAh Li-ion** (42×64×147 mm, ~840 g, **XT60H-F**). Single pack on top; frame has 20×250 mm straps. Belly pod + second pack later = open item.
- **XT60 male to XT90 female adapter** (battery XT60H to ESC lead XT90); optional **XT60 Y cable** (1F–2M) if tapping UBEC from same pack. **60 A fuse** (slow-blow or blade, in main battery→ESC path) to protect the 60 A-rated segment from overload; required when ESC is 80 A and path is XT60-limited.

**Payload power**
- **10A 5V UBEC** — part TBD. Input must support **6S** (2–6S or similar is fine). Output: **GPIO 5V wires to Pi 5**, barrel jack to OAK-D; umbilical to underpod.
- **Payload UBEC options (6S-capable input, 5V 10A continuous):**
  - **Hobbywing UBEC 10A (2–6S)** (PN 30603000): 6–25.2 V in, 5/6/7.4/8.4 V out (dip switch), 10 A cont / 20 A peak, 43×32×12.5 mm, 36 g. Input: connect to battery in parallel; confirm whether flying leads or solder pads.
  - **Castle Creations CC BEC 2.0** (14A max, 14S): [RMRC](https://www.readymaderc.com/products/details/castle-creations-cc-bec2-14a-14s). Input up to 14S (58.8 V); output 4.75–12 V adjustable via **Castle Link** (sold separately — add to cart if choosing this BEC). 14 A peak; dual output wires. 43×14×8 mm, **21 g** with wires. 6S well within range.
- **UBEC input:** Tap from flight pack so UBEC sees 6S; connector per chosen unit (solder, XT60, etc.) and pack (XT60H).
- UBEC 5V output → Pi 5 GPIO header pins 2/4 (5V) + pin 6 (GND); use Dupont or solder direct.
- Barrel pigtail, UBEC → OAK-D (5 V)
- UBEC 5V + GND → F9P breakout VCC/GND (Dupont or small lead); confirm breakout accepts 5 V or use 3.3 V regulator if needed.
- Umbilical (power + trigger) to underpod; connector type TBD at build.

**Compute and VO**
- **Raspberry Pi 5 (4 GB)** (~$60) + active cooler (~$5–10). Verify thermal performance under sustained load with propwash cooling.

**Storage**
- **[Raspberry Pi SSD Kit for Raspberry Pi - 512 GB](https://www.sparkfun.com/raspberry-pi-ssd-kit-for-raspberry-pi-512gb.html)** (KIT-26688, ~$85). Includes NVMe SSD + M.2 HAT+. Stacks on Pi 5; no USB port consumed; PCIe 2.0 x1. Can boot OS from NVMe.

**Positioning (RTK + OAK-D, upper package)**
- **F9P:** From [SparkFun GPS-RTK-SMA Kit](https://www.sparkfun.com/sparkfun-gps-rtk-sma-kit.html) (KIT-18292; includes ZED-F9P breakout, antenna, ground plate, USB). For this build we use the **ZED-F9P breakout** from the kit with **Ardusimple helical** and **Ardusimple ground plate** (kit antenna/ground plate are heavier; optional for other use). **Already owned.**
- **OAK-D (original)** — [Luxonis OAK-D](https://docs.luxonis.com/hardware/products/OAK-D) (RVC2, stereo depth, USB 2/3, ~115 g; IMU, 2.5–3 W base + camera streaming). **Already owned.**
- **RTK helical antenna (chosen):** [SparkFun GNSS Multi-Band L1/L2/L5 Helical Antenna (Locking SMA)](https://www.sparkfun.com/gnss-multi-band-l1-l2-l5-helical-antenna-locking-sma.html) (GPS-30249, MAN1216Q50). **25 g**, L1/L2/L5, locking three-screw flange for vibration-resistant mount; 50×50×42 mm; $99. [Datasheet](https://cdn.sparkfun.com/assets/c/4/1/f/c/MAN1216Q50-Updated-Dec2025.pdf). Alternatives: [Ardusimple L1/L2 helical](https://www.ardusimple.com/product/helical-antenna/) 18 g, ~$124; [Ardusimple L1/L2/L5 tripleband](https://www.ardusimple.com/product/lightweight-helical-tripleband-l-band-antenna-ip67/) 25 g, ~€146.
- **PCB ground plane:** Ardusimple **Ground Plate for GNSS antenna** (markings for helical or ceramic); ~30 g. **Already owned.**
- Mast: ~10 cm rigid (TPU + epoxy to base; top adapter for ground plane + helical)

**Cameras (start config)**
- **Two** cameras on Pi 5 CSI ports: **2× [SparkFun Raspberry Pi Camera Module 3](https://www.sparkfun.com/raspberry-pi-camera-module-3.html)** (SEN-21331). **76° FOV** (standard lens), **12 MP** Sony IMX708, CSI-2, phase-detect autofocus, HDR; **~$33 each**. **Native on Pi 5** — no driver or voltage compatibility concerns. **Mapping:** 12 MP / 76° is good resolution for mapping; FOV is narrower than wide-angle alternatives.

**Lower array (underpod; not first pass; interface TBD)**
- 1x HQ camera + glass lens
- 3x Pi cams (plastic lenses)
- Interface: muxer vs CamArray vs USB Shield (revisit — see Open items "Multi-camera interface")
- CSI ribbons, standoffs, screws
- Maltese cross mount (3D-print)
- Underpod shell

**Upper array (optional, under-canopy / panos; interface TBD)**
- 4x Pi cams at ~45 deg
- Interface: muxer vs CamArray vs USB Shield
- Mount

**Cables and connectors**
- **Battery → ESC:** Pack is **iFlight Fullsend 6S 8000 mAh**, **XT60H-F** (female on pack). Blitz E80 Pro **G2 bundle** supplies **XT90 10AWG** on the ESC lead (male plug into battery side). **Mismatch:** Use an **XT60 male to XT90 female adapter** (plug adapter's XT60 male into the battery; ESC lead's XT90 male plugs into adapter's XT90 female). Widely available (e.g. Rotor Riot, RC Accessory, ~$3–6). **Current:** XT60 and the adapter are ~60 A continuous; E80 can draw 80 A. Without protection, the 60 A segment could be overloaded and overheat (same idea as 14 AWG on a 20 A circuit). **Required:** **Fuse the main battery→ESC path** at or below the rating of the weak link (e.g. **60 A**, or 55 A for margin). Place fuse in the high-current path so it opens before the XT60/adapter/Y leg sees sustained overcurrent. Use a slow-blow or blade fuse that allows short bursts (takeoff, climb) but protects against sustained overload. If you use an XT60 Y, the Y and adapter are both in the 60 A segment — fuse protects the whole segment. Re-terminate to XT90 (pack or lead) if you want to remove the 60 A limit and fuse at 80 A.
- **UBEC tap:** From same pack: use an **XT60 Y cable** (one female for battery, two male legs) — one leg to the XT60→XT90 adapter then ESC, other leg to UBEC input (solder XT60 male or appropriate connector to UBEC input wires). Or single adapter plus a separate parallel lead for UBEC; confirm UBEC input connector and pack polarity.
- **UART / serial (FC to peripherals):**  
  - **SERIAL2:** ELRS receiver (CRSF) → FC; cable often included with R24-TD; else 4-pin JST-GH or equivalent to Matek serial pad.  
  - **SERIAL3:** F9P (UART TX/RX/GND) → FC; Dupont or JST from F9P breakout to FC SERIAL3 pins; confirm pinout.  
  - **SERIAL4:** Pi 5 (companion MAVLink) ↔ FC; UART from Pi 5 40-pin header to FC SERIAL4; connector and pinout TBD.  
  - **SERIAL5:** WalkSnail OSD (MSP DisplayPort) ← FC; cable from FC SERIAL5 to WalkSnail OSD port; confirm WalkSnail pinout and ArduPilot protocol.  
- **F9P power:** 5 V and GND from UBEC to F9P breakout VCC/GND (Dupont or small lead). Confirm breakout input voltage (many ZED-F9P breakouts accept 3.3–5.5 V on VCC). Do not rely on USB or Qwiic for in-flight power unless the breakout is explicitly powered from the Qwiic bus (Pi 5 3.3 V).
- **F9P → Pi 5:** Qwiic cable (I2C) for GPS status/telemetry; SparkFun Qwiic to Pi 5 I2C on 40-pin header.
- **OAK-D:** USB to Pi 5 (usually included with OAK-D); power via UBEC barrel (see above).
- Spare: Dupont / JST-GH / servo-style as needed for trigger line (FC → underpod) and any ESC telemetry (optional SERIAL6).

**Structure and wiring**
- Base board / payload plate
- Mounts, wiring, structure (weight TBD; placeholder 60 g)
- Zip ties, heatshrink (antenna tails for ELRS, general wiring)

**Ground station**
- RadioMaster Boxer ELRS (transmitter; internal ELRS is 2.4 GHz only; for 915 MHz RC use external module e.g. Bandit Micro 915 MHz)
- **Matek R24-TD** ExpressLRS receiver (on craft, 2.4 GHz, true diversity; same link = RC + MAVLink). See **ELRS receiver (chosen)** below.

**ELRS receiver (chosen: Matek R24-TD)**  
- **Onboard:** **Matek R24-TD** (2.4 GHz, **true diversity**, two antennas; still under ~$50; better hope of getting a control signal through in an emergency). **Antenna mount:** zip-tie "tails" with heatshrink tubing — **one antenna out to the side, one straight up**. WalkSnail's 2× VTX antennas go in the angled TPU mounts at the stern; ELRS antennas stay clear of those and the RTK mast.  
- **MAVLink mode:** ELRS 3.5+; set RX serial protocol and TX link mode to MAVLink. ESP-based (Boxer + R24-TD). Connect RX to FC over CRSF (one UART).  
- **Other options (reference):** BetaFPV SuperD, Happymodel EP1 Dual, Namimno Flash Diversity, Radiomaster RP3. Confirm receiver in the [ELRS Configurator](https://expresslrs.org/quick-start/configuration/) for MAVLink firmware.

**Control feedback (WalkSnail Avatar HD Pro)**
- WalkSnail Avatar HD Pro kit (air: camera + VTX, dual antennas)
- **Extended camera–VTX MIPI cable** (kit cable ~12–14 cm; nose-to-stern on 455 mm frame needs longer run). Source ~200 mm WalkSnail-compatible MIPI cable or extension; confirm part/availability at order time.
- WalkSnail power: cable from flight pack or BEC (6–25.2 V); connector per air unit.
- OSD: MSP DisplayPort (semantic overlay, not baked; preserve for live + DVR post-processing)
- Antenna placement: clear of Pi 5 heatsink, RTK mast, and ELRS antenna
- Ground (choose one): Avatar HD Goggles L, Avatar HD Goggles X, or Avatar VRX + HDMI screen

---

## Flight stack and interconnect compatibility

Summary: **physical**, **electronic**, **radio**, and **onboard** links are compatible with the chosen FC (Matek H7A3-SLIM), ESC (Blitz E80 Pro), ELRS, OAK-D, F9P, Pi 5, underpod trigger, and WalkSnail. **Stack:** Rekon 10 Pro documented: 30.5×30.5 mm, **20 mm cavity (Z)**; footprint (X/Y) not specified. Blitz E80 Pro: Z likely OK (ESC+FC fit in 20 mm); **X/Y threatened** (35×42 mm). Plan ESC on top, FC below; verify X/Y clearance (dry-fit). See Physical table.

### Physical

| Item | Notes |
|------|------|
| **FC** | Matek H7A3-SLIM: 30.5x30.5 mm, ~7 g. Fits Rekon 10 Pro 30.5 mm stack. |
| **ESC** | Blitz E80 Pro: 35x35 mm mounting, **35×42 mm overall** (7 mm overhang in one axis), ~65 g. E80 Pro G2 w/ cover bundle includes 30x30 to 35x35 adapter. **Axes:** **Z (height):** Rekon cavity 20 mm; ESC + adapter + FC ≈ 12–15 mm — **likely OK**; use 20 mm standoffs for FC+ESC bay. **X/Y (footprint):** **threatened** — ESC body 35×42 mm overhangs 30.5 mm mounting; frame does not publish max footprint, so 35×42 mm may hit top plate or standoffs. **Settled:** stack order ESC on top (adapter to 30.5 mm), FC below. **Verify:** X/Y clearance only (35×42 mm vs frame/standoffs; dry-fit). Some 10" builds (e.g. XL10) return E80 Pro as too big; Rekon may be more permissive. Fallback: 30.5 mm native ESC (55–60 A). |
| **FC–ESC** | FC has 8 PWM pins (JST-SH 8-pin) for 4-in-1; Blitz uses one 4-in-1 cable. DShot supported by both. |

### Electronic (power, protocols)

| Link | Compatibility |
|------|----------------|
| **FC** | 6–36 V (8S); no BEC — use UBEC for 5 V payload. |
| **ESC** | 2–8S input; no BEC. Flight pack feeds ESC; FC powered from same pack (Matek 6–36 V input). |
| **ESC–FC** | DShot150/300/600, MultiShot, OneShot. Blitz BLHeli_32 telemetry (current, etc.) can go to FC on a UART if desired. |

### Radio (off-board)

| Link | Compatibility |
|------|----------------|
| **ELRS** | One UART for ELRS receiver (CRSF); RC + MAVLink on same link in MAVLink mode. Boxer ELRS 2.4 GHz ↔ ELRS RX on craft. |
| **GCS** | GCS connects to **handset** (USB or Backpack WiFi), not a second radio. Full MAVLink telemetry and commands over the single ELRS link. |

### Onboard communications (FC to peripherals)

The H7A3-SLIM has **6 UARTs**. A feasible allocation:

| UART | Use | Notes |
|------|-----|-------|
| **SERIAL1** | Spare / reserved | No direct OAK-D UART — OAK-D is USB to Pi 5 only (see below). |
| **SERIAL2** | ELRS receiver (RC + MAVLink) | CRSF; ELRS in MAVLink mode feeds both sticks and MAVLink. |
| **SERIAL3** | F9P (RTK GPS) | **Position** (NMEA/UBX) from F9P to FC. FC gets corrected fix; RTCM corrections go **into** the F9P on another port (e.g. UART2 or base/radio), not to the FC. |
| **SERIAL4** | Pi 5 (companion) | MAVLink both ways. FC → Pi 5: triggers, status, commands. Pi 5 → FC: VO and other OAK-D-derived data (Pi 5 bridges OAK-D over USB and forwards results on this UART). |
| **SERIAL5** | WalkSnail OSD | MSP DisplayPort (semantic overlay; OSD_TYPE=5, SERIAL5_PROTOCOL=42). Not baked — logical layer for live and DVR. |
| **SERIAL6** | ESC telemetry (optional) or spare | BLHeli_32 telemetry for current/voltage if wired; else spare for trigger out or other. |

**GPS (F9P), FC, and Pi 5 — connection options**

- **FC must get GPS:** ArduPilot needs direct GPS (NMEA/UBX) for navigation and RTK. So **F9P → FC on one UART** (SERIAL3) is required. RTCM corrections can be fed to the F9P on its second UART or from a base/radio; that is separate from who reads position.
- **Chosen: F9P → FC (UART) and F9P → Pi 5 (I2C/Qwiic).** We want **fine-grained GPS status and telemetry** on the Pi 5 — signal strengths, lock quality, fix type, etc. — for logging and ad hoc analysis. The Pi 5 saves and/or forwards this (see Observability below); it's higher volume than we push over the telemetry radio. The ZED-F9P can drive **multiple interfaces at once** and you can **configure which messages go out on which port** (UART vs I2C). So we run **F9P UART → FC** (SERIAL3) with the nav stream the FC needs, and **F9P I2C (Qwiic) → Pi 5** with the detailed status stream; the two are independent and don't collide or use up FC link bandwidth. Qwiic keeps Pi 5 UARTs/USB free; I2C bandwidth is plenty for GPS status. Pi 5 I2C on 40-pin header (SDA/SCL); SparkFun ZED-F9P breakouts with Qwiic for the Pi 5 link.

**Triggers:** FC can drive a **trigger line** (GPIO or PWM) to the underpod umbilical; ArduPilot supports relay or GPIO for camera trigger. FC can also send **MAVLink commands** (e.g. DO_DIGICAM_CONTROL) to the Pi 5 over SERIAL4; Pi 5 runs a MAVLink client and can fire local cameras or forward trigger to underpod.

**FC ↔ Pi 5:** **Yes.** One UART (e.g. SERIAL4) as MAVLink: FC sends attitude, position, mode, and commands; Pi 5 can send requests or status. Use ArduPilot companion computer protocol (MAVLink) on that serial link.

**FC ↔ ESC:** **Yes.** Motor commands via DShot on the 4-in-1 PWM cable. Optional: ESC telemetry back to FC on one UART for current/consumption.

**Overlays to FPV:** **Yes.** WalkSnail uses **MSP DisplayPort** (semantic overlay, not baked): FC sends OSD elements + positions; goggles/VRX render and record OSD as a separate logical layer (post tools can re-render or strip it). Use SERIAL5 with OSD_TYPE=5, SERIAL5_PROTOCOL=42; configure in Mission Planner and WalkSnail OSD/font setup.

**OAK-D ↔ FC:** **No direct UART.** OAK-D connects to the **Pi 5 over USB** only. The Pi 5 runs the OAK-D pipeline (depthai, VINS-Fusion for VO — see [ArduPilot OAK-D VIO guide](https://ardupilot.org/copter/docs/common-vio-oak-d.html)) and **translates/forwards** results (e.g. visual odometry, detections) to the FC over the **companion UART** (SERIAL4). So the FC sees VO and companion data from the Pi 5, not from the OAK-D directly.

**Component awareness:** With the above mapping: **ELRS** brings RC + MAVLink to the FC; **Pi 5** (with OAK-D on USB) feeds VO and companion data to the FC on SERIAL4; **F9P** feeds position; **underpod** gets trigger from FC (GPIO/relay or via Pi 5); **WalkSnail** gets OSD from FC. All key components can be on the same "information loop" (FC as hub). Confirm WalkSnail serial OSD pinout and ArduPilot SERIALx protocol in final wiring.

---

## Open items

1. **Antenna:** Chosen — SparkFun GNSS L1/L2/L5 Helical (Locking SMA), 25 g. ANN-MB-00 only for debugging if needed.
2. **Pi 5 thermal:** Verify Pi 5 + active cooler thermal performance under sustained load (2× CSI cameras + OAK-D orchestration + NVMe writes) with propwash cooling. If fan is unreliable on a vibrating platform, consider a passive heatsink sized for the A76 cores.
3. **Trigger / OAK-D:** Does OAK-D support external trigger while still streaming VO to FC at high rate? If yes, we can possibly trigger it; only the two direct Pi 5 cameras are certain for first pass.
4. **Underpod telemetry:** Umbilical with position (telemetry) vs record-on-trigger-only and align by frame count later.
5. **Multi-camera interface:** Revisit muxer vs CamArray vs USB Shield for lower/upper array. CamArray = simultaneous trigger, 1/4 res tiling; muxer = sequential; USB Shield = USB + 1/4 res. Simultaneous trigger + sequential readout may not exist for muxer.
6. **Pano:** How much pano coverage on a global trigger (all cams fire together)?
7. **Structure:** Measure actual structure/mounts/wiring/underpod; adjust 60 g placeholder.
8. **Motor/prop:** Lock XING size (3110/3314) and exact 2-blade prop (HQProp 10x4.5 vs Gemfan 1050 bi-blade) for Rekon 10 Pro.
9. **Stack / ESC clearance:** Rekon 10 Pro: 20 mm cavity (Z), no max footprint (X/Y). E80 Pro: Z likely OK; **X/Y threatened** (35×42 mm). ESC on top, FC below; verify X/Y only (dry-fit). XL10 builders sometimes return E80 Pro; Rekon may be OK.
10. **UART / OSD:** Lock final UART map (OAK-D, ELRS, F9P, Pi 5, WalkSnail OSD, ESC telem); confirm WalkSnail serial OSD wiring and ArduPilot protocol.
11. **Frame reinforcement:** Confirm Rekon 10 Pro kit contents (2x 2 mm reinforcement bars in some listings). Decide: fit bars for stiffness vs omit for weight/clearance.
12. **Stern / antenna mount:** WalkSnail 2× VTX antennas in Rekon's **angled TPU mounts at the stern**. ELRS (R24-TD) 2× antennas on **zip-tie tails with heatshrink**: one out to the side, one straight up. Confirm at build time.
13. **Belly pod + battery later:** Single pack for now; when adding belly pod (underpod), battery + pod mounting will need a solution (frame has top/bottom battery; pod may compete for space).
14. **WalkSnail extended MIPI:** Confirm source and part for ~200 mm camera–VTX cable (kit cable ~12–14 cm too short for nose–stern on 455 mm frame); add to BoM when locked.

---

## References (quick)

- **Frame:** [Rekon 10 Pro 455 mm](https://rekonfpv.com/collections/new-arrivals/products/rekon10-pro-long-range-frame-kit-10-inch-for-fpv-racing-drone) (original LR; US: GetFPV, Next FPV, Amazon). **Battery:** [iFlight Fullsend 6S 8000 mAh Li-ion](https://shop.iflight.com/Fullsend-6S-8000mAh-Li-Ion-Battery-Pro1914) (42×64×147 mm, ~840 g, XT60H-F); single pack on top. Payload: 10A 5V UBEC (part TBD; see BoM options); [RPi SSD Kit 512 GB](https://www.sparkfun.com/raspberry-pi-ssd-kit-for-raspberry-pi-512gb.html) (NVMe + M.2 HAT+).
- F9P: [SparkFun GPS-RTK-SMA Kit](https://www.sparkfun.com/sparkfun-gps-rtk-sma-kit.html) (ZED-F9P breakout). Antenna: [SparkFun GNSS L1/L2/L5 Helical (Locking SMA)](https://www.sparkfun.com/gnss-multi-band-l1-l2-l5-helical-antenna-locking-sma.html) (25 g); ground plane: Ardusimple Ground Plate for GNSS antenna. ANN-MB-00 for debug only.
- OAK-D: [Luxonis OAK-D (original)](https://docs.luxonis.com/hardware/products/OAK-D).
- ArduPilot: Matek H7A3-SLIM (MATEKH7A3); ESC iFlight Blitz E80 Pro; combined link Matek R24-TD ELRS (true diversity, MAVLink) for telemetry and RC.
- Cameras: Start with **2× [SparkFun Raspberry Pi Camera Module 3](https://www.sparkfun.com/raspberry-pi-camera-module-3.html)** (SEN-21331, 76° FOV, 12 MP, ~$33 ea) on Pi 5 CSI (native). Expansion (lower/upper array) TBD. OAK-D for VO + depth; power via barrel from UBEC.
- FPV: WalkSnail Avatar HD Pro (air, dual antennas in stern angled TPU mounts); ground = Goggles L/X or VRX + HDMI screen. ELRS R24-TD: 2× antennas on zip-tie tails + heatshrink (one side, one up). Clear of Pi 5 heatsink, RTK mast.


----

Supplier notes:

### Pyrodrone

* Doesn't carry rekon parts
* Matek H7A3-Slim out of stock, $84
* has [blitz](https://pyrodrone.com/products/copy-of-iflight-blitz-e80-80a-2-8s-blheli_32-dshot600-4-in-1-esc-30x30mm) $312
* [matek elrs](https://pyrodrone.com/products/matek-elrs-r24-td-expresslrs-2-4ghz-true-diversity-receiver) $33
* Battery:
  * only have 8s FullSend in stock
  * has 8000 mAh Li-ion [battery](https://pyrodrone.com/collections/6s-batteries/products/gaoneng-gnb-8000mah-22-2v-6s-10c-6s2p-made-with-samsung-21700-40t-long-range-cinelifter-lipo-battery-xt60) $136
* [tx60 male to 90 female](https://pyrodrone.com/products/xt60-to-xt90-adapter-1pc-choose-type?variant=40631518134315) $6
* only has 3-blade 10" props and they're all sold out
* [xing2 3110](https://pyrodrone.com/collections/iflight-xing2-motors/products/iflight-xing2-3110-fpv-motor-unibell-900kv) $59 each
* Has WalkSnail kit but sold out. They have the single antenna version
  or the "avatar gt"? https://pyrodrone.com/products/pre-order-walksnail-digital-hd-vtx-hd-pro-camera-kit-v2-for-walksnail-avatar-fatshark-dominator-hd-fpv-system-choose-memory-size $203


## GetFPV

* [blitz](https://www.getfpv.com/iflight-blitz-e80-pro-g2-80a-4-in-1-blheli-32-esc-35x35-30x30.html?) at $325
* [rekon 10](https://www.getfpv.com/rekon-fpv-rekon10-pro-long-range-frame-kit-10.html) at $143
* [matek](https://www.getfpv.com/mateksys-h743-slim-v3-flight-controller.html) out of stock $127
* [rd-24](https://www.getfpv.com/mateksys-expresslrs-2-4ghz-true-diversity-receiver-elrs-r24-td.html) $33
* [xing2 3110](https://www.getfpv.com/iflight-xing2-3110-cinelifter-motor-900kv-1250kv-1600kv.html) $67 * 4
* no 2-blacd 10" props
* no fullsend, but a three pack of 6000 mAh for $559 [here](https://www.getfpv.com/batteries/18650-batteries/lumenier-nav-6000mah-6s-lithium-ion-battery-xt60-3-pack-bundle.html) or a single 8000 for $192 going to 6000 saves 200g.S