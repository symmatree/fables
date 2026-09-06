# Rekon 10 Pro -- moved to the `coordinator` repo

The Rekon 10 design documents now live in
[**`symmatree/coordinator`, `docs/rekon10/`**](https://github.com/symmatree/coordinator/tree/main/docs/rekon10),
next to the code and flight-controller config that implement them. Edit them there.

| Topic | Now at |
|-------|--------|
| Index | [`docs/rekon10/README.md`](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/README.md) |
| System overview, mission, mapping payload | [rekon-design.md](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/rekon-design.md) |
| Canopy ops doctrine (ice-hole pattern, gap detection) | [canopy-ops.md](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/canopy-ops.md) |
| OAK-D forehead mount | [oak-d-mount.md](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/oak-d-mount.md) |
| Arm pods (Pi Zero + Camera Module 3, sync, PPS) | [arm-pods.md](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/arm-pods.md) |
| Mapping pipeline (PPK, ODM, rolling shutter) | [mapping.md](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/mapping.md) |
| Central hub, power, pod harness | [central-hub.md](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/central-hub.md) |
| Flight platform (as-built hardware, wiring) | [flight-platform.md](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/flight-platform.md) |
| Flight platform build log | [flight-platform-build-log.md](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/flight-platform-build-log.md) |
| ArduPilot configuration | [ardupilot.md](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/ardupilot.md) |
| Ground equipment (radio, goggles) | [ground-station.md](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/ground-station.md) |
| Per-flight FC-log analysis notebook | [flight-analysis.ipynb](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/flight-analysis.ipynb) |
| EdgeTX / ESC config exports | [`config/`](https://github.com/symmatree/coordinator/tree/main/docs/rekon10/config) |

## What is still here

`attachments/` stays in this repo -- vendor manuals, datasheets, and log artifacts, ~38 MB
of re-downloadable reference material that coordinator's `check-added-large-files` guard
keeps out. The moved documents link to it by absolute URL, so those citations keep working.
[`flight-analysis-loiter-around.html`](flight-analysis-loiter-around.html), a rendered
notebook output, stays for the same reason.
