# attic-US-24-250W

## Network Information

*Network data collected via UniFi MCP API on 2026-02-14. Data retrieved using `mcp_unifi_get_device_details` and `mcp_unifi_get_device_statistics` with site_id="default" and device_id="643f78bc07fdb50cec11ad45". See [UniFi Device Data Collection Process](unifi-device-data-collection.md) and [Client and Device Data Collection Process](client-data-collection.md) for update instructions.*

- **IP Address**: 10.0.0.10
- **MAC Address**: f4:92:bf:8d:35:a2
- **Device ID**: 643f78bc07fdb50cec11ad45
- **Name**: attic-US-24-250W
- **Model**: US24P250
- **Type**: Switch (USW)
- **Serial Number**: F492BF8D35A2
- **Firmware Version**: 7.2.123.16565
- **State**: Online (state: 1)
- **Adopted**: Yes
- **Uplink Depth**: 3
- **Uptime**: ~120.8 days (10,438,705 seconds)

### Statistics

- **Total TX Bytes**: 24.2 GB (26,004,738,256 bytes)
- **Total RX Bytes**: 1.3 GB (1,377,658,332 bytes)
- **Total Bytes**: 25.5 GB (27,382,396,588 bytes)
- **CPU Usage**: N/A (not reported by device)
- **Memory Usage**: N/A (not reported by device)

## Ethernet cabling

*Recorded 2026-03-15. Confirmed broken signal lines in the attic.*

All 24 switch ports are PoE+ (see Product Info), so any port can power cameras, APs, or other PoE devices.

**Punchdown column:** Tripp = Triplitte mini (block ports 1-12). Mono = Monoprice 24 (block ports 13-15). Blank = no punchdown (direct run or jack only).

| Switch port | Punchdown | Notes |
|-------------|-----------|--------|
| 1 | Mono 15 | laundry camera. New punchdown looks okay. |
| 2 | - | long brown wire, jack only (no punchdown), into attic floor. |
| 3 | Tripp 3 | study front low blue. Blue maybe not broken. |
| 4 | Tripp 4 | study front low green. Green broken. |
| 5 | Tripp 5 | study front high blue. Looks okay visually. |
| 6 | - | (not in use) |
| 7 | Tripp 11 | garage camera (eaves).  insulation nicks. |
| 8 | Tripp 8 | study rear blue. Looks okay. |
| 9 | Tripp 9 | study rear green. Actively broken. |
| 10 | Tripp 6 | study front high green. Looks okay visually. |
| 11 | Tripp 12 | lower attic access point.  nicks. |
| 12 | Tripp 10 | front door camera (eaves).  nicks. |
| 13 | Mono 14 | basement blue. New punchdown looks okay (repunched). |
| 14-16 | - | (not in use) |
| 17 | - | ace base. |
| 18-24 | - | (not in use) |

## Product Info

| Field | Value |
|-------|-------|
| **Display Name** | UniFi® Switch 24 250W |
| **Full Name** | Switch 24 PoE (250 W) |
| **Abbreviation** | US 24 PoE 250W |
| **SKU** | US-24-250W |
| **Type** | Switch (USW) |
| **Features** | PoE Support, Always-On Fan |
| **PoE ports** | All 24 RJ45 ports (PoE+, 250W total budget). Per [UI Tech Specs](https://techspecs.ui.com/unifi/switching/us-24-250w): 24 x PoE+ (max 34W per port). |

**Links:**
- [UniFi Store Page](https://store.ui.com/us/en/products/us-24-250w)
- [Tech Specs](https://techspecs.ui.com/unifi/switching/us-24-250w)

*Product information sourced from [UniFi Device Models JSON](https://gist.github.com/sgrodzicki/265273ff0ede952d6fcd1a1eedb6aa60).*

## Technical Specifications

### Overview

- **Dimensions**: 485 x 285.4 x 43.7 mm  (19.1 x 11.2 x 1.7")
- **Max. PoE Output**: Up to PoE+
- **Total PoE Availability**: 250W
- **Redundancy**: DC Power Backup
- **Form Factor**: Rack mount (1U)

### Performance

- **Switching Capacity**: 52 Gbps
- **Total Non-Blocking Throughput**: 26 Gbps
- **Forwarding Rate**: 38.69 Mpps

### Hardware

- **Max. Power Consumption**: 30W (Excluding PoE Output)
- **Power Method**: Universal input, 100—240V AC, 50/60 Hz
- **Power Input Method**: AC input
- **Power Supply**: AC/DC, internal, 250W
- **Supported Voltage Range**: 100—240V AC
- **Management**: Ethernet
- **Weight**: 4.7 kg (10.4 lb)
- **Enclosure Material**: SGCC steel
- **Mount Material**: SGCC steel
- **Supported Rack Depth**: 400~1200 mm (15.7-47.2")
- **ESD Protection**: Air/contact: ± 24kV
- **Ambient Operating Temperature**: -5 to 40° C (23 to 104° F)
- **Ambient Operating Humidity**: 5 to 95% noncondensing
- **NDAA Compliant**: Yes
- **Certifications**: CE, FCC, IC, Anatel: 01245-15-08356

*Technical specifications extracted from UniFi Tech Specs pages by parsing the embedded `__NEXT_DATA__` JSON from the page HTML.*

---

*Data collected via UniFi MCP API. See [UniFi Device Data Collection Process](unifi-device-data-collection.md) for update instructions.*
