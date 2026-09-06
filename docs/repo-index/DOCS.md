# fables -- Documentation Index

Generated 2026-07-05. Summaries reflect the content AS OF this date; verify before relying.

---

## About this repo

`fables` is the public half of a personal knowledge base (the private half lives in `facts`). It holds
technical material that is safe to publish: drone hardware and software, robotics, homelab
infrastructure patterns, photogrammetry experiments, GNSS work, and epistemics/philosophy. No
family or private-life content appears here. Prefer to edit through the `facts` parent repo rather
than directly.

---

## Structural map

| Directory | What lives here | Approx file count |
|-----------|----------------|-------------------|
| `Datasets/` | Drone imageset logs, OpenDroneMap (ODM) map run records, and the house/property mapping plan and experiment tracker | 26 |
| `Drones/` | Per-platform hardware and software docs: Rekon 10 Pro (primary research platform), DJI Mini 3 Pro, Flywoo Firefly 16, rover prototype, and coordinator virtualization study | 18 |
| `OpenMower/` | Architecture, OS stack, configuration, and field notes for the OpenMower autonomous lawn mower | 7 |
| `Tiles/` | Kubernetes homelab cluster (Talos + Proxmox): node docs, per-component software configuration, and cluster TODO | 38 |
| `kb/` | Knowledge base: network gear (UniFi), compute (Proxmox nodes, workstations), cameras, OAK-D depth camera, data-collection procedures, and the master entity index | 53 |
| `philosophy/` | Guiding principles distilled from conversation transcripts -- epistemics, knowledge management, system design | 1 |
| `u-blox/` | u-blox GNSS receiver docs: ZED-F9P, ZED-F9R, UBX messages, firmware, antenna, and inventory | 11 |

---

## Datasets

House and property photogrammetry: flight plans, per-imageset records (GPS tracks, EXIF metadata,
coverage maps), and ODM reconstruction run records with drop-image logs.

| Path | Summary | Link |
|------|---------|------|
| `Datasets/plan-house-and-property-mapping.md` | Staged mapping goals: Stage 1 house 3D model, Stage 2 surface heightfield, Stage 3 full ~10-acre property with woods | [plan-house-and-property-mapping.md](https://github.com/symmatree/fables/blob/main/Datasets/plan-house-and-property-mapping.md) |
| `Datasets/experiments-house-model.md` | Experiment tracker for ODM house model iterations -- per-run table of collection params, ODM settings, and outcome notes | [experiments-house-model.md](https://github.com/symmatree/fables/blob/main/Datasets/experiments-house-model.md) |
| `Datasets/privacy-review.md` | Privacy review covering what is and is not published from the aerial dataset | [privacy-review.md](https://github.com/symmatree/fables/blob/main/Datasets/privacy-review.md) |
| `Datasets/imagesets-bond_ave-*.md` | Per-imageset records (15 files, 2022-2026): GPS-tagged image inventory, EXIF summary, coverage map, flight notes | [Datasets/](https://github.com/symmatree/fables/blob/main/Datasets/) |
| `Datasets/odm-maps-bond_ave-*/` | Per-ODM-run records (4 subdirs): reconstruction quality metrics, dropped-image logs, map preview | [Datasets/](https://github.com/symmatree/fables/blob/main/Datasets/) |

---

## Drones

| Path | Summary | Link |
|------|---------|------|
| `Drones/rekon10/` | **Moved to `coordinator`.** Rekon 10 Pro design docs (system design, canopy ops, arm pods, mapping, ArduPilot config, flight platform, central hub, OAK-D mount, ground station) now live next to the code that implements them. Only `attachments/` (vendor manuals) stays here. | [docs/rekon10/](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/README.md) |
| `Drones/coordinator/virtualization-study.md` | Architecture analysis comparing bare-metal, Docker Compose, Proxmox/Talos, and K3s for the payload coordinator (Pi 4B running VIO + NTP + USB networking) | [virtualization-study.md](https://github.com/symmatree/fables/blob/main/Drones/coordinator/virtualization-study.md) |
| `Drones/dji-mini-pro-3/` | DJI Mini 3 Pro notes: control modes (Cine/Normal/Sport), camera settings, DroneLink capture process | [dji-mini-pro-3/](https://github.com/symmatree/fables/blob/main/Drones/dji-mini-pro-3/) |
| `Drones/flywoo-firefly16/` | Flywoo Firefly 16 FPV quad notes: build record, Gemini VTX power | [flywoo-firefly16/](https://github.com/symmatree/fables/blob/main/Drones/flywoo-firefly16/) |
| `Drones/johnny/rover-design.md` | Ground rover design notes | [rover-design.md](https://github.com/symmatree/fables/blob/main/Drones/johnny/rover-design.md) |

---

## OpenMower

| Path | Summary | Link |
|------|---------|------|
| `OpenMower/README.md` | Directory index and current state (re-imaged 2026-06-14 to latest OpenMowerOS; access details) | [README.md](https://github.com/symmatree/fables/blob/main/OpenMower/README.md) |
| `OpenMower/openmower-architecture.md` | v1 stack layers, configurable/updatable pieces, version identification, and where mixed/indeterminate state can appear | [openmower-architecture.md](https://github.com/symmatree/fables/blob/main/OpenMower/openmower-architecture.md) |
| `OpenMower/openmower-os-stack.md` | How OpenMowerOS orchestrates the stack: payload source, config locations, OS vs. application version identity | [openmower-os-stack.md](https://github.com/symmatree/fables/blob/main/OpenMower/openmower-os-stack.md) |
| `OpenMower/openmower-docs-summary.md` | Summary of official docs: configuration, testing, monitoring, debugging, v1 legacy notes and errata | [openmower-docs-summary.md](https://github.com/symmatree/fables/blob/main/OpenMower/openmower-docs-summary.md) |
| `OpenMower/v1-physical-and-logical-controls.md` | v1 power switch location, Neopixel LED meanings, charging via modified dock | [v1-physical-and-logical-controls.md](https://github.com/symmatree/fables/blob/main/OpenMower/v1-physical-and-logical-controls.md) |
| `OpenMower/onboard-data-gathering-instructions.md` | Handoff doc for SSH-based inspection: context, inspection order, commands, and behavior guidelines | [onboard-data-gathering-instructions.md](https://github.com/symmatree/fables/blob/main/OpenMower/onboard-data-gathering-instructions.md) |
| `OpenMower/report-from-onboard.md` | Findings from onboard inspection run | [report-from-onboard.md](https://github.com/symmatree/fables/blob/main/OpenMower/report-from-onboard.md) |

---

## Tiles

Homelab Kubernetes cluster running Talos Linux on Proxmox, using SFF NUC nodes (GMKtec N150/N95
machines). Successor to the Tales cluster.

| Path | Summary | Link |
|------|---------|------|
| `Tiles/Tiles (cluster).md` | Cluster overview: node membership, goals, and improvement backlog | [Tiles (cluster).md](https://github.com/symmatree/fables/blob/main/Tiles/Tiles%20(cluster).md) |
| `Tiles/Tiles (proxmox).md` | Proxmox layer overview linking to node docs and data-collection procedures | [Tiles (proxmox).md](https://github.com/symmatree/fables/blob/main/Tiles/Tiles%20(proxmox).md) |
| `Tiles/ProxMoxNodeSetup.md` | How the Proxmox nodes were built | [ProxMoxNodeSetup.md](https://github.com/symmatree/fables/blob/main/Tiles/ProxMoxNodeSetup.md) |
| `Tiles/tiles-cp-{1,2,3}.md` | Per-node docs for the three control-plane VMs | [Tiles/](https://github.com/symmatree/fables/blob/main/Tiles/) |
| `Tiles/tiles-wk-{1,2,3}.md` | Per-node docs for the three worker VMs | [Tiles/](https://github.com/symmatree/fables/blob/main/Tiles/) |
| `Tiles/tiles-test-{cp,wk}.md` | Test control-plane and worker node docs | [Tiles/](https://github.com/symmatree/fables/blob/main/Tiles/) |
| `Tiles/tiles-host-instability.md` | Notes on host-level instability incidents and root cause analysis | [tiles-host-instability.md](https://github.com/symmatree/fables/blob/main/Tiles/tiles-host-instability.md) |
| `Tiles/TODO.md` | Cluster improvement backlog | [TODO.md](https://github.com/symmatree/fables/blob/main/Tiles/TODO.md) |
| `Tiles/Lancer.md` | Lancer node (Halo Strix) -- sometimes part of the cluster | [Lancer.md](https://github.com/symmatree/fables/blob/main/Tiles/Lancer.md) |
| `Tiles/Rising.md` | Rising node (Ryzen 9) | [Rising.md](https://github.com/symmatree/fables/blob/main/Tiles/Rising.md) |
| `Tiles/Software/README.md` | Overview and update procedure for Tiles/Software component docs | [Software/README.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/README.md) |
| `Tiles/Software/argocd.md` | ArgoCD GitOps controller configuration | [argocd.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/argocd.md) |
| `Tiles/Software/cilium.md` | Cilium CNI configuration and notes | [cilium.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/cilium.md) |
| `Tiles/Software/grafana.md` | Grafana configuration and dashboard notes | [grafana.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/grafana.md) |
| `Tiles/Software/loki.md` | Loki log aggregation configuration | [loki.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/loki.md) |
| `Tiles/Software/mimir.md` | Mimir metrics backend configuration | [mimir.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/mimir.md) |
| `Tiles/Software/alloy.md` | Grafana Alloy (telemetry collector) configuration | [alloy.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/alloy.md) |
| `Tiles/Software/cert-manager.md` | cert-manager TLS certificate automation | [cert-manager.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/cert-manager.md) |
| `Tiles/Software/external-dns.md` | ExternalDNS automated DNS record management | [external-dns.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/external-dns.md) |
| `Tiles/Software/postgres-operator.md` | Postgres Operator for in-cluster databases | [postgres-operator.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/postgres-operator.md) |
| `Tiles/Software/odm.md` | OpenDroneMap deployment on the cluster | [odm.md](https://github.com/symmatree/fables/blob/main/Tiles/Software/odm.md) |
| `Tiles/Software/*.md` (mixins, others) | Additional component docs: argocd-mixin, cilium-mixin, coredns-mixin, kubernetes-mixin, node-exporter-mixin, apprise, local-path-provisioner, nfs-csi-driver, onepassword, static-certs | [Software/](https://github.com/symmatree/fables/blob/main/Tiles/Software/) |

---

## kb (Knowledge Base)

Structured notes on physical and virtual infrastructure: network gear, compute nodes, cameras, depth
camera specs, and the data-collection procedures that keep entity docs current.

| Path | Summary | Link |
|------|---------|------|
| `kb/things.md` | Master entity index: links to every maintained entity grouped by the procedure that owns it | [things.md](https://github.com/symmatree/fables/blob/main/kb/things.md) |
| `kb/data-collection.md` | Index of all data-collection procedures with source, output location, and map-preview script references | [data-collection.md](https://github.com/symmatree/fables/blob/main/kb/data-collection.md) |
| `kb/drone-configs.md` | Drone configuration reference | [drone-configs.md](https://github.com/symmatree/fables/blob/main/kb/drone-configs.md) |
| `kb/rekon-rx.md` | Rekon receiver/radio notes | [rekon-rx.md](https://github.com/symmatree/fables/blob/main/kb/rekon-rx.md) |
| `kb/oak-d/oak-d.md` | Luxonis OAK-D (original) specs: camera sensors, stereo geometry, RVC2, USB-C power; compared against OAK-D-S2/Pro | [oak-d.md](https://github.com/symmatree/fables/blob/main/kb/oak-d/oak-d.md) |
| `kb/unifi/docs/logical.md` | UniFi network logical topology | [logical.md](https://github.com/symmatree/fables/blob/main/kb/unifi/docs/logical.md) |
| `kb/unifi/docs/measurements.md` | UniFi network measurements | [measurements.md](https://github.com/symmatree/fables/blob/main/kb/unifi/docs/measurements.md) |
| `kb/unifi/docs/Unifi MCP servers.md` | UniFi MCP server integration notes | [Unifi MCP servers.md](https://github.com/symmatree/fables/blob/main/kb/unifi/docs/Unifi%20MCP%20servers.md) |
| `kb/unifi/*.md` | Per-device UniFi docs (9 devices: APs, switches, gateway) maintained by unifi-device-data-collection | [kb/unifi/](https://github.com/symmatree/fables/blob/main/kb/unifi/) |
| `kb/proxmox/*.md` | Proxmox node docs (6 nodes: nuc-g2p-1/2, nuc-g3p-1/2, plus GMKtec hardware notes) | [kb/proxmox/](https://github.com/symmatree/fables/blob/main/kb/proxmox/) |
| `kb/Computers/*.md` | Workstation/compute notes: bifrost (GeekBench results, GPU), namaste, AceBase, system comparison, latency reference | [kb/Computers/](https://github.com/symmatree/fables/blob/main/kb/Computers/) |
| `kb/cameras/*.md` | Security camera notes (5 cameras: eaves, foscam driveway/front, laundry, Samsung) | [kb/cameras/](https://github.com/symmatree/fables/blob/main/kb/cameras/) |
| `kb/network-devices/device-by-ip.md` | IP-to-device mapping for the local network | [device-by-ip.md](https://github.com/symmatree/fables/blob/main/kb/network-devices/device-by-ip.md) |
| `kb/gitattributes-recovery.md` | Notes on recovering from gitattributes/line-ending issues | [gitattributes-recovery.md](https://github.com/symmatree/fables/blob/main/kb/gitattributes-recovery.md) |
| `kb/imagesets-data-collection.md` | Procedure: how imageset docs are built from NAS paths and EXIF metadata | [imagesets-data-collection.md](https://github.com/symmatree/fables/blob/main/kb/imagesets-data-collection.md) |
| `kb/odm-maps-data-collection.md` | Procedure: how ODM map run docs are built and map previews rendered | [odm-maps-data-collection.md](https://github.com/symmatree/fables/blob/main/kb/odm-maps-data-collection.md) |
| `kb/odm-evaluation-tools.md` | Tools for evaluating ODM reconstruction quality: OpenSfM diagnostics, 3D overlays | [odm-evaluation-tools.md](https://github.com/symmatree/fables/blob/main/kb/odm-evaluation-tools.md) |

---

## philosophy

| Path | Summary | Link |
|------|---------|------|
| `philosophy/guiding-principles.md` | Eight engineering and epistemic principles distilled from annotated conversation transcripts, with evidence and limits for each: preserve vs. derive tier separation; make the easy path correct; own vs. rent; pets vs. hostage-takers; active perturbation over passive resemblance; raw observation vs. interpretation; two investigation modes; signal-vs-actor separation | [guiding-principles.md](https://github.com/symmatree/fables/blob/main/philosophy/guiding-principles.md) |

---

## u-blox

Notes on u-blox GNSS receivers used across the mapping, OpenMower, and drone platforms.

| Path | Summary | Link |
|------|---------|------|
| `u-blox/u-blox inventory.md` | Inventory of all u-blox receivers on hand (ArduSimple in OpenMower, ZED-F9P Sparkfun, ZED-F9R, SparkFun Facet) | [u-blox inventory.md](https://github.com/symmatree/fables/blob/main/u-blox/u-blox%20inventory.md) |
| `u-blox/ZED-F9P module.md` | ZED-F9P (high-precision GNSS, RTK) module notes | [ZED-F9P module.md](https://github.com/symmatree/fables/blob/main/u-blox/ZED-F9P%20module.md) |
| `u-blox/F9R/ZED-F9R module.md` | ZED-F9R (sensor fusion, dead reckoning) module notes | [ZED-F9R module.md](https://github.com/symmatree/fables/blob/main/u-blox/F9R/ZED-F9R%20module.md) |
| `u-blox/F9R/F9R on Sparkfun Breakout.md` | F9R on the SparkFun breakout board: pinout, setup, wiring notes | [F9R on Sparkfun Breakout.md](https://github.com/symmatree/fables/blob/main/u-blox/F9R/F9R%20on%20Sparkfun%20Breakout.md) |
| `u-blox/u-blox UBX messages.md` | UBX protocol message reference notes | [u-blox UBX messages.md](https://github.com/symmatree/fables/blob/main/u-blox/u-blox%20UBX%20messages.md) |
| `u-blox/Firmware.md` | Firmware update notes for u-blox receivers | [Firmware.md](https://github.com/symmatree/fables/blob/main/u-blox/Firmware.md) |
| `u-blox/ZED F9P integration manual.md` | Integration manual notes for the ZED-F9P | [ZED F9P integration manual.md](https://github.com/symmatree/fables/blob/main/u-blox/ZED%20F9P%20integration%20manual.md) |
| `u-blox/u-blox Serial WSL on Windows.md` | Getting u-blox serial access working under WSL on Windows | [u-blox Serial WSL on Windows.md](https://github.com/symmatree/fables/blob/main/u-blox/u-blox%20Serial%20WSL%20on%20Windows.md) |
| `u-blox/u-blox connections.md` | Connection wiring reference | [u-blox connections.md](https://github.com/symmatree/fables/blob/main/u-blox/u-blox%20connections.md) |
| `u-blox/ubxlib.md` | ubxlib (C library for UBX) usage notes | [ubxlib.md](https://github.com/symmatree/fables/blob/main/u-blox/ubxlib.md) |
| `u-blox/antenna/u-blox-ANN-MB-00.md` | u-blox ANN-MB-00 multi-band antenna notes | [u-blox-ANN-MB-00.md](https://github.com/symmatree/fables/blob/main/u-blox/antenna/u-blox-ANN-MB-00.md) |
