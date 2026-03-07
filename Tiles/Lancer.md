GMKtec Evo X2
Strix Halo: Max AI 395 w/ 128G of RAM

## Component Summary

Lancer is the most powerful machine in the fleet, a GMKtec EVO X2 mini PC built around AMD's Strix Halo "Ryzen AI Max+ 395" APU: 16 Zen 5 cores / 32 threads at up to 5.1 GHz, with an integrated Radeon 8060S GPU (40 RDNA 3.5 CUs) and an XDNA 2 NPU rated at 50+ AI TOPS. It ships with 128 GB of unified LPDDR5x memory that can be split between CPU and GPU (currently 64 GB each). This is a current-generation (2025) flagship mobile chip; its Geekbench 6 scores of 2975 single-core and 16767 multi-core place it well ahead of every other system here, roughly 70% above [[bifrost]] in single-core and over 2x in multi-core. The iGPU's OpenCL score of 96289 competes with a discrete NVIDIA RTX 4060 laptop GPU and is 1.6x the GTX 1070 Ti in Bifrost. The 128 GB unified memory pool is unique in the fleet and critical for large AI models, photogrammetry datasets, and memory-hungry VMs.

Lancer currently runs Windows 11 with WSL and is physically in the basement on the rack, accessed via Remote Desktop or Chromoting. Its primary roles are as the heaviest-compute workstation for OpenDroneMap processing (where its large RAM is essential for dense point clouds), as a potential Tiles cluster worker node, and for any workload requiring significant GPU acceleration without a discrete card. The Radeon 8060S can handle video encode/decode, depth-field acceleration for ODM, and moderate ML inference via ROCm. With wired gigabit Ethernet and the highest single-thread performance in the fleet, Lancer is the natural target for offloading large batch jobs from any other machine.

Physically in the basement on top of the rack.

### Network Performance (Speed Test)
* down 833.3 Mbps, up 967.5 Mbps
* Latency 9 ms
* Jitter 2 ms
## Remote Access
### Windows Remote Desktop
Connect to lancer.local.symmatree.com
Credentials in `op://tiles-secrets/Lancer-Windows`

### Chromoting
Credentials in `op://Private/Chromoting Lancer`
## RAM Config

RAM can be split statically in BIOS or dynamically (?) in Windows, up to 96G of "VRAM", currently 64G each

## Windows
Lancer may someday have a dual life but right now it runs Windows (and WSL).

* I have a way to run an ODM OpenDroneMap worker node here for memory. Could in theory connect to remote UI in cluster but right now just ran locally.
* [[facts]] is checked out on Windows side at `C:\Users\symmetry\Documents\GitHub\facts` (this is mounted in WSL as well to reduce the number of replicas)

### WSL

Launch via Cursor, wait a while. Workspace `tiles/tiles.code-workspace` has

* tiles
* tales
* semipro
* polisher
* gnss
* dotfiles-symm
* amateur
* bond
* facts (mounted from Windows)
* WebODM (not mine just checked out to run it)

## Network Information

*Network data collected via UniFi MCP API on 2026-02-14. Data retrieved using `mcp_unifi_get_client_details` and `mcp_unifi_get_client_statistics` with site_id="default" and client_mac="84:47:09:75:89:a6". See [Client Data Collection Process](client-data-collection.md) for update instructions.*

- **IP Address**: 10.0.128.51
- **MAC Address**: 84:47:09:75:89:a6
- **Hostname**: lancer
- **UniFi Name**: lancer
- **Connection Type**: Wired
- **Connected to Switch**: [[basement-us-48-g1]]
- **Gateway**: [[morpheus.local.symmatree.com]]
- **Network**: 10.0.0.1_default
- **OUI**: Shenzhen IP3 Century Intelligent Technology CO.,Ltd
- **Uptime**: ~3.8 days (330,108 seconds)
- **First Seen**: 2025-01-23 20:15:04
- **Last Seen**: 2026-02-14
- **Statistics**: Unavailable (all values are zero)

# Benchmarks

### Geekbench 6 CPU

[Geekbench 6 CPU under windows](https://browser.geekbench.com/v6/cpu/16215925)
[[GMKtec NucBox_EVO-X2 - Geekbench.pdf]]
Single-Core Score: 2975
Multi-Core Score: 16767

### Geekbench 6 GPU

[Geekbench 6 GPU under Windows](https://browser.geekbench.com/v6/compute/5640785)
[[GMKtec NucBox_EVO-X2 - GPU - Geekbench.pdf]]
OpenCL Score: 96289
