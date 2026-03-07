# Proxmox Data Collection Process

## Overview

This document describes the process for collecting and maintaining Proxmox node information from Proxmox VE clusters using the Proxmox REST API via the `proxmoxer` Python library.

## Data Collection Method

### Phase 1: Node Data Collection

Node data is collected via the Proxmox REST API using the following steps:

1. **Connect to Proxmox host**: Use `proxmoxer.ProxmoxAPI` to connect to a Proxmox host:
   - Host: One of the Proxmox nodes (e.g., `nuc-g3p-1.local.symmatree.com`)
   - Port: 8006 (HTTPS)
   - User: `root@pam` (or configured user)
   - Password: Retrieved from 1Password via `op://tiles-secrets/proxmox-root/password`
   - SSL verification: Disabled (self-signed certificates)
   - Timeout: 60 seconds

2. **List nodes**: Call `proxmox.nodes.get()` to retrieve all nodes in the cluster. This single call already includes all the essential fields we need:
   - `node`: Node name
   - `disk`: Used disk space in bytes
   - `maxdisk`: Total disk space in bytes
   - `mem`: Used memory in bytes
   - `maxmem`: Total memory in bytes
   - `uptime`: System uptime in seconds
   - `cpu`: Current CPU usage (0-1, or number of cores used)
   - `maxcpu`: Maximum CPU cores available
   - `status`: Node status (e.g., "online")

   **Note on additional endpoints**: 
   - The `proxmox.nodes(node_name).status.get()` endpoint is available if additional status information is needed beyond what `nodes.get()` provides.
   - The `proxmox.nodes(node_name).report.get()` endpoint is available and provides comprehensive system information, but it is relatively slow and produces voluminous output. It's useful for debugging but overkill for regular data collection.

3. **Format and output JSON**: The script formats the data and outputs a JSON array with node data to stdout. The JSON includes both raw values and pre-formatted strings for easy insertion into markdown documents:
   - Raw values: `disk`, `maxdisk`, `mem`, `maxmem`, `uptime`, `cpu`, `maxcpu`
   - Formatted strings: `disk_used_str`, `disk_total_str`, `mem_used_str`, `mem_total_str`, `uptime_str`
   - Calculated percentages: `disk_fraction`, `mem_fraction` (rounded to 1 decimal place)

### Phase 2: VM Data Collection

VM data is collected via the Proxmox REST API using the following steps:

1. **Connect to Proxmox host**: Same as Phase 1 (use `proxmoxer.ProxmoxAPI`)

2. **List nodes**: Call `proxmox.nodes.get()` to get all nodes in the cluster

3. **For each node, list VMs**: Call `proxmox.nodes(node_name).qemu.get(full=1)` to retrieve all VMs on that node. The `full=1` parameter (must be integer `1`, not boolean `True`) provides detailed VM information including:
   - `vmid`: VM ID
   - `name`: VM name
   - `status`: VM status (e.g., "running", "stopped")
   - `cpu`: Current CPU usage (decimal, 0-1 range)
   - `cpus`: Number of allocated CPU cores
   - `mem`: Used memory in bytes
   - `maxmem`: Total allocated memory in bytes
   - `uptime`: VM uptime in seconds

4. **Get IP addresses**: For each VM, attempt to retrieve IP address via agent endpoints:
   - First try: `proxmox.nodes(node_name).qemu(vmid).agent.info.get()` - look for `result.ip-addresses` array with IPv4 addresses
   - Fallback: `proxmox.nodes(node_name).qemu(vmid).agent('network-get-interfaces').get()` - parse network interfaces for IPv4 addresses
   - Note: Agent endpoints require the QEMU guest agent to be installed and running in the VM. If unavailable, IP will be marked as "N/A (agent not running or IP not found)"

5. **Format and output JSON**: The script formats the data and outputs a JSON array with VM data to stdout. The JSON includes both raw values and pre-formatted strings:
   - Raw values: `vmid`, `name`, `node`, `status`, `cpu_usage`, `cpus_allocated`, `mem_used`, `mem_max`, `uptime`
   - Formatted strings: `mem_used_str`, `mem_total_str`, `uptime_str`
   - Calculated percentages: `mem_fraction` (rounded to 1 decimal place)
   - IP address: `ip_address` (from agent endpoints or "N/A")

## Script Usage

### Node Data Collection

The node data collection script is located at `polisher/proxmox/node_data.py`.

**Environment Setup:**
- Create a `.env` file in `polisher/proxmox/` with:
  ```
  PROXMOX_USER=root@pam
  PROXMOX_PASSWORD=op://tiles-secrets/proxmox-root/password
  PROXMOX_HOST=nuc-g3p-1.local.symmatree.com
  ```

**Running the script:**
```bash
cd polisher/proxmox
op run --env-file="./.env" -- ../.venv/bin/python3 node_data.py
```

The script outputs JSON to stdout with node data for all nodes in the cluster.

### VM Data Collection

The VM data collection script is located at `polisher/proxmox/vm_data.py`.

**Environment Setup:**
- Same as node data collection (uses the same `.env` file)

**Running the script:**
```bash
cd polisher/proxmox
op run --env-file="./.env" -- ../.venv/bin/python3 vm_data.py
```

The script outputs JSON to stdout with VM data for all VMs across all nodes in the cluster.

## Data Mapping

Each node entry in the JSON output includes:
- **node**: Node name (e.g., "nuc-g3p-1")
- **host**: Proxmox host used for connection
- **disk**: Used disk space in bytes (raw)
- **maxdisk**: Total disk space in bytes (raw)
- **disk_used_str**: Formatted disk usage (e.g., "9.0 GiB")
- **disk_total_str**: Formatted total disk (e.g., "31.9 GiB")
- **disk_fraction**: Disk usage percentage (e.g., 28.1)
- **mem**: Used memory in bytes (raw)
- **maxmem**: Total memory in bytes (raw)
- **mem_used_str**: Formatted memory usage (e.g., "13.4 GiB")
- **mem_total_str**: Formatted total memory (e.g., "15.4 GiB")
- **mem_fraction**: Memory usage percentage (e.g., 87.2)
- **uptime**: System uptime in seconds (raw)
- **uptime_str**: Formatted uptime (e.g., "30d 22h")
- **cpu**: Current CPU usage (decimal, 0-1 range)
- **maxcpu**: Maximum CPU cores
- **status**: Node status (e.g., "online")

Each VM entry in the JSON output includes:
- **vmid**: VM ID (e.g., 7211)
- **name**: VM name (e.g., "tiles-cp-1")
- **node**: Node name where VM is running (e.g., "nuc-g2p-1")
- **host**: Proxmox host used for connection
- **status**: VM status (e.g., "running", "stopped")
- **cpu**: Current CPU usage (decimal, 0-1 range)
- **cpus**: Number of allocated CPU cores
- **mem**: Used memory in bytes (raw)
- **maxmem**: Total allocated memory in bytes (raw)
- **mem_used_str**: Formatted memory usage (e.g., "4.7 GiB")
- **mem_total_str**: Formatted total memory (e.g., "5.0 GiB")
- **mem_fraction**: Memory usage percentage (e.g., 93.2)
- **uptime**: VM uptime in seconds (raw)
- **uptime_str**: Formatted uptime (e.g., "1d 10h")
- **ip_address**: IP address from agent endpoints, or "N/A" if unavailable

## Document Updates

### Phase 1: Node Data Updates

For each physical node document (e.g., `kb/proxmox/nuc-g3p-1.md`, `kb/proxmox/nuc-g3p-2.md`), add or update a **Proxmox Status** section with:

**Proxmox Status Section:**
- Status (online/offline)
- Disk usage: Used / Total (with percentage)
- Memory usage: Used / Total (with percentage)
- CPU: Current / Max cores
- Uptime: Human-readable format (days and hours)

**Formatting:**
- Disk and memory values are pre-formatted in the JSON output using `humanize.naturalsize()` with `binary=True` (binary SI units: KiB, MiB, GiB, TiB)
- Percentages are pre-calculated in the JSON output (`disk_fraction`, `mem_fraction`)
- Uptime is pre-formatted in the JSON output as "Xd Yh" format (`uptime_str`)
- CPU is shown as decimal value (0-1 range) / maxcpu cores

**Example:**
```markdown
## Proxmox Status

*Proxmox data collected via Proxmox REST API on 2025-02-01. Data retrieved using `proxmoxer.ProxmoxAPI` connecting to `nuc-g3p-1.local.symmatree.com:8006` and calling `nodes.get()`.
See [[proxmox-data-collection]] for update instructions.*

- **Status**: Online
- **Disk**: 9.0 GiB / 31.9 GiB (28.1% used)
- **Memory**: 13.4 GiB / 15.4 GiB (87.2% used)
- **CPU**: 0.13 / 4 cores
- **Uptime**: 30d 22h
```

**Footnotes:**
- Include a footnote with the data source (Proxmox REST API)
- Include the collection date
- Include the specific API call used (`nodes.get()`)
- Link to this process document

### Phase 2: VM Data Updates

For each VM, create or update a document in `Tiles` (e.g., `Tiles/tiles-cp-1.md`, `Tiles/tiles-wk-2.md`) with a **Proxmox VM Status** section.

**Proxmox VM Status Section:**
- VM ID
- Status (running/stopped)
- Node (which physical node the VM is running on)
- CPU: Current usage / Allocated cores
- Memory: Used / Total (with percentage)
- Uptime: Human-readable format (days and hours)
- IP Address: From agent endpoints if available

**Formatting:**
- Memory values are pre-formatted in the JSON output using `humanize.naturalsize()` with `binary=True` (binary SI units: KiB, MiB, GiB, TiB)
- Percentages are pre-calculated in the JSON output (`mem_fraction`)
- Uptime is pre-formatted in the JSON output as "Xd Yh" format (`uptime_str`)
- CPU is shown as decimal value (0-1 range) / allocated cores

**Example:**
```markdown
## Proxmox VM Status

*Proxmox VM data collected via Proxmox REST API on 2025-02-01. Data retrieved using `proxmoxer.ProxmoxAPI` connecting to `nuc-g3p-1.local.symmatree.com:8006` and calling `nodes.get()` then `nodes(node).qemu.get(full=1)` for each node. IP address retrieved via agent endpoints when available. See [[proxmox-data-collection]] for update instructions.*

- **VM ID**: 7211
- **Status**: Running
- **Node**: nuc-g2p-1
- **CPU**: 0.35 / 1 cores
- **Memory**: 4.7 GiB / 5.0 GiB (93.2% used)
- **Uptime**: 1d 10h
- **IP Address**: 10.0.128.11
```

**Footnotes:**
- Include a footnote with the data source (Proxmox REST API)
- Include the collection date
- Include the specific API calls used (`nodes.get()`, `nodes(node).qemu.get(full=1)`, agent endpoints)
- Note that IP addresses require the QEMU guest agent to be running
- Link to this process document

## File Structure

Physical node documents are stored in `kb/proxmox/` with filenames matching the node hostname (e.g., `nuc-g3p-1.md`, `nuc-g3p-2.md`).

Physical node documents should include:
1. Hardware reference (link to hardware model document)
2. Proxmox Web UI link
3. Network Information section (from UniFi client data)
4. **Proxmox Status section** (from Proxmox API data)
5. **Virtual Machines section** (list of VMs running on this node, with links to their documents)

VM documents should include:
1. **Physical Node** link at the top (link back to the physical node document)
2. Network Information section (from UniFi client data, if available)
3. **Proxmox VM Status section** (from Proxmox API data)

**Linking Pattern:**
- Each physical node document should include a "Virtual Machines" section listing all VMs running on that node, with links to their documents
- Each VM document should include a "Physical Node" link at the top (after the title) linking back to the physical node document
- This creates bidirectional links between nodes and their VMs

## Update Process

To update node information:

1. **Run data collection script**: Execute `node_data.py` to get current node data as JSON:
   ```bash
   cd polisher/proxmox
   op run --env-file="./.env" -- ../.venv/bin/python3 node_data.py > /tmp/nodes.json
   ```

2. **Read JSON output**: The JSON contains all necessary data including pre-formatted values

3. **Match nodes to documents**: Match node names from JSON to existing documents in `kb/proxmox/` (e.g., "nuc-g3p-1" → `nuc-g3p-1.md`)

4. **Update documents manually**: For each matching document, intelligently update the "Proxmox Status" section:
   - Locate the section (after "Network Information" section)
   - Update values using the pre-formatted strings from JSON (`disk_used_str`, `disk_total_str`, `mem_used_str`, `mem_total_str`, `uptime_str`)
   - Use pre-calculated percentages (`disk_fraction`, `mem_fraction`)
   - Format CPU as `{cpu} / {maxcpu} cores` (e.g., "0.13 / 4 cores")
   - Update the collection date in the footnote
   - Do not edit or fix user-written content; preserve all other content in the document exactly

5. **New nodes**: If a node doesn't have a document, create one following the document structure

To update VM information:

1. **Run data collection script**: Execute `vm_data.py` to get current VM data as JSON:
   ```bash
   cd polisher/proxmox
   op run --env-file="./.env" -- ../.venv/bin/python3 vm_data.py > /tmp/vms.json
   ```

2. **Read JSON output**: The JSON contains all necessary data including pre-formatted values

3. **Match VMs to documents**: Match VM names from JSON to existing documents in `Tiles/` (e.g., "tiles-cp-1" → `Tiles/tiles-cp-1.md`)

4. **Update or create documents**: For each VM:
   - If document exists: Intelligently update the "Proxmox VM Status" section
   - If document doesn't exist: Create a new document with Physical Node link, Network Information (from device-by-ip.md if available), and Proxmox VM Status sections
   - Use pre-formatted strings from JSON (`mem_used_str`, `mem_total_str`, `uptime_str`)
   - Use pre-calculated percentages (`mem_fraction`)
   - Format CPU as `{cpu} / {cpus} cores` (e.g., "0.35 / 1 cores") using the `cpu` and `cpus` fields from the JSON
   - Update the collection date in the footnote
   - Ensure the "Physical Node" link at the top of the VM document points to the correct node (from `node` field in JSON)
   - Do not edit or fix user-written content; preserve all other content in existing documents exactly

5. **Update node documents**: For each physical node, update the "Virtual Machines" section:
   - List all VMs running on that node (from the JSON data, filter by `node` field)
   - Include links to each VM document using short wiki links (e.g. `[[tiles-cp-1]]`, `[[tiles-wk-2]]`); VM documents live in `Tiles/`
   - This section should be kept in sync with the actual VMs running on each node

**Do not update user-written content.** Only add or update the Proxmox Status section (node docs), Proxmox VM Status section (VM docs), Virtual Machines list (node docs), and their footnotes. Do not edit, "fix," or rewrite any other content in the file that the user wrote. Preserve it exactly.

**Note**: The update process is performed manually by an LLM reading the JSON and intelligently merging the data into markdown files, preserving existing content and structure. This avoids the complexity and risk of automated text merging scripts.

## Data Source

All node data is sourced from the Proxmox VE REST API via the `proxmoxer` Python library. The API provides read-only access to node status and resource usage information.

## Dependencies

- `proxmoxer`: Python wrapper for Proxmox REST API
- `humanize`: For formatting bytes and numbers in human-readable format

Both are listed in `polisher/requirements.txt` and installed in the `.venv` virtual environment.
