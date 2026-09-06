# rekon-rx

**Matek ELRS R24-TD** on the Rekon 10 airframe. Canonical wiring and integration: [`docs/rekon10/flight-platform.md`](https://github.com/symmatree/coordinator/blob/main/docs/rekon10/flight-platform.md) in the `coordinator` repo. ExpressLRS **3.6.3** on the receiver.

Network index: [`device-by-ip`](network-devices/device-by-ip.md) and [`things`](things.md).

## Network

- **Hostname:** `rekon-rx.local.symmatree.com`
- **IPv4:** `10.0.4.65` (DHCP reservation on house LAN; placement mid-range was intentional to avoid disturbing a fragile setup)
- **WiFi:** Connected to house WiFi for ELRS Web UI / updates (OTA).

*Documented manually; not maintained by automated client-data-collection.*
