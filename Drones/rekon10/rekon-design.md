# Rekon 10 Pro -- System design

[Back to index](README.md)

System-level framing only: mission goals, operational requirements, and the architectural response. Subsystem detail (wiring, params, geometry, specs, thresholds, pipelines, build-log notes) lives in the topic docs listed in the [README](README.md). This doc does not repeat those details and is not authoritative about any single subsystem.

---

## Mission context

The Rekon 10 Pro is a forestry/property mapping platform producing dense 3D point clouds, heightfields, and textured meshes of complex vertical structures -- tree trunks, house walls, terrain relief under canopy. "High quality DEMs" in this context means robust multi-angle 3D reconstruction where multi-camera coverage from many directions matters more than single-frame geometric perfection from a nadir camera. This is not competing with the DJI M3E for flat-earth orthomosaic surveys; it is capturing geometry that a single top-down camera physically cannot see.

The primary operational challenge is flying under tree canopy where RTK GPS signal degrades or drops entirely. When the RTK GPS loses "Fixed" status, ArduPilot falls back on visual/inertial odometry to maintain dead-reckoning and position hold.

**Photogrammetry baseline:** Single-camera DJI Mini 3 Pro mapping experiments are documented in the [experiments-house-model](../../Datasets/experiments-house-model.md) log. They identify autofocus, nearfield parallax, and turnaround gimbal instability as the dominant problems -- not rolling shutter. The Rekon's architecture is a response to those single-camera limitations.

## Navigation architecture (roles)

- **GNSS + compass:** Single **Holybro F9P Rover Lite** (ZED-F9P + integrated compass) on the mast; RTCM from a ground base station.
- **VIO role:** **OAK-D** stereo+IMU module paired with the **Raspberry Pi 4B** Coordinator computing position estimates for GPS-degraded and under-canopy flight. Detail: [oak-d-mount.md](oak-d-mount.md), [central-hub.md](central-hub.md).
- **Payload time base:** Shared [**DS3234**](https://www.sparkfun.com/sparkfun-deadon-rtc-breakout-ds3234.html) **SQW** (1 Hz) for multicamera PPS distribution -- local time agreement, disciplined from GNSS when available ([central-hub.md](central-hub.md), [arm-pods.md](arm-pods.md)).

## Mapping payload architecture

The mapping payload is a **synchronized multi-camera array** organized as two complementary rings, with a staged build:

- **Horizontal ring (current build):** Downward-looking ring providing nadir-to-mid-elevation coverage from many azimuths at once, so vertical structures are seen from multiple angles in a single pass.
- **Vertical ring (future build):** 360-degree side-scan perpendicular to travel, extending coverage from mid-elevation up through horizontal and above.
- **Current build also pulls forward** a near-zenith pair from the vertical ring for **canopy gap detection** during under-canopy missions.

All camera geometry (aim angles, pod assignment, FOV overlap, vibration analysis, DS3234 PPS wiring) lives in [arm-pods.md](arm-pods.md). Hub/power/Coordinator detail lives in [central-hub.md](central-hub.md). Post-processing pipeline lives in [mapping.md](mapping.md).

### Key rationale: synchronized capture

The fundamental design bet is that **bursts of simultaneous images across many cameras** produce better photogrammetric feature matching than repeated passes with a single camera, because transient scene features (moving twigs and leaves, shifting shadows) are identical across a synchronized burst but differ minutes apart across passes. This is the principal response to the single-camera limitations documented in the [DJI experiments](../../Datasets/experiments-house-model.md). Timing mechanisms and measured / assumed precision live in [arm-pods.md](arm-pods.md); the corresponding post-processing path lives in [mapping.md](mapping.md).

## Operational requirements

- **AUW:** approximately 2 kg.
- **Survey speed target:** 3-5 m/s for overhead mapping transects; slower under canopy.
- **Under-canopy doctrine:** periodic GPS re-acquisition via canopy gaps ("ice-hole" pattern), bounded VIO dead-reckoning between fixes. Full doctrine, error budgets, and fallbacks in [canopy-ops.md](canopy-ops.md).
