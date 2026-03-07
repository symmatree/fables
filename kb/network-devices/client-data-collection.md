# UniFi Client and Device Data Collection Process

**When following this process:** **Always use the real current date** whenever the procedure calls for a date (e.g. collection-date footnote, "Last updated", Last Seen for active clients). Determine today's date from the system or another authoritative source—do not assume the date from user context, session metadata, or training data, which may be stale or wrong. If you cannot determine the current date, ask the user. If you encounter a value that seems unlikely or impossible, ask the user rather than changing it. Do not "fix" or correct source/API values because they look wrong—record them as given. Unambiguous display formatting (e.g. turning a Unix timestamp into a readable date string) is fine.

## Overview

This document describes the process for collecting and maintaining client (end-user device) and UniFi device (UniFi equipment: access points, switches, gateways) information from the UniFi network controller using the UniFi MCP (Model Context Protocol) server.

**Important Terminology**: In this document and in the UniFi API context, "device" refers specifically to **UniFi devices** (access points, switches, and gateways), not generic network devices. Generic network devices are referred to as "clients" in the UniFi API.

## Data Collection Method

### Client Data Collection

Client (end-user device) data is collected via the UniFi MCP server using the following steps:

1. **List active clients**: Call `mcp_unifi_list_active_clients` with:
   - `site_id`: The site identifier (e.g., "default" or a specific site ID)
   - Returns a list of all currently active clients on the network

2. **Get client details**: For each client, call `mcp_unifi_get_client_details` with:
   - `site_id`: The site identifier
   - `client_mac`: The MAC address of the client (from the list_active_clients response)
   - Returns detailed information about the client including IP, hostname, name, connection type, etc.

3. **Get client statistics**: For each client, call `mcp_unifi_get_client_statistics` with:
   - `site_id`: The site identifier
   - `client_mac`: The MAC address of the client
   - Returns bandwidth and connection statistics including TX/RX bytes, packets, rates, signal strength, etc.

### Device Data Collection

UniFi network device (access points, switches, gateways) data is collected via the UniFi MCP server using the following steps:

1. **List devices by type**: Call `mcp_unifi_list_devices_by_type` with:
   - `site_id`: The site identifier (e.g., "default" or a specific site ID)
   - `device_type`: One of "uap" (access points), "usw" (switches), "ugw" (gateways), or "udm" (gateway/controller e.g. UniFi Dream Machine)
   - Returns a list of all devices of that type on the network

2. **Get device details**: For each device, call `mcp_unifi_get_device_details` with:
   - `site_id`: The site identifier
   - `device_id`: The device ID (from the list_devices_by_type response)
   - Returns detailed information about the device including IP, MAC, name, model, version, uptime, etc.

3. **Get device statistics**: For each device, call `mcp_unifi_get_device_statistics` with:
   - `site_id`: The site identifier
   - `device_id`: The device ID
   - Returns bandwidth and performance statistics including TX/RX bytes, uptime, CPU, memory, etc.

**Note on Client API Calls for UniFi Devices**: While `mcp_unifi_get_client_details` can be called with a UniFi device MAC address, it returns only minimal information (MAC, name, OUI) with most fields null (no IP, hostname, uptime, network assignment, etc.). The `mcp_unifi_get_client_statistics` call fails entirely for UniFi device MAC addresses with "client not found" error. Therefore, UniFi devices must be queried using the device-specific API calls (`get_device_details` and `get_device_statistics`) with `device_id`, not `client_mac`.

## Data Mapping

### Client Data Mapping

When building the full table (locally) or updating enriched documents, each client uses the following fields from the API responses:

### From `list_active_clients`:
- **MAC Address**: `mac` field (primary identifier)
- **IP Address**: `ip` field
- **Hostname**: `hostname` field
- **Name**: `name` field (user-assigned name in UniFi)
- **Connection Type**: `is_wired` (true/false)
- **Guest Network**: `is_guest` (true/false)
- **OUI**: `oui` field (manufacturer from MAC address)
- **OS Name**: `os_name` field (operating system identifier)
- **Connected To**: `ap_mac` (access point) or `sw_mac` (switch) or `gw_mac` (gateway)
- **Uptime**: `uptime` field (in seconds)
- **Last Seen**: `last_seen` field (Unix timestamp)
- **First Seen**: `first_seen` field (Unix timestamp)

### From `get_client_details`:
- Additional details that may not be in the list response
- Network assignment information

### From `get_client_statistics`:
- **TX Bytes**: `tx_bytes` - Total bytes transmitted
- **RX Bytes**: `rx_bytes` - Total bytes received
- **TX Packets**: `tx_packets` - Total packets transmitted
- **RX Packets**: `rx_packets` - Total packets received
- **TX Rate**: `tx_rate` - Current transmit rate (for wireless clients)
- **RX Rate**: `rx_rate` - Current receive rate (for wireless clients)
- **Signal**: `signal` - Signal strength in dBm (for wireless clients)
- **RSSI**: `rssi` - Received Signal Strength Indicator (for wireless clients)
- **Noise**: `noise` - Noise floor in dBm (for wireless clients)

### UniFi Device Data Mapping

When building the full table (locally) or updating enriched documents, each UniFi device uses the following fields from the API responses:

### From `list_devices_by_type`:
- **Device ID**: `id` field (primary identifier for API calls)
- **MAC Address**: `mac` field
- **IP Address**: `ip` field
- **Name**: `name` field (user-assigned name in UniFi)
- **Model**: `model` field (device model code)
- **Type**: `type` field ("uap", "usw", "ugw", or "udm")
- **State**: `state` field (1 = online, 0 = offline)
- **Adopted**: `adopted` field (true/false)
- **Version**: `version` field (firmware version)
- **Uptime**: `uptime` field (in seconds)
- **Serial Number**: `serial` field
- **Uplink Depth**: `uplink_depth` field (network topology depth)
- **Bytes**: `bytes` field (total bytes transferred)
- **TX Bytes**: `tx_bytes` field (total bytes transmitted)
- **RX Bytes**: `rx_bytes` field (total bytes received)

### From `get_device_details`:
- Additional details that may not be in the list response
- Same fields as list response, potentially with more current values

### From `get_device_statistics`:
- **TX Bytes**: `tx_bytes` - Total bytes transmitted (current)
- **RX Bytes**: `rx_bytes` - Total bytes received (current)
- **Bytes**: `bytes` - Total bytes transferred (current)
- **Uptime**: `uptime` - Current uptime in seconds
- **CPU**: `cpu` - CPU usage percentage (if available)
- **Memory**: `mem` - Memory usage percentage (if available)
- **State**: `state` - Current device state
- **Uplink Depth**: `uplink_depth` - Current network topology depth

## Document Matching

For each client and UniFi device, the system attempts to match it to existing documentation:

**Starting Point**: The `device-by-ip.md` index lists entities that have documentation (Entity + Document link). Use it to identify which clients/devices already have documentation.

**Matching Process** (for clients/devices not yet in the index); in all cases, search
within the entire `facts` Git repo, not just the `kb/` directory.

1. **Search by hostname**: Look for files containing the client's hostname (case-insensitive). For example, "nuc-g3p-1.local.symmatree.com" would match files containing "nuc-g3p-1"
2. **Search by name**: Look for files containing the client's UniFi-assigned name (case-insensitive)
3. **Search by IP**: Look for files containing the client's IP address
4. **Search by device type**: Match based on OUI/manufacturer and device type (e.g., "Sonos", "ecobee", "roborock")

When a match is found:
- The client's/UniFi device's name is added to the `device-by-ip.md` index with a link to the existing document using the format `[[path/to/document]]`
- Enrich the existing document with client/UniFi device data from `get_client_details`/`get_device_details` and `get_client_statistics`/`get_device_statistics`
- Add footnotes indicating the data source (UniFi MCP API)

**Do not update user-written content.** Only add or update the Network Information and Statistics sections (and their footnotes) that this process owns. Do not edit, "fix," or rewrite any other content in the document (notes, links, commentary, etc.) that the user wrote. Preserve it exactly.

**UniFi Devices**: UniFi network devices (access points, switches, gateways) should also be included in the `device-by-ip.md` index when they have documents. These devices are maintained in `kb/unifi/` through the [UniFi Device Data Collection Process](unifi-device-data-collection.md).

**Note**: Connection type (Wired/Wireless) and connection details (which AP/Switch/Gateway a client is connected to) are not in the index. This information is available in the individual device/client documents when they exist, in the Network Information section.

## File Structure

### `device-by-ip.md` (published)

**What is in the repo:** An **index only**—entities that have their own kb document, with columns **Entity** and **Document** (link). No IP addresses, MACs, hostnames, or OUI are published. The full device-by-IP table (with IPs, MACs, etc.) is not written to the repo; it can be regenerated from the entities list and API when needed.

**Index structure:**
- One row per entity that has a kb document
- **Entity**: short name (e.g. morpheus, bifrost, nuc-g3p-1)
- **Document**: `[[path/to/document]]` link to the kb doc

When you add or remove documents for clients/UniFi devices, update this index so it stays in sync with which entities are documented.

**Full table (local/private):** During a collection run you may build a full table (IP, Name, Hostname, MAC, OUI) for matching and for updating enriched documents. Do not commit that full table to the repo; only the index above is published.

### Enriched Documents

When a client matches an existing document, the following information is added (footnoted):

**Network Information Section:**
- IP Address
- MAC Address
- Hostname
- Connection Type (Wired/Wireless) - for clients only
- Connected To (which AP/Switch/Gateway) - for clients only. Use the MAC address from `ap_mac`, `sw_mac`, or `gw_mac` to look up the corresponding UniFi device document (by matching MAC addresses in `kb/unifi/` files). If a matching device document exists, link to it using `[[kb/unifi/device-name]]` format. If no matching device document exists, display the MAC address as-is.
- Gateway - Use the gateway MAC address to look up the corresponding UniFi gateway device document (by matching MAC addresses in `kb/unifi/` files). If a matching device document exists, link to it using `[[kb/unifi/device-name]]` format. If no matching device document exists, display the MAC address as-is.
- Network Assignment
- Uptime
- First Seen / Last Seen timestamps - for clients only
- Device Type (UAP/USW/UGW) - for UniFi devices only
- Uplink Depth - for UniFi devices only
- Statistics availability note (if all statistics are zero, include a single line: "**Statistics**: Unavailable (all values are zero)" instead of creating a Statistics section)

**Statistics Section** (only if statistics contain non-zero values):
- Total bytes transferred (TX/RX)
- Total packets (TX/RX)
- Current connection rates (for wireless)
- Signal strength metrics (for wireless)

**Note on Statistics**: If all statistics values are zero (TX/RX bytes and packets all zero), do not create a separate Statistics section. Instead, add a single line in the Network Information section: "**Statistics**: Unavailable (all values are zero)". This avoids cluttering documents with empty statistics sections.

All data is footnoted with: `*Network data collected via UniFi MCP API on [date]. See [Client Data Collection Process](./client-data-collection.md) for update instructions.*`

## Update Process

### Updating Client and Device Information

1. **Refresh client list**: Call `mcp_unifi_list_active_clients` to get current active clients
2. **Refresh device lists**: Call `mcp_unifi_list_devices_by_type` for each device type ("uap", "usw", "ugw", "udm") to get current UniFi devices
3. **Compare with existing data**: Use the `device-by-ip.md` index and your local full table (if built) to:
   - New clients/UniFi devices with new docs: add a row to the index (Entity + Document link)
   - Removed or renamed docs: remove or update the index row
   - The index shows which clients/UniFi devices already have documentation
4. **Update statistics**: For each active client/UniFi device, call `mcp_unifi_get_client_statistics`/`mcp_unifi_get_device_statistics` to update bandwidth/connection data
5. **Update enriched documents**: For clients/UniFi devices with existing documents (identified by the `device-by-ip.md` index), update the Network Information section with latest data. If statistics are all zero, update the "Statistics: Unavailable" line; if statistics have non-zero values, update or create the Statistics section accordingly.
6. **Update timestamps**: Update "Last Seen" and "Uptime" fields
7. **Cross-check index**: Review `device-by-ip.md` and verify that every index row has a corresponding document that was updated in this run (if applicable), and that every document you updated is listed in the index. Add any missing index rows for new docs; remove rows for docs that no longer exist.

### Updating UniFi Device Information

**Note**: UniFi device information is maintained in the `kb/unifi/` directory through the [UniFi Device Data Collection Process](unifi-device-data-collection.md). The `device-by-ip.md` table includes UniFi devices for reference, but UniFi device data should be updated directly in the device documents, not through this client data collection process.

When updating `device-by-ip.md` (the index):
1. **Include UniFi devices that have docs**: Every device in `kb/unifi/` that has a document should have a row in the index (Entity + Document link)
2. **Use existing UniFi device data**: Reference the Network Information sections in UniFi device documents rather than making additional MCP calls when updating those docs
3. **Keep index in sync**: When you add or remove a device document, add or remove the corresponding index row. Do not add IP/MAC/hostname columns to the published file

## Data Source

All client and UniFi device data is sourced from the UniFi Network Controller via the UniFi MCP server API. The MCP server provides read-only access to client and UniFi device information through the UniFi Controller's API.

## Notes

### Client Notes

- Clients may appear and disappear from the network frequently
- Wireless clients may have null values for some statistics when not actively transmitting
- Wired clients typically have null values for signal strength metrics
- Some clients may not have IP addresses assigned (DHCP pending, static assignment issues, etc.)

### UniFi Device Notes

- UniFi devices are typically always present once adopted, but may go offline
- UniFi device statistics may show null values for CPU/memory if not supported by the device model
- Uplink depth indicates network topology (null for gateways, 1+ for switches/APs)
- UniFi device bytes statistics represent total traffic through the device, not device-to-controller traffic

### General Notes

- The `device-by-ip.md` file should be sorted by IP address for easy lookup
- Both clients and devices are included in the same table for unified network view
