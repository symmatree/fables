# UniFi Device Data Collection Process

## Overview

This document describes the process for collecting and maintaining device information from the UniFi network controller using the UniFi MCP (Model Context Protocol) server.

Please execute this procedure carefully, noting any concerns or ambiguities. If anything doesn't work, please stop to consult rather than inventing a new procedure. Similarly if you have better ideas, please make a list of suggestions.

## Data Collection Method

Device data is collected via the UniFi MCP server using the following steps:

1. **List all sites**: Call `mcp_unifi_list_all_sites` to retrieve available UniFi sites
2. **List devices by type**: For each site, call `mcp_unifi_list_devices_by_type` with:
   - `site_id`: Use `"default"` for the default site
   - `device_type`: One of "uap" (access points), "usw" (switches), "ugw" (gateways), or "udm" (gateway/controller e.g. UniFi Dream Machine)

## Data Mapping

Each device document is created from the API response fields:

- **Model**: `model` field (e.g., "U7PG2", "US48")
- **Name**: `name` field (device hostname/label)
- **IP Address**: `ip` field. **Do not write WAN or public IP.** For gateways (UGW/UDM), record only the LAN/internal IP in the kb. Omit WAN IP for privacy (e.g. write "10.0.0.1 (LAN); WAN IP omitted for privacy").
- **MAC Address**: `mac` field
- **Firmware Version**: `version` field
- **Uptime**: `uptime` field (in seconds)
- **Type**: `type` field ("uap", "usw", "ugw", or "udm")
- **State**: `state` field (1 = online, 0 = offline)
- **Adopted**: `adopted` field (true/false)
- **Serial Number**: `serial` field
- **Uplink Depth**: `uplink_depth` field (for switches, indicates network hierarchy)

## Product Information Collection

Product information is collected from the [UniFi Device Models JSON](https://gist.github.com/sgrodzicki/265273ff0ede952d6fcd1a1eedb6aa60) mapping file:

1. **Fetch the JSON mapping**: Download the raw JSON from the gist using:
   ```bash
   curl -s https://gist.githubusercontent.com/sgrodzicki/265273ff0ede952d6fcd1a1eedb6aa60/raw/unifi_device_models.json
   ```

2. **Map model codes to product info**: For each device's `model` field (e.g., "U7PG2", "US48", "UDMPROSE"), look up the corresponding entry in the JSON. The JSON uses model codes as keys. **Note**: The model code can be retrieved from the UniFi MCP API via `mcp_unifi_get_device_details` - the `model` field in the API response contains the model code (e.g., "UDMPROSE" for UDM SE).

3. **Extract product data**: From each JSON entry, extract:
   - `names.sku`: Product SKU (e.g., "UAP-AC-Pro", "US-48-G1")
   - `compliance.displayName`: Official display name
   - `names.fullName`: Full product name
   - `names.abbreviation`: Abbreviated name
   - `type`: Device type
   - `features`: Feature flags (e.g., PoE, fan control, WiFi standards)
   - `radios`: Radio specifications (for access points)

4. **Add Product Info section**: Create a table in each device document with the extracted information, excluding FCC compliance data.

5. **Technical Specifications Collection**: Technical specifications are collected from `techspecs.ui.com` pages using the Python script at `polisher/unifi/extract_tech_specs.py`:
   - **URL Pattern**: 
     - Access Points: `https://techspecs.ui.com/unifi/wifi/{sku}`
     - Switches: `https://techspecs.ui.com/unifi/switching/{sku}` or `https://techspecs.ui.com/unifi/other/{sku}`
   - **Method**: The script fetches the page HTML using Python's `urllib.request`, extracts the embedded `__NEXT_DATA__` JSON from the `<script id="__NEXT_DATA__" type="application/json">` tag, and parses the technical specification data. The data is server-rendered in the initial HTML response, so no browser automation or JavaScript execution is needed.
   - **Usage**: 
     ```bash
     # Get JSON output
     python3 polisher/unifi/extract_tech_specs.py "https://techspecs.ui.com/unifi/wifi/uap-ac-pro" --json
     
     # Get Markdown output (default)
     python3 polisher/unifi/extract_tech_specs.py "https://techspecs.ui.com/unifi/wifi/uap-ac-pro"
     ```
   - **Data Extraction**: The script parses JSON from `props.pageProps.product.technicalSpecification.sections` to extract:
     - Overview section (dimensions, WiFi standard, coverage area, etc.)
     - Hardware section (power, mounting, weight, temperature, etc.)
     - Performance section (switching capacity, throughput, etc.)
     - Features section (for access points)
     - Software section (if applicable)
     - Automatically skips "Layer 2 Features" section
   - **Output Format**: The script outputs Markdown-formatted technical specifications that can be directly inserted into device documentation files

## File Naming Convention

Device documents are stored in `kb/unifi/` with filenames based on the device name:
- Convert to lowercase
- Replace spaces and special characters with hyphens
- Use `.md` extension

Example: `spa-eaves-uap-ac-pro.md`, `basement-us-48-g1.md`

**Do not update user-written content.** Only add or update the sections this process owns: Network Information, Product Info, Technical Specifications (and their footnotes). Do not edit, "fix," or rewrite any other content in the file that the user wrote. Preserve it exactly.

## Document Structure

Each device document includes:
1. Device name as heading
2. **Network Information** section with:
   - Complete device identification (IP, MAC, Device ID, Name, Model, Type, Serial Number)
   - Current operational status (Firmware Version, State, Adopted status, Uplink Depth, Uptime)
   - **Statistics** subsection with:
     - Total bytes transferred (TX, RX, Total)
     - CPU and Memory usage (if reported by device)
   - Data collected via `mcp_unifi_get_device_details` and `mcp_unifi_get_device_statistics` MCP calls
   - Footnotes with data source, collection date, and specific MCP call parameters for future updates
3. **Product Info** section with:
   - Display name, SKU, and product details from the JSON mapping
   - Links to UniFi Store page and Tech Specs page
4. **Technical Specifications** section with:
   - Overview (dimensions, form factor, etc.)
   - Performance metrics (switching capacity, throughput, etc.)
   - Features (for access points)
   - Hardware details (power, mounting, weight, temperature, certifications, etc.)
   - Extracted from techspecs.ui.com using the Python script
5. Link back to this process document
6. Footnotes indicating data sources (UniFi MCP API, JSON mapping, techspecs.ui.com)

## Update Process

To update device information:

1. **Device Data Updates**: For each device, call `mcp_unifi_get_device_details` and `mcp_unifi_get_device_statistics` with:
   - `site_id`: Use `"default"` for the default site
   - `device_id`: The device ID (from the device document's Network Information section)
2. **Update Network Information Section**: Compare API response with existing device documents and update:
   - Firmware version
   - Uptime
   - IP address (if changed). For gateways, update only LAN IP; do not write WAN/public IP.
   - State (online/offline, adopted state)
   - Statistics (TX/RX bytes, CPU, memory if available)
   - Update the collection date in the footnote
3. **Technical Specifications Updates**: To update or add technical specifications:
   - Extract the Tech Specs URL from the device document's Product Info section
   - Run the extraction script:
     ```bash
     python3 polisher/unifi/extract_tech_specs.py "<tech_specs_url>"
     ```
   - Copy the Markdown output and add it to the device document after the Product Info section
4. **New Devices**: Create new documents for newly discovered devices following the document structure above
5. **Removed Devices**: Archive or delete documents for devices that are no longer in the network.
6. **Adding Product Info and Tech Specs to Existing Client Documents**: If a client document exists for a device that is also a UniFi device (e.g., a gateway that appears in both client and device lists), you can add Product Info and Technical Specifications sections to that document:
   - **Get model code**: Use `mcp_unifi_get_device_details` with `site_id="default"` and the device's MAC address or search for the device by name/MAC to get the `device_id`, then retrieve the `model` field
   - **Fetch product info**: Look up the model code in the UniFi Device Models JSON gist (same process as step 2-4 above)
   - **Fetch tech specs**: Use the `polisher/unifi/extract_tech_specs.py` script with the techspecs URL (typically `https://techspecs.ui.com/unifi/cloud-gateways/{sku}` for gateways, or similar patterns for other device types)
   - **Add sections**: Add Product Info and Technical Specifications sections to the existing client document, following the same format as device documents
   - **Document the process**: Add a note in the Product Info section indicating how the model code was retrieved (e.g., "Model code 'UDMPROSE' retrieved from UniFi MCP API via `mcp_unifi_get_device_details`")

## Paths Tried and Ruled Out

### Technical Specifications Scraping

1. **Direct `web_search` for store.ui.com content**: 
   - **Tried**: Using `web_search` tool to search for product pages
   - **Ruled Out**: Failed to retrieve JavaScript-rendered "Technical" tab content. The search results don't provide access to dynamically loaded content.

2. **Direct `curl` to store.ui.com without parsing**:
   - **Tried**: Fetching HTML directly with `curl`
   - **Ruled Out**: Returned raw HTML without dynamic content. The "Technical" tab content is loaded via JavaScript after page load.

3. **Browser automation snapshots**:
   - **Tried**: Using browser automation tools to navigate to pages and capture snapshots
   - **Ruled Out**: Accessibility snapshots capture page structure but not the actual rendered content values. The snapshot format shows element structure but not the data values displayed in tables.

4. **Final Solution**: 
   - **Method**: Use the Python script `polisher/unifi/extract_tech_specs.py` to fetch `techspecs.ui.com` pages and extract the embedded `__NEXT_DATA__` JSON data
   - **Why it works**: The `techspecs.ui.com` pages embed all technical specification data in a JSON object within a `<script id="__NEXT_DATA__">` tag, which is available in the initial HTML response and doesn't require JavaScript execution or browser automation
   - **Implementation**: The script uses Python's `urllib.request` to fetch the HTML, regex to extract the JSON from the script tag, and Python's `json` module to parse and extract the technical specification sections. The script handles nested feature groups and formats the output as Markdown suitable for documentation

## Data Source

All data is sourced from:
- **Device Information**: UniFi Network Controller via the UniFi MCP server API. The MCP server provides read-only access to device information through the UniFi Controller's API.
- **Product Information**: [UniFi Device Models JSON](https://gist.github.com/sgrodzicki/265273ff0ede952d6fcd1a1eedb6aa60) mapping file
- **Technical Specifications**: [UniFi Tech Specs](https://techspecs.ui.com) pages, extracted from embedded JSON data
