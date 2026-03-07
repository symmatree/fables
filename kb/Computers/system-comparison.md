# System Fleet Summary and Comparison

Quick-reference sheet for all compute, RAM, storage, GPU, and network resources across the fleet. Designed to be handed to an agent when proposing workflows across the available systems.

*Last updated: February 2026*

## Fleet at a Glance

| System | Role | CPU | Cores/Threads | RAM | GPU | Storage | Network | Geekbench 6 SC | Geekbench 6 MC | Geekbench 6 GPU (OpenCL) |
|--------|------|-----|---------------|-----|-----|---------|---------|----------------|----------------|--------------------------|
| [[Lancer]] | Workstation (Win+WSL) | AMD Ryzen AI Max+ 395 (Strix Halo) | 16C/32T | 128 GB LPDDR5x | Radeon 8060S (40 CU, RDNA 3.5) | 1 TB NVMe | 1 GbE wired | **2975** | **16767** | **96289** |
| [[Rising]] | Tiles cluster worker (Talos) | AMD Ryzen 9 7940HS | 8C/16T | 32 GB DDR5-5600 | Radeon 780M (12 CU, RDNA 3) | 1 TB NVMe | 1 GbE wired | **2727** | **13169** | **34061** |
| [[bifrost]] | Desktop workstation (Windows) | Intel Core i7-8700K (Coffee Lake) | 6C/12T | 64 GB DDR4-3200 | NVIDIA GTX 1070 Ti (8 GB) | — | 1 GbE wired | **1749** | **7387** | **59640** |
| [[namaste]] | Laptop daily driver (Win+WSL) | Intel Core i5-8350U (Kaby Lake-R) | 4C/8T | 16 GB DDR4-2400 | Intel UHD 620 | — | Wi-Fi 5 (802.11ac) | ~1300 est. | ~4500 est. | — |
| [[Raconteur]] | NAS / Domain Controller | Intel Xeon D-1527 | 4C/8T | 32 GB DDR4 ECC | — | 45.5 TB (2 pools) + SSD cache | 10 GbE SFP+ | — | — | — |
| nuc-g3p-1 / nuc-g3p-2 | Proxmox hosts (Tiles VMs) | Intel N150 (Twin Lake) | 4C/4T | 16 GB | Intel UHD 730 | 512 GB NVMe | 2.5 GbE wired | ~1257 | ~3007 | — |
| nuc-g2p-1 / nuc-g2p-2 | Proxmox hosts (Tiles VMs) | Intel N150 (Twin Lake) | 4C/4T | 12 GB | Intel UHD 730 | 512 GB NVMe | 1 GbE wired | ~1257 | ~3007 | — |
| [[AceBase N95 8GB\|AceBase]] | Spare / attic node | Intel N95 (Alder Lake-N) | 4C/4T | 8 GB DDR4-2667 | Intel UHD (24 EU) | 256 GB SATA SSD | 1 GbE wired | ~1100 | ~2800 | — |

## Geekbench 6 Results Comparison

### CPU Benchmarks

| System | Single-Core | Multi-Core | Source |
|--------|-------------|------------|--------|
| Lancer (Strix Halo) | 2975 | 16767 | [[GMKtec NucBox_EVO-X2 - Geekbench.pdf]] / [online](https://browser.geekbench.com/v6/cpu/16215925) |
| Rising (7940HS) | 2727 | 13169 | [[GMKtec NucBox K4 - Geekbench.pdf]] / [online](https://browser.geekbench.com/v6/cpu/16586744) |
| Bifrost (i7-8700K) | 1749 | 7387 | [[bifrost-geekbench-6]] / [online](https://browser.geekbench.com/v6/cpu/16595965) |
| N150 nodes (avg) | ~1257 | ~3007 | Geekbench browser averages |
| AceBase (N95) | ~1100 | ~2800 | Estimated from CPU-Z comparisons |
| Namaste (i5-8350U) | ~1300 | ~4500 | Estimated from Geekbench browser averages |

### GPU Benchmarks (OpenCL)

| System | OpenCL Score | GPU | Source |
|--------|-------------|-----|--------|
| Lancer | 96289 | Radeon 8060S (40 CU iGPU) | [[GMKtec NucBox_EVO-X2 - GPU - Geekbench.pdf]] / [online](https://browser.geekbench.com/v6/compute/5640785) |
| Bifrost | 59640 | GTX 1070 Ti (8 GB discrete) | [[bifrost-geekbench-6-gpu]] / [online](https://browser.geekbench.com/v6/compute/5811251) |
| Rising | 34061 | Radeon 780M (12 CU iGPU) | [[GMKtec NucBox K4 - GPU - Geekbench.pdf]] / [online](https://browser.geekbench.com/v6/compute/5806289) |

Lancer's integrated Radeon 8060S outperforms Bifrost's discrete GTX 1070 Ti by 61% in OpenCL and is competitive with an NVIDIA RTX 4060 laptop GPU. Rising's Radeon 780M is roughly on par with a GTX 1650. The remaining systems have no meaningful GPU compute capability.

## Compute Tiers

### Tier 1 — Heavy Workloads
**Lancer** and **Rising** are the modern AMD-powered machines.

- **Lancer** is the clear performance leader. Use it for: large photogrammetry jobs ([[OpenDroneMap]] with large image sets), ML model inference, heavy compilation, anything needing >32 GB RAM, or GPU-accelerated compute (ROCm). Its 128 GB unified memory is unique in the fleet.
- **Rising** is the second-strongest CPU. Currently dedicated to Talos/Kubernetes as the most capable Tiles worker. Could also serve heavy batch workloads if freed from cluster duty. 32 GB DDR5 is adequate for most single-job scenarios.

### Tier 2 — Legacy Workstation
**Bifrost** has the only discrete NVIDIA GPU (GTX 1070 Ti, 8 GB VRAM), which makes it the only system with mature CUDA support. Still useful for: CUDA-dependent tools, moderate gaming, CAD, and as a Windows Remote Desktop target. The 64 GB of RAM lets it handle large datasets. CPU is now the weakest of the three workstations.

### Tier 3 — Mobile / Light Duty
**Namaste** is the daily-driver laptop. Use for: Obsidian vault editing, light coding via Cursor/WSL, web browsing, email, meetings. Offload any heavy work to Lancer or Bifrost via remote desktop or SSH.

### Tier 4 — Infrastructure Nodes
The **Proxmox cluster** (4x Intel N150 mini PCs) provides lightweight Kubernetes hosting for the Tiles cluster. Per-node compute is roughly equivalent to the Xeon in Raconteur. Not suitable for heavy workloads but excellent for always-on services, monitoring, and control-plane duties at very low power (~15 W each).

**AceBase** (Intel N95, 8 GB) is the weakest and oldest node. Currently in the attic as a spare.

### Storage Tier
**Raconteur** (Synology RS1619xs+) is the centralized NAS with 45.5 TB across two storage pools, SSD read/write caches, 10 GbE SFP+ uplink, and 32 GB ECC RAM. It also runs Active Directory domain services, Surveillance Station, backups, and Cloud Sync. Its Xeon D-1527 (4C/8T, 2.2 GHz) is comparable in CPU throughput to a single N150 node. Primary role is storage serving, backup, and directory services — not general compute.

## Network Topology

All wired systems connect through the [[basement-us-48-g1|basement US-48]] switch to the [[morpheus.local.symmatree.com|Morpheus]] UniFi Dream Machine SE gateway (IDS/IPS throughput: 3.5 Gbps).

| System | Connection | Speed | Switch |
|--------|-----------|-------|--------|
| Lancer | Wired | 1 GbE | basement-us-48-g1 |
| Rising | Wired | 1 GbE | basement-us-48-g1 |
| Bifrost | Wired | 1 GbE | attic-us-24-250w |
| Namaste | Wi-Fi 5 | ~300 Mbps | 2nd-floor-uap-ac-pro |
| Raconteur | Wired SFP+ | 10 GbE | basement-usw-aggregation |
| nuc-g3p-1/2 | Wired | 2.5 GbE | basement-us-48-g1 |
| nuc-g2p-1/2 | Wired | 1 GbE | basement-us-48-g1 |

Raconteur has the fastest network link (10 GbE via SFP+). The G3 Plus Proxmox nodes have 2.5 GbE NICs but are connected through a 1 GbE switch, so effective throughput is capped at 1 Gbps unless the aggregation switch path is used. All other wired systems are 1 GbE. Namaste is the only wireless-only system.

## RAM Summary

| System | RAM | Type | Notes |
|--------|-----|------|-------|
| Lancer | 128 GB | LPDDR5x | Split 64/64 CPU/GPU (configurable in BIOS up to 96G GPU) |
| Bifrost | 64 GB | DDR4-3200 | Dual channel |
| Rising | 32 GB | DDR5-5600 | Dual SO-DIMM, max 64 GB |
| Raconteur | 32 GB | DDR4 ECC | Expandable to 64 GB |
| Namaste | 16 GB | DDR4-2400 | Soldered, not upgradable |
| nuc-g3p-1/2 | 16 GB each | DDR4/DDR5 | N150 max 16 GB |
| nuc-g2p-1/2 | 12 GB each | DDR4/DDR5 | N150 max 16 GB |
| AceBase | 8 GB | DDR4-2667 | Single slot |

**Fleet total**: ~340 GB of RAM across all systems.

## Workload Routing Guide

When proposing a workflow across these systems, use this decision matrix:

| Workload | Best Target | Reason |
|----------|-------------|--------|
| Large photogrammetry (ODM, 500+ images) | Lancer | 128 GB RAM, strongest CPU+GPU |
| Moderate photogrammetry (ODM, <200 images) | Bifrost or Lancer | 64 GB RAM sufficient, GPU helps |
| CUDA-specific tools | Bifrost | Only NVIDIA GPU (GTX 1070 Ti) |
| ML inference (ONNX, PyTorch) | Lancer | Strix Halo iGPU + 128 GB unified memory |
| Heavy compilation / builds | Lancer | Fastest single-core, most threads |
| Kubernetes services (always-on) | Tiles cluster (N150 nodes + Rising) | Low power, dedicated infrastructure |
| Video transcoding | Lancer or Rising | AMD hardware encode/decode (VCN) |
| NAS / file serving / backups | Raconteur | 45.5 TB storage, 10 GbE, ECC RAM |
| Daily coding / Obsidian editing | Namaste | Portable, Cursor+WSL |
| Windows gaming | Bifrost | Discrete GPU + best monitor/keyboard |
| CAD / 3D modeling (interactive) | Bifrost | Dedicated GPU + large RAM |
| Batch jobs needing >32 GB RAM | Lancer (128 GB) or Bifrost (64 GB) | Only systems with >32 GB |

## Generation and Era Context

| System | CPU Launch | Architecture | Process Node | Era Peers |
|--------|-----------|-------------|--------------|-----------|
| Lancer | 2025 | Zen 5 + RDNA 3.5 | 4 nm / 3 nm | Competes with Intel Core Ultra 200H, Apple M4 Pro |
| Rising | 2023 | Zen 4 + RDNA 3 | 4 nm | Competes with Intel 13th/14th Gen H-series, Apple M2 Pro |
| Bifrost | 2017 | Coffee Lake (desktop) | 14 nm | Competed with AMD Ryzen 7 1700X; GPU competed with RX Vega 56 |
| Namaste | 2017 | Kaby Lake Refresh (mobile) | 14 nm | Competed with AMD Ryzen 5 2500U |
| Raconteur | 2015 | Broadwell-DE (server) | 14 nm | Server-class; contemporaries include Xeon E3-1230 v5 |
| N150 nodes | 2024 | Twin Lake / Alder Lake-N | Intel 7 (10 nm) | Budget tier; competes with ARM Cortex-A78 SBCs |
| AceBase | 2022 | Alder Lake-N | Intel 7 (10 nm) | Budget tier; roughly equivalent to N150 |
