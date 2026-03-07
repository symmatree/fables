GMKTec NucBox K4 [[www.gmktec.com-products-amd-ryzen-9-7940hs-mini-pc-nucbox-k4]]

## Component Summary

Rising is a GMKtec NucBox K4 mini PC powered by an AMD Ryzen 9 7940HS (Zen 4, 8 cores/16 threads, 4.0 GHz base / 5.2 GHz boost, 35-54 W TDP) with 32 GB DDR5-5600 and a 1 TB PCIe 4.0 NVMe SSD. The integrated Radeon 780M GPU (12 RDNA 3 CUs at 2800 MHz) provides respectable graphics for a system with no discrete card. At launch in 2024 the 7940HS was a top-tier mobile chip, competitive with desktop i7 parts of the same era. Its Geekbench 6 scores of 2727 single-core and 13169 multi-core make it the second-strongest CPU in the fleet behind [[Lancer]], and substantially ahead of [[bifrost]] (1749 / 7387). The Radeon 780M's OpenCL score of 34061 is roughly on par with a GTX 1650 and about 57% of Bifrost's GTX 1070 Ti (59640), but with more modern features and better video encode/decode support.

Rising currently serves as a dedicated Tiles Kubernetes cluster node (bare-metal Talos Linux), providing serious compute density in a tiny form factor. With USB4, Wi-Fi 6, 2.5 GbE LAN, and an AMD XDNA IPU for AI inference, it is the most capable cluster worker node by far, offering roughly 3-4x the throughput of the N150-based Proxmox nodes. Its 32 GB of fast DDR5 makes it suitable for memory-intensive pods. The Radeon 780M could potentially accelerate video transcoding or OpenDroneMap depth processing via ROCm if exposed to workloads, and the BIOS UMA frame buffer is currently set to Auto to allow dynamic GPU memory scaling.
**Deployment:** Step-by-step plan (Talos USB, Terraform, machine config) and source links for automation: tiles repo `docs/rising-deployment.md`.

## Windows Benchmarks

### Geekbench 6
CPU:
https://browser.geekbench.com/v6/cpu/16586744
[[GMKtec NucBox K4 - Geekbench.pdf]]

Single-Core Score: 2727
Multi-Core Score: 13169

GPU:
https://browser.geekbench.com/v6/compute/5806289
[[GMKtec NucBox K4 - GPU - Geekbench.pdf]]
OpenCL Score: 34061

# BIOS
Press `Esc` repeatedly to get into BIOS

Per BIOS (titled "Aptio Setup - AMI")
Footer says "Version 2.22.1287 Copyright 2024 AMI"

* BIOS version GMK_K4 1.10
* EC FW Version 1.04
* AMD Ryzen 9 7940HS w/ Radeon 780M Graphics
* Processor speed 4.0 GHz
* MasonSemi SSD, 1024GB
* Total memory 32768 MB DDR5
* Memory current speed 5600 MHz
* TPM Support Enabled
* CPU: All Enabled:
 	* NX Mode
 	* SVM Mode
 	* AMD SMT (Hyper Threading)
 	* Core Performance Boost
* GFX: UMA Frame buffer size: 3G
	* Changed to Auto before Talos switchover 2026-02-16
	 	* Options are Auto, 512M, 1G, 2G, 3G, 4G, 8G
	 	* Gemini claims this is just "reservation" because some games want to see a fixed size, but that 512M would scale up on the fly as needed. This is unproven.
* UEFI Network: Was enabled w/ IPv4 only. Now disabled.

[amd's docs about UMA](https://www.amd.com/en/resources/support-articles/faqs/PA-280.html) say
> The UMA Frame Buffer Size when set to Auto (default setting) allows the system to manage the amount of shared memory for graphics. In this configuration, the size of the UMA frame buffer should scale depending on the amount of available system memory, enabling the system to perform in an optimal state. Therefore, it is recommended to leave the setting on Auto, which is ideal for most types of video processing workloads.

Which is nice but I wish it was a little more committal about what it actually does, "available system memory" isn't necessarily the right setting I would think? Anyway Gemini has a few suggestions for using this GPU for video encoding or decoding, or for NVR processing (which is probably the Strix Point system instead but still a good note), or accelerating the OpenDroneMap depth field which would be VERY nice.

* Secure boot disabled
* Secure boot mode standard

Boot config options

* Wake on LAN: Enabled
* IPU Support: enabled
 	* This is probably "an AMD Inference Processing Unit (IPU), which is contained in some (but not all) Ryzen 7000 mobile processors (HS and U series) [2]. In some publications it is called "XDNA". <https://community.frame.work/t/ryzen-ai-with-amd-ipu-on-framework-laptops/36356>
* Power mode: quiet / balanced / performance (currently Performance)
* Network stack enabled, ipv4 enabled, ipv6 disabled

## Network Information

*Network data collected via UniFi MCP API on 2026-02-14. Data retrieved using `mcp_unifi_get_client_details` and `mcp_unifi_get_client_statistics` with site_id="default" and client_mac="84:47:09:2f:a9:ef". See [Client Data Collection Process](client-data-collection.md) for update instructions.*

* **IP Address**: 10.0.128.52
* **MAC Address**: 84:47:09:2f:a9:ef
* **Hostname**: rising
* **UniFi Name**: rising
* **Connection Type**: Wired
* **Connected to Switch**: [[basement-us-48-g1]]
* **Gateway**: [[morpheus.local.symmatree.com]]
* **Network**: 10.0.0.1_default
* **OUI**: Shenzhen IP3 Century Intelligent Technology CO.,Ltd
* **Uptime**: ~4.8 days (411,363 seconds)
* **First Seen**: 2025-01-21 20:15:36
* **Last Seen**: 2026-02-14
* **Statistics**: Unavailable (all values are zero)
