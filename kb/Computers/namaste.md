ThinkPad X1 Yoga 3rd
i5-8350U
16.0 GB

## Network Speed Test

Signal: -60 dBm
PHY Speed: down 283 Mbps up 283 Mbps 15ms latency
Band: 5GHz
Channel: 153
WiFi Standard: WiFi 5

On retest after changing wifi presets to "max performance" in unifi:
* down  237.5 Mbps up 347.5 Mbps
* Latency 17 ms
* Jitter 1 ms


## Network Information

*Network data collected via UniFi MCP API on 2026-02-14. Data retrieved using `mcp_unifi_get_client_details` and `mcp_unifi_get_client_statistics` with site_id="default" and client_mac="40:ec:99:bc:a2:cd". See [Client Data Collection Process](client-data-collection.md) for update instructions.*

- **IP Address**: 10.0.98.3
- **MAC Address**: 40:ec:99:bc:a2:cd
- **Hostname**: namaste
- **UniFi Name**: namaste-wifi
- **Connection Type**: Wireless
- **Connected To**: [[2nd-floor-uap-ac-pro]]
- **Gateway**: [[morpheus.local.symmatree.com]]
- **Network**: 10.0.0.1_default
- **OUI**: Intel Corporate
- **Uptime**: ~6.9 hours (24,893 seconds)
- **First Seen**: 2023-04-19 16:15:01
- **Last Seen**: 2026-02-14

### Statistics

- **Total TX Bytes**: 3.9 GB (3,885,986,813 bytes)
- **Total RX Bytes**: 1.0 GB (1,066,653,367 bytes)
- **Total TX Packets**: 3,177,368
- **Total RX Packets**: 1,631,466
- **TX Rate**: 300,000 bps
- **RX Rate**: 300,000 bps
- **Signal**: -61 dBm
- **RSSI**: 35
- **Noise**: -107 dBm

## Component Summary

Namaste is a 2018 Lenovo ThinkPad X1 Yoga 3rd Gen ultrabook with an Intel Core i5-8350U (Kaby Lake Refresh, 4 cores/8 threads, 1.7 GHz base / 3.6 GHz boost, 15 W TDP) and 16 GB of soldered DDR4 RAM. When it shipped the i5-8350U was a strong business-class mobile chip, the first quad-core in the U-series line, roughly doubling multi-threaded performance over prior dual-core i5 ultrabook CPUs. By 2025-2026 standards it is the weakest machine in the fleet by a wide margin: estimated Geekbench 6 single-core around 1200-1400 and multi-core around 4000-5000, which is comparable to the Intel N150 mini PCs running the Proxmox cluster. The Intel UHD 620 integrated graphics are negligible for GPU compute. The 16 GB RAM ceiling limits heavy dev workloads.

Namaste's current role is as the daily-driver laptop, used mostly at the couch or away from the desk. It connects over Wi-Fi (802.11ac, typically ~300 Mbps to a UAP-AC-Pro) and is the primary machine for Cursor/VSCode via WSL, light dev work, Obsidian editing of this vault, and web browsing. It is not suited for heavy compilation, large container builds, photogrammetry, or any GPU-accelerated workload. Its strength is portability, the 2-in-1 Yoga form factor, vPro manageability, and the fact that heavier work can be offloaded to [[Lancer]] or [[bifrost]] via remote desktop or SSH.

## Dev Setup and Paths
Under Windows, things are checked out
#### C:\Users\symmetry\Documents\GitHub
* [[facts]]
* semipro
* [[tales]]
### WSL
Ubuntu. `symmetry` / `op://Private/Namaste WSL Login/password`
Mostly accessed via Cursor using WSL integration. Cursor can launch WSL itself, don't need to run an explicit tunnel nor launch it from the WSL side.
User has semipro dotfiles and tools installed.
Repos:
* [[Tiles-Repo]]
* semipro
* [[facts]]
* polisher

## Windows Sysinfo
OS Name	Microsoft Windows 11 Pro
Version	10.0.26100 Build 26100
Other OS Description 	Not Available
OS Manufacturer	Microsoft Corporation
System Name	NAMASTE
System Manufacturer	LENOVO
System Model	20LFS06600
System Type	x64-based PC
System SKU	LENOVO_MT_20LF_BU_Think_FM_ThinkPad X1 Yoga 3rd
Processor	Intel(R) Core(TM) i5-8350U CPU @ 1.70GHz, 1896 Mhz, 4 Core(s), 8 Logical Processor(s)
BIOS Version/Date	LENOVO N25ET63W (1.49 ), 12/20/2022
SMBIOS Version	3.0
Embedded Controller Version	1.21
BIOS Mode	UEFI
BaseBoard Manufacturer	LENOVO
BaseBoard Product	20LFS06600
BaseBoard Version	SDK0J40697 WIN
Platform Role	Mobile
Secure Boot State	On
PCR7 Configuration	Elevation Required to View
Windows Directory	C:\WINDOWS
System Directory	C:\WINDOWS\system32
Boot Device	\Device\HarddiskVolume1
Locale	United States
Hardware Abstraction Layer	Version = "10.0.26100.1"
User Name	SYMMATREE\symmetry
Time Zone	Eastern Standard Time
Installed Physical Memory (RAM)	16.0 GB
Total Physical Memory	15.8 GB
Available Physical Memory	5.42 GB
Total Virtual Memory	21.3 GB
Available Virtual Memory	8.91 GB
Page File Space	5.50 GB
Page File	C:\pagefile.sys
Kernel DMA Protection	Off
Virtualization-based security	Running
Virtualization-based security Required Security Properties	
Virtualization-based security Available Security Properties	Base Virtualization Support, Secure Boot, DMA Protection, UEFI Code Readonly, SMM Security Mitigations 1.0, Mode Based Execution Control
Virtualization-based security Services Configured	Hypervisor enforced Code Integrity
Virtualization-based security Services Running	Hypervisor enforced Code Integrity
App Control for Business policy	Enforced
App Control for Business user mode policy	Off
Automatic Device Encryption Support	Elevation Required to View
A hypervisor has been detected. Features required for Hyper-V will not be displayed.	

