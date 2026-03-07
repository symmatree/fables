# Data Collection Procedures

This index lists the documented procedures for collecting and maintaining data in the knowledge base. Each procedure describes how to gather data from an external source (API, CLI, etc.) and update the corresponding kb entities.

| Procedure | Source | Output location |
| --------- | ------ | ---------------- |
| [[github-repo-data-collection]] | GitHub REST API (`gh` CLI) | `GithubRepos/` |
| [[unifi-device-data-collection]] | UniFi MCP server | `kb/unifi/` |
| [[client-data-collection]] | UniFi MCP server | `kb/network-devices/device-by-ip` (index of documented entities), client-linked docs in `kb/Computers/`, `kb/proxmox/`, etc. |
| [[proxmox-data-collection]] | Proxmox REST API (`proxmoxer`) | `kb/proxmox/` (node docs) |
| [[tiles-software-data-collection]] | tiles repo (charts, argocd-applications/templates, tf/modules/k8s-cluster, tanka) | `Tiles/Software/` |
| [[tiles-software-logs]] | Grafana (Loki) + kubectl; run per component | `Tiles/Software/<component>.md` Logs section |
| [[imagesets-data-collection]] | NAS path + EXIF (Pillow script, polisher venv) | `Datasets/` (imagesets-*.md) |
| [[odm-maps-data-collection]] | NAS odm-maps dir + map preview script (polisher venv) | `Datasets/odm-maps-*/` (one doc + optional map_preview.png per map) |
| [[odm-evaluation-tools]] | ODM outputs + OpenSfM intermediate data | Diagnostic outputs (maps, plots, 3D overlays) for reconstruction quality analysis |

**Map preview scripts (polisher, output PNG for embedding):**

- **ODM map:** See [[odm-maps-data-collection]]. `polisher/.venv/bin/python polisher/facts/render_odm_map_preview.py <map_output_dir> <output_png>`. Put the PNG in the same directory as the ODM map doc and embed with `![[map_preview.png]]`.
- **Imageset:** `polisher/.venv/bin/python polisher/facts/render_imageset_map_preview.py <imageset_folder> <output_png> [--ortho <ortho.tif>]`. Plots markers at each image GPS position and a chevron for EXIF GPSImgDirection when present. Optional `--ortho` uses an orthophoto as base (e.g. from the corresponding ODM run). Put the PNG next to the imageset doc or in a sibling folder and embed from the parent doc (e.g. `![[map_preview.png]]`). See [[imagesets-data-collection#Map preview]].

**Repo invariants (defended internally):**

- We keep quotation marks as ASCII straight quotes (0x22) in procedure and KB text so tooling and search/replace work. Paste from Google Docs, Obsidian, etc. is fine. From polisher, run: `polisher/.venv/bin/python polisher/facts/normalize_ascii_quotes.py <path-to-facts-repo>` whenever you notice curly quotes or before a commit; the script rewrites U+201C/U+201D to ASCII.

**Notes:**

- UniFi **devices** (APs, switches, gateways) are maintained via [[unifi-device-data-collection]] and live in `kb/unifi/`.
- UniFi **clients** (end-user devices) and the device-by-IP table are maintained via [[client-data-collection]]. That process also references devices in the device-by-IP table and can update or create docs for clients (e.g. in `kb/Computers/`, `kb/proxmox/`).
