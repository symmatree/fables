# morpheus: network gateway, Unifi controller

Unifi Dream Machine SE
Specs: [[techspecs.ui.com-unifi-cloud-gateways-udm-se]]
Hosts the Unifi UI and interfaces with Verizon

Directly hosts
* [[ReoBondBell]] because it needs PoE and that's the only souce in the basement
* [[basement-uap-ac-pro|basement-uap-ac-pro]] because that provides connectivity during an outage (or maintenance) with the fewest devices, only morpheus needs to have mains power.

## Network Information

*Network data collected via UniFi MCP API on 2025-01-31. Data retrieved using `mcp_unifi_get_device_details` and `mcp_unifi_get_device_statistics` with site_id="default" and device_id="63360e240b970d164b255e34". See [UniFi Device Data Collection Process](unifi-device-data-collection.md) and [Client and Device Data Collection Process](client-data-collection.md) for update instructions.*

- **IP Address**: 10.0.0.1 (LAN); WAN IP omitted for privacy.
- **MAC Address**: 60:22:32:93:c3:15
- **Device ID**: 63360e240b970d164b255e34
- **Name**: morpheus.local.symmatree.com
- **Model**: UDMPROSE
- **Type**: Gateway (UDM)
- **Serial Number**: 60223293C315
- **Firmware Version**: 4.4.6.27560
- **State**: Online (state: 1)
- **Adopted**: Yes
- **Uplink Depth**: 1
- **Uptime**: ~76.7 days (6,625,714 seconds)

### Statistics

- **Total TX Bytes**: 3.4 TB (3,418,207,430,498 bytes)
- **Total RX Bytes**: 257.7 GB (257,681,538,570 bytes)
- **Total Bytes**: 3.7 TB (3,675,888,969,068 bytes)
- **CPU Usage**: N/A (not reported by device)
- **Memory Usage**: N/A (not reported by device)

## Product Info

*Product information for the UniFi Dream Machine SE (UDM SE) gateway device. Model code "UDMPROSE" retrieved from UniFi MCP API via `mcp_unifi_get_device_details` with site_id="default" and device_id="63360e240b970d164b255e34".*

| Field | Value |
|-------|-------|
| **Display Name** | UniFi® Dream Machine Pro SE |
| **Full Name** | Dream Machine Special Edition |
| **Abbreviation** | UDM SE |
| **SKU** | UDM-SE |
| **Type** | Gateway (UDM) |
| **Features** | PoE |
| **Device Capabilities** | GATEWAY, SWITCH, NETWORK_APPLICATION, PROTECT_APPLICATION |
| **IPS Throughput** | 3.5 Gbps |
| **PoE Budget** | 190W capacity |

**Links:**
- [UniFi Store Page](https://store.ui.com/us/en/products/udm-se)
- [Tech Specs](https://techspecs.ui.com/unifi/cloud-gateways/udm-se)

*Product information sourced from [UniFi Device Models JSON](https://gist.github.com/sgrodzicki/265273ff0ede952d6fcd1a1eedb6aa60).*

## Technical Specifications

### Overview

- **Dimensions**: 442.4 x 43.7 x 285.6 mm (17.4 x 1.7 x 11.2")
- **Managed UniFi Devices**: 100+
- **Managed Cameras**: (24) HD (14) 2K (8) 4K
- **Managed Access Hubs**: 150
- **Simultaneous Users Connected**: 1,000+
- **Max. WAN Port Count**: 8
- **Default WAN Ports**: (1) 10G SFP+ (1) 2.5 GbE RJ45
- **IDS/IPS Throughput**: 3.5 Gbps
- **Form Factor**: Rack mount (1U)
- **Redundancy**: Shadow Mode (VRRP) Gateway Failover DC Power Backup

### Security

- **Stateful Firewall**: Yes
- **Application-Aware Layer 7 Firewall**: Yes
- **DPI & Traffic Identification**: Yes
- **Zone-Based Firewall Advanced Filtering (Regions, Domains, Apps)**: Yes
- **Content Filtering**: Yes
- **Intrusion Prevention (IPS/IDS)**: Yes
- **Ad Blocking**: Yes
- **IDS/IPS Signatures**: 55,000+ with CyberSecure
- **VLAN/Subnet-based Traffic Segmentation**: Yes

### VPN & SD-WAN

- **License-Free SD-WAN**: Yes

### Networking

- **Multi-WAN Load Balancing**: Yes
- **Shadow Mode (VRRP) High Availability**: Yes
- **LACP Port Aggregation**: Yes
- **Advanced QoS**: Yes
- **Multicast DNS (mDNS)**: Yes
- **Advanced NAT (SNAT / DNAT / Masquerade / NAT Pooling / 1-to-1 NAT)**: Yes
- **Integrated RADIUS Server**: Yes
- **RADIUS over TLS (RadSec)**: Yes
- **Additional Internet Failover with UniFi LTE Backup**: Yes
- **Internet Quality and Outage Reporting**: Yes
- **MAC Address Table Size**: 4,000
- **Policy-based WAN and VPN Routing**: Yes
- **Customizable DHCP Server**: Yes
- **IPv6 ISP Support**: Yes
- **IGMP Proxy**: Yes
- **Virtual Network Override**: Yes

### Hardware

- **NVR Storage**: (1) 3.5" NVR HDD bay Built-in 128 GB SSD for Faster Experience
- **PoE Budget**: 180W
- **Voltage Range PoE Mode**: PoE: 44-57V PoE+: 50-57V
- **Max. Power Consumption**: 50W (Excluding PoE Output)
- **Power Method**: (1) Universal AC input, 100—240V AC, 4.4A Max., 50/60 Hz (1) USP-RPS DC input, 52V DC, 3.94A
- **Power Supply**: AC/DC, internal, 240W
- **Supported Voltage Range**: 100—240V AC
- **Heat Dissipation**: 170 BTU/hr (Excluding PoE Output)
- **Processor**: Quad-core ARM® Cortex®-A57 at 1.7 GHz
- **System Memory**: 4 GB
- **On-board Storage**: 16 GB eMMC 128 GB SSD (Integrated)
- **Weight**: 5 kg (10.9 lb)
- **Enclosure Material**: Aluminium CNC, SGCC steel
- **Mount Material**: SGCC steel
- **LCM Display**: 1.3" touchscreen
- **Management**: Ethernet Bluetooth
- **Button**: (1) Factory-reset
- **ESD/EMP Protection**: Air: ± 15kV, contact: ± 8kV
- **Ambient Operating Temperature**: -10 to 40° C (14 to 104° F)
- **Ambient Operating Humidity**: 5 to 95% noncondensing
- **NDAA Compliant**: Yes
- **Certifications**: CE, FCC, IC, Anatel: 07309-22-08356, SRRC

*Technical specifications extracted from UniFi Tech Specs pages by parsing the embedded `__NEXT_DATA__` JSON from the page HTML using the `polisher/unifi/extract_tech_specs.py` script.*

---

*Data collected via UniFi MCP API. See [UniFi Device Data Collection Process](unifi-device-data-collection.md) for update instructions.*