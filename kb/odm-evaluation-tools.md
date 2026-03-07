# ODM Evaluation and Diagnostic Tools

Tools and techniques for evaluating drone imagery, ODM reconstruction quality, and diagnosing reconstruction failures. Covers existing tools, ad hoc analyses, planned tooling, and 3D visualization approaches.

Related docs: [[odm-maps-data-collection]] (map doc process), [[imagesets-data-collection]] (imageset doc process), [[experiments-house-model]] (experiment log and open issues).

---

## Existing tools (polisher repo)

These are scripted, repeatable tools that run as part of the data collection process.

### collect_odm_run_record.py

**Purpose:** Extract and format ODM processing stats from a single map run.

**Reads:** `log.json` (ODM options), `odm_report/stats.json` (processing stats, feature stats, reconstruction counts, reprojection/GPS errors, timing, GSD). Compares options to `odm_option_defaults.json` to show only non-default settings.

**Produces:** Markdown tables (to stdout) for pasting into map docs under `## ODM run record`. Includes: non-default ODM options, processing statistics (capture window, area, OpenSfM step times), features statistics, reconstruction counts, reprojection errors, GPS errors, total time, GSD.

**Invocation:** `polisher/.venv/bin/python polisher/facts/collect_odm_run_record.py <map_output_dir>`

**Limitation:** Reports aggregate stats only. No per-image breakdown, no spatial analysis. Useful for comparing runs at a glance but misleading for diagnosing spatial problems (e.g. house-2 has worse ce90 than house despite being a better visual result).

### render_odm_map_preview.py

**Purpose:** Generate a PNG preview of the orthophoto with optional boundary overlay.

**Reads:** `odm_orthophoto.tif`, optionally `odm_georeferencing/odm_georeferenced_model.bounds.geojson` or a custom boundary GeoJSON.

**Produces:** A PNG image embedded in the map doc.

**Invocation:** `polisher/.venv/bin/python polisher/facts/render_odm_map_preview.py <map_output_dir> <output_png>`

### analyze_odm_reconstruction.py

**Purpose:** Per-shot spatial analysis of reconstruction quality. The single most informative diagnostic tool we have.

**Reads:** `images.json` (input image GPS positions), `odm_report/shots.geojson` (reconstructed camera positions).

**Produces:**
- `reconstruction_status.png` -- map with green dots (reconstructed), red X (dropped), arrows showing GPS-to-reconstructed displacement.
- `dropped-images.md` -- table of dropped images with metadata.

**Invocation:** `polisher/.venv/bin/python polisher/facts/analyze_odm_reconstruction.py <map_output_dir>`

**Key insight (Conclusion 3 in experiments doc):** Per-shot displacement and dropped-image maps are more informative than aggregate stats. Plotting each shot's displacement immediately reveals which images are pulling the model and where the reconstruction is unstable. Dropped-image maps show spatial clustering that aggregate counts hide.

**Planned enhancements:** Scalar displacement ranking, worst-images table, per-quadrant breakdown. Currently deferred.

### render_imageset_map_preview.py

**Purpose:** Plot GPS positions of all images in an imageset, with optional orthophoto background.

**Reads:** Image EXIF (GPS position, optional GPSImgDirection).

**Produces:** PNG with markers at each image position, chevrons for heading.

**Invocation:** `polisher/.venv/bin/python polisher/facts/render_imageset_map_preview.py <imageset_folder> <output_png> [--ortho <ortho.tif>]`

---

## Ad hoc analyses (previous sessions)

These were one-off Python scripts run inline during the [house model experiments](2f8a2ad0-5c7e-4163-be79-9400aaebd2e8) session. Not yet scripted as reusable tools, but the logic is documented here for future extraction.

### Flight pattern analysis

**Purpose:** Understand the drone's flight path, identify N-S vs E-W passes, and locate problem images within the crosshatch pattern.

**Reads:** EXIF from all images in an imageset (DateTimeOriginal, GPS lat/lon via PIL).

**Logic:** Sort images chronologically. Compute heading between consecutive shots. Detect turnarounds (gaps >5 s). Classify segments as N-S or E-W by dominant heading direction. Mark known problem images.

**Output:** Table of images with timestamp, lat, lon, heading, gap, segment ID, and problem flag. Summary of pass structure and which segments contain problem images.

**Key finding:** 02-21-grid is a crosshatch (12 N-S segments then 9 E-W segments). SE problem images come from both passes, confirming the problem is spatial, not pass-specific.

### Cross-run reconstruction status comparison

**Purpose:** Compare which images are reconstructed, dropped, or displaced across multiple ODM runs (house, house-2, uncrop).

**Reads:** `images.json` (input image GPS), `odm_report/shots.geojson` (reconstructed positions) from each run.

**Logic:** Build reconstructed set from shots.geojson per run. Compute displacement as Euclidean distance in UTM (EPSG:32617) between original GPS and reconstructed position. For each problem image: report recon/dropped/displacement per run.

**Output:** Per-image status table across runs. Displacement statistics (median, mean, max, counts above thresholds). Quadrant-level breakdowns (NW/NE/SW/SE based on median lat/lon split).

**Key findings:** High-displacement survivors are net-negative (uncrop destabilized previously well-placed images). NW is a drop problem, SE is a displacement problem, NE/north-wall is both.

### DEM elevation sampling at problem locations

**Purpose:** Determine whether terrain elevation explains problem image clusters.

**Reads:** `odm_dem/dsm.tif` (from uncrop run for full coverage), image GPS + EXIF altitude.

**Logic:** Load DSM with rasterio. Transform image GPS (WGS84) to DSM CRS. Sample elevation at each problem image location. Compute AGL (flight altitude - ground elevation) and elevation drop relative to house center.

**Output:** Per-cluster elevation ranges, AGL, and drop vs house level.

**Key findings:** SE drops 15-26 m below house level (AGL nearly doubles). NW is flat at the perimeter. NE is level ground with normal AGL. The SE problem is terrain-driven; the NE problem is not.

### Spatial distribution of drops

**Purpose:** Quantify where dropped images cluster geographically.

**Reads:** `images.json`, `odm_report/shots.geojson`.

**Logic:** Compute dropped set (input minus reconstructed). Split at median lat/lon into quadrants. Count drops per quadrant.

**Output:** Per-run quadrant drop counts and percentages.

**Key finding:** NW quadrant dominates drops across all runs (55-67% of all drops).

### Turnaround fragility analysis

**Purpose:** Test whether row endpoint images (turnaround points) drop at higher rates than mid-segment images.

**Reads:** Flight pattern analysis output + reconstruction status per run.

**Logic:** Classify each image as turnaround (first/last 2 in segment) or mid-segment. Compute drop rate and average displacement for each category, split by quadrant.

**Output:** Drop rate and displacement stats by position-type x quadrant.

**Key finding:** Turnaround images drop at 4x the rate of mid-segment (31% vs 7.7%). But the effect is spatial: NW turnarounds are worst (67% dropped), SE turnarounds only 10% dropped but mid-segment displacement is high.

---

## Planned diagnostic tools

### OpenSfM intermediate data analysis

The `opensfm/` directory (preserved when `--optimize-disk-space` is off, which is the default) contains rich intermediate data that no existing tool reads:

| Directory/File | Contents | Format |
|---|---|---|
| `features/` | Per-image detected features | `.npz` (numpy): pixel coordinates + descriptors |
| `matches/` | Pairwise feature matches after geometric verification | Binary files per image pair |
| `tracks.csv` | Feature tracks linking matches across images | CSV: track_id, image_id, feature_id, pixel_x, pixel_y, ... |
| `reconstruction.json` | Final reconstruction: camera poses, 3D points, calibration | JSON (see OpenSfM dataset structure docs) |
| `stats/` | Heatmaps, match graph, report PDF | PNG + JSON + PDF |

### Feature height classification (high priority)

**Purpose:** For each reconstructed feature, determine whether it is at ground level, canopy height, or on a structure.

**Reads:** `features/` + `tracks.csv` + `reconstruction.json` + external ground DEM (e.g. USGS 3DEP or the run's own DSM).

**Logic:** Load features -> tracks -> reconstructed 3D points. For each reconstructed point, compare its Z coordinate to the ground DEM at that XY position. Classify as ground (within ~2 m of DEM), canopy (well above DEM), or structure (above DEM but within known building footprints).

**Output:**
- **Track length vs height scatter plot** -- if nearfield parallax is the dominant problem, expect inverse correlation: canopy features have short tracks (2-3), ground features have long tracks (5+). This would be a single compelling diagnostic.
- **Per-image feature height histogram** -- what fraction of each image's features are at ground vs canopy height? Does this correlate with reconstruction success?
- **3D point cloud colored by track length** -- overlay on the reconstruction to see where long-track vs short-track features cluster spatially.

**Tests:** Nearfield parallax theory (features cluster by height) vs directional lighting theory (features cluster by sun angle). See theory discrimination section below.

### Accepted vs rejected feature spatial maps

**Purpose:** Visualize where features survive vs fail at each pipeline stage.

**Reads:** `features/` (all detected), `tracks.csv` (survived matching + tracking), `reconstruction.json` (survived triangulation + BA).

**Logic:** For each image, classify its features into: (a) detected but not matched, (b) matched but not tracked (short track), (c) tracked but not reconstructed (triangulation/outlier rejection), (d) reconstructed. Overlay as color-coded scatter on the image.

**Output:** Per-image feature fate map. Aggregate statistics across images.

**Tests:** If parallax is the problem, rejected features should concentrate in canopy regions isotropically. If directional lighting is the problem, rejections should show an axial pattern aligned with the solar azimuth.

### Per-image-pair match success map

**Purpose:** For a given image pair, show which features matched and which didn't.

**Reads:** `features/` for both images, `matches/` for the pair.

**Logic:** Load features for both images. Load match results. Overlay matched vs unmatched features on each image.

**Output:** Side-by-side feature maps showing match success patterns.

**Use case:** Targeted debugging once a problem pair is identified. Not useful for broad exploration (too many pairs).

---

## Theory discrimination via diagnostics

The nearfield parallax and directional lighting theories make distinct spatial predictions that the planned tools can distinguish:

| Theory | Prediction for feature failures | Diagnostic |
|---|---|---|
| **Nearfield parallax** | Failures cluster by height above ground (canopy = bad, ground = good). Isotropic -- no preferred axis. | Feature height classification: rejected features above DEM, accepted features near DEM. |
| **Directional lighting** | Failures cluster by position relative to sun angle. Match failures along shadow boundaries, perpendicular to solar azimuth. | Accepted/rejected feature maps: axial pattern in rejections aligned with sun vector. |
| **Autofocus on treetops** | Ground features detected but slightly soft, reducing match confidence. Canopy features sharp. | Feature descriptor strength vs height: canopy features should have higher descriptor response (sharper edges). |
| **Low-contrast ground** | Ground features detected but with weak descriptors, losing to stronger canopy features in matching. | Descriptor magnitude vs height: ground descriptors weaker than canopy on 02-21 but comparable on 02-16 (snow). |

Both parallax and lighting likely contribute; the diagnostic question is which dominates. A single "track length vs height" scatter plot would be the cheapest discriminator.

---

## 3D visualization strategy

### The case for 3D over image-space

Image-space analysis (overlaying features on individual images or image pairs) is useful for spot-checking but fundamentally limited:
- With 400+ images per collection (growing), random sampling won't find patterns.
- You can only look at one or two images at a time, so you'd need to already know where to look.
- Features from different images can't be compared side-by-side because each has a different viewpoint.

A shared 3D coordinate system solves all three problems:
- Data from all images is projected into a common space and visible at once.
- Spatial patterns (clusters, axes, gradients) are immediately visible.
- You can interactively toggle layers (different collections, feature types, classifications) on and off.

For example: the point cloud with feature points colored by track length would immediately show whether long-track features cluster on the ground (parallax theory) or along the sun axis (lighting theory). A human can assess this visually in seconds.

Crucially, image-space metadata can be carried into 3D as scalar fields on the projected points. For example, coloring each 3D feature point by its position within its parent image (e.g. left-right or center-vs-edge) would reveal axial patterns in feature success/failure that relate to sun angle, lens quality, or flight direction -- without needing to look at individual images. This is a way to embed 2D information while keeping the information density of hundreds of images in a single 3D view.

### Viewer options

| Tool | Type | Strengths | Weaknesses | Effort |
|---|---|---|---|---|
| **CloudCompare** | Desktop app | Mature, handles huge point clouds. Scalar fields for coloring by any attribute. Python scripting (CloudComPy). Comparison between clouds. Free. | Desktop only. UI is functional but dated. Scripting API is large but poorly documented. | Low -- just export PLY/LAS with custom scalar fields and load. |
| **Potree** | Web viewer | Beautiful, handles billions of points. Annotations, measurements. ODM already exports compatible formats (3D Tiles, LAS/LAZ). | Read-only (view, not analyze). Adding custom overlay points requires building a custom page. No built-in scripting for analysis. | Medium -- need to convert feature data to a compatible format and build a page. |
| **Open3D** | Python library | Fully programmable from Python. Easy to create multiple colored point clouds and overlay them. Interactive viewer with point picking. | Requires Python environment. Not a persistent viewer (closes when script exits, though can be kept open). Smaller point budget than CloudCompare/Potree for very large clouds. | Low-medium -- a Python script that loads PLY + feature data and shows them together. |
| **Blender** | Desktop app | Full 3D scene with layers, toggles, custom shaders. Can import PLY, LAS, OBJ. Python scripting. Beautiful rendering. | Steep learning curve for programmatic use. Point cloud support is via add-ons, not native. Overkill for analysis. | High for automation, low for manual one-off exploration. |
| **Three.js / custom web** | Web viewer | Full control. Could build exactly the diagnostic interface we want (toggle layers, filter by track length, color by height, click to inspect). | Significant web dev effort. Point cloud rendering performance requires careful implementation. | High. |

### Recommended approach

**Phase 1 (immediate, zero setup):** CloudCompare. ODM already outputs `odm_georeferencing/odm_georeferenced_model.laz`. Write a Python script that reads OpenSfM intermediate data (`features/`, `tracks.csv`, `reconstruction.json`) and exports a second LAZ/PLY file containing only the reconstructed feature points, with scalar fields for:
- Track length
- Height above DEM
- Feature type (ground / canopy / structure)
- Reconstruction stage (survived matching / survived tracking / survived BA / rejected)
- Position in parent image (normalized x, y -- enables coloring by left-right or center-vs-edge to reveal axial patterns from sun angle, lens quality, or flight direction)
- Source image heading / flight pass (N-S vs E-W, useful for cross-pass analysis)

Load both in CloudCompare. The main point cloud provides context; the feature point cloud provides the diagnostic overlay. Color by any scalar field. Toggle layers on/off. This gets us to "can I see if features are on the canopy or the forest floor" with minimal effort.

**Phase 2 (when patterns are understood):** Open3D Python script. Once we know what diagnostic views are most useful, wrap them in a reusable script that loads a run's data and presents the key visualizations. More portable than CloudCompare (runs anywhere Python runs), and the analysis logic (height classification, track length stats) is already in Python.

**Phase 3 (if ongoing monitoring is needed):** Potree/web viewer with pre-computed layers. For Level 4 (maintaining maps over time), a persistent web viewer where each collection's features are a toggleable layer would let you visually compare across time. But this is premature until we have multiple good reconstructions to compare.

### Coordinate system compatibility

ODM outputs are georeferenced (typically UTM via EPSG:32617 for our site). OpenSfM's `reconstruction.json` stores points in a local coordinate system that is aligned to GPS during reconstruction. The `odm_georeferencing` step transforms these to the georeferenced CRS. So:

- The output point cloud (`odm_georeferenced_model.laz`) is in UTM.
- OpenSfM's 3D points in `reconstruction.json` are in a local frame; to overlay them on the georeferenced cloud, they need the same georeferencing transform. This transform is available in the ODM pipeline but may need to be extracted or reapplied.
- Alternatively, the undistorted reconstruction (`undistorted/reconstruction.json`) may already be in the final CRS.

**Action item:** Verify the coordinate system of `reconstruction.json` vs the georeferenced output and document the transform needed to align them. This is a prerequisite for the CloudCompare overlay approach.

---

## Index

Part of [[data-collection]] (evaluation tools). Related: [[odm-maps-data-collection]], [[experiments-house-model]].
