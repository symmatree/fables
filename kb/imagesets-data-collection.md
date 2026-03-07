# Imagesets Data Collection Process

## Overview

This document describes the process for collecting and maintaining metadata about drone imagesets stored on the NAS (`\\raconteur\datasets`). Data is derived from EXIF in the images (e.g. image count, altitude range, GPS locations). Output files live in `Datasets/` and are named by site and flight (e.g. `imagesets-bond_ave-2026-02-16-grid.md`). This process is just getting started; the script and field set will evolve.

**When following this process:** Use the actual current date for collection footnotes. Record values from EXIF as given; do not correct or "fix" source data.

## Prerequisites

**Automation (cron / headless):** This process is designed so a script or an LLM (e.g. Cursor CLI with a local model) can run it unattended. The procedure is explicit enough for a small local model to follow step-by-step; the LLM adds value by creating and maintaining the markdown docs and `kb/things.md` instead of hard-coding every template. Run from the **facts repo root**. The EXIF collection script lives in the **polisher** repo at `polisher/facts/collect_imageset_exif.py`; use `polisher/.venv/bin/python` (paths relative to your workspace or absolute). If the NAS is not mounted or the script fails, exit with a clear error rather than guessing.

- **NAS mounted in WSL**: The datasets share must be available (e.g. map `\\raconteur\datasets` to a drive letter in Windows, then in WSL it appears under `/mnt/<letter>`; restart WSL after mapping if the drive did not appear). Typical path in WSL: `/mnt/d` for `\\raconteur\datasets`. If D: is mounted in Windows but `/mnt/d` is empty in WSL, mount it from WSL: `sudo mount -t drvfs D: /mnt/d`.
- **Python + Pillow**: Use the polisher venv, which includes Pillow for reading EXIF:
  ```bash
  cd /path/to/polisher && .venv/bin/pip install -r requirements.txt
  ```
  Then run collection scripts with `polisher/.venv/bin/python`.

## Data Collection Method

### 1. Identify imagesets to update

- **Goal: one summary per imageset folder.** Every subfolder under `{NAS_MOUNT}/imagesets/{site}/` that contains drone images is an imageset and should have a corresponding doc in `Datasets/`. Do not restrict to a particular naming pattern (e.g. `YYYY-MM-DD-variant`). Folder names are human-typed and will be inconsistent; the benefit of using an LLM is to recognize all of them, create or update docs with sensible filenames, and surface naming ambiguities so the human can fix instructions or rename folders if desired.
- **From NAS**: List **all** subfolders under `{NAS_MOUNT}/imagesets/{site}/` for each site. Each subfolder that looks like an imageset (contains image files, e.g. `.JPG`/`.jpg`) is one imageset. Skip only obvious non-folders (e.g. loose files like `Thumbs.db`, `odm_orthophoto.tif`) or archive files (e.g. `.zip`) if they appear as entries in the directory listing.
- **From existing docs**: Check `Datasets/` and the Datasets section in `kb/things.md` to see which sets are already tracked and to avoid duplicate links when adding new docs.
- **Create new docs for every imageset folder that has no doc.** If a NAS folder has no corresponding document, create one. Normalize the folder name to a safe doc filename (e.g. `imagesets-{site}-{normalized-folder-name}.md`—lowercase, hyphens, no spaces). If the folder name doesn't match a strict `date-variant` pattern, derive a sensible doc name and note the mismatch in your run summary so the human can update instructions or rename as needed. Add the new doc and link it in `kb/things.md` (see Update Process step 6).

### 2. For each imageset folder

For each chosen imageset (e.g. `bond_ave/2026-02-16-grid`):

1. **Enumerate images**: List image files in the folder (e.g. `.JPG`, `.jpg`). Count = image count for the doc.
2. **Read EXIF** (via Pillow or a small script using it):
   - **Altitude**: From GPS IFD (tag 6) only. The script does this. If the script reports no altitude, ask the user how to proceed or investigate why it is missing (e.g. check whether GPS altitude is absent in the files, camera/firmware behaviour, or a script bug); do not assume it will "randomly" be missing and document that without resolving or escalating.
   - **GPS**: Use all images to compute the bounding box (min/max lat, min/max lon). The script does this.
3. **Aggregate**: Image count; altitude range (min–max m); bounding box (lon_min, lat_min) .. (lon_max, lat_max). All three are required.

### 3. Update or create the Datasets doc

- **Filename**: `Datasets/imagesets-{site}-{normalized-name}.md`. When the folder name is already like `YYYY-MM-DD-variant` (e.g. `2026-02-16-grid`), use it as-is for the doc name (e.g. `imagesets-bond_ave-2026-02-16-grid.md`). When the folder name uses other conventions (e.g. `Bond-2024-04-22`, `bond-snow-2026-01-01`), normalize to a safe, consistent filename (lowercase, hyphens) so the doc name uniquely matches that folder (e.g. `imagesets-bond_ave-2024-04-22.md`, `imagesets-bond_ave-2026-01-01-snow.md`). One doc per folder; the doc name must identify the folder unambiguously.
- **Path on NAS**: Use the **exact** folder path for this imageset: `\\raconteur\datasets\imagesets\{site}\{folder_name}` (e.g. `...\2026-02-16-grid` or `...\Bond-2024-04-22`). Do not substitute a different variant or name.
- **Content**: Add or update a "From EXIF" (or "Dataset summary") section with: image count; altitude range (min–max, in m); bounding box (lon, lat) as in Document Structure. All three are required.

**Do not update user-written content.** Preserve any existing content in the file (mission params, DroneLink link, processing notes, etc.). Only add or update the sections this process owns: Path on NAS, From EXIF (dataset summary), map preview embed, and the collection footnote. Do not edit, "fix," or rewrite links, wording, or other content that the user wrote.

## Data Mapping

Fields derived from EXIF for the Datasets doc:

| EXIF / source        | Doc use                          |
|----------------------|-----------------------------------|
| Number of image files| Image count                       |
| GPS altitude (all imgs)| Altitude range (min–max, m)     |
| GPS lat/lon          | Bounding box (required)          |

*Exact tag names (e.g. GPSAltitude, GPSLatitude, GPSLongitude) depend on Pillow's EXIF IFD layout; the collection script should document which tags it uses.*

## File Naming and Location

- **Directory:** `Datasets/` (at the facts repo root).
- **Filename:** `imagesets-{site}-{normalized-name}.md`. Normalize the NAS folder name to a safe filename (lowercase, hyphens); when the folder is already `YYYY-MM-DD-variant` use it directly. For other naming styles (e.g. `Bond-2024-04-22`, `bond-woods-2026-01-04`), derive a unique doc name that clearly corresponds to that folder.
- **One doc per imageset folder:** Every imageset folder on the NAS gets exactly one doc. Folder names will vary; create docs for all of them and surface any naming ambiguities for the human.
- **Other files in Datasets/:** Some files in `Datasets/` are not one-to-one imageset docs (e.g. flight narratives, process notes). ODM map docs are maintained by [[odm-maps-data-collection]]. Do not treat supporting material as obsolete; do ensure every imageset **folder** has a doc.

## Document Structure

Each imageset file in `Datasets/` should include:

- **Heading**: `# imagesets / {site} / {folder_name}` (use the actual NAS folder name, e.g. `2026-02-16-grid` or `Bond-2024-04-22`).
- **Path on NAS**: `\\raconteur\datasets\imagesets\{site}\{folder_name}` (exact path to this imageset folder).
- **Mission/processing notes**: Preserve existing content (DroneLink link, altitude, overlap, pattern, processing flags, etc.).
- **From EXIF (dataset summary)**:
  - **Image count**: Total number of images.
  - **Altitude range**: Min–max altitude in m (from EXIF).
  - **Bounding box**: (lon_min, lat_min) .. (lon_max, lat_max) from EXIF.

Add a footnote with collection date and pointer to this process:

*Imageset summary from EXIF on YYYY-MM-DD. See [[imagesets-data-collection]] for update instructions.*

## Update Process

1. **NAS:** Confirm the datasets share is available. Typical WSL path: `/mnt/d` for `\\raconteur\datasets`. If missing, exit with a clear message (do not assume a path). Check e.g. `ls "{NAS_MOUNT}/imagesets"` or list `/mnt/*/imagesets` to find the mount.
2. **Sites and folders:** For each site under `{NAS_MOUNT}/imagesets/`, list **all** subfolders. Process every subfolder that is an imageset (contains image files such as `.JPG`/`.jpg`). Skip only obvious non-imagesets (e.g. a `.zip` file in the listing, or a single loose file). Do not skip a folder because its name doesn't match a strict pattern (e.g. `YYYY-MM-DD-variant`). Human naming is inconsistent; create a doc for each imageset folder and use a normalized doc filename that identifies that folder.
3. **Cross-check:** For each imageset folder, determine the doc filename you will use (normalize folder name to `imagesets-{site}-{normalized-name}.md`). Check whether that doc already exists; if not, check `kb/things.md` so you can add a new link without duplicating.
4. **For each imageset folder:**
   - Run: `polisher/.venv/bin/python polisher/facts/collect_imageset_exif.py <folder_path>` (e.g. `/mnt/d/imagesets/bond_ave/2026-02-21-grid`). If the command fails or required EXIF fields (e.g. altitude) are missing, report to the user and either resolve (e.g. fix script, identify cause) or get direction; do not silently skip or document "no altitude" and move on.
   - Use the KEY=value output to fill the "From EXIF" section. Format: `* Image count: <N>`; `* Altitude range (GPS, approx MSL): <ALT_MIN>–<ALT_MAX> m`; `* Bounding box (lon, lat): (<LON_MIN>, <LAT_MIN>) .. (<LON_MAX>, <LAT_MAX>)`. Footnote: `*Imageset summary from EXIF on YYYY-MM-DD. See [[imagesets-data-collection]] for update instructions.*` (use today's date).
   - Run the map preview script and embed the PNG: `polisher/.venv/bin/python polisher/facts/render_imageset_map_preview.py <folder_path> <output_png>` with `output_png` in the facts repo (e.g. `Datasets/imageset_preview-{site}-{normalized-name}.png`). Add `--ortho <path>` if you have an ortho for this flight. In the imageset doc, embed the image (e.g. `![[imageset_preview-{site}-{normalized-name}.png]]`).
   - Target file: `Datasets/imagesets-{site}-{normalized-name}.md`. Update or create: add or refresh the "From EXIF" block and footnote only. Do not edit or fix user-written content (mission, DroneLink link, processing notes, etc.); preserve it exactly.
5. **New imagesets:** If you created any new imageset doc in step 4, add it to `kb/things.md` (step 6).
6. **Maintain [[things]]:** In the Datasets section of `kb/things.md`, add links for any new imageset docs. Use the same list format as existing entries (e.g. `- [[Datasets/imagesets-bond_ave-2026-02-21-grid]]`). Place imageset links under the right "Imagesets (bond_ave …)" subsection; create a new date subsection if needed (e.g. "Imagesets (bond_ave 2026-02-21)"). ODM map links are maintained by [[odm-maps-data-collection]].

## Data Source

All data is from EXIF metadata in the image files on the NAS. Run extraction with polisher's venv (`polisher/.venv/bin/python`) and Pillow; you can use inline Python (reading GPS IFD 0x8825, altitude tag 6, lat/lon tags 2 and 4) or a small script under polisher/facts. No external API is required.

### Script (polisher/facts/collect_imageset_exif.py)

Run: `polisher/.venv/bin/python polisher/facts/collect_imageset_exif.py <folder_path>`. Output is KEY=value lines: `IMAGE_COUNT`, `ALT_MIN`, `ALT_MAX`, `LAT_MIN`, `LAT_MAX`, `LON_MIN`, `LON_MAX`. The script uses Pillow's GPS IFD (0x8825), altitude tag 6, lat/lon tags 2 and 4, and negates longitude when ref is W. Pillow can return `IFDRational` objects instead of (numerator, denominator) tuples; the script must handle both or EXIF reading will fail (e.g. "object of type 'IFDRational' has no len()").

### Map preview (polisher/facts/render_imageset_map_preview.py)

Run: `polisher/.venv/bin/python polisher/facts/render_imageset_map_preview.py <imageset_folder> <output_png> [--ortho <ortho.tif>]`. Draws a small map: red markers at each image GPS position and a blue chevron for EXIF GPSImgDirection (heading) when present. Optional `--ortho`: path to a georeferenced orthophoto (e.g. from the corresponding ODM run) to use as the base layer; points are transformed to the ortho CRS when needed. Requires Pillow, matplotlib; for `--ortho`, rasterio. Write the PNG to a path in the facts repo so the imageset doc can embed it, e.g. `Datasets/imageset_preview-bond_ave-2026-02-16-grid.png` or next to the doc; embed with `![[map_preview.png]]` (or the chosen filename). When running headless or in a restricted environment, matplotlib needs a writable config directory: ensure `~/.config` is writable or set `MPLCONFIGDIR` to a writable path (e.g. `export MPLCONFIGDIR=/tmp`). Index: [[data-collection]].

## Notes

- **Missing altitude or other EXIF:** When the script reports no altitude (or other required field), do not treat it as normal. Either ask the user how to proceed or investigate why (script bug, camera not writing GPS altitude, wrong IFD/tag). Resolve or escalate; do not write steps that assume things will randomly break and we ignore it.
- **WSL + mapped drive:** If you map a network drive in Windows after WSL is running, it may not appear under `/mnt/` until WSL is restarted (`wsl --shutdown` from Windows, then open WSL again). If D: is visible in Windows Explorer but `/mnt/d` exists and is empty in WSL, mount it from WSL: `sudo mount -t drvfs D: /mnt/d`.
- **Path typo:** Ensure the "Path on NAS" in each doc matches the **variant** (e.g. grid vs orbit vs house-close-orbit); it's easy to copy-paste the wrong path.
- **things.md:** If you add new imageset docs, add them to the Datasets section in `kb/things.md` so they stay discoverable; see Update Process step 6. ODM map docs are added via [[odm-maps-data-collection]].
- **Longitude:** EXIF often stores West as positive; use negative longitude in the doc (e.g. -80.04…) to match GeoJSON/conventions.
