# balcony-USW-Lite-16-PoE

## Network Information

*Network data collected via UniFi MCP API on 2026-02-14. Data retrieved using `mcp_unifi_get_device_details` and `mcp_unifi_get_device_statistics` with site_id="default" and device_id="65ee4e74be8bcb28e96f2b02". See [UniFi Device Data Collection Process](unifi-device-data-collection.md) and [Client and Device Data Collection Process](client-data-collection.md) for update instructions.*

- **IP Address**: 10.0.0.15
- **MAC Address**: f4:e2:c6:5a:01:ad
- **Device ID**: 65ee4e74be8bcb28e96f2b02
- **Name**: balcony-USW-Lite-16-PoE
- **Model**: USL16LPB
- **Type**: Switch (USW)
- **Serial Number**: F4E2C65A01AD
- **Firmware Version**: 7.2.123.16565
- **State**: Online (state: 1)
- **Adopted**: Yes
- **Uplink Depth**: 3
- **Uptime**: ~123.8 days (10,697,937 seconds)

### Statistics

- **Total TX Bytes**: 0.4 GB (473,860,920 bytes)
- **Total RX Bytes**: 0.1 GB (126,460,721 bytes)
- **Total Bytes**: 0.6 GB (600,321,641 bytes)
- **CPU Usage**: N/A (not reported by device)
- **Memory Usage**: N/A (not reported by device)

## Ethernet cabling

| Port | Device / link | Notes |
|------|----------------|--------|
| 1 | spa-in-eaves AP | AP at spa/eaves |
| 2 | Amcrest bullet cam | Spa-eaves camera |
| 3 | ESP32 PoE unit | Temporary; temp/humidity test |
| 16 | Uplink to basement | Main uplink |

*Recorded 2026-03-15.*

### Maintenance / cabling

- **2026-03-15:** Re-punched only the **spa-in-eaves AP** end (port 1 link) at the balcony end--that drop had a visible insulation nick. Did not redo the uplink to basement or the spa-eaves camera (Foscam/Amcrest on port 2); camera could be repunched later if needed. The cable to this switch had been suspected of one or more broken pairs, which could have been pulling the segment down.
- Uplink (port 16) runs to basement; spa-in-eaves link serves the AP (port 1) and camera (port 2).

## Product Info

| Field | Value |
|-------|-------|
| **Display Name** | UniFi® Switch Lite 16 PoE |
| **Full Name** | Switch Lite 16 PoE |
| **Abbreviation** | USW Lite 16 PoE |
| **SKU** | USW-Lite-16-PoE |
| **Type** | Switch (USW) |
| **Features** | PoE Support |

**Links:**
- [UniFi Store Page](https://store.ui.com/us/en/products/usw-lite-16-poe)
- [Tech Specs](https://techspecs.ui.com/unifi/switching/usw-lite-16-poe)

*Product information sourced from [UniFi Device Models JSON](https://gist.github.com/sgrodzicki/265273ff0ede952d6fcd1a1eedb6aa60).*

## Technical Specifications

### Overview

- **Dimensions**: 192 x 185 x 44 mm (7.6 x 7.3 x 1.7")
- **Max. PoE Output**: Up to PoE+
- **Total PoE Availability**: 45W
- **Form Factor**: Compact desktop, wall

### Performance

- **Switching Capacity**: 32 Gbps
- **Total Non-Blocking Throughput**: 16 Gbps
- **Forwarding Rate**: 24 Mpps
- **Supported VLANs**: 1,000
- **MAC Address Table Size**: 8,000
- **Packet Buffer Size**: 0.5 MB

### Hardware

- **Max. Power Consumption**: 15W (Excluding PoE Output) 60W (Including PoE Output)
- **Power Method**: Universal input, 100—240V AC, 50/60 Hz
- **Power Input Method**: AC input
- **Power Supply**: AC/DC, internal, 60W
- **Supported Voltage Range**: 100—240V AC
- **Management**: Ethernet
- **Heat Dissipation**: 51.2 (Excluding PoE Output)
- **Weight**: 1.2 kg (2.6 lb)
- **Enclosure Material**: Polycarbonate
- **Mount Material**: Polycarbonate
- **Supported Rack Depth**: 400~1200 mm (15.7-47.2")
- **Ambient Operating Temperature**: -15 to 40° C (5 to 104° F)
- **Ambient Operating Humidity**: 10 to 90% noncondensing
- **NDAA Compliant**: Yes
- **Certifications**: CE, FCC, IC, Anatel: 04479-21-08356

*Technical specifications extracted from UniFi Tech Specs pages by parsing the embedded `__NEXT_DATA__` JSON from the page HTML.*

---

*Data collected via UniFi MCP API. See [UniFi Device Data Collection Process](unifi-device-data-collection.md) for update instructions.*
