# Network Logical Design

## Current Physical Infrastructure

### Network Topology

```
Internet (Verizon) 
    ↓
morpheus.local.symmatree.com (UDM-SE) - 10.0.0.1
    ↓ (10G SFP+)
basement-USW-Aggregation (8x 10G SFP+)
    ↓
basement-US-48-G1 (48x 1G + 2x 10G SFP+)
    ↓
Physical hosts and devices
```

### Current IP Allocation (DHCP Reservations - In Use)

#### 10.0.0.0/24 - UniFi Infrastructure

- **morpheus.local.symmatree.com**: UniFi Dream Machine SE (10.0.0.1)
- Other UniFi hardware (switches, APs)
- Router/Controller, DNS: local.symmatree.com domain
- Current network: 10.0.0.0/16 (VLAN 0, "LAN")

#### 10.0.1.0/24 - Physical Hosts and Legacy VMs  

- **Physical Proxmox Hosts** (4 hosts):
  - nuc-g2p-1.local.symmatree.com
  - nuc-g2p-2.local.symmatree.com  
  - nuc-g3p-1.local.symmatree.com (primary endpoint: <https://nuc-g3p-1.local.symmatree.com:8006/>)
  - Fourth host (details TBD)
- **Tales cluster VMs** (legacy, to be decommissioned)
- **raconteur.ad.local.symmatree.com**: Synology RS1619xs+
  - Primary Domain Controller for SYMMATREE/ad.local.symmatree.com

#### 10.0.11.1 to 10.0.12.254 - UniFi Auto-DHCP Range

- **Reserved for UniFi automatic IP allocation**
- Spans 10.0.11.1-10.0.11.254 + 10.0.12.1-10.0.12.254 (510 addresses)
- Do not use for static assignments
- UniFi serves these for devices without reservations

#### 10.0.98.0/24 - Client Machines (Management Access)

- Windows laptop and other client devices
- Fixed IPs for findability and management
- Not serving services, just need to be reachable

#### 10.0.99.0/24 - Servers and IoT Services  

- Home Assistant, cameras, vacuum cleaners
- IoT devices that need to be connected to (not just connecting out)
- Devices with web interfaces or API endpoints

#### Tiles Cluster (Production) - 10.0.101.0/22 Block

- **VM + VIP Range**: 10.0.101.0/24
  - Control Plane VIP: 10.0.101.10 (Talos-managed, for kubectl access)  
  - Control Plane VMs: 10.0.101.21, 10.0.101.22, 10.0.101.31
  - Worker VMs: 10.0.101.41, 10.0.101.42, 10.0.101.51
- **LoadBalancer Range**: 10.0.102.0/24 (Cilium L2 announcements, "internal-external")
- **Pod CIDR**: 10.0.103.0/24 (ipv4NativeRoutingCIDR - native routing within 10.0.0.0/16)
- **Service CIDR**: 10.0.104.0/24  
- **Cluster Summary**: 10.0.101.0/22 covers everything

#### Tiles-Test Cluster - 10.0.105.0/22 Block  

- **VM + VIP Range**: 10.0.105.0/24
  - Control Plane VIP: 10.0.105.10 (Talos-managed)
  - Control Plane VMs: 10.0.105.32
  - Worker VMs: 10.0.105.52
- **LoadBalancer Range**: 10.0.106.0/24 (Cilium L2 announcements)
- **Pod CIDR**: 10.0.107.0/24 (ipv4NativeRoutingCIDR - native routing within 10.0.0.0/16)
- **Service CIDR**: 10.0.108.0/24
- **Cluster Summary**: 10.0.105.0/22 covers everything
