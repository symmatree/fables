# nuc-g3p-2

Hardware: [[GMKtec Nucbox G3 Plus N150 16GB]]

Proxmox Web UI: https://nuc-g3p-2.local.symmatree.com:8006 (no valid cert)

## Network Information

*Network data collected via UniFi MCP API on 2026-02-14. Data retrieved using `mcp_unifi_get_client_details` and `mcp_unifi_get_client_statistics` with site_id="default" and client_mac="e0:51:d8:1d:09:1e". See [Client Data Collection Process](client-data-collection.md) for update instructions.*

- **IP Address**: 10.0.1.76
- **MAC Address**: e0:51:d8:1d:09:1e
- **Hostname**: nuc-g3p-2.local.symmatree.com
- **Connection Type**: Wired
- **Connected to Switch**: [[basement-us-48-g1]]
- **Gateway**: [[morpheus.local.symmatree.com]]
- **Network**: 10.0.0.1_default
- **OUI**: China Dragon Technology Limited
- **OS**: Linux (os_name: 1)
- **Uptime**: ~4.8 days (411,154 seconds)
- **First Seen**: 2024-09-25 20:39:09
- **Last Seen**: 2026-02-14
- **Statistics**: Unavailable (all values are zero)

## Proxmox Status

*Proxmox data collected via Proxmox REST API on 2026-02-14. Data retrieved using `proxmoxer.ProxmoxAPI` connecting to `nuc-g3p-1.local.symmatree.com:8006` and calling `nodes.get()`. See [Proxmox Data Collection Process](proxmox-data-collection.md) for update instructions.*

- **Status**: Online
- **Disk**: 9.1 GiB / 31.9 GiB (28.5% used)
- **Memory**: 13.7 GiB / 15.4 GiB (89.1% used)
- **CPU**: 0.28 / 4 cores
- **Uptime**: 43d 23h

## Virtual Machines

- [[tiles-test-wk]]
- [[tiles-test-cp]]
