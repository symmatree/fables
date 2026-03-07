# nuc-g3p-1

Hardware: [[GMKtec Nucbox G3 Plus N150 16GB]]

Proxmox Web UI: https://nuc-g3p-1.local.symmatree.com:8006 (no valid cert)

## Network Information

*Network data collected via UniFi MCP API on 2026-02-14. Data retrieved using `mcp_unifi_get_client_details` and `mcp_unifi_get_client_statistics` with site_id="default" and client_mac="e0:51:d8:1b:6a:5e". See [Client Data Collection Process](client-data-collection.md) for update instructions.*

- **IP Address**: 10.0.1.75
- **MAC Address**: e0:51:d8:1b:6a:5e
- **Hostname**: nuc-g3p-1.local.symmatree.com
- **Connection Type**: Wired
- **Connected to Switch**: [[basement-us-48-g1]]
- **Gateway**: [[morpheus.local.symmatree.com]]
- **Network**: 10.0.0.1_default
- **OUI**: China Dragon Technology Limited
- **OS**: Linux (os_name: 60)
- **Uptime**: ~1.8 days (155,626 seconds)
- **First Seen**: 2024-09-25 20:25:30
- **Last Seen**: 2026-02-14
- **Statistics**: Unavailable (all values are zero)

## Proxmox Status

*Proxmox data collected via Proxmox REST API on 2026-02-14. Data retrieved using `proxmoxer.ProxmoxAPI` connecting to `nuc-g3p-1.local.symmatree.com:8006` and calling `nodes.get()`. See [Proxmox Data Collection Process](proxmox-data-collection.md) for update instructions.*

- **Status**: Online
- **Disk**: 9.1 GiB / 31.9 GiB (28.6% used)
- **Memory**: 13.3 GiB / 15.4 GiB (86.5% used)
- **CPU**: 0.15 / 4 cores
- **Uptime**: 43d 23h

## Virtual Machines

- [[tiles-cp-3]]
- [[tiles-wk-3]]
