# Mapping pipeline

[Back to index](README.md)

Post-processing path from raw captures to photogrammetric products. Hardware, sync, and capture-side concerns live in the topic docs linked below.

---

## Inputs

- **Synchronized image bursts** from the arm-pod cameras (Pi Zero 2 W + Camera Module 3, rolling shutter). Capture geometry, aim angles, and overlap targets: [arm-pods.md](arm-pods.md).
- **Synchronized capture timestamps** from each Pi Zero. Timestamps are phase-locked to the shared **DS3234** epoch via SQW PPS + chrony on the camera pods; see [arm-pods.md](arm-pods.md), *Time distribution: chrony + PPS*.
- **ArduPilot high-rate pose log** (50-100 Hz) covering the capture window, for post-hoc pose interpolation. Logging on the FC: [ardupilot.md](ardupilot.md).
- **RTK positions** where available from the F9P; VIO-fused pose during GPS-degraded intervals (see [oak-d-mount.md](oak-d-mount.md)).

## Processing

- **PPK-style timestamp interpolation:** Each image's capture timestamp (RTC-synced) is interpolated against ArduPilot's pose log to assign a pose (position + attitude) at shutter time. Captures do not need to be aligned to FC log ticks; the sub-ms PPS-locked timestamps make interpolation clean. Precision math for the timing/pose tie-in lives in [arm-pods.md](arm-pods.md) (*Software sync only*, *Time distribution: chrony + PPS*).
- **OpenDroneMap (ODM):** Primary photogrammetry pipeline.
- **Rolling shutter correction:** Enabled in ODM, fed the per-camera sensor readout parameters. Motivation and per-camera analysis: [arm-pods.md](arm-pods.md) (*Vibration and camera mounting rationale*).

## Under-canopy product considerations

Under-canopy legs are bounded by the ice-hole pattern so each leg begins and ends at an RTK-Fixed position. The mapping error budget (post-hoc, forgiving) is deliberately separated from the flight-safety budget (real-time, coarse). See [canopy-ops.md](canopy-ops.md), *Two separate error budgets*, for how VIO drift interacts with post-processing endpoint constraints rather than with real-time navigation.

The post-hoc endpoint-constrained reconstruction is being prototyped as an **offline global (batch) factor-graph solve** over the recorded feature motions with GPS priors at the leg endpoints (intermediate GPS withheld) -- coordinator [#59](https://github.com/symmatree/coordinator/issues/59). Early measurement (GPS-good backyard proxy) puts stereo-only drift at tens of cm over 10-20 m legs; see [canopy-ops.md](canopy-ops.md), *Planning interval*, and coordinator [`vio-quality-experiments.md`](https://github.com/symmatree/coordinator/blob/main/analysis/vio-quality-experiments.md). This is the mechanism that turns each leg's VIO into a georeferenced trajectory for ODM.

## Design rationale (synchronized multi-camera vs single-camera baseline)

Why the Rekon's mapping architecture is multi-camera synchronized rather than a single gimballed camera making repeated passes is framed in [rekon-design.md](rekon-design.md) and grounded in the single-camera DJI Mini 3 Pro experiments in [`../../Datasets/experiments-house-model.md`](../../Datasets/experiments-house-model.md).

## TODO

- Document the exact ODM invocation / config (rolling-shutter params per camera, GCP handling, feature-matching tuning).
- Document how per-camera sensor readout parameters are measured/validated for the Camera Module 3 units in use.
- Document the inter-camera extrinsic calibration procedure and how it is consumed by ODM.
- Define what "mission deliverable" means (point cloud, mesh, orthomosaic, DEM) per use case and the corresponding ODM output selection.
