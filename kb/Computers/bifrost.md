bifrost.ad.local.symmatree.com

Main DNS name is from the domain controller: the PDC for **ad.local.symmatree.com** (Active Directory) owns DNS for that domain; we formally log into `ad.local.symmatree.com` as the domain.

Available through Windows Remote Desktop. Use `SYMMATREE\symmetry` from the `Private` vault.
### Network Speed Test

* down 866 Mbps up 946 Mbps latency 8 ms
* Latency 8 msJitter 0 ms
## Network Information

*Network data collected via UniFi MCP API on 2026-02-15. See [Client Data Collection Process](client-data-collection.md) for update instructions.*

- **IP Address**: 10.0.98.1
- **MAC Address**: 18:31:bf:2b:72:3c
- **Hostname**: bifrost (UniFi); canonical DNS **bifrost.ad.local.symmatree.com** from domain controller
- **Connection Type**: Wired
- **Connected To**: [[attic-us-24-250w]]
- **Gateway**: [[morpheus.local.symmatree.com]]
- **Network Assignment**: 10.0.0.1_default
- **Uptime**: 64446 seconds
- **First Seen**: 2023-04-19 (1681880892)
- **Last Seen**: 2026-02-15 (1771174298)
- **Statistics**: Unavailable (all values are zero)

## Setup and Uses
Desktop in study (but rarely used due to needing to be near the dog). Best monitor and keyboard, wired ethernet.
* Sometimes Windows gaming, direct or remoted
* Sometimes dev. Most recently, after losing a WSL setup, almost all to notebook.local.symmatree.com which was hosted on [[Tales (cluster)]] via the JupyterNotebook setup, and I haven't restored that.
* Only place that's really good for CAD and similar loads, if they need more oomph than a docked laptop, and don't remote very well.
* 64G is second-most RAM to [[Lancer]], twice as much as [[Rising]]; CPU is weakest of the three, but GPU is between Rising and Lancer. So bifrost can run larger tasks like map reconstructions with [[OpenDroneMap]]. No current best-practice for exposing it as a node. (Mostly whether to run launcher from Windows-to-Docker or run within WSL. Either way it's a kernel inside a VM, just a choice of integrations basically.)
## Dev Setup and Paths
* [[facts]] at `C:\Users\symmetry\Documents\GitHub\facts
	* This is what Obsidian (Windows) points at, as you'd expect
* [[amateur-repo]] at `C:\Users\symmetry\dev\amateur`, no local changes
WSL has no particular commitment to:
* [[tales]]
* [[semipro-repo]]
* [[gnss-repo]]
## Benchmarks
### Geekbench 6 Windows - CPU
https://browser.geekbench.com/v6/cpu/16595965
Single-Core Score: 1749
Multi-Core Score: 7387
[[bifrost-geekbench-6]]

### Geekbench 6 Windows - GPU
https://browser.geekbench.com/v6/compute/5811251
OpenCL Score 59640
[[bifrost-geekbench-6-gpu]]

## Component Summary

Bifrost is a 2018-era enthusiast desktop built on an ASUS ROG Maximus X Formula (Z370 chipset) with an Intel Core i7-8700K (Coffee Lake, 6 cores/12 threads, 3.7 GHz base / 4.7 GHz boost), 64 GB of DDR4-3200 dual-channel RAM, and an NVIDIA GeForce GTX 1070 Ti with 8 GB GDDR5. At launch the i7-8700K was Intel's top mainstream gaming CPU and the GTX 1070 Ti sat just below the flagship GTX 1080; today both are solidly entry-level by 2025-2026 standards. The Geekbench 6 single-core score of 1749 is roughly 60% of a current mid-range chip like the Ryzen 9 7940HS (2727) and about 59% of the Strix Halo in [[Lancer]] (2975). The GPU's OpenCL score of 59640 is well behind the Radeon 8060S iGPU in Lancer (96289) but still ahead of the Radeon 780M in [[Rising]] (34061). The 64 GB of RAM remains the second-largest pool in the fleet after Lancer's 128 GB.

Bifrost's remaining role is as the primary Windows desktop for tasks that benefit from a dedicated GPU and large RAM: occasional gaming, CAD, photogrammetry with [[OpenDroneMap]], and as a Windows Remote Desktop target. The GTX 1070 Ti is no longer competitive for modern AAA gaming or ray-tracing workloads, but its 8 GB VRAM and CUDA cores are still useful for GPU-accelerated compute like depth-map generation in ODM, video transcoding, and light ML inference. With wired gigabit Ethernet to the study and the best monitor/keyboard setup in the house, Bifrost remains the go-to station for interactive graphical work that exceeds what the laptops can handle, even if the CPU is now the weakest of the three primary workstations.

## System Information (Windows)
OS Name	Microsoft Windows 11 Pro
Version	10.0.26100 Build 26100
Other OS Description 	Not Available
OS Manufacturer	Microsoft Corporation
System Name	BIFROST
System Manufacturer	ASUS
System Model	System Product Name
System Type	x64-based PC
System SKU	SKU
Processor	Intel(R) Core(TM) i7-8700K CPU @ 3.70GHz, 3696 Mhz, 6 Core(s), 12 Logical Processor(s)
BIOS Version/Date	American Megatrends Inc. 2701, 7/13/2021
SMBIOS Version	3.0
Embedded Controller Version	255.255
BIOS Mode	UEFI
BaseBoard Manufacturer	ASUSTeK COMPUTER INC.
BaseBoard Product	ROG MAXIMUS X FORMULA
BaseBoard Version	Rev 1.xx
Platform Role	Desktop
Secure Boot State	On
PCR7 Configuration	Elevation Required to View
Windows Directory	C:\WINDOWS
System Directory	C:\WINDOWS\system32
Boot Device	\Device\HarddiskVolume1
Locale	United States
Hardware Abstraction Layer	Version = "10.0.26100.1"
User Name	Not Available
Time Zone	Eastern Standard Time
Installed Physical Memory (RAM)	64.0 GB
Total Physical Memory	63.9 GB
Available Physical Memory	56.0 GB
Total Virtual Memory	67.9 GB
Available Virtual Memory	58.7 GB
Page File Space	4.00 GB
Page File	C:\pagefile.sys
Kernel DMA Protection	Off
Virtualization-based security	Running
Virtualization-based security Required Security Properties	
Virtualization-based security Available Security Properties	Base Virtualization Support, Secure Boot, DMA Protection, Mode Based Execution Control
Virtualization-based security Services Configured	
Virtualization-based security Services Running	
App Control for Business policy	Enforced
App Control for Business user mode policy	Off
Automatic Device Encryption Support	Elevation Required to View
A hypervisor has been detected. Features required for Hyper-V will not be displayed.	
