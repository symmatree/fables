# Rekon 10 Pro

System overview, mission context, and design rationale: **[rekon-design.md](rekon-design.md)**

## Topic documents

| Topic | File |
|-------|------|
| System overview, mission, mapping payload | [rekon-design.md](rekon-design.md) |
| Canopy ops doctrine (ice-hole pattern, gap detection, map building, VIO risks) | [canopy-ops.md](canopy-ops.md) |
| OAK-D forehead mount | [oak-d-mount.md](oak-d-mount.md) |
| GPS mast, F9P, ground plane, SMA | [gps-mount.md](gps-mount.md) |
| Arm pods (Pi Zero + cameras; multicamera sync, PPS, chrony, upward gap-detect pair) | [arm-pods.md](arm-pods.md) |
| Mapping pipeline (PPK interpolation, ODM, rolling-shutter correction) | [mapping.md](mapping.md) |
| Central hub, power, pod harness | [central-hub.md](central-hub.md) |
| Flight platform (as-built hardware, wiring, stack recipe) | [flight-platform.md](flight-platform.md) |
| Flight platform build log (chronicle, bench notes) | [flight-platform-build-log.md](flight-platform-build-log.md) |
| ArduPilot configuration (params, serial, RC, tools) | [ardupilot.md](ardupilot.md) ; [`config/rekon10-ardupilot.param`](config/rekon10-ardupilot.param) |
| EdgeTX REKON10 model | [`config/MODELS/model01.yml`](config/MODELS/model01.yml) |
| EdgeTX FIREFLY16 model | [`config/MODELS/model02.yml`](config/MODELS/model02.yml) |
| EdgeTX Boxer radio (calibration, `currModel`, etc.) | [`config/RADIO/radio.yml`](config/RADIO/radio.yml) |
| Ground equipment (radio, goggles) | [ground-station.md](ground-station.md) |
| Telemetry, logging, u-blox bench checks | [telemetry-and-logging.md](telemetry-and-logging.md) |
| RTK integration (Holybro F9P, threads A through I, NTRIP/Tiles later) | [rtk-integration-tracker.md](rtk-integration-tracker.md) |
| Flight stack bring-up (phases + params) | Cursor plan `~/.cursor/plans/rekon_flight_stack_bring-up_b564811b.plan.md` |


**`config/`:** EdgeTX and ArduPilot exports live under [`config/`](config/) -- [`MODELS/model01.yml`](config/MODELS/model01.yml), [`MODELS/model02.yml`](config/MODELS/model02.yml), [`RADIO/radio.yml`](config/RADIO/radio.yml), [`rekon10-ardupilot.param`](config/rekon10-ardupilot.param). If IDE-wide search returns nothing for those paths, open them by path: some multi-root setups only index a single workspace root, so glob-from-default-root can miss `facts/` even though the files are in git here.
