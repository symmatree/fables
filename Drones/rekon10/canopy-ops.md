# Canopy operations doctrine

[Back to index](README.md)

Mission doctrine for flying under tree canopy: the "ice-hole" navigation pattern, gap detection, incremental map building, error budgets, VIO risks, and fallback procedures. Hardware details for gap detection live in [arm-pods.md](arm-pods.md) (*Upward-looking gap detection*); navigation sensors and VIO in [rekon-design.md](rekon-design.md).

> **Measured evidence (2026-07-07).** Several error-budget and VIO-risk items below were *assumptions*
> when written. Some now have data from two 2026-07-05 flights, reprocessed through a tracked,
> deterministic VIO pipeline in the **coordinator** repo -- see coordinator
> [#42](https://github.com/symmatree/coordinator/issues/42),
> [`analysis/vio-quality-experiments.md`](https://github.com/symmatree/coordinator/blob/main/analysis/vio-quality-experiments.md),
> and the `vio-quality.ipynb` notebook. Measured points are marked **[measured, GPS-good proxy]** inline.
> **Important caveat on all of them:** the data is from **GPS-good, open, well-lit** flights (RTK the
> whole time; GPS-denial is *simulated* by withholding intermediate GPS from the reconstruction). Canopy
> -- feature-poor, moving leaves, lighting transitions, low light -- is a different and likely worse
> environment, and remains **untested**. Treat every number as an **optimistic floor**.

---

## Ice-hole pattern (periodic GPS re-acquisition)

The core operational concept for under-canopy mapping is **periodic GPS re-acquisition through canopy gaps**, not long continuous flights where VIO drift accumulates unboundedly. Think of it as searching for gaps in the ice: fly under canopy for a bounded interval, find a gap, ascend to clear sky, reset navigation, descend through the same hole, and resume.

### Why this is the right scoping decision

VIO (OAK-D + VINS-Fusion on the Coordinator) will drift. Under canopy with variable lighting, feature-poor ground (leaf litter, uniform soil), and vibration, even good VIO accumulates position error over time. The alternative to periodic GPS reset is **real-time localization against a previously-built map** (visual relocalization, LiDAR map matching, etc.) -- a hard software problem with bad failure modes that would require significant compute and careful map management. The ice-hole pattern sidesteps this entirely: VIO only needs to dead-reckon for ~60-90 seconds at a time, well within its design envelope, and the system never needs to recognize "where it is" on a map in real time.

PPK post-processing also benefits: each under-canopy leg starts and ends with a known GPS position (RTK Fixed). ArduPilot's pose log has the VIO-fused trajectory in between. Post-processing can constrain both endpoints, giving a well-bounded trajectory for image georeferencing even without continuous RTK.

### Planning interval

**Target: ~60-90 seconds between GPS re-acquisitions**, corresponding to roughly 60-180 m of path at under-canopy speeds (1-2 m/s -- obstacle avoidance keeps you slower than the 3-5 m/s survey speed). This is a **planning target, not a rigid timer**. Some forests have convenient gaps every 30 m; dense closed canopy might not offer one for 200 m. The system should support **opportunistic gap-finding** driven by an upward-looking camera (see [arm-pods.md](arm-pods.md), *Upward-looking gap detection*) and pilot judgment, not a countdown.

Over 60-90 seconds of flight, VIO drift should remain in the tens-of-cm range -- acceptable for photogrammetry and well within what PPK endpoint constraints can absorb.

> **[measured, GPS-good proxy]** On the armed 2026-07-05 flight, reconstructing **stereo-only** VIO
> (no IMU -- see *VIO risk assessment* below) with intermediate GPS **withheld** and anchored only at
> segment endpoints, a locally-rigid fit holds to (rms residual): **~6 cm @ 2 m, ~16 cm @ 5 m, ~26 cm
> @ 10 m, ~37 cm @ 20 m, ~64 cm @ 40 m** of path. So over the 10s-of-metres leg the plan targets, drift
> is **tens of cm** as assumed -- confirming the budget, on the optimistic (open, well-lit) end. This is
> a rigid-fit *proxy*; a proper GPS-anchored global (batch) solve should match or beat it (coordinator
> [#59](https://github.com/symmatree/coordinator/issues/59)).

### Ascent / hold / descent procedure

1. **Identify gap.** In **phase 1** (Pixel Fold strapped to frame, disconnected from flight system), the pilot uses FPV to position under a candidate gap and checks the phone's upward view for confirmation -- purely human-in-the-loop, no autonomous gap logic. In **phase 2** (permanent NNW + NNE vertical-ring pair), an onboard algorithm reports a gap-status flag on the OSD, with WiFi image confirmation available as a secondary channel. See [arm-pods.md](arm-pods.md), *Upward-looking gap detection*.
2. **Position below gap.** Fly to center beneath the candidate gap. FPV gives forward/lateral context; upward camera gives zenith-region confirmation.
3. **Slow vertical ascent.** Creep straight up, capturing upward frames periodically (every 1-2 s) and re-evaluating clearance. The first penetration of a new gap must be cautious -- the upward camera provides an assessment from below, but parallax and thin branches can fool a camera looking through foliage. Speed: ~0.5-1 m/s climb, pausing if the picture changes.
4. **Clear sky -- hold.** Once above canopy with open sky, hold position and wait for the **F9P to re-acquire RTK Fixed** and the **ArduPilot EKF to settle back onto the GPS lane** (`EKF_STATUS_REPORT` flags). Do not rush back down on Float. Expected hold time: **5-15 seconds** with warm almanac and continuous RTCM; up to **30-60 seconds** if the F9P lost satellite tracking entirely during a long under-canopy leg. This hold directly costs mission time and battery but is non-negotiable for navigation integrity.
5. **Descend through the same hole.** You already characterized gap geometry on the way up. Descend vertically through the same opening. This avoids the risk of a blind descent into unknown obstruction.
6. **Resume under-canopy mapping.**

### Time and energy budget

Each cycle costs roughly: 10-20 s climb (depends on canopy height, 10-25 m typical eastern US deciduous) + 5-30 s hold (RTK reconvergence) + 10-20 s descent = **25-70 seconds per cycle**. With a 90-second under-canopy leg, the overhead is **20-45% of total mission time**. Significant, but acceptable given the alternative (unbounded drift or online SLAM). Reducing hold time by keeping RTCM flowing continuously (so the F9P's almanac stays warm even without position fixes) helps.

### Wind at tree-top level

Ascending above canopy exposes the drone to wind that was blocked below. The 10" platform with substantial thrust margin handles this, but the pilot should expect a lateral push at the canopy-to-open transition. Loiter mode during the hold phase lets ArduPilot manage wind hold automatically once GPS is back.

### What this does NOT require

- No prior map of the area (first flight is fine).
- No LiDAR for canopy detection (camera-based gap detection is sufficient for the vertical corridor).
- No online visual relocalization or map-matching software.
- No changes to ArduPilot -- standard GPS/VIO EKF switching handles it.

The lidar rangefinder (Benewake TFS20-L, planned -- not yet fitted) helps with **AGL accuracy** during the under-canopy legs but is not required for the ice-hole pattern itself.

---

## Two separate error budgets

The flight-safety error budget and the mapping error budget are different problems with different tolerances and different solutions. Conflating them leads to over-engineering.

### Flight safety (real-time)

The drone needs to know where it is well enough to **find its way back to the gap it came from** and **not fly into a tree**. This is a coarse requirement -- meter-scale accuracy is fine. VIO drift of 30-50 cm over a 90-second leg is not a safety problem. Even a meter of drift is survivable if the pilot is flying conservatively.

The real flight-safety threat is not gradual drift but **sudden VIO jumps** -- a 2-meter step in estimated position causes ArduPilot to command a correction that sends the drone sideways into a trunk. Mitigations:

> **[measured, GPS-good proxy]** Confirmed, and important: even the well-behaved **stereo-only**
> reconstruction is smooth 99% of the time (inter-sample steps < 10 cm) but throws **rare 1-2 m
> single-sample jumps** (max ~1.3 m armed, ~2.4 m handheld). So dropping the IMU removes the
> *catastrophic* runaway (see *VIO risk assessment*) but **not** this jump mode -- it is the residual
> safety item. Handle it with ArduPilot's **existing** EKF3 innovation gate (`EK3_POS_I_GATE` +
> external-nav source noise, `EK3_GLITCH_RAD`), which rejects measurements whose innovation exceeds the
> gate; **do not build a bespoke filter** until that gate is shown insufficient. (Lane switching,
> `EK3_IMU_MASK`/`EK3_ERR_THRESH`, is a *different* mechanism -- IMU-core health, not measurement
> outliers.) Note the deployed IMU-fusion config fails **fail-confident** (a smooth ~1000 m/s garbage
> velocity), which is the worst case for "in doubt, hold" -- another reason to prefer stereo-only. See
> coordinator [`vio-quality-experiments.md`](https://github.com/symmatree/coordinator/blob/main/analysis/vio-quality-experiments.md) (E12, X10).

- **Fly slow under canopy** (1-2 m/s). This gives both VIO and the pilot time to react.
- **Use AltHold or Stabilize as the fallback**, not Loiter, if VIO is degraded. Position hold without good position estimates is worse than no position hold.
- **Pilot must be comfortable on FPV alone.** If VIO fails entirely, the pilot is flying manual under canopy. This is the same skill as FPV freestyle in a forest, minus the speed. Practice it before relying on it as a safety net.

### Mapping quality (post-hoc)

The photogrammetric map does not care that VIO drifted 30 cm during a leg. ODM's bundle adjustment distributes error across the entire image set after the fact. What matters for map quality:

- **Enough image overlap** within and between bursts. The 8-camera array provides massive intra-burst overlap; forward travel at 1-2 m/s with 1-2 Hz capture provides inter-burst overlap.
- **GPS-anchored endpoints** to constrain the solution. Each ice-hole breakout provides one. PPK interpolation fills in the legs between them.
- **Stable features** (trunks, ground, rocks) for cross-burst feature matching. Twigs and leaves move between bursts; the DJI-era filtering strategies ([arm-pods.md](arm-pods.md), *Multi-camera temporal advantage*) apply to the cross-burst problem.

A safety breakout also counts as a GPS endpoint for PPK -- the "safety" maneuver retroactively fixes mapping drift for the leg that preceded it. There is no wasted motion.

### Multi-camera geometry is unusually forgiving of drift

A single-camera platform that drifts 50 cm has 50 cm of positional error in every image from that leg. The 8-camera array captures the same scene from 8 angles simultaneously. Within each synchronized burst, the inter-camera geometry is rigid (one frame, bolted to the same airframe). Bundle adjustment can solve the rig's pose from the image content alone, even if the reported GPS/VIO position is off. The GPS endpoints constrain the trajectory; the multi-camera overlap provides massive redundancy for the SfM solver.

Forward-and-backward cameras (NNE/SSW, NNW/SSE) see the same trees from opposite directions on outbound and return passes, creating natural **image-based loop closure** even when GPS does not provide one.

---

## Incremental map building ("nibble in from the edges")

The forest does not need to be mapped in one flight. Each mission adds coverage that merges with prior data.

### Strategy

1. **Early missions** build a strong GPS-anchored skeleton around the canopy perimeter and near large, easy gaps. Lots of GPS time, short under-canopy legs, conservative.
2. **Middle missions** push deeper into closed canopy, using known gaps from prior flights and connecting new imagery back to the already-reconstructed skeleton.
3. **Deep missions** target areas that require longer VIO-only legs or smaller gaps. By this point the surrounding geometry is well-constrained, so even a drifty leg can be anchored at both ends by overlap with prior data.

Each mission's GPS endpoints tie into prior data. ODM (or any SfM pipeline) gets better as you add more images to an already-constrained region. The skeleton grows inward.

### What makes this work

- **Overlap with prior flights.** Each new flight's GPS-anchored segments must overlap with previously reconstructed areas. The edges of the existing map are the launch points for new coverage.
- **Stable ground-truth features.** Tree trunks, rocks, terrain, and built structures do not move between flights. Canopy features (leaf positions) do. The SfM solver needs the stable features to tie flights together; the synchronized array's intra-burst stability handles the transient features within each flight.
- **Consistent camera geometry.** The rig definition (8 cameras at known offsets and angles) is the same every flight. ODM can jointly optimize all cameras from all flights if the rig is stable.

### What does NOT need to happen on day one

- No need to map the entire forest in one battery.
- No need for centimeter-accurate VIO under canopy -- PPK and bundle adjustment handle that post-hoc.
- No need for the vertical ring -- the horizontal ring captures geometry fine for the mapping mission. The vertical ring adds side-scan coverage under canopy and gap detection; the gap detection is handled by the Pixel Fold in phase 1.

---

## VIO risk assessment

VIO quality under canopy is the **gating unknown** in this plan. Everything else -- cameras, timing, GPS, frame, power -- is well-characterized hardware doing well-understood things. The one thing that has not been flight-tested is whether VINS-Fusion on a Pi 4B with the OAK-D produces usable position estimates while flying at 1-2 m/s under tree canopy.

> **[measured, GPS-good proxy] IMU-fusion (`imu: 1`) fails hard; stereo-only works -- deployed default
> has since moved to `imu: 0` (coordinator [#69](https://github.com/symmatree/coordinator/issues/69)).** On
> both 2026-07-05 flights, the then-deployed IMU-fusion pose **runs away** (to ~41.9 km on the armed flight,
> velocity to ~1000 m/s), while **stereo-only** VINS (`imu: 0`) tracks the whole flight at ~1 m ATE.
> Because the OAK-D is stereo, metric **scale comes from the baseline** and the IMU is not needed for it
> -- "visual-**inertial**" is a *monocular* requirement we don't share. The likely architectural fault:
> we fuse a **poor** IMU (BNO085 *fused* output, hard-mounted, online-estimated extrinsic/time) into VINS
> *first*, then feed that to the FC's central EKF, which already fuses a **good** IMU -- a redundant,
> low-quality inertial stage given authority. The plan should **run the OAK-D stereo-only** and let the
> FC's EKF do the inertial fusion (or reintroduce the IMU only as a properly-weighted relative-velocity
> factor in the offline solve, coordinator [#59](https://github.com/symmatree/coordinator/issues/59)).
> *Caveat:* stereo scale weakens for **far** scenes vs the ~75 mm baseline, so this holds for the
> **near-field** canopy regime, not at altitude. Cause of the IMU-fusion failure (vibration vs extrinsic
> vs time-sync vs the fused-IMU model) is **not isolated** -- see the vibration bullet below.

### Failure modes to expect

- **Feature-poor scenes** (uniform leaf litter, snow, water) can cause sudden jumps, not gradual drift. VIO needs visual texture to track.
- **Rapid lighting transitions** (flying from shade into a sunbeam) can blow out stereo matching. Auto-exposure lag on the OAK-D may exacerbate this.
- **Vibration coupling** through the OAK-D's bobbins into the IMU can corrupt VINS-Fusion's pre-integration. The bobbin isolation is designed for this, but it is untested in flight. **[measured, GPS-good proxy]** The camera IMU *does* see vibration (accel band-power >5 Hz ~400-500x higher armed vs handheld), but we have **not** isolated vibration as the cause of the IMU-fusion failure -- the motors-off handheld run *also* failed on `imu: 1` (though "motors off" is not "vibration-free": hand tremor, footfalls). Running **stereo-only** sidesteps this entire class of risk (no IMU pre-integration to corrupt), whatever its true cause.
- **Compute limits on Pi 4B.** VINS-Fusion is not lightweight. If the Pi 4B drops frames or falls behind on IMU integration, position estimates degrade unpredictably.

### Mitigations (all already in the plan)

- **Short VIO-only legs** (60-90 seconds). Bounds how far any failure mode can propagate.
- **Slow flight** (1-2 m/s). Gives VIO more frames per meter of travel, more time to converge, and more pilot reaction time if something goes wrong.
- **Conservative early missions.** Fly near large gaps, short legs, easy terrain. Build confidence before pushing deep.
- **Pilot FPV fallback.** The pilot can always take over on FPV alone. This is the ultimate safety net.

### What to watch for in early flights

- **EKF innovation values** in the ArduPilot logs. Large or oscillating innovations on the VIO lane indicate the FC does not trust the VIO data. Review logs after every canopy flight.
- **Position jumps** in the VIO stream. These show up as sudden spikes in VIBE or NKF messages. If they correlate with lighting transitions or feature-poor zones, those areas need slower flight or avoidance.
- **Thermal throttling** on the Pi 4B. If VIO degrades after several minutes, check CPU temperature. The Coordinator may need better cooling or reduced background load.

---

## Gap frequency (empirical assumption)

The plan assumes enough canopy gaps exist in the target forests (eastern US deciduous) to support periodic breakouts every 60-180 m of path. This is plausible -- trails, creek beds, logging roads, dead-tree clearings, and natural gaps from storm damage are common. But it is an **assumption, not a measurement**.

### Validate early

The first flights should explicitly test gap frequency. Fly the canopy edge and count: how far between gaps that are large enough to safely ascend through? If the answer is "every 30-50 m," the plan is conservative and there is room to extend legs. If the answer is "every 200+ m," the VIO legs get long and the drift budget tightens.

### Retreat mode

If the pilot flies for 90 seconds and cannot find a gap, the correct response is **retreat to the last known gap**, not "keep going deeper." Every gap that has been successfully used is a known-safe exit. Fly back toward it on VIO, ascending through the same hole. This means the pilot should maintain awareness of the bearing and approximate distance to the last gap at all times -- a mental model, not a software requirement (though the Coordinator could track it in phase 2).

---

## RTK reconvergence in narrow gaps

Popping above the canopy through a narrow gap may not give a full-sky view. Trees on all sides restrict satellite geometry. The F9P may achieve a 3D fix but struggle to reach RTK Fixed in a narrow opening.

### Practical guidance

- **Accept Float or 3D-only for the safety breakout.** Getting above the canopy with any GPS fix is enough to prevent getting lost. PPK will refine the position later.
- **If RTK Fixed is needed** (e.g., to anchor a critical survey endpoint), hold longer or reposition to a wider opening. Budget 30-60 seconds for worst-case convergence in a narrow gap.
- **RTCM must flow continuously** even under canopy (via ELRS). If the F9P loses RTCM input, RTK convergence after breakout takes much longer because the receiver needs to rebuild the differential corrections from scratch. Keep the ELRS link active and RTCM injecting at all times.
