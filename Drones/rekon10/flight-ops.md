# Flight operations (how a sortie actually runs)

[Back to index](README.md)

Operator-side facts about flying the rekon10: what has to be true before launch, what arming
actually is, and what the vehicle is doing while it sits on the ground. None of it is readable off
a DataFlash log or a parameter dump, and post-hoc analysis has repeatedly inferred it wrong -- which
is the reason for writing it down rather than leaving it implicit.

Mission doctrine for the under-canopy legs is [canopy-ops.md](canopy-ops.md); ArduPilot parameters
and pre-arm check mechanics are [ardupilot.md](ardupilot.md); the ground radio and corrections
hardware are [ground-station.md](ground-station.md).

> **Provenance.** Lines marked **[operator]** are the pilot's account of how the sortie is flown.
> Lines marked **[measured]** are decoded from a named flight log. Where both bear on the same fact
> they are given separately, because they can drift apart -- the operator's account is what is
> *intended* and the log is what happened on one particular day.

---

## Launch preconditions

**RTK Float is required before launch, deliberately.** **[operator]** The pilot holds on the ground
until the F9P reports RTK Float and does not launch without it. The reason is not navigation --
the vehicle flies GPS-primary and would manage on a 3D fix -- it is **ground truth**. Nearly every
question being asked of this airframe (VIO quality, drift budgets, mapping accuracy) is assessed by
comparing something against the GPS/EKF trajectory, and that comparison is only worth making if the
reference is good. Launching without Float produces a flight whose data cannot settle anything.

**[measured, 260814-woods]** RTK Float acquired at t=26.9 s, still Float at arm (t=67.4) and at
liftoff (t=75.4). The precondition was met.

**The precondition is a *launch* condition and does not survive the sortie.** **[measured,
260814-woods]** Float held until t=176.5, flickered against DGPS through ~198 s, then dropped to a
plain 3D fix at t=198.7 and stayed there for the rest of the traverse, recovering only on the way
out. **0% of the deep-woods window (200-290 s) was at RTK Float; 43% of the airborne window
overall.** So "GPS ground truth" is a claim about the *open* parts of a flight. Under canopy the
truth reference degrades in exactly the regime the VIO exists to cover, and the two degrade
together -- coordinator
[`analysis/vio-quality-experiments.md`](https://github.com/symmatree/coordinator/blob/main/analysis/vio-quality-experiments.md)
E19 records the same pattern on 260712, with the tell being accuracy (`HAcc`/`VAcc`) rather than
satellite count or HDop, both of which stay green.

**Most of the pre-launch ground time is spent getting corrections to flow.** **[operator]** The
RTCM path runs over a backpack WiFi link that is unreliable, so the wait before arming is largely
fighting that link and watching lock status, sometimes across several disarm/rearm cycles. Tracked
in coordinator [#195](https://github.com/symmatree/coordinator/issues/195) (Float fast, Fixed rare),
[#196](https://github.com/symmatree/coordinator/issues/196) (move the link off the Boxer),
[#199](https://github.com/symmatree/coordinator/issues/199) (halve the RTCM uplink); the delivery
path itself is coordinator
[`docs/rtk-corrections-path.md`](https://github.com/symmatree/coordinator/blob/main/docs/rtk-corrections-path.md).

**[measured]** That wait is a large share of some capture sessions. On flights recorded before
capture arm-gating landed (coordinator [#88](https://github.com/symmatree/coordinator/issues/88),
2026-07-30), pre-ARM ground frames are **51.7%** of the 260712 capture set and **24.0%** of 260730,
against 0.0-1.3% on the arm-gated flights.

---

## Arming is a transition, not a state

**[operator]** Arming is "putting the car in drive, not turning the key." It times out within
seconds if the vehicle does not launch, forcing a disarm and rearm, so the pilot arms only once
everything else is already satisfied and launches immediately -- an estimated ~5 s later.

**[measured]** Arm-to-liftoff, across four flights where both events are unambiguous: **1.2 s**
(260712), **7.4 s** (260730), **7.8 s** (260812-maneuver), **8.0 s** (260814).

Three consequences, all of which have bitten analysis:

- **There is no dwellable "armed on the ground" regime to collect.** Any experiment that wants
  motors running with the airframe stationary has to come from a **hover**, or from a tie-down
  bench rig. Waiting on the ground with the motors spinning is not something this airframe will do.
- **Idle is not a small dose of hover -- it is a different treatment.** **[measured, 260814]**
  Armed-on-the-ground sits at a median **2057 RPM / VIBE 0.99**, against **6970 RPM / VIBE 8.72**
  in the airborne hover: **3.4x the RPM and 8.8x the vibration**, so a motors-on-ground frame
  carries roughly **11%** of the hover vibration dose. It is not a control for anything that
  happens in flight.
- **Do not derive the airborne window from `ARM` records or EV codes.** **[measured, 260814]**
  `EV Id=28` fires at t=71.74, **3.7 s before liftoff**, with `ThO=0.018` and zero climb rate -- it
  marks spool-up, not takeoff. Derive liftoff and touchdown physically instead (altitude above the
  pre-arm ground level, and throttle falling to zero).

---

## The vehicle at rest on the ground

**It sits slightly tilted.** **[operator]** The buckle on the battery strap props one side, so the
airframe is not level when parked. Consequence: **an at-rest attitude reading is not a level
reference.** Anything that treats "sitting on the ground" as roll = pitch = 0, or that uses a
ground segment to calibrate a camera-to-body rotation, inherits that tilt as a fixed bias.

**Home-relative altitude is not height above ground.** **[measured, 260814]** The vehicle took off
from the paver patio and landed roughly **0.8 m below** the home datum, in grass downslope, and
spent much of the traverse at negative home-relative altitude while flying a couple of metres above
actual terrain. Consequence: an absolute altitude threshold mis-detects touchdown, and "altitude"
in a log is not AGL unless a rangefinder says so ([ardupilot.md](ardupilot.md), *Rangefinder*, is
still future work).

---

## What this means for log analysis

A short checklist for anyone scoring a flight:

1. **Derive the airborne window physically** -- altitude above the pre-arm ground level for
   liftoff, throttle to zero for touchdown. Not `ARM`, not EV codes, not an absolute altitude
   threshold.
2. **Do not use armed-on-ground frames as a motors-on control.** They are ~11% of the hover
   vibration dose and there are only a handful of them.
3. **Do not assume RTK-quality truth across a whole flight.** Check the GPS status trace over the
   window being scored; under canopy it will not be Float, and satellite count and HDop will not
   tell you that.
4. **Do not treat an at-rest attitude as level.** The parked tilt is a real, unmeasured bias.
5. **Check how much of a pre-2026-07-30 capture session is pre-launch ground time** before quoting
   any "in-flight" distribution from it.

---

## Related

- [canopy-ops.md](canopy-ops.md) -- mission doctrine for the under-canopy legs (ice-hole pattern,
  error budgets, retreat mode).
- [ardupilot.md](ardupilot.md) -- parameters, RTCM/RTK configuration, and what actually blocks arming.
- [ground-station.md](ground-station.md) -- radio, goggles, and ground equipment.
- coordinator [`analysis/vio-quality-experiments.md`](https://github.com/symmatree/coordinator/blob/main/analysis/vio-quality-experiments.md)
  -- the experiment ledger these constraints keep turning up in.
