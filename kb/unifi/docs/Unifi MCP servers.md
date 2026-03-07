Multiple implementations out there
[[Unifi-MCP-server-enuno]]
### Core Network Management

[](https://github.com/enuno/unifi-mcp-server#core-network-management)

- **Device Management**: List, monitor, restart, locate, and upgrade UniFi devices (APs, switches, gateways)
- **Network Configuration**: Create, update, and delete networks, VLANs, and subnets with DHCP configuration
- **Client Management**: Query, block, unblock, and reconnect clients with detailed analytics
- **WiFi/SSID Management**: Create and manage wireless networks with WPA2/WPA3, guest networks, and VLAN isolation
- **Port Forwarding**: Configure port forwarding rules for external access
- **DPI Statistics**: Deep Packet Inspection analytics for bandwidth usage by application and category
- **Multi-Site Support**: Work with multiple UniFi sites seamlessly
- **Real-time Monitoring**: Access device, network, client, and WiFi statistics

### Security & Firewall (v0.2.0)

[](https://github.com/enuno/unifi-mcp-server#security--firewall-v020)

- **Firewall Rules**: Create, update, and delete firewall rules with advanced traffic filtering
- **ACL Management**: Layer 3/4 access control lists with rule ordering and priority
- **Traffic Matching Lists**: IP, MAC, domain, and port-based traffic classification
- **Zone-Based Firewall**: Modern zone-based security with zone management and zone-to-zone policies
- **RADIUS Authentication**: 802.1X authentication with RADIUS server configuration
- **Guest Portal**: Customizable captive portals with hotspot billing and voucher management

### Quality of Service (v0.2.0)

[](https://github.com/enuno/unifi-mcp-server#quality-of-service-v020)

- **QoS Profiles**: Create and manage QoS profiles for traffic prioritization
- **Traffic Routes**: Time-based routing with schedules and application awareness
- **Bandwidth Management**: Upload/download limits with guaranteed minimums
- **ProAV Mode**: Professional audio/video QoS templates
- **Reference Profiles**: Built-in QoS templates for common applications

### Backup & Operations (v0.2.0)

[](https://github.com/enuno/unifi-mcp-server#backup--operations-v020)

- **Automated Backups**: Schedule backups with cron expressions
- **Backup Management**: Create, download, restore, and delete backups
- **Cloud Sync Tracking**: Monitor backup cloud synchronization status
- **Checksum Verification**: Ensure backup integrity with SHA-256 checksums
- **Multiple Backup Types**: Network configurations and full system backups

### Multi-Site Management (v0.2.0)

[](https://github.com/enuno/unifi-mcp-server#multi-site-management-v020)

- **Site Provisioning**: Create, update, and delete UniFi sites
- **Site-to-Site VPN**: Configure VPN tunnels between sites
- **Device Migration**: Move devices between sites seamlessly
- **Site Health Monitoring**: Track site health scores and metrics
- **Cross-Site Analytics**: Aggregate device and client statistics across locations
- **Configuration Export**: Export site configurations for backup/documentation

### Network Topology (v0.2.0)

[](https://github.com/enuno/unifi-mcp-server#network-topology-v020)

- **Topology Discovery**: Complete network graph with devices and clients
- **Connection Mapping**: Port-level device interconnections
- **Multi-Format Export**: JSON, GraphML (Gephi), and DOT (Graphviz) formats
- **Network Depth Analysis**: Identify network hierarchy and uplink relationships
- **Visual Coordinates**: Optional device positioning for diagrams

skirby:
* https://github.com/sirkirby/unifi-network-mcp
>  Every capability is exposed via standard MCP **tools** prefixed with `unifi_`, so any LLM or agent that speaks MCP (e.g. Claude Desktop, `mcp-cli`, LangChain, etc.) can query, analyze **and** – when explicitly authorized – modify your network. These tools must have local access to your UniFi Network Controller, by either running locally or in the cloud connected via a secure reverse proxy.
>  - Full catalog of UniFi controller operations – firewall, traffic-routes, port-forwards, QoS, VPN, WLANs, stats, devices, clients **and more**.
> - All mutating tools require `confirm=true` so nothing can change your network by accident.
> - **Workflow automation friendly** – set `UNIFI_AUTO_CONFIRM=true` to skip confirmation prompts (ideal for n8n, Make, Zapier).
> - Works over **stdio** (FastMCP). Optional SSE HTTP endpoint can be enabled via config.
 > - **Code execution mode** with tool index, async operations, and TypeScript examples.
 > - One-liner launch via the console-script **`unifi-network-mcp`**.
> - Idiomatic Python ≥ 3.13, packaged with **pyproject.toml** and ready for PyPI.