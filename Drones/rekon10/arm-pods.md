# Camera arm pods

[Back to index](README.md)

## Overview

Each of the four arms carries a pod with 2x Pi Zero 2 W + Camera Module 3 (Sony IMX708). Pods are mounted at the **arm-frame junction** (where the arm meets the central frame plates -- the structurally stiffest point of the arm, with maximum path length and damping between the motors and the cameras). Each pod is slung along the underside of the arm, with the Zeros in a skeletized clamshell and the cameras aimed outward and downward (see Aim geometry below).

Each macro-block of 4 cameras (two arms' worth) shares a 4-port USB hub in the central hub with the Coordinator as the host (and independent power injection).

Future iteration adds a **vertical ring** of cameras to complement this horizontal (downward-looking) ring. The vertical ring provides **360-degree side-scan**: cameras aimed from roughly 20 degrees ahead of the vehicle's midships to 20 degrees behind, in a plane approximately perpendicular to the direction of travel, covering the full azimuthal circle. Combined with the horizontal ring (nadir to about -50 degrees elevation), the vertical ring extends coverage upward from roughly -40 degrees (overlapping the horizontal ring's upper edge) through horizontal and well above -- a large swath of the hemisphere in every direction as the drone moves through the woods. The vertical ring's design is pending; the current build protects for it in terms of total power and thrust (payload weight is currently a small fraction of what we could devote to it while remaining airworthy). Its own coordinator, BEC, and PPS buffers would be added at that stage.

However, two cameras from the vertical ring -- **NNW and NNE**, aimed near-zenith -- are pulled forward into the current build phase for **canopy gap detection** during under-canopy missions (see *Upward-looking gap detection* below and [canopy-ops.md](canopy-ops.md)). These are the topmost members of the vertical ring; the remaining members (filling in the 360-degree side-scan coverage from -40 degrees up to +50 degrees or so) come later.

Each Zero is responsible for triggering its camera and recording the results locally. USB is used for upstream communication (simulated network device), including low-rate telemetry, NTP, and libcamera sync messages from one Zero designated as the pacesetter. The **Coordinator** (the Raspberry Pi 4B that also runs VIO -- see [central-hub.md](central-hub.md)) bridges the USB network to the sibling Zeros and serves NTP for "absolute" time initialization. It also collects telemetry and informationally reports successful captures back through MAVLink. This is NOT a load-bearing timestamp signal, just telemetry for the operator to know the system thinks it is capturing.

### Aim geometry

All 8 cameras are aimed at **-70 degrees depression** (20 degrees from nadir), distributed azimuthally at 45-degree increments offset 22.5 degrees from the flight line. Using compass-point naming (forward = N): **NNE, ENE, ESE, SSE, SSW, WSW, WNW, NNW**.

No camera points straight down. The array captures sides of vertical structures (walls, tree trunks, terrain relief) that a nadir camera cannot see. This is the fundamental design intent -- heightfields and dense point clouds require viewing geometry from many angles, not just overhead.

**Why -70 degrees:** The Camera Module 3 standard has 66 degrees horizontal / 41 degrees vertical FOV (75 degrees diagonal). At -70 degrees depression with 20.5-degree vertical half-FOV:

- **Bottom edge:** -70 - 20.5 = -90.5 degrees. Just past nadir -- by design, the bottom edge kisses straight down. No nadir gap exists in the array.
- **Top edge:** -70 + 20.5 = -49.5 degrees. Well below horizon; every pixel looks at least 49.5 degrees below horizontal.

The oblique projection at the top edge widens the effective azimuthal footprint: the 66-degree horizontal FOV sweeps approximately 86 degrees of azimuth at the -49.5-degree top edge. With 8 cameras at 45-degree spacing, adjacent cameras overlap by ~41 degrees in the far field -- nearly complete double coverage everywhere. Cameras mirrored through a plane perpendicular to the axis of travel (e.g. ENE and WSW) see opposite sides of the same objects (at different points in time).

### Pod camera assignment

Two design constraints govern which cameras share a pod. These are choices imposed for specific benefits, not inherent requirements of the system.

**Constraint 1 -- no angularly-adjacent cameras in the same pod (for baseline):** Adjacent cameras in the azimuthal ring are less than an inch apart if co-located on the same arm. Requiring non-adjacent cameras in each pod guarantees that each adjacent pair has ~4-5 inches of baseline in overlap regions. This baseline is not useful for stereo at 25 m altitude, but could be valuable for nearfield depth (twigs, obstacles).

**Constraint 2 -- each pod holds cameras exactly 90 degrees apart (for mounting simplicity):** This is stricter than constraint 1 and implies it. Each pod holds one "forward/back-ish" and one "side-ish" camera (e.g. NNE + ESE). Benefits: landing/ground-protection feet can stay in camera blind spots and be roughly identical (rotated) across all 4 legs; 90-degree pairs are easier to validate visually and mechanically; more common parts across pods despite arm geometry requiring at least mirroring.

Final angle-to-node assignment is TBD and iterable; these constraints define the feasible set.

## Hardware

### Thermal

- **Camera Module 3:** Not a thermal concern. Pulling still frames at 1-2 Hz for photogrammetry is very low duty cycle.
- **Pi Zero 2 W:** The real thermal bottleneck. The quad-core CPU runs very hot under load (chrony, network, USB gadget, SD writes). Will hit 80 degrees C throttling if it can't breathe.
- **Solution:** Full-length aluminum heatsinks on the Zeros, with the pod design leaving the center channel open for prop-wash cooling.
- **Hardware sources:** Pi Zero 2 W, Camera Module 3 (standard), ribbon cables, and heatsinks from PiShop.

### "Bridge" pod design

One option is to mount to zero only to bosses for the mounting holes and build a "bridge"
over it.

- **Structural flanks:** Thick solid ribs/walls on the left and right sides of the Pi Zero, extending past it.
- **Camera anchor:** The lower skeletal case holding the camera module bolts directly to those thick side walls. Creates a contiguous ring of plastic from the carbon arm through the sled flanks to the camera lens -- rock-solid.
- **Open core:** The entire center channel is open. The Pi Zero and heatsink sit in a wind tunnel getting maximum prop-wash cooling, carrying no structural weight.

### Signal wiring (PPS timing from GPS)

Run a **twisted pair**: signal wire + dedicated signal ground (any GND pin from the Pi header). This keeps the loop area near zero and prevents ESC EMI from corrupting the pulse.

At the Pi side, connect the signal ground through a **100-ohm resistor** to prevent it from becoming a high-current shortcut during a motor failure, while still providing a clean 3.3 V reference.

## Software

### System

Configure USB as simulated network adapter; the Coordinator bridges. TODO: More details

### Time coordination

Following pieces of [Microsecond accurate NTP with a Raspberry Pi and PPS GPS](https://austinsnerdythings.com/2021/04/19/microsecond-accurate-ntp-with-a-raspberry-pi-and-pps-gps/) it looks like `chrony` running on the Zeros to get NTP from the Coordinator.

### Capture sync

### Software sync only

The Camera Module 3 does not have XVS hardware trigger pins. The build uses **software-based timing sync for all cameras**.

All cameras use interpolated timestamping: capture timestamps (locked to GPS time via PPS + chrony) are matched against ArduPilot's high-frequency pose logs (50-100 Hz) during post-processing (PPK-style interpolation). Even at 10 m/s (a worst-case for the timing math, not a planned survey speed) with 1 ms sync, positional error is only ~1 cm -- acceptable for photogrammetry. libcamera claims less than 10 microseconds.

**Planned survey speed:** 3-5 m/s for overhead mapping transects, slower under canopy. At 3 m/s with the same 1 ms sync budget, positional error is ~3 mm.

**Overlap targets:** >75% forward overlap, 60-70% lateral overlap for mapping transects. High overlap serves both rolling shutter correction (dense feature matching) and general photogrammetry quality. The multi-camera geometry provides additional inter-camera overlap that a single-camera platform cannot match.

### Time distribution: chrony + PPS

Standard NTP over USB gadget mode has 2-10 ms of jitter due to USB polling, which at 10 m/s translates to 2-10 cm of positional error -- enough to throw away the RTK advantage. The fix is hardware PPS.

**Architecture:**

1. **The Coordinator** gets absolute time from GPS (NMEA sentences via serial or MAVLink SYSTEM_TIME) plus the PPS pulse. It acts as NTP server on the USB gadget network.
2. **Each Zero** gets "rough" absolute time from the Coordinator over USB (accurate to the correct second, but sloppy by 5-15 ms).
3. **A physical PPS wire** from the GPS runs to a GPIO pin on every Pi Zero.
4. **Chrony** on each Zero is configured with both sources: it uses the network time to determine *which* second it is, then **phase-locks to the hardware PPS interrupt** for sub-microsecond alignment. All USB jitter is eliminated.

When libcamera saves a frame, the timestamp comes from CLOCK_MONOTONIC, which is now locked to GPS time. Post-processing interpolation against ArduPilot's GPS-based TimeUS logs is clean.

See central-hub.md for signal buffering details.

### Image storage

Images are written locally to each Pi Zero's SD card (not streamed over the shared USB 2.0 bus, which would bottleneck at 480 Mbps). The Coordinator uses the USB network only for commands (start/stop recording) where a few ms of latency doesn't matter.

## Vibration and camera mounting rationale

This section documents the analysis and design alternatives so future reviewers don't re-litigate the vibration question from scratch. See also [oak-d-mount.md](oak-d-mount.md) for the OAK-D's different vibration isolation approach (bobbins), which serves a different purpose (VIO, not photogrammetry stills).

### Spectrum of isolation approaches

**Extreme isolation (gondola/pendulum):** Hang the cameras on a suspended platform below the drone, decoupled from frame vibration by compliant tethers. Cameras stay rigid to each other. Infeasible in practice (aerodynamic drag, control authority loss, weight, complexity) and not warranted without evidence of a vibration problem.

**Moderate isolation (bobbins, like the OAK-D mount):** Elastomeric isolators absorb high-frequency vibration while maintaining macro-scale pose rigidity. This works for the OAK-D because VIO integrates visual and inertial data continuously -- even sub-pixel vibration corrupts the EKF integration over time. Problematic for the mapping pods: the cameras are very light (Pi Zero + CM3), likely too light to actuate soft isolators meaningfully; bobbins introduce relative motion between pods that share no mechanical connection except through the frame; this undermines the inter-pod geometric registration that photogrammetry depends on (the frame IS the reference that relates all 8 cameras to each other and to the GPS antenna).

**Rigid mounting (current design):** Clamshell around the carbon arm + bolted to frame mounting holes at the arm-frame junction. Cameras become part of the frame's rigid body. Motor vibration reaches the cameras, but amplitude is what matters.

### First-principles displacement analysis

The dominant vibration source is the 2-blade props. At hover (~50% throttle), the motors spin at roughly 900 KV * 22 V * 0.5 = ~9900 RPM, giving a 2-per-rev fundamental of ~330 Hz. At this frequency, vibration amplitude on a stiff carbon fiber structure at the arm-frame junction (not the motor end) is expected to be in the tens-of-microns range.

At ~1 cm GSD, one pixel corresponds to ~7.5 mm of camera displacement. Even 0.1 mm (100 microns) of vibration amplitude at the camera = ~0.013 pixels. Millimeter-scale displacement would be needed for visible effects in imagery, and at 330 Hz that would be catastrophically violent -- audible, tactile, and likely destructive.

The harmonic notch filter (fed by bidirectional DShot RPM telemetry from the AM32 ESCs) removes motor vibration from the FC's control loop, preventing the FC from amplifying vibration through feedback. This doesn't physically reduce frame vibration, but it prevents the control system from making it worse.

**Cantilever mode shape (first bending):** A carbon arm is roughly a **cantilever**: the **motor end** is an **antinode** for the lowest bending mode (large transverse motion); the **bolted root** is near a **displacement node** for that same mode. Pods at the **arm-frame junction** therefore see **less** of that mode's tip flapping than pods at mid-arm or at the motor would. This is **not** isolation from **all** motion: the root is not a perfect clamp, **higher-order** bending modes and **torsion** still move the junction, and **whole-body** attitude motion moves the hub and arms together.

**Control-loop coupling (separate from prop-line resonance):** Vibration can appear on **gyros**; the attitude loop can then **command torque** at frequencies where **phase margin** is thin, adding energy into the airframe. That is a real failure mode in FPV tuning lore, but blaming **D alone** at a fixed **30-80 Hz** is oversimplified -- **P, I, D, filters, and delays** set the limit-cycle frequency together. **Harmonic notch** (above) targets **blade-pass** from **RPM**; **gyro low-pass**, **D-term filtering**, **gain discipline**, and the **FC soft mount** are the other usual mitigations. For sinusoidal motion, **peak acceleration ~ amplitude * (2*pi*f)^2** -- **1 mm** at **50 Hz** is **~10 g** peak (the formula Gemini used is correct). Whether the **hub** ever reaches **1 mm** at those frequencies in your build is an empirical question; it would be **obvious** in flight and in logs long before "mythical" extremes. **Whole-hub** motion at **smaller** amplitude or **lower** frequency can still matter for stills before anything that dramatic.

### Why the OAK-D is different

VIO compares visual pixel flow against IMU-measured acceleration continuously. Even imperceptible vibration that doesn't affect individual still frames can corrupt the EKF integration over time, causing position drift and eventually flyaways. The OAK-D therefore gets rubber bobbins to absorb high-frequency vibration while maintaining structural rigidity for the VIO pose transform.

The mapping cameras take independent stills -- each frame stands alone. There is no integration over time, no cumulative corruption. Vibration only matters if it causes visible blur or jello in a single exposure.

### Autofocus voice coil (VCM) vs whole-body vibration

Camera Module 3 autofocus uses a **voice coil motor (VCM)**: the focusing lens group is suspended and translated axially relative to the sensor package. It is not a rigidly locked cine lens. That adds an **internal** mechanical degree of freedom in addition to rigid-body motion of the pod.

This is a **different failure mode** from rolling shutter geometry:

- **Rolling shutter shear / line-time jello** come from **rigid-body** motion (and readout order) during exposure. The first-principles argument above is about **whole-camera** displacement at the arm-frame junction; it does not bound motion **inside** the lens stack.
- **VCM-related blur** would come from **axial** (focus) drift or small **relative** motion of the lens group **with respect to the sensor** during integration. That widens the point spread (defocus-like or generalized blur). **Micron-scale** axial error can hurt sharpness before millimeter-scale whole-body motion dominates the RS discussion.

**Why this is expected to be benign at operating RPM:** Phone-class VCM actuators (the CM3 uses the same construction) have a mechanical resonance set by the lens mass and leaf-spring stiffness, typically in the **80-200 Hz** range. The prop fundamental at hover (~330 Hz for 2-blade, higher for 3-blade) sits **above** that resonance by roughly 2-4x. Above resonance, transmissibility **rolls off** -- the lens group is too heavy to follow the housing, so the VCM suspension acts as a **passive lowpass filter** at operating RPM. The lens stays relatively still while the housing vibrates around it. During motor spinup the RPM sweeps **through** resonance transiently, but mapping captures do not happen during spinup.

**Survivability:** The VCM will not be physically damaged by frame vibration at these amplitudes. Phone cameras with the same actuator architecture survive walking, pocket vibration, car rides, and drop impacts -- environments with far more energy at far more problematic (low) frequencies than a carbon fiber frame at ~330 Hz and tens-of-microns amplitude. Tens of microns of axial lens shift also produce no detectable defocus at mapping altitudes (depth of field at 25 m AGL is meters deep). "Destroy the VCM" or "overwhelm its ability to hold focus" would require energy orders of magnitude beyond what the arm-frame junction delivers.

Whether prop-band vibration actually excites the VCM suspension enough to cause **subtle** image softness on this mount remains an **empirical** question. The **Pod-integrated vibration logging** plan ties mechanical spectra **at the camera load path** to image quality (sharpness, AF behavior) so this is testable rather than hand-waved.

**Mitigations if tests show a problem:** Prefer **fixed-focus** mapping captures -- lock lens position after one AF cycle, or use a constant-focus / manual mode in software so the VCM is not hunting while the shutter is open; avoid AF moves immediately before each shot on a vibrating airframe.

### What we don't know

- **Actual vibration amplitudes.** The first-principles estimate above is reasonable but unverified. The FC has floating-hole isolator mounts, but its accelerometer and gyro data will still be useful for characterizing frame vibration when the motors first spin up.
- **2-blade vs 3-blade props.** 3-blade props shift the fundamental to 3x RPM (potentially different amplitude and frequency). Comparing FC vibration data between 2-blade and 3-blade configurations would be informative.
- **Resonant modes of the pod itself.** The clamshell pod has its own structural dynamics. If a pod resonance happens to coincide with the prop frequency, local amplification could occur. Test imagery will reveal this.
- **VCM suspension at prop-band frequencies.** Whether the floating lens group picks up enough relative motion during a still exposure to soften imagery is unknown without correlation between **pod-path accel** logs and sharpness / AF state.

### Pod-integrated vibration logging (planned)

This supports the vibration and rolling-shutter discussion with **data at the camera path**, without relying on the FC or OAK-D IMUs (isolators / bobbins decouple those from the same mechanical reference as the mapping cameras).

**Intent:** Keep **lightweight digital accelerometers** (e.g. ADXL345-class, SPI) **permanently** in each pod, mounted **rigidly in the shell on the same structural path as the camera bracket**, so logs reflect what the camera housing experiences. Optional second sensor near the **motor mount** on the same arm gives a **source** spectrum for transfer-path analysis; short runs (~order 4 inches) from breakout to that pod's **Pi Zero** keep SPI wiring manageable -- twisted pairs (clock/GND, data/GND), same noise hygiene as PPS.

**Logging:** For calibration-style hovers, stream high-rate samples to a **RAM-backed path** (e.g. `/dev/shm`) to avoid SD stalls in the sampling loop; after disarm, copy artifacts to SD. Routine mapping can leave the hardware idle or run low-duty logging.

**When to re-fly a fixed calibration profile:** Change of props, battery mass class, GPS mast / AUW, or major payload changes -- store a small **config manifest** (prop type, mass notes) beside each log so spectra are comparable over time.

**Throttle-ladder resonance campaign (optional):** One way to excite changing forcing frequency is to **dwell** at several throttle steps above a **hover baseline** (e.g. 50%, 55%, 60%, 65%, 70% of the stick range you define in firmware), holding each long enough for FFTs to settle. To make the baseline repeatable, **ballast** so that **hover** occurs at the chosen mid-stick point: e.g. if dyno data gives ~789 g thrust per motor at 50% on a static rig, four motors supply ~3.15 kgf total at that point, so AUW ballasted to ~3.15 kg hovers near that throttle (example numbers -- replace with **your** prop and dyno sheet). **Net vertical acceleration** at a step is **a = F_net / m** in SI units with **F_net = T_total - m*g** (thrust and weight as forces in newtons), or equivalently subtract weight from total thrust expressed in kgf and multiply by **g** before dividing by mass in kg. Do **not** multiply by **g** again after dividing force by mass (a common garbled formula).

**Kinematics vs aerodynamics:** Displacement from **d = 0.5 * a * t^2** for a multi-second dwell assumes **constant** acceleration -- a **vacuum upper bound**. Climb drag, induced power, and prop **slip** cap climb rate (order of tens of m/s for a 10" class prop at high RPM; ballpark: pitch length per rev times rev/s, then discount for slip). Real altitude gain per dwell is **much less** than the naive integral of constant **a**, especially at the highest steps.

**Airspace and sequencing:** Running a ladder **without** bleeding altitude between steps stacks height fast and can blow **VLOS** and legal ceilings in one long sequence. **Return to the hover baseline** (and **descend** if needed) **between** steps so each dwell starts near the same altitude band. Fly only where rules and spotting allow.

**Caveats:** Linear interpolation between sparse dyno points (50%, 60%, 70%) adds error; **2-blade** vs **3-blade** RPM and thrust curves differ -- using the more aggressive dyno set is intentionally conservative if you accept that mismatch. Hub ballast changes **modal frequencies** slightly; note ballast mass and placement in the manifest.

**Resonance bandwidth (Q) and step size:** Real modes are **damped** peaks in frequency, not infinitely thin lines. Joint friction, epoxy, and printed pods add **loss** so a mode that matters in flight may span on the order of **10-20 Hz** half-power width (order-of-magnitude only -- measure yours). During a dwell, the **forcing frequency** must sit inside that band long enough for the response to ring up. For **2-per-rev** prop forcing, blade-pass frequency is roughly **f = 2 * RPM / 60** Hz, so a **delta_f** hertz wide structural peak maps to a motor-speed span of about **delta_RPM = delta_f * 60 / 2 = 30 * delta_f** (e.g. **10 Hz** -> **~300 RPM**, **20 Hz** -> **~600 RPM**). **5-10%** throttle steps in the mid-throttle regime are often **hundreds of RPM** apart -- coarse enough to fly safely, fine enough to **overlap** modest-Q peaks if each step is held several seconds. Tight Q (very narrow peaks) would need finer steps or a slower continuous sweep; the frame-as-flown is unlikely to be tuning-fork sharp.

**Linear vs logarithmic spacing:** **Log** frequency sweeps suit **multi-decade** axes (acoustics, RF). The motor speeds you actually use span roughly **one mechanical octave**, and modal linewidth is naturally discussed in **constant hertz**, so **linear** throttle (or RPM) steps keep overlap between steps more uniform than log spacing. No need for log stairs on this axis.

**Harmonics and the "divisor" trap:** The frame has **fixed** natural frequencies (arm bending, torsion, pod modes). The motor injects **f0** (blade passage) plus **weaker** harmonics (**2f0**, **3f0**, ...). At some RPM, **2f0** may graze a mode with **little** harmonic energy and the craft feels smooth; at another RPM, **f0** may hit the **same** structural frequency with **full** fundamental energy and the response is violent. You **cannot** skip high-RPM testing because lower-RPM runs were quiet -- that is oscillator-style **divisor** reasoning and it fails here. **Sweep the full operational throttle band** you intend to use in anger.

**Time alignment:** Existing **PPS + chrony** per Zero gives a common time base for **post-flight** merge and comparison across the four arms; interpret **inter-pod phase** within the limits of how samples are timestamped on each Zero.

**Optional visual hinting:** Locked-off video plus Eulerian-style magnification can **qualitatively** show where flex concentrates at **low** frequencies relative to the camera frame rate; it does not replace accel for prop-band **frequency** truth (Nyquist). Useful mainly to **place** sensors and to sanity-check overall motion scale, not as a spectrum reference.

### What would change our minds

Evidence of jello (periodic waviness in lines that should be straight) in actual test stills, **or unexplained uniform softness / focus-dependent blur** after ruling out motion blur and AF mis-targeting, or FC vibration data showing unexpectedly large amplitudes at frequencies that interact with the sensor readout time (~26 ms for the IMX708). If either appears, moderate isolation (bobbins at the pod-to-arm interface) becomes the next thing to try -- but this introduces the inter-pod registration and minimum-weight-to-actuate problems noted above. If blur tracks **AF-on vs locked-focus** tests, treat VCM dynamics as the leading hypothesis before changing pod isolation.

---

## Rolling shutter considerations

The Camera Module 3 uses the Sony IMX708, which is an **electronic rolling shutter** sensor. It reads out line-by-line from top to bottom, not all at once. This section distinguishes between "has a rolling shutter sensor" (a hardware fact) and "exhibits rolling shutter problems" (an empirical question that depends on speed, vibration, and processing).

### "Has RS" vs "has RS problems"

The DJI Mini 3 Pro also has a rolling shutter sensor. It was flown at 5.6 m/s (20 km/h) at 25 m AGL for house-mapping experiments documented in [experiments-house-model.md](../../Datasets/experiments-house-model.md). The best result (house-2) reconstructed 400/446 shots with 0.86 px reprojection error, **without rolling shutter correction enabled in ODM**. The problems identified exhaustively in that document -- autofocus locking on treetops, nearfield parallax, turnaround gimbal instability, boundary tuning -- are not rolling shutter artifacts. RS correction was never enabled because there was no evidence it was needed.

The Rekon array at 3-5 m/s with similar or shorter readout times should have less forward-flight RS displacement than the DJI at 5.6 m/s.

### Forward-flight displacement

At 3-5 m/s with ~26 ms readout (approximate for the IMX708 in 12 MP mode -- needs confirmation from datasheet or measurement): 7.8-13 cm of physical camera displacement during readout. At ~1 cm GSD this is 8-13 pixels of systematic affine shear (parallelogram distortion). This is predictable, not random, and is exactly what ODM's rolling shutter correction models.

### Look-angle geometry

The simple "v * t_readout" is the naive worst case. Actual RS displacement per pixel depends on the angle between the velocity vector and each camera's line of sight.

With all 8 cameras at -70 degrees depression, the depression is steep enough that the geometry is still nadir-like: the cos^2 correction factor ranges from 0.88 (near-along-track cameras like NNE) to ~0.94 (cross-track cameras like ENE). The cross-track cameras (ENE, ESE, WSW, WNW) see the most RS because forward velocity is nearly perpendicular to their line of sight. The along-track cameras (NNE, SSE, SSW, NNW) see ~6% less RS because some velocity is along their line of sight.

The DJI comparison is slightly conservative: the DJI at -70 forward-facing had its velocity partially along the LOS, giving it ~12% less RS than pure nadir. The Rekon's cross-track cameras are modestly worse off. Net: the DJI at 5.6 m/s forward-facing likely saw comparable or slightly less RS distortion per pixel than the Rekon's worst-case cross-track cameras at 3-5 m/s. The DJI produced usable photogrammetry without RS correction. The Rekon should too -- but enabling RS correction in ODM is free accuracy, especially for the cross-track cameras.

### Vibration-induced jello vs forward-flight shear

Two distinct RS artifacts with different signatures:

- **Forward-flight shear:** Systematic parallelogram distortion from camera translation during readout. Predictable, correctable given readout time. Signature: consistent lean of vertical lines in the direction of flight.
- **Vibration jello:** Periodic waviness from camera oscillation during readout. Requires millimeter-scale lateral displacement at the camera (see Vibration section above for why this is unlikely at ~330 Hz on a rigid carbon frame). Signature: sinusoidal waviness in lines that should be straight.
- **Internal lens motion (VCM):** Camera Module 3 autofocus suspends the lens on a voice coil. Relative axial or lateral motion of the lens group during integration causes **defocus-like or generalized blur**, which is **not** the same artifact as RS shear or line-time jello. See **Autofocus voice coil (VCM) vs whole-body vibration** under *Vibration and camera mounting rationale*.

### Processing: ODM rolling shutter correction

ODM supports `--rolling-shutter` with a readout time parameter. Document the IMX708 readout time once confirmed (approximately 26 ms for 12 MP mode based on similar quad-bayer sensors). Enabling RS correction is a free accuracy improvement -- it models the affine shear and removes it from the bundle adjustment.

### Multi-camera spatial advantage

8 cameras with inter-camera overlap provide the dense feature matching that RS correction models rely on. This is coverage a single-camera platform cannot match.

### Multi-camera temporal advantage

This is arguably the most important advantage of the synchronized array.

With PPS-synchronized capture (microsecond alignment via chrony), all 8 cameras freeze the scene at the same instant. A single camera (like the DJI) doing two crosshatch passes captures the same area minutes apart -- shadows shift, leaves move, twigs change position between passes.

The matching problems identified in the DJI experiments (nearfield parallax, "parallax soup," wind-induced twig movement, inconsistent features across captures) are fundamentally **single-camera sequential problems**. With synchronized multi-camera capture:

- **Twig features are frozen** at one physical position across all 8 images. Within a single synchronized capture, even transient nearfield objects are perfectly stable features.
- **Intra-pod stereo baseline** (~4-5 inches between cameras in the same pod) produces small, manageable parallax even for nearfield objects, vs meters of baseline between sequential single-camera captures.
- **Forward-and-back cameras** capture opposite sides of a tree within seconds of passing overhead, vs a lawnmower grid where front and back come from different passes (a full track-width of lateral displacement, minutes apart).
- **Feature tracks** may not extend across captures taken seconds later (wind moves things), but within each synchronized burst the stitching web should be far more robust than sequential grids.

This reframes the nearfield parallax analysis from the [DJI experiments](../../Datasets/experiments-house-model.md): the feature-track-length filtering strategies developed there (raise `min_track_length`, etc.) were designed for single-camera sequential capture where twigs are unstable across time. Synchronized capture creates a **local exception** to the nearfield parallax problem within each burst -- all 8 images stitch robustly because the scene is frozen. Between successive bursts (seconds apart, meters of drone displacement), the full problem returns: wind moves twigs, the scene changes, and cross-burst feature tracks through nearfield objects will be unreliable. The overall reconstruction depends on connecting these robust intra-burst webs to each other via stable features (ground, trunks, structures). The DJI-era filtering strategies remain relevant for the cross-burst matching problem.

---

## Processing pipeline

Images land on each Pi Zero's local SD card. Post-flight processing:

1. **Collect images** from all SD cards, with GPS-locked timestamps embedded by libcamera (CLOCK_MONOTONIC, phase-locked to GPS via PPS + chrony).
2. **PPK-style interpolation:** Match each image's capture timestamp against ArduPilot's high-rate pose logs (50-100 Hz) to determine the exact 3D position and attitude of the drone at the moment of capture.
3. **Feed to ODM** with `--rolling-shutter` enabled and the measured IMX708 readout time. ODM handles feature matching, bundle adjustment, RS correction, point cloud generation, mesh/DEM/orthophoto output.
4. **Multi-camera metadata:** Each image carries its camera's aim direction and position offset from the GPS antenna (lever arm). ODM's multi-camera support (or manual rig definition) uses this to jointly optimize all cameras.

---

## Upward-looking gap detection

Canopy gap detection for the ice-hole operations pattern ([canopy-ops.md](canopy-ops.md)) requires an upward-facing camera and a way to get images or status to the pilot. Two implementation phases let the first canopy missions fly before the vertical-ring pods are built.

### Phase 1: Pixel Fold as interim gap-detection camera

Strap a Pixel Fold to the top of the frame, camera pointed up. The phone is **completely disconnected from the flight system** -- no USB to the Coordinator, no data integration, no WiFi required during flight. The drone does not know the phone exists.

- **Power:** USB-C pigtail from the 5 V stripboard rail (same approach as the Coordinator's power feed). ~500 mA without negotiation keeps the phone alive for the duration of a flight. Even this is optional -- the phone's own battery will outlast the flight pack.
- **Mounting:** A simple printed bracket on top of the frame, aimed upward. Secure against vibration (VHB + strap or bolted cradle).
- **Operation:** The pilot uses FPV to position under a candidate gap, then checks the Pixel Fold's upward view on a ground device (via hotspot, or via the phone's screen after landing if the gap evaluation can wait). When satisfied, the pilot commands a vertical climb manually. The drone simply sees a climb stick input -- no autonomous gap-detection logic in the loop.
- **WiFi (optional):** If the pilot wants live upward imagery during flight, connect a ground phone to the Pixel Fold's hotspot. Range through canopy is marginal (~30 m line-of-sight, less through foliage) but improves as the drone ascends. This is a convenience, not a requirement.

This gets canopy missions flying without designing, printing, and integrating another set of pods on top of the OAK-D mount, GPS mast, and arm pods.

### Phase 2: Permanent vertical-ring pair (NNW + NNE)

The first two cameras from the planned **vertical ring** (see *Overview* above). These are the topmost members of that ring -- the near-zenith pair. Primary role: **canopy gap detection** with onboard algorithmic assessment. Secondary role: **canopy-from-below photogrammetry** data (crown architecture, branch density) when running at full resolution. When the rest of the vertical ring is populated, these two cameras become its zenith segment with no changes.

Replaces the Pixel Fold once the vertical-ring pods are built. Advantages over the phone: no separate device to manage, integrated into the Coordinator's PPS/USB/telemetry system, onboard gap-detection algorithm feeds a MAVLink OSD flag at full ELRS range, and the cameras contribute photogrammetric data.

### Aim geometry (upward pair)

Each camera is a standard Camera Module 3 (66 x 41 degree FOV) mounted **rotated 90 degrees** so the 66-degree axis is in **elevation** and the 41-degree axis is in **azimuth**. Aimed at **+70 degrees elevation** (20 degrees from zenith):

- **Upper edge:** +70 + 33 = +103 degrees -- past zenith by 13 degrees. Both cameras' upper edges cross the zenith pole.
- **Lower edge:** +70 - 33 = +37 degrees -- well above horizon, well clear of the prop disc in level flight.

NNW is at -22.5 degrees azimuth from forward, NNE at +22.5 degrees. Near zenith, projection geometry widens azimuthal coverage substantially, so the two cameras **overlap around the zenith pole** by roughly 20-25 degrees. Together they cover the straight-overhead region plus ~20 degrees to either side -- the corridor that matters for vertical ascent through a canopy gap.

**Prop clearance:** At +37 degrees (lower FOV edge), the camera looks well above the prop plane in level flight. When the drone pitches forward at survey speed, the prop plane tilts toward the camera. Verify clearance with a bench photo at maximum expected pitch angle (~15-20 degrees). If the prop tip enters the FOV, raise the aim angle or crop the lower edge in software.

**Protection:** Top-mounted cameras are exposed to rain, debris, and (in theory) descending prop wash from above in wind. A clear polycarbonate dome or recessed mount is recommended.

### Gap detection mode

**When active:** Only during under-canopy missions, commanded by the Coordinator or pilot. In open-sky mapping, these cameras either capture full-resolution frames for canopy-from-below photogrammetry or stay idle.

**Capture parameters:** Low resolution (640x480 or 320x240), **0.5 Hz** (one frame every 2 seconds). This is trivial load on the Pi Zero compared to full-resolution mapping captures.

**Detection algorithm:** The problem is easy. Looking straight up through canopy, branches and leaves are **dark silhouettes against bright sky** -- the highest-contrast scene in nature. Start with a simple brightness threshold:

1. Capture a low-res frame.
2. Extract the zenith region (center of the overlapping FOV, roughly +/- 15-20 degrees from vertical).
3. Compute the fraction of pixels above a brightness threshold (or a histogram bimodality metric).
4. If the bright fraction exceeds a tuned threshold, report "gap candidate." Otherwise "obstructed."

No ML required for V1. The Pi Zero runs this locally and reports a binary flag to the Coordinator over USB. The Coordinator aggregates the two cameras (NNW and NNE must both agree on "clear" in their overlap region) and relays a **gap-status telemetry flag** to the FC via MAVLink.

**Bias the algorithm conservative:** A false "clear" (reports gap when branches are present) is dangerous -- the drone flies into an obstruction. A false "obstructed" (reports blocked when a gap exists) only wastes time. Tune the threshold to **favor false negatives** (miss a gap) over false positives (miss a branch). The pilot retains final authority.

**Incremental confidence during ascent:** As the drone creeps upward through a candidate gap (0.5-1 m/s climb), the upward cameras re-evaluate every 1-2 seconds. The gap assessment **improves with altitude** -- parallax decreases, thin branches resolve better, and the cameras see deeper into the gap. The first frame from the ground is the least trustworthy; the frame from halfway through the gap is much better.

### Pilot confirmation via WiFi (both phases)

**Phase 1 (Pixel Fold):** The pilot views the phone's upward camera feed directly on a ground device connected to the phone's hotspot. No algorithm, no OSD flag -- human eyeballs on the image. This is the right approach while the concept of operations is new and the pilot is learning what "a flyable gap" looks like from below.

**Phase 2 (Pi Zero pair):** One of the two upward-looking Zeros advertises a **WiFi AP** and serves a minimal web page (or raw JPEG endpoint) showing the latest upward-looking frame. The pilot connects a phone on the ground. The onboard gap-detection algorithm also feeds a **MAVLink OSD flag** ("gap detected" / "obstructed") over ELRS at full range -- but especially early on, seeing the actual image is the fastest way to calibrate trust in the algorithm. Plan to use WiFi confirmation heavily during the first few gap penetrations after transitioning from phase 1, then taper off as confidence grows.

**WiFi range (both phases):** ~30 m line-of-sight in open, less through canopy. Improves as the drone ascends through the gap, which is exactly when the pilot most wants the image.

**Pilot decision flow (phase 2 at maturity):**

1. **OSD flag** (via MAVLink over ELRS): "gap detected" / "obstructed" -- always available, full ELRS range.
2. **WiFi image** (via phone): visual confirmation for ambiguous cases -- available when in range.
3. **FPV view** (Walksnail): forward/lateral context during ascent -- always available but aimed forward, not up.
4. **Slow cautious ascent** with periodic re-evaluation from the upward cameras.

Do not design the mission around WiFi availability. Canopy attenuates it, and you chose ELRS for RTCM delivery precisely because you could not count on WiFi to the aircraft.

### Weight and electrical budget (upward pair)

| Item | Est. mass (g) | Notes |
|------|---------------:|-------|
| Pi Zero 2 W x2 | 30 | ~15 g each with headers |
| Camera Module 3 x2 | 8 | ~4 g each |
| Heatsink x2 | 18 | ~9 g each |
| Pod shell x2 (printed, PLA or PETG) | 20-30 | Rigid mount; simpler than horizontal-ring pods |
| Cables, connectors | 10-15 | USB, ribbon, PPS |
| **Total** | **~90-100** | |

AUW increase from ~2.0 kg to ~2.1 kg. Negligible given the available thrust margin.

**Power:** Two Zeros + cameras + SD + WiFi (when AP is active) = ~600-800 mA at 5 V (3-4 W) peak. The Castle BEC has headroom.

**USB hub:** The upward pair needs two hub ports that are not part of the horizontal-ring hubs. This is the first hub for the vertical ring -- a small 4-port unit with two ports used now and two spare for future vertical-ring cameras. See [central-hub.md](central-hub.md) for hub and PPS buffer allocation.

### Mounting

Top-side of the frame, at the arm-frame junctions for the **forward-left** and **forward-right** arms (matching the NNW and NNE azimuthal positions). Same structural rationale as the horizontal-ring pods: arm-frame junction is the stiffest point. Vibration analysis from the horizontal ring applies here -- the upward pair sits on the same structural path.

Pod design can be simpler than the horizontal ring: no need for the elaborate clamshell aiming geometry, since both cameras point nearly straight up at the same elevation angle. A shared top-plate bracket with two camera pockets at the correct aim angles is one option.

---

## Connections (end-to-end endpoints)

### Pi Zero 2 W

Each arm holds two of these in a V.

* USB from hub (**data + power** today; optional **data-only** USB with **5 V on header** from stripboard -- see [central-hub.md](central-hub.md) *Alternative: data-only hub links*)
* MicroSD for storage (in Pi Zero)
* PPS line and ground from central hub to GPIO on PiZero, maybe through a resistor
* Camera-to-pi-zero ribbon cable
* (Planned) SPI accelerometer(s) on short twisted-pair runs from pod breakout to Zero -- see *Pod-integrated vibration logging* under *Vibration and camera mounting rationale*
* USB harness reference cable: PiShop `CS-PID-40` (USB A-male to USB Micro-B, 6 in)

## Camera Module 3

* Camera-to-pi-zero ribbon cable to pi zero
* Cable options used in this design: PiShop `850` (38 mm Zero camera cable) and PiShop `407` (150 mm alternative for routing flexibility)
* Storage media reference: PiShop `964` (Class 10 32 GB microSD)

---
