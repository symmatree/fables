# Experiments: house model iteration

*Single place to track experiments, conclusions, and open issues for the Stage 1 house 3D model. Map docs keep their own commentary; we log outcomes and next steps here.*

**Overall plan:** [[plan-house-and-property-mapping]]

### Levels of success

1. **Build one good map once.** A house model with correct geometry, clean textures (no twig projection), visible eaves/overhangs, plus a good heightfield for the yard and (eventually) woods with fallen logs visible in the point cloud. **Not yet achieved.** 02-16 had twig textures on all walls and no eave coverage (all high-altitude, nothing in shadow). House-2 is "basically usable" but has ~2 m corner error on the north wall and twig projection there.
2. **Build an acceptable map almost every time under controlled conditions.** An understood, predictable process where we can robustly predict success and choose to avoid known failure conditions (weather, lighting, focus settings). Requires understanding which variables matter and what their safe ranges are.
3. **Build an acceptable map in almost any conditions.** Leverage understanding of failure modes to *mitigate* rather than merely *avoid* them. The "snowglobe" use case is the aspirational target: reconstruct from underexposed, high-dynamic-range, low-texture evening images in snow. Strategy: align difficult images to an existing (good) bundle adjustment without updating the geometry; possibly preprocess images for feature visibility during reconstruction but use original moody imagery for texturing and point-cloud coloring.
4. **(Separate axis) Maintain a map over time.** Stable point cloud and texture that update to reflect real changes (renovations, seasonal shifts, drainage work) without random jitter or convergence failures across recaptures. Underpins the broader rough-and-ready BIM and smart-home management goals. May require strong priors from previous captures and accumulated confidence.

Current status: working toward Level 1. Most analysis has been diagnostic (understanding *why* it fails). Only 2 full collection runs to date (02-16 snow + grid/orbit; 02-21 grid/orbit + close-orbit), of which only the second included close-orbit imagery.

---

## Experiments log

One row per run. Fill in blanks from map docs and memory; question marks where we don't yet have a single source of truth.

| Map | Input imagesets | Collection (alt, overlap, speed, pattern, gimbal) | ODM (boundary, feature/pc quality, 3d mesh) | Outcome / usability note |
|-----|-----------------|---------------------------------------------------|---------------------------------------------|--------------------------|
| [[odm-maps-bond_ave-2026-02-16]] | [[imagesets-bond_ave-2026-02-16-grid]], [[imagesets-bond_ave-2026-02-16-orbit]] | 25 m alt; grid 75/70% overlap, 20 km/h, -70°; orbit 10 km/h, 36.6 m radius. GSD 1.1 cm | Defaults (not recorded in map doc) | Not usable: tree textures projected on all sides, gaps under eaves, model gaps in point cloud; garage door mush; slight gutter waviness. DEM good for downed logs |
| [[odm-maps-bond_ave-2026-02-21-house]] | [[imagesets-bond_ave-2026-02-21-grid]], [[imagesets-bond_ave-2026-02-21-orbit]], [[imagesets-bond_ave-2026-02-21-house-close-orbit]] | Same plan as 02-16 (25 m, 20/10 km/h). Close-orbit: manual waypoints within tree line, 5 km/h. See [[imagesets-bond_ave-2026-02-21-flight]]. GSD 1.0 cm | Tight crop; feature-quality ultra, pc-quality high, use-3dmesh true | Tight cutline -> degenerate spa geometry; north wall insane + twigs projected; camera positions poor on north side |
| [[odm-maps-bond_ave-2026-02-21-house-2]] | Same as house | Same | Looser lasso + min_num_features: 30000 (vs default 10000 in house); bad camera poses still outside this boundary | **Best result so far.** Basically usable except north wall: corner ~2m off, twigs projected on texture. Orthophoto a little soupy, waviness near water feature. 3x more features -> 2.6x more points, 21 more shots reconstructed (400 vs 379) |
| [[odm-maps-bond_ave-2026-02-21-uncrop/odm-maps-bond_ave-2026-02-21-uncrop]] | Same as house | Same | auto_boundary: true (no manual boundary); min_num_features: 30000; dem_gapfill_steps: 0; dtm: false. Otherwise same as house-2 | **Worse than house-2 on every metric.** 392/446 shots (vs 400), GPS ce90 2.43 (vs 1.57), track length 3.35. Auto-boundary was 4x larger than house-2 but reconstructed less area (13947 vs 14959 m2). Many images well-placed in house-2 had 14-38 m displacements in uncrop. Wider boundary introduced noise, not stability. |

*Mission params: 02-21 grid/orbit used the same DroneLink plan as 02-16. Key collection differences were autofocus change mid-flight and camera settings; see [[imagesets-bond_ave-2026-02-21-flight]]. We still want structured mission params from DroneLink recorded locally (see issue #343).*

*Ground conditions: 02-16 had snow cover (initially feared featureless, but matched 379/380). By 02-21 a sharp thaw left bare leaf-litter. Despite similar dates and solar angle (~39 deg at noon), ground conditions were very different. Snow likely helped matching significantly -- see Learnings for analysis.*

*Gimbal warnings: DroneLink frequently warned about "gimbal movement limits" during turnarounds in the crosshatch grid. Likely caused by commanding sharp direction changes that exceed the gimbal's stabilization range. See turnaround fragility analysis in Learnings.*

*Focus test (late Feb 2026): Attempted static focus at 25 m AGL. Sharpest point was roughly 2/3 through the focus range, NOT at infinity. Previous analysis suggested hyperfocal distance was close enough to use infinity, but this was wrong operationally. Focus was set by eyeballing the live feed, which is not repeatable. Need better tooling: focus peaking in DroneLink UI, magnification, or some other aid for consistent focus setting.*

*Shutter speed test (late Feb 2026): Attempted flight on an overcast/foggy day (nice diffuse lighting, but dark). Test shots had significant motion blur. Set manual shutter to ~1/400. Need to think carefully about minimum shutter speed given flight speed, GSD, and acceptable blur budget.*

*Tree collision (late Feb 2026, same session as focus/shutter tests): On the first grid mission attempt, the drone stopped near the first turnaround -- very close to a treetop. Manually raised height and returned to origin, assuming the grid plan routed around a tall tree. Set manual focus, adjusted shutter, relaunched. Completed roughly one grid line, then flew directly into a tree. Damage: at least two shattered prop blades, possibly more need replacement. Conditions: ~40 F / 4 C, overcast/foggy, launched quickly from warm indoors (routine is fast now). Within a couple of minutes of collecting debris and going inside, heavy rain started. See new open issue "Barometric altitude drift" for root cause analysis. **Post-crash action items:** replace damaged blades (need to buy spares); check camera calibration on next flight; consider a short targeted mission (e.g. close-orbit only) as first post-crash flight to verify camera/gimbal health before committing to a full grid.*

---

## Conclusions

Higher-level truths distilled from the experiments so far.

1. **Tighter boundaries can produce better reconstruction than wider ones.** ODM's `auto_boundary` derives a boundary from point cloud density, not camera positions -- for this scene it produced a ~180x180 m extent covering the entire flight area, roughly 4x the bounding box of the manual house-2 boundary (~84x84 m). The wider boundary performed worse on every metric: fewer reconstructed shots, worse GPS accuracy, and previously well-anchored images destabilized with 14-38 m displacements. The manual house-2 boundary appears near-optimal for this scene -- wide enough to include useful context around the house, narrow enough to exclude distant trees and terrain that introduce matching noise. "Include everything" is not a safe default; boundary tuning matters.

2. **Ultra-quality features and high-quality point cloud are feasible at this dataset size.** With ~446 input images at 1 cm GSD, `feature-quality: ultra` + `pc-quality: high` + `min_num_features: 30000` + `use-3dmesh: true` completes in 50-70 minutes on 32 cores with 32 GB RAM (house, house-2). The uncrop run used a 47 GB system but the same settings completed on 32 GB for the boundary-constrained runs. There is no reason to use lower quality settings for datasets of this scale.

3. **Per-shot GPS displacement and dropped-image maps are the most informative diagnostics.** Raw aggregate stats (GPS ce90, reprojection error) can be misleading -- house-2 has the best visual result but worse ce90 than house. Plotting each shot's displacement from its original GPS position immediately reveals which images are pulling the model (up to 20+ m off) and where the reconstruction is unstable. Dropped-image maps show spatial clustering (NW edge, over the problem north wall) that aggregate drop counts hide. Both are generated by `polisher/facts/analyze_odm_reconstruction.py`.

4. **Autofocus on treetops is a systematic problem for photogrammetry in wooded scenes.** Autofocus picks the highest-frequency signal (twigs at canopy level), leaving ground features -- which are more useful for matching -- slightly soft. This compounds with bare leaf-litter (low-contrast ground) and directional winter lighting to produce poor matching in tree-dominated areas. Static focus set to ground distance (~flight AGL) would be the single biggest collection improvement.

5. **Snow cover and diffuse lighting dramatically improve matching in wooded areas.** 02-16 (snow + overcast) matched 379/380 in exactly the same terrain where 02-21 (bare ground + direct sun) struggles. The trees are identical between collections; the difference is ground texture and lighting. Snow provides high-contrast features that remain matchable even when slightly defocused; diffuse lighting eliminates shadow-boundary parallax. These are the dominant variables, not flight speed or overlap.

6. **Three distinct failure modes by area, each with different root causes.** SE = displacement (terrain drops 15-26 m, doubling AGL and worsening focus/GSD; low-texture ground). NW = drops (flight perimeter + turnaround gimbal instability; terrain is flat). NE/north wall = drops + high-displacement survivors on level ground with normal AGL (autofocus + poorly anchored images pulling geometry). Processing parameter changes alone cannot fix SE or NW; the north wall is the most promising target for reprocessing with image exclusion.

7. **ODM's "area" statistic is reconstructed camera footprint, not boundary or orthophoto area.** The `processing_statistics.area` field in `stats.json` measures the ground area covered by successfully reconstructed cameras. This is why uncrop (13947 m2) < house-2 (14959 m2) despite uncrop's boundary being 4x larger: uncrop reconstructed fewer cameras and covered less ground. Do not use this metric to compare boundary sizes -- compare the actual boundary geometries or orthophoto extents instead.

---

## Open issues

Each topic tracks confirmed findings, current theories, disproven ideas, and next steps. A topic closes when confirmed theories fully explain the observed behavior.

### North wall geometry (corner ~2 m off)

**Confirmed:**

- **Autofocus locks onto treetops, not ground.** Spot-check of NE/north-wall images confirms focus is consistently on the tops of trees (twigs = highest-frequency signal in frame) rather than the ground. Ground features -- including human-made structures visible in orbit and some grid images -- are slightly soft. One orbit image (DJI_0044 area) also shows possible extra blur in the top-right corner, possibly contamination on the lens. Autofocus changed mid-flight (tap-to-focus, manually picked spots). Confirmed across SE, NW, and NE images from both grid and orbit.
- **High-displacement survivors are net-negative and likely pulling the corner.** DJI_0820/0821 were dropped in house but recovered in house-2 with 14-18 m displacements, landing right near the north wall. Uncrop made them worse (22-26 m). The mechanism is understood: low `resection_min_inliers` (10) lets poorly anchored images through. Interventional test (exclude images or raise threshold) not yet run, but observational evidence is strong across three runs.

**Current theories:**

- **The north wall problem is fundamentally occlusion, not just degradation.** Unlike the SE corner (where trees are *above* the ground target and degrade features through parallax/focus), the north side has trees *between* the camera and the house wall. The wall is physically obstructed from grid images, not just defocused. Static focus and higher altitude would help the SE (sharper ground features, less parallax) but would NOT help the north wall because the physical obstruction remains. This means the north wall specifically needs either: (a) close-orbit imagery from below the canopy winning over bad grid images in reconstruction, or (b) excluding grid images with canopy contamination from the north-wall area, or (c) the frozen-skeleton approach where the wall geometry is constrained by a prior.
- **Close-orbit autofocus behavior is unclear and may not be helping.** The close-orbit is within the tree line, pointed at the house, so autofocus *should* lock onto the house wall (largest, nearest high-contrast target). But DJI/DroneLink autofocus behavior is not well understood -- it's unclear whether it fires once at mission start, continuously, on each waypoint, or some other pattern. If AF locks onto a nearby trunk or branch rather than the house behind it, the close-orbit images would also have degraded wall features. The DJI_0044 blur observation is consistent with this. Spot-checking close-orbit focus specifically (not just grid images) would clarify.
- **Nearfield parallax (cross-ref Reconstruction quality).** If the nearfield parallax theory is correct, the north wall grid images are built on unstable twig features at canopy height rather than ground/structure features. The north side has dense tree cover between camera and wall, making this worse than other sides. Higher altitude or DEM-guided feature masking might improve north-wall geometry even without new close-orbit images.

**Weakened:**

- ~~Insufficient close-orbit coverage on the north side specifically.~~ Originally theorized that manual waypoints within the tree line might have uneven coverage. However, evidence increasingly points to bad grid images (high-displacement survivors) overriding good close-orbit data, not missing close-orbit images. Close-orbit images are NOT dropped in any run. The problem may be that ODM uses the badly-placed grid cameras for the north wall geometry because they pass the lenient resection threshold. Not fully disproven but weakened as the primary explanation.

**Disproven:**

- ~~Wider boundary / include all camera positions~~ -- tested by uncrop (auto_boundary, 179x182 m extent, 4x house-2). Result: worse on every metric. The north wall problem is not caused by boundary exclusion.
- ~~No technical image faults~~ -- spot-check of SE and NE images reveals autofocus is consistently on treetops rather than ground, making ground features soft. This IS a technical fault, just a systematic one (autofocus behavior) rather than per-image.

**Next steps:**

- [x] **(b) Spot-check** problem images for focus/blur/exposure. **Done.** Focus is consistently on treetops, not ground. Ground features are soft. One possible lens contamination. See Learnings for details.
- [ ] **(e/g) Reprocess** with house-2 boundary but exclude known high-displacement images (DJI_0820, DJI_0821, DJI_0841, DJI_0902, etc.), or raise `resection_min_inliers` to 50-100 to auto-reject poorly anchored images. Tests whether removing noisy cameras fixes the corner.
- [ ] **Future flight: set focus statically to ground distance** rather than autofocus. Autofocus picks the highest-frequency signal (twigs at treetop level), leaving the more useful ground features soft. Manual focus at flight altitude (~25 m AGL) would sharpen ground while only slightly softening treetops. Investigate DJI/DroneLink focus lock options.
- [ ] **Spot-check close-orbit images for focus target.** Grid image autofocus is confirmed as locking onto treetops, but close-orbit images (within tree line, pointed at house) have not been specifically checked. If AF fires continuously and locks onto a nearby trunk or branch rather than the house wall, close-orbit images would also have degraded wall features. DJI/DroneLink AF behavior (one-time vs continuous vs per-waypoint) is not well documented. Check a few close-orbit images to see where focus actually landed.
- [ ] **SketchUp shape prior (cross-ref Reconstruction quality).** A rough extrusion model of the house used as a soft bundle adjustment constraint could directly prevent the ~2 m corner displacement by penalizing gross wall curvature. Would not require better input images -- purely a processing improvement on existing data.

### Twig texture projection onto walls

**Confirmed:**

- Tree texture projection is a **texturing** issue, not point classification. The geometry/point cloud is correct; ODM's texture selection picks pixels where twigs are between camera and wall surface.
- Close-orbit images (captured within tree line) improved texture on most sides vs 02-16, which had twigs on **all** sides. But the north wall is still affected.

**Current theories:**

- **`texturing-data-term: gmi` prefers twigs over walls.** ODM defaults to gradient magnitude image, which scores high-contrast twig-against-wall pixels highly. Switching to `area` (prefer larger continuous patches) should deprioritize twig pixels.
- **Close-orbit images not selected as texture source for the north wall.** The close-orbit images exist but ODM may prefer grid images (shot through branches) due to view-angle weighting or other texture selection parameters.
- **Auto-exposure variation causing soupy orthophoto.** Sunny white balance + auto exposure in strong directional winter light could produce exposure jumps between passes. Worth checking if the orthophoto "soupiness" in house-2 correlates with pass boundaries.

**Disproven:**

(none yet -- no texturing experiments run)

**Next steps:**

- [ ] **(c) texturing-data-term: area** run. House-2 boundary + same settings, single change vs house-2. Not exposed in WebODM UI; requires CLI or config edit.
- [ ] Investigate whether ODM's texture selection output reveals which source images are used per mesh face.

### Reconstruction quality (drops, displacement, stability)

**Confirmed:**

- **High-displacement survivors are net-negative.** Strongly confirmed by uncrop: images well-placed in house-2 (DJI_0901: 0.3 m, DJI_0862: 0.5 m) exploded to 24-38 m displacements. Low `resection_min_inliers` (10) lets poorly anchored images through. Uncrop had 209 shots >1 m vs 158 in house-2, 75 in house, 54 in 02-16.
- **Boundary affects which images drop and where, but is not the sole driver.** Uncrop dropped more (54) than house-2 (46) despite no boundary. The wider context likely introduces ambiguous matches.
- **Dropped-image and GPS displacement maps are the most revealing diagnostics** (see Conclusion 3). Generated by `polisher/facts/analyze_odm_reconstruction.py`; see `reconstruction_status.png` and `dropped-images.md` in each map doc.

**Current theories:**

- **`min_num_features: 30000` is an independent improvement** over the default 10000, but confounded with boundary change in house-2 (563k initial points vs 214k, 21 more shots reconstructed). Would need a run with house-tight boundary + 30000 to isolate. See also the "mixed blessing" theory below about the interaction with lenient filtering.
- **Boundary size has a "sweet spot."** Confirmed by three runs: tight (house) < optimal (house-2, ~84x84 m) > wide (uncrop, auto, ~180x180 m). See Conclusion 1. Too tight clips useful context; too wide introduces noise.
- **Turnaround images are fragile, especially in NW.** Row endpoint images drop at 31% vs 7.7% mid-segment in house-2. NW turnarounds are worst (67% dropped). DroneLink warned about gimbal movement limits during sharp turns, which may cause motion blur or frame instability at row endpoints. However, SE turnarounds only drop at 10% -- SE's problem is displacement (28% of mid-segment images >2m), not drops. Filtering turnarounds alone would not fix SE but might help NW.
- **SE corner is low-matchability due to three compounding factors.** (1) Autofocus locks onto treetops, leaving ground features soft; (2) bare leaf-litter ground is low-contrast even when in focus; (3) strong directional lighting creates intra-pass parallax issues. 02-16 (snow + diffuse light) matched 379/380 in the same area because snow provides high-contrast ground features that remain matchable even when slightly defocused. Static focus at ground distance + snow/overcast conditions would likely fix the SE corner entirely. Both crosshatch passes are equally affected, confirming this is spatial, not flight-direction or camera related.
- **Intentional slow shutter speed could selectively blur nearfield features.** If nearfield parallax is the problem, an intentionally slow shutter would cause more motion blur for close objects (which have greater apparent velocity) than for the ground (further away, less apparent motion). This would optically suppress the twigs' feature attractiveness while keeping ground features relatively sharp. The tradeoff is overall image quality degradation; the shutter speed would need to be tuned to blur objects at canopy distance (~10 m) while keeping ground (~25 m) acceptably sharp. At 20 km/h (~5.6 m/s) and 1 cm GSD, ground-level blur at 1/100 s would be ~6 pixels while canopy-level blur would be ~14 pixels. **Highly speculative** -- needs careful calculation and likely a test flight before committing.
- **DEM-guided feature selection could filter out canopy features before matching.** Using a publicly available mapping DEM (e.g. USGS 3DEP, state lidar) as a prior for ground elevation, features could be reprojected to approximate 3D positions and those significantly above ground level downweighted or excluded before the matching stage. This would force the matcher to use ground-level and structure-level features, avoiding the nearfield parallax problem entirely. Features selected this way would also be more likely to persist across collection days (ground and structures vs. ephemeral twigs). Implementation could range from a pre-processing mask (easier: generate a "canopy probability" mask per image using the DEM + camera pose, suppress features in high-canopy zones) to a modification of OpenSfM's feature selection (harder: fork required). **Untested concept** -- feasibility depends on DEM resolution vs. canopy variability.
- **Nearfield parallax may be the dominant matching problem in wooded scenes (unifying theory).** At 25 m AGL with ~15 m trees, treetops are ~10 m from the camera while the ground is 25 m away. Parallax (apparent motion between adjacent frames) scales as 1/distance, so treetop features have ~2.5x the parallax of ground features. This creates several compounding problems: (a) feature matching must account for much larger pixel displacements for nearfield objects; (b) twigs at varying canopy heights form a "parallax soup" with no coherent depth plane; (c) wind moves twigs between shots (even 2 s apart), adding noise to nearfield features; (d) nearfield features don't persist across collection days (growth, breakage, wind position). If true, this theory predicts: higher altitude reduces the parallax ratio and may push twigs below feature-detection resolution; higher overlap reduces absolute parallax for all objects; and the 02-16 snow success may partly be because wet, poorly-lit twigs were weak features while high-contrast snow dominated matching. **Testable** -- see feature-height analysis and altitude/overlap experiments in Next steps.
- **Track length filtering may naturally reject twig features (cheapest nearfield-parallax mitigation).** OpenSfM builds feature tracks -- chains of the same feature matched across multiple images. A twig with extreme nearfield parallax or wind movement would match inconsistently, producing short tracks (2-3 images). A fallen log, path, or structural edge on the ground would match reliably across many overlapping images, producing long tracks. Existing data supports this: 02-16 (snow, good matching) had average track length 5.14; house (poor) had 3.61; uncrop (worst) had 3.35. The good run's features persisted across more images. OpenSfM's `min_track_length` defaults to 2; raising it (e.g. to 4-5) would force features to survive across more views to contribute, preferentially keeping stable ground features and rejecting transient canopy features. Combined with `min_num_features: 30000` (plenty of candidates to filter from), this could be a zero-cost way to bias toward ground features without any external data. **Testable on existing data** with a reprocessing run. More aggressively, `resection_min_inliers` (currently 10) could also be raised to reject images that only match on short-lived features.
- **Active probing for persistent features (extends track-length filtering).** Rather than just preferring long-track features when they happen to appear, actively search for features likely to produce long tracks. This could be a two-pass approach: (1) initial detection + matching + track building; (2) characterize long-track features (where in image, local texture signature, height above DEM); (3) re-detect features biased toward those characteristics, or densify around known long-track feature locations. With 30k features per image there is likely already coverage of ground features among the candidates, but this is a guess -- the feature height analysis (see above) would confirm whether we're detection-limited or selection-limited. **Concept only** -- the simple min_track_length raise should be tried first.
- **Geometric priors as soft constraints in bundle adjustment.** Rather than only filtering features (pre-processing), geometric models could be injected directly into the bundle adjustment as weak cost terms. Three progressively stronger variants:
  - **(a) DEM ground-plane prior:** Add a cost term penalizing reconstructed 3D points that are far from a known ground DEM (e.g. USGS 3DEP). This would reduce overall tilt drift, anchor the ground plane, and gently discourage canopy-height points from dominating the solution. The prior should be very weak (large covariance) since the DEM is approximate and many legitimate points (rooflines, structures) sit above it.
  - **(b) Structural shape prior:** Use a rough CAD model (e.g. SketchUp extrusion of the house footprint + roof pitch) as a soft prior encouraging wall planarity and general building shape. This would NOT clamp the reconstruction to the model -- details, vegetation, garden structures, etc. would still be free -- but would penalize gross wall curvature or corner displacement. Covariance would be set loose enough that the optical data dominates for detail, but tight enough to prevent the ~2 m north-wall corner error.
  - **(c) Bootstrapped reconstruction prior:** Once a good partial reconstruction exists (e.g. the lawn, the house from the south side, or trunk/ground features from the woods), feed it back as a progressively stronger prior for future runs or for reprocessing with additional images. Each iteration tightens the constraint as confidence grows.
  - **(d) Frozen-skeleton localization (strongest form, essential for leafed-in canopy).** Freeze an existing skeleton's 3D points entirely and resect new cameras against them without updating the skeleton geometry. New images don't need to match *each other* well -- they only need enough matches against historical ground features already triangulated in the skeleton. This is localization against a known map, not independent reconstruction. Critical distinction: ODM's `--align` is post-hoc rigid ICP on an *independently completed* reconstruction (useless if the new reconstruction is garbage); Time-SIFT processes all epochs in a shared block but treats all images equally (doesn't freeze the skeleton). Frozen-skeleton localization requires **asymmetric BA** in Ceres (fix skeleton point variables, optimize only new camera poses + optionally new points anchored to the skeleton). May be essential for year-round operation: leaf-in prevents from-scratch reconstruction ~6 months/year, but fleeting glimpses of known ground features through canopy gaps could be enough to place cameras if they're matching against a frozen winter skeleton rather than against each other.
  OpenSfM uses Ceres Solver for bundle adjustment, which supports custom cost functions, so adding point-to-surface distance terms is architecturally feasible. The open question is how to set covariance weights relative to GPS priors (~2-5 m) and reprojection error terms -- too strong and the prior overrides real measurements, too weak and it has no effect. **Untested concept requiring OpenSfM modification**, but the framework supports it.
- **02-16 vs 02-21 feature contrast hypothesis (extends snow/lighting theory).** The snowy 02-16 run may have succeeded not only because snow is high-contrast, but because snow *masked* low-level canopy noise while the twigs themselves were wet, dark, and poorly lit (low feature attractiveness). By contrast, 02-21's dry twigs under direct side-lighting appeared bone-white and high-contrast -- the strongest features in the frame -- while the bare leaf-litter ground was uniform low-contrast brown. If the feature detector preferentially selected bright dry twigs on 02-21, the reconstruction would be built on unstable nearfield features instead of stable ground features. **Testable** by examining selected feature pairs and their reprojected heights in both runs (requires preserved opensfm/ directories).
- **`min_num_features: 30000` may be a mixed blessing without stricter filtering.** House-2 (30k features) has 158 shots >1 m displacement vs 75 in house (10k features). More features means more canopy matches squeaking through the permissive `resection_min_inliers: 10`. The improvement in reconstructed shots (400 vs 379) may have come at the cost of more high-displacement survivors. The optimal combination is likely 30k features (for ground-feature coverage) paired with strict quality gates (`min_track_length: 4-5`, `resection_min_inliers: 50+`) -- high detection, aggressive filtering. Currently we have high detection and lenient filtering, which is potentially the worst combination for a canopy-dominated scene.
- **02-16 may have selected an entirely different feature population, not just matched better.** 02-16 used default 10k features, worse quality settings, no close-orbit, and still produced the best displacement stats (median 0.52 m) and longest tracks (5.14). If the nearfield parallax theory is correct, the snow/overcast conditions didn't just improve matching -- they fundamentally changed which features the detector *selected*. Wet dark twigs = low descriptor response; bright snow = high descriptor response. The feature detector may have naturally preferred ground features without any configuration changes, because the scene conditions made ground features the strongest signal. The feature height analysis would show whether 02-16 and 02-21 selected from the same population of features (at different quality) or from completely different populations (ground vs canopy). This distinction matters: if it's a different population, then collection conditions are the dominant control and processing interventions are secondary.

**Disproven:**

- ~~Boundary clipping is the sole cause of dropped images~~ -- uncrop dropped more with no boundary (54 vs 46).
- ~~Wider boundary = better reconstruction~~ -- uncrop (auto_boundary, 4x house-2 area) was worse on every metric.

**Next steps:**

- [ ] **(e) Raise `resection_min_inliers`** to 50-100 to auto-reject poorly anchored images. Not an ODM flag; requires editing `opensfm/config.yaml`. Overlaps with north wall task (e/g).
- [ ] Preserve `opensfm/` directory on next run to get per-shot reconstructed feature counts (currently not in exported ODM output on NAS).
- [ ] Consider a run with house-tight boundary + `min_num_features: 30000` to isolate the feature improvement from the boundary change.
- [ ] Investigate whether filtering turnaround images (first/last 1-2 per row) reduces NW drops without losing important coverage. Could combine with resection_min_inliers increase.
- [ ] **Feature height analysis between 02-16 and 02-21.** If we can preserve the `opensfm/` directory from runs of both datasets, examine the selected feature pairs and their reprojected heights. Did 02-16 (snow) select mostly ground-level features while 02-21 selected canopy-level features? Would directly test the nearfield parallax and feature-contrast hypotheses. Requires reprocessing with `--opensfm-keep` or equivalent to retain intermediate data.
- [ ] **Higher altitude + higher overlap test flight.** If nearfield parallax is the dominant problem, increasing altitude (e.g. 40-50 m AGL) reduces the parallax ratio (treetops at 25-35 m vs ground at 40-50 m: ratio ~1.4-1.6x instead of 2.5x at 25 m) and may push twigs below feature-detection resolution. Increasing overlap reduces absolute inter-frame parallax for all objects. Both also apply to the large-scale collection mission (higher altitude reduces total shots and processing time). Tradeoff: worse GSD.
- [ ] **Downsample existing 02-21 images to isolate resolution vs parallax.** Higher altitude conflates two effects: (1) lower pixel resolution (twigs shrink, possibly below feature detection threshold) and (2) flattened parallax ratio (nearfield motion more similar to ground). Downsampling existing images by 2x simulates the resolution loss of 50 m AGL (~2 cm GSD) while preserving the original 25 m AGL parallax baked into the pixel data. Comparing downsampled-reprocessed vs house-2 baseline isolates the resolution effect. If a subsequent real 50 m flight also improves, the delta between that and the downsampled result is the parallax contribution. **No flight required** -- can run immediately on existing data.
- [ ] **Intentional slow shutter test** (speculative). Fly a test pass at ~1/100 s and compare feature detection density at ground vs canopy height to a normal 1/400 s pass. Would validate or reject the selective-blur theory cheaply before committing to a full collection.
- [ ] **DEM-guided feature masking prototype.** Obtain USGS 3DEP or state lidar DEM for the site. For each image, project a ground-elevation surface using camera pose + DEM to create a "canopy probability" mask. Suppress or downweight features detected in high-canopy zones before feeding to OpenSfM. Test on existing 02-21 images to see if it improves matching without a new flight.
- [ ] **Image pair alignment viewer (debug tool).** Take two allegedly-nearby images, rotate both to the same facing direction (nadir-corrected), and display them switching back and forth. With correct alignment this should show a smooth translation-only shift; a misaligned pair would jump to different terrain. Useful for visually diagnosing which image pairs are failing to match and why.
- [ ] **Raise `min_track_length` (cheapest test of nearfield parallax theory).** Reprocess 02-21 with house-2 boundary + `min_track_length: 4` or `5` (default 2) in OpenSfM config. If the nearfield parallax theory is correct, this should preferentially keep ground features (long tracks) and drop twig features (short tracks), improving matching stability especially in the SE and NE. Combine with existing `min_num_features: 30000` to ensure enough candidates survive the filter. Compare track length distribution, displacement stats, and dropped images to house-2 baseline. This is the **cheapest possible test** of the nearfield parallax theory -- no new flight, no code changes, just a config parameter.
- [ ] **Geometric priors in bundle adjustment (research).** Investigate adding soft geometric constraints to OpenSfM's Ceres-based bundle adjustment: (a) DEM ground-plane prior, (b) SketchUp house extrusion as shape prior, (c) bootstrapped reconstruction prior from earlier runs. Key research question: how to set covariance weights relative to GPS and optical terms. Start by reading OpenSfM's reconstruction code to understand the existing cost function structure and where point-to-surface terms could be added.

### Seasonal canopy leaf-in and collection viability

**Confirmed:**

(none yet)

**Current theories:**

- **Full leaf canopy may make grid-based photogrammetry of the ground unviable in wooded areas.** Bare twigs are thin and partially transparent to the camera at many angles; a leafed-in canopy is an opaque, continuously shifting barrier. Even with near-zero wind, leaves shift enough between frames (2 s interval at minimum) to destroy feature consistency. All current analysis is from bare-canopy winter collections. Green tips were already visible on twigs at the time of the late-Feb crash, so the window for bare-canopy collection may be closing.
- **Video capture with intelligent frame selection may be the key enabler for leafed-in conditions.** Switching from 12 MP stills (2 s minimum interval) to 4K video (30 fps = 0.033 s interval) would allow post-hoc selection of frames where gaps in the foliage expose the ground. This is qualitatively different from still capture: instead of hoping a still coincides with a gap, you can search a continuous stream for the best visibility. Tradeoffs: 4K is ~8.3 MP (30% resolution loss), H.264/H.265 compression degrades fine texture detail (harmful for already-weak ground features), rolling shutter in video mode adds geometric distortion, and GPS metadata is less precise (~1 Hz SRT vs per-frame EXIF). For grid collection, stills likely remain superior in bare-canopy conditions; video may become essential once leaf-in makes still-frame ground visibility unreliable.
- **Higher altitude may help by looking "through" more canopy gaps.** At nadir, the camera sees through the canopy wherever there's a vertical gap. Higher altitude means a narrower cone of view per pixel, so each pixel integrates less canopy at oblique angles. But this is speculative and may be a small effect compared to the opaque coverage of a full canopy.
- **The close-orbit (within tree line, low altitude) may become the only reliable way to capture the house in summer.** Below the canopy, leaves are not between camera and subject. But the flight path is constrained by tree trunks and branches, and the crash risk is higher.
- **Seasonal "skeleton" collection strategy.** At the limit, the bare-canopy window (roughly Nov-Mar) may be the only time we can reconstruct from scratch with full ground coverage. Summer collections would then align into the winter skeleton reconstruction -- updating point clouds and textures with current imagery but not attempting to solve geometry independently. The winter reconstruction becomes the persistent structural prior; summer collections add seasonal detail (leaf color, garden state, snow/ice) and detect changes (construction, drainage work, tree removal) without needing to re-derive the underlying geometry. This is a specific instance of the bootstrapped reconstruction prior concept, driven by the physical constraint that the canopy makes independent reconstruction impractical for ~6 months of the year.

**Disproven:**

(none yet)

**Next steps:**

- [ ] **Determine the bare-canopy collection window** for this site (roughly Nov-Mar in western PA, but varies by species). Note leaf-in progress on each flight.
- [ ] **Test video capture on a close-orbit** as a lower-risk experiment (slow speed, less rolling shutter, closer to subject so compression artifacts matter less). Compare frame-extracted reconstruction quality to still-capture close-orbit.
- [ ] **Investigate DJI video quality settings** (bitrate, I-frame interval, D-Log/D-Cinelike for flat color profile that preserves detail). Higher bitrate and shorter GOP (more I-frames) reduce compression impact on feature matching.
- [ ] **Consider leaf-in as a forcing function** for the DEM-guided feature masking and higher-altitude strategies. If ground visibility is intermittent, intelligent frame selection + DEM-aware feature filtering may be the combination that makes summer collection viable.

### Barometric altitude drift / tree collision

**Confirmed:**

(none yet)

**Current theories:**

- **Warm-sensor barometric drift.** Drone was brought from warm indoors (~70 F) into ~40 F damp air and launched quickly (routine is fast). The barometric pressure sensor would have been reading warm-air pressure at launch, then cooled rapidly in flight. As the sensor cooled, it would read increasing pressure (cold air is denser), which the flight controller interprets as descending -- causing it to *not* climb enough or to actively descend to maintain the "altitude" reading. This would produce a systematic low bias that grows over the first few minutes of flight. Previous flights were in colder weather with more setup time, allowing the sensor to equilibrate before launch.
- **Approaching weather front.** Heavy rain started within minutes of the crash. A dropping barometric pressure (low-pressure system moving in) would cause the drone to read lower-than-actual pressure at ground level but have calibrated against the higher launch-time pressure, making it believe it is higher than it actually is. This effect compounds with the warm-sensor drift. However, pressure was presumably already low at launch time, so the delta during the short flight may have been small.
- **Inaccurate terrain model in flight plan.** DroneLink plans altitude based on a terrain model (SRTM or similar). If the model underestimates tree canopy height or local terrain features, the planned altitude could route through canopy. The first near-miss (turnaround, manually raised) suggests the plan itself may have had marginal clearance.

**Disproven:**

(none yet)

**Next steps:**

- [ ] **Replace damaged prop blades.** At least two shattered; inspect remaining blades for cracks or nicks. Buy spares to have a full set of replacements on hand.
- [ ] **Post-crash camera/gimbal calibration check.** First flight after repair should assess whether camera calibration has changed (impact could shift lens relative to sensor, alter gimbal alignment, or crack UV filter). Compare EXIF focal length and any in-flight calibration readouts to pre-crash values. If possible, shoot a known target (checkerboard, building corner) and compare to pre-crash images.
- [ ] **Short targeted test flight as first post-crash mission.** Fly just the close-orbit (which we wanted to test in isolation anyway) rather than a full grid. This limits risk, tests camera/gimbal health, and produces a useful comparison dataset (close-orbit only vs close-orbit + grid). Fly at a conservatively higher altitude or in an open area first to verify altitude hold.
- [ ] **Barometric equilibration protocol.** On future flights, power on the drone outdoors and wait 3-5 minutes before launching to let the barometric sensor equilibrate to ambient temperature and pressure. Note ambient temperature and weather trend in the flight log.
- [ ] **Verify DroneLink terrain model accuracy.** Compare the planned flight altitudes to actual tree canopy heights in the collision area using the existing DSM from the uncrop run. If the terrain model (SRTM) significantly underestimates canopy height, add a safety margin to planned AGL or switch to a higher-resolution terrain source.
- [ ] **Check blade balance after replacement.** Mismatched or poorly balanced replacement blades can cause vibration that affects camera sharpness and gimbal stability. Verify all blades are from the same batch/manufacturer.

---

## Planned next steps

Prioritized checklist. Details and rationale in Open issues above.

- [x] Evaluate house-2 (looser lasso). Result: best so far, usable except north wall.
- [x] **(a) Wider boundary** (uncrop). Result: worse on every metric.
- [x] **(b) Spot-check** problem images for focus/blur/exposure. **Done.** Autofocus locks on treetops; ground features soft. Snow + diffuse lighting on 02-16 explain its superior matching. Three distinct failure modes by area (SE, NW, NE). See Learnings.
- [ ] **(c) texturing-data-term: area** run (Twig texture)
- [ ] **(e/g) Cleaner image set** -- exclude bad images or raise resection_min_inliers (North wall geometry, Reconstruction quality)
- [ ] **Post-crash recovery:** replace blades, buy spares, calibration check flight (Immediate)
- [ ] **Short close-orbit-only test flight** as first post-crash mission -- tests camera/gimbal health and produces useful comparison data (Immediate / Collection)
- [ ] **Establish barometric equilibration protocol** for future flights (Collection)
- [ ] **Future flight: static focus at ground distance**, investigate DJI/DroneLink focus lock and repeatable focus-setting workflow (focus peaking, magnification). Eyeballed focus at ~2/3 of range was sharpest at 25 m but is not repeatable. (Collection)
- [ ] **Downsample existing 02-21 images by 2x** and reprocess -- isolates resolution effect from parallax effect, no flight needed (Diagnostic)
- [ ] **Future flight: higher altitude + higher overlap** to test nearfield parallax theory; compare to downsample result to isolate parallax contribution (Collection)
- [ ] **Shutter speed analysis:** calculate minimum shutter for acceptable blur at planned speed/altitude/GSD; consider whether intentional slow shutter for nearfield suppression is viable (Collection)
- [ ] **Feature height analysis** between 02-16 and 02-21 runs (requires preserved opensfm/ dirs) (Diagnostic)
- [ ] **Raise `min_track_length`** to 4-5 in OpenSfM config -- cheapest test of nearfield parallax theory (Processing, config-only)
- [ ] **DEM-guided feature masking prototype** using USGS 3DEP or state lidar (Processing)
- [ ] **Image pair alignment viewer** debug tool (Tooling)
- [ ] **Geometric priors in bundle adjustment** -- DEM ground prior, SketchUp shape prior, bootstrapped reconstruction prior (Research / OpenSfM modification)
- [ ] Backfill 02-21 imageset docs (issue #343)
- [ ] Backfill uncrop map doc and run data collection scripts (deferred)

---

## Summary comparison table (run records)

Run `polisher/.venv/bin/python polisher/facts/collect_odm_run_record.py` on each map dir (e.g. `/mnt/d/odm-maps/bond_ave-2026-02-16`, `.../bond_ave-2026-02-21-house`, `.../bond_ave-2026-02-21-house-2`) and paste the full output into each map doc. Then aggregate key metrics below for quick comparison across runs.

| Map | Area (m²) | Capture window | Total time | GSD (cm/px) | Reconstructed shots | Reproj. error (px) | GPS ce90 | Avg track len |
|-----|-----------|-----------------|------------|-------------|---------------------|--------------------|----------|---------------|
| [[odm-maps-bond_ave-2026-02-16]] | 15927 | 12:53-13:24 | 56m 2s | 1.09 | 379/380 | 1.47 | 0.70 | 5.14 |
| [[odm-maps-bond_ave-2026-02-21-house]] | 13887 | 12:10-12:30 | 51m 40s | 0.95 | 379/446 | 1.07 | 1.43 | 3.61 |
| [[odm-maps-bond_ave-2026-02-21-house-2]] | 14959 | 12:10-12:30 | 1h 8m 14s | 0.93 | 400/446 | 0.86 | 1.57 | ? |
| [[odm-maps-bond_ave-2026-02-21-uncrop/odm-maps-bond_ave-2026-02-21-uncrop]] | 13947 | 12:10-12:30 | 1h 5m 56s | 0.92 | 392/446 | -- | 2.43 | 3.35 |

*Filled from ODM run records. Uncrop reprojection error not available in stats output. House-2 track length not yet extracted. See each map doc for full run-record tables. Track length now tracked as a key metric -- longer tracks correlate with better reconstruction quality (see nearfield parallax theory).*

---

## Learnings

*Detailed observations and supporting data. See Conclusions for high-level takeaways and Open issues for current theories and next steps.*

- Tight crop around the house caused degenerate geometry where the box cut off the spa.
- house-2 is the best result so far -- much better than 02-16. The house itself is basically usable except for the north wall.
- house-2 changed **two things** vs house: looser boundary **and** min_num_features: 30000 (vs default 10000). Both intentional, but the min_num_features change wasn't noted in the doc until the run records were compared. The extra features gave 3x more detected features/image, 2.6x more initial points (563k vs 214k), and recovered 21 dropped shots (400 vs 379 reconstructed). We don't yet know which change contributed more.
- Both 02-21 runs also changed multiple settings vs 02-16: feature-quality ultra, pc-quality high, use-3dmesh true, in addition to the close-orbit images. These were deliberate quality improvements and we're keeping them, but it means the improvement from 02-16 to house/house-2 reflects many changes at once.
- The house-2 boundary is tighter than the outermost camera positions, but this turns out **not** to be the primary bottleneck. The uncrop run removed the boundary entirely (auto_boundary with a 179x182 m extent vs house-2's 84x84 m) and performed worse: fewer reconstructed shots (392 vs 400), worse GPS (ce90 2.43 vs 1.57), and images that were well-placed in house-2 became wildly displaced. House-2's manual boundary may actually be near-optimal: wide enough to include useful context around the house, narrow enough to exclude distant noise (trees, roads, property edges) that destabilizes bundle adjustment.
- Higher quality settings (feature-quality ultra, pc-quality high, use-3dmesh) are being kept, but comparing house to 02-16 suggests they didn't produce a better reconstruction on their own: house ended up with the same 379 reconstructed shots (from 66 more inputs), similar point count (198k vs 192k), worse track length (3.61 vs 5.14), and worse GPS residuals (ce90 1.43 vs 0.70). Only reprojection error improved (1.07 vs 1.47 px). The tight boundary likely ate whatever gains the quality settings provided. The real reconstruction jump came in house-2, from min_num_features + boundary.
- The problematic wall is the **north** wall (not eastern as originally noted): corner geometry ~2m off from actual, twigs projected onto texture.
- Camera positions: some bad poses on the north side were outside the boundary even in house-2. The uncrop run (auto_boundary, no manual clip) included all camera positions with a boundary 4x larger than house-2's, but the result was **worse**, not better. The problem is not simply that cameras were excluded.
- 02-16 had tree textures projected onto house on **all** sides -- not just one wall. 02-21 runs improved this substantially; the close-orbit images (within the tree line) may have helped.
- Tree texture projection is a **texturing** issue, not point classification: the geometry/point cloud is fine, but ODM's texture selection picks pixels where twigs are between camera and wall surface.
- Close-orbit was a deliberate attempt to provide wall imagery from within the tree line so ODM would prefer those images over grid images shot through branches. Included in both 02-21 runs.
- 02-21 flight had autofocus changed mid-flight (tap-to-focus enabled, manually picked spots) and auto exposure with sunny white balance in strong directional light. See [[imagesets-bond_ave-2026-02-21-flight]].
- Dropped shots: 02-16 lost 1/380; house lost 67/446 (15%); house-2 lost 46/446 (10%); **uncrop lost 54/446 (12%)** -- more than house-2 despite having no boundary constraint. Spatial analysis of dropped images (see `dropped-images.md` and `reconstruction_status.png` in each map doc directory):
  - Drops cluster heavily in the **northwest** quadrant: house 37/67 NW, house-2 28/46 NW. Western and northern grid edges are most affected.
  - **None of the close-orbit images were dropped outright** in any run. The drops are all grid/orbit edge images.
  - A cluster of dropped images in the mid-northeast in house-2 sits **directly over the problem north wall**. These are likely the images that would have constrained the reconstruction of that wall.
  - Exposure settings on dropped images are all normal (1/640-1/1000, ISO 100-110, f/1.7). This is a matching problem, not an image quality problem.
  - house-2 recovered 21 images vs house, mostly in NW (37->28) and NE (12->4).
  - The uncrop run dropped **more** images than house-2 despite no boundary. This disproves the theory that boundary clipping is the sole cause of dropped images. The wider reconstruction context likely introduces ambiguous matches that cause different images to fail.

![[fables/Datasets/odm-maps-bond_ave-2026-02-21-house/reconstruction_status.png]]
![[fables/Datasets/odm-maps-bond_ave-2026-02-21-house-2/reconstruction_status.png]]

- GPS errors are ~2x worse in 02-21 runs (ce90 1.4-1.6) vs 02-16 (0.70). Likely a symptom of dropped shots and boundary constraints distorting bundle adjustment, not an independent collection problem.
- Reprojection error improved across runs: 02-16 1.47 px -> house 1.07 px -> house-2 0.86 px. house-2's lowest error is consistent with it being the best visual result.
- **Per-shot GPS displacement analysis** (EXIF GPS position vs bundle-adjusted reconstructed position -- not inter-image delta; via `analyze_odm_reconstruction.py`):
  - **02-16:** median 0.52 m, mean 0.65 m, max 3.25 m. 54 shots >1 m, 5 >2 m, 1 >3 m. Well-constrained baseline.
  - **house:** median 0.61 m, mean 1.01 m, max 20.3 m. 75 shots >1 m, 26 >2 m, 11 >3 m. Top displacements (up to 20 m) all cluster on the **eastern edge** (~lon -80.041), even though no images were outright dropped there. These images are placed essentially at random and are net-negative.
  - **house-2:** median 0.85 m, mean 1.13 m, max 22.0 m. **158 shots >1 m** (vs 75 in house), 19 >2 m, 10 >3 m. DJI_0820 and DJI_0821, which were dropped in house but recovered in house-2, have 14-18 m displacements near the north wall (lat 40.5327). These recovered images are almost certainly pulling the north wall reconstruction off rather than helping it.
  - **uncrop:** median 1.03 m, mean 1.81 m, max 38.0 m. **209 shots >1 m**, 55 >2 m, 24 >3 m. Substantially worse than every other run. Images that were well-placed in house/house-2 (e.g. DJI_0901: 0.3 m in house, 1.0 m in house-2) exploded to 14-38 m displacements. The wider reconstruction actively destabilized previously well-anchored images.
  - **Trend across runs:** displacement quality degrades as boundary gets wider: 02-16 (no boundary, small input set) > house (tight) > house-2 (loose) > uncrop (auto/huge). The exception is visual quality, where house-2 looks best despite worse displacement stats than house. This suggests a "sweet spot" for boundary size.
  - **High displacement count is a warning sign** independent of dropped images: images that survive reconstruction but are placed 5-20 m from their GPS position with only a handful of inlier matches are effectively noise. The low resection_min_inliers (10) lets them in.
- **Grid flight pattern (02-21-grid):** The 332-image grid imageset is a crosshatch: two lawnmower passes at 90 degrees, flown back-to-back with no landing in between. DJI filename numbering wraps (0702->0999 then 0001->0034) because the memory card folder rolled over mid-flight.
  - **Pass 1 (N-S rows):** 12 segments, 164 images, DJI_0702 to DJI_0865, 12:14:23-12:21:51. Rows run roughly north-south with east-west transits.
  - **Pass 2 (E-W rows):** 9 segments, 167 images, DJI_0866 to DJI_0034, 12:22:00-12:28:51. Rows run roughly east-west with north-south transits.
  - Each row has ~14-19 images at ~2s intervals. Turn-arounds are ~9-11s gaps.
  - **SE problem images come from both passes:** 9 from Pass 1 (segments 7-11, the easternmost N-S rows at their southern ends) and 12 from Pass 2 (segments 12-17, the southernmost E-W rows at their eastern ends). The problem is spatial (SE corner terrain), not pass-specific or temporal.
- **Spot-check of problem images (SE, NW, NE):** SE images (DJI_0806, 0902, 0841, 0860, 0901, 0862, 0937, 0904) all look broadly similar: dominated by black/white trees with strong directional lighting. Some have decent ground features (downed logs, etc.) but twigs are clearly the dominant attractors. NE/north-wall images (0817-0822, orbit 0043/0044) have plenty of good human-made features (structures, rooflines) that should match well. **Key finding: focus is consistently on the treetops, not the ground.** Autofocus picks the highest-frequency signal in the frame (twigs), leaving ground features slightly soft. One orbit shot (0044 area) shows possible extra blur in the top-right corner, possibly lens contamination. This is a systematic technical fault that degrades ground-feature matching everywhere, but is worst in tree-dominated areas where the ground is the only useful match target. Lighting was strong side-light (winter sun, lowering): trees almost white on sunny side, very dark on shadow side. Collection was centered on solar noon (12:14-12:28 EST, solar noon ~12:20 at 80W), but Feb 21 at lat 40.5N gives only ~39-degree solar elevation -- enough for tree-length shadows. Shadow movement over the 14-minute window is negligible (~0.5 deg). Since the camera looks down, the illumination pattern is the same regardless of flight direction (rotation-invariant features), so this does not specifically hurt cross-pass matching. The harder matching problem is intra-pass: adjacent parallel rows have lateral parallax across the shadow boundary.
- **Snow cover and diffuse lighting may be the key variables.** 02-16 matched 379/380 images (median displacement 0.52 m) in exactly the same area with the same flight plan and similar solar angle -- but had snow on the ground and was a cloudy, less windy day (diffuse lighting, no harsh shadows). By 02-21 a sharp thaw left bare leaf-litter under direct sun with strong directional shadows. Two compounding differences: (1) snow provides high-contrast, distinctive ground features visible through bare canopy, while leaf-litter is uniform low-contrast brown; (2) diffuse lighting eliminates the shadow-boundary parallax problem entirely. The SE corner problem may not be "too far into the woods" (02-16 disproves that) but "too far into the woods **without reliable ground features and under harsh lighting**."
- **Turnaround fragility analysis (house-2):** Images at row endpoints (first/last 2 images per segment) drop at 4x the rate of mid-segment images (31% vs 7.7%). But the effect is strongly spatial:
  - **NW turnarounds: 67% dropped** (16/24), NW mid-seg: 17% dropped. Worst quadrant by far for drops.
  - **SW turnarounds: 35% dropped** (7/20), SW mid-seg: 7%.
  - **NE turnarounds: 5% dropped**, avg disp 2.18 m. NE mid-seg: 5%, avg disp 0.92 m.
  - **SE turnarounds: 10% dropped**, avg disp 2.29 m, 5 >2m. **SE mid-seg: only 2% dropped, but 18 out of ~65 reconstructed (28%) have >2m displacement.** SE is a displacement problem, not a drop problem.
  - DroneLink warned about gimbal movement limits during turns, which may contribute to NW/SW drop rates. But SE's problem is that images get reconstructed with bad positions -- they pass the low resection_min_inliers threshold but lack enough reliable matches for accurate placement.
  - **Key distinction: NW = drops (terrain + turnarounds), SE = displacement (terrain matchability).**
- **Ground elevation under problem clusters (from uncrop DSM):**
  - **SE:** Ground drops 15-26 m below house level (301-312 m vs 327 m). AGL is 42-52 m instead of the intended ~25 m -- nearly double, degrading GSD and worsening the autofocus-on-treetops problem (focus locked at ~25 m, ground at 42-52 m).
  - **NW:** Essentially flat where DEM coverage exists (326-327 m, within 1 m of house). Most NW problem images are outside the DEM entirely (flight perimeter). NW drops are an edge-of-coverage / turnaround issue, not terrain-elevation driven.
  - **NE (north wall):** Level ground, all within 1-2 m of house elevation, AGL ~27 m. The north wall problem is NOT caused by terrain drop or increased distance. DJI_0858 is an outlier (316 m, +11 m drop) but it sits further south near the slope.
- **SE corner problem images (for manual review):** Cross-referencing displacement and drop status across house, house-2, and uncrop identifies images that are persistently problematic in the SE quadrant. Many images (0901, 0862, 0866, etc.) are well-placed in house/house-2 but have 14-38 m displacements in uncrop, confirming the wider reconstruction destabilizes them. DJI_0806 is dropped in all three runs. Source imageset: `2026-02-21-grid`.

| Image | house | house-2 | uncrop | Notes |
|-------|-------|---------|--------|-------|
| [DJI_0902](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0902.JPG) | 0.8 m | 14.7 m | **38.0 m** | Worst total displacement |
| [DJI_0841](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0841.JPG) | 0.9 m | **22.0 m** | 10.4 m | Severe in house-2 |
| [DJI_0806](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0806.JPG) | DROPPED | DROPPED | DROPPED | **Dropped in all 3 runs** |
| [DJI_0904](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0904.JPG) | DROPPED | 9.1 m | DROPPED | Dropped in 2/3 runs |
| [DJI_0860](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0860.JPG) | **20.1 m** | 1.7 m | 6.3 m | Wildly unstable across runs |
| [DJI_0901](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0901.JPG) | 0.3 m | 1.0 m | **24.1 m** | Fine in house/house-2, terrible in uncrop |
| [DJI_0862](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0862.JPG) | 0.5 m | 1.2 m | **23.4 m** | Same pattern as 0901 |
| [DJI_0937](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0937.JPG) | **16.8 m** | 0.9 m | 6.1 m | Bad in house only |
| [DJI_0866](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0866.JPG) | 0.5 m | 0.6 m | **21.5 m** | Bad only in uncrop |
| [DJI_0807](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0807.JPG) | 1.0 m | DROPPED | DROPPED | Dropped in 2/3 runs |

- **NW corner problem images (for manual review):** The NW quadrant has the highest drop rate of any area (67% of turnaround images, 17% mid-segment in house-2). All 15 worst images are dropped in all 3 runs. Mix of turnaround and mid-segment positions. All from `2026-02-21-grid`. Pass 1 images are from the first few N-S rows (westernmost); Pass 2 images are from the last few E-W rows (northernmost).

| Image | house | house-2 | uncrop | Pos | Notes |
|-------|-------|---------|--------|-----|-------|
| [DJI_0703](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0703.JPG) | DROPPED | DROPPED | DROPPED | turn | Pass 1, first N-S row |
| [DJI_0704](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0704.JPG) | DROPPED | DROPPED | DROPPED | turn | Pass 1, first N-S row |
| [DJI_0705](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0705.JPG) | DROPPED | DROPPED | DROPPED | turn | Pass 1, first N-S row |
| [DJI_0706](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0706.JPG) | DROPPED | DROPPED | DROPPED | turn | Pass 1, 2nd N-S row start |
| [DJI_0713](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0713.JPG) | DROPPED | DROPPED | DROPPED | mid | Pass 1, 2nd N-S row |
| [DJI_0731](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0731.JPG) | DROPPED | DROPPED | DROPPED | mid | Pass 1, 3rd N-S row |
| [DJI_0732](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0732.JPG) | DROPPED | DROPPED | DROPPED | mid | Pass 1, 3rd N-S row |
| [DJI_0733](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0733.JPG) | DROPPED | DROPPED | DROPPED | turn | Pass 1, 3rd N-S row end |
| [DJI_0991](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0991.JPG) | DROPPED | DROPPED | DROPPED | mid | Pass 2, 2nd-to-last E-W row |
| [DJI_0992](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0992.JPG) | DROPPED | DROPPED | DROPPED | turn | Pass 2, 2nd-to-last E-W row |
| [DJI_0995](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0995.JPG) | DROPPED | DROPPED | DROPPED | turn | Pass 2, 2nd-to-last E-W row |
| [DJI_0996](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0996.JPG) | DROPPED | DROPPED | DROPPED | mid | Pass 2, 2nd-to-last E-W row |
| [DJI_0997](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0997.JPG) | DROPPED | DROPPED | DROPPED | mid | Pass 2, 2nd-to-last E-W row |
| [DJI_0031](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0031.JPG) | DROPPED | DROPPED | DROPPED | mid | Pass 2, last E-W row |
| [DJI_0033](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0033.JPG) | DROPPED | DROPPED | DROPPED | turn | Pass 2, last E-W row end |

- **NE / north-wall problem images (for manual review):** The NE quadrant near the north wall has a mix of drops and high-displacement survivors. DJI_0817-0822 are consecutive grid images from the same N-S row cluster running right over the north side of the house (lat ~40.5325-40.5328, lon ~-80.0415). DJI_0820/0821 are the known high-displacement images previously identified as likely pulling the north wall corner off.

| Image                                                                                     | house      | house-2    | uncrop     | Pos  | Notes                            |
| ----------------------------------------------------------------------------------------- | ---------- | ---------- | ---------- | ---- | -------------------------------- |
| [DJI_0817](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0817.JPG)  | DROPPED    | DROPPED    | DROPPED    | mid  | **Dropped all 3 runs**           |
| [DJI_0822](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0822.JPG)  | DROPPED    | DROPPED    | DROPPED    | turn | **Dropped all 3 runs**           |
| [DJI_0819](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0819.JPG)  | DROPPED    | 5.0 m      | DROPPED    | mid  | Dropped 2/3                      |
| [DJI_0818](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0818.JPG)  | 2.2 m      | DROPPED    | DROPPED    | mid  | Dropped 2/3                      |
| [DJI_0820](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0820.JPG)  | DROPPED    | **14.8 m** | **26.2 m** | turn | Known north-wall puller          |
| [DJI_0821](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0821.JPG)  | DROPPED    | **18.5 m** | **22.0 m** | turn | Known north-wall puller          |
| [DJI_0981](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0981.JPG)  | DROPPED    | DROPPED    | 2.3 m      | mid  | Dropped 2/3                      |
| [DJI_0014](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0014.JPG)  | DROPPED    | 0.5 m      | **11.2 m** | turn | Stable in house-2, bad in uncrop |
| [DJI_0021](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0021.JPG)  | DROPPED    | 1.6 m      | 2.7 m      | mid  |                                  |
| [DJI_0858](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0858.JPG)  | 7.7 m      | 2.6 m      | 4.4 m      | mid  | High displacement in all runs    |
| [DJI_0824](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-grid/DJI_0824.JPG)  | **13.3 m** | 0.3 m      | 0.3 m      | mid  | Bad in house only                |
| [DJI_0044](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-orbit/DJI_0044.JPG) | 1.0 m      | 1.9 m      | 2.6 m      |      | Orbit image                      |
| [DJI_0043](file://///raconteur/datasets/imagesets/bond_ave/2026-02-21-orbit/DJI_0043.JPG) | 0.9 m      | 1.7 m      | 2.5 m      |      | Orbit image                      |

- **"Area" in the summary table is reconstructed camera footprint**, not boundary area. It measures the ground coverage of successfully reconstructed cameras from OpenSfM's `processing_statistics.area`. This is why uncrop (13947 m2) < house-2 (14959 m2) despite uncrop's boundary being 4x larger: uncrop reconstructed fewer cameras and covered less ground. See `boundary_comparison.png` in the uncrop map directory for a visual overlay of all boundaries.
- **auto_boundary behavior:** With `auto_boundary: true` and `auto_boundary_distance: 0`, ODM derives the boundary from the point cloud density, not from camera positions. The resulting polygon is a complex multipolygon (with holes for sparse areas) covering the full ~180x180 m flight area. This is dramatically larger than the ~84x84 m manual house-2 boundary. The `crop: 3` default trims 3 m from the output but does not meaningfully constrain reconstruction.
- 02-16 driveway area "soft" in DEM -- possible focus or motion blur in originals?

---

## ODM/OpenSfM stack: parameter reachability

*Which flags we want actually exist, and at what level of the stack are they accessible?*

### Stack layers

1. **WebODM UI** -- web form, passes JSON options to NodeODM. Limited to what WebODM recognizes. Good for quick standard runs; insufficient for our experiments.
2. **ODM CLI** (`docker run opendronemap/odm`) -- all documented flags at docs.opendronemap.org/arguments/. This is where most useful parameters live.
3. **OpenSfM config.yaml** (manual edit between stages) -- the full OpenSfM config at `opensfm/config.yaml` inside the ODM output directory. Hundreds of parameters. Workflow: run `--end-with opensfm`, edit config, then `--rerun-from opensfm`.
4. **OpenSfM source code** -- forking required. Only needed for adding entirely new cost functions (e.g. geometric priors in bundle adjustment).

### Parameter audit

| What we want | Parameter | Default | Layer | Notes |
|---|---|---|---|---|
| Minimum track length | `min_track_length` | 2 | **OpenSfM config** | Exists. Want to test 4-5. Not exposed in ODM CLI. |
| Resection min inliers | `resection_min_inliers` | 10 | **OpenSfM config** | Exists. Want to test 50-100. Not exposed in ODM CLI. |
| Texturing data term | `--texturing-data-term` | gmi | **ODM CLI** | Exists. Want to test `area`. |
| Preserve opensfm/ dir | `--optimize-disk-space` | False | **ODM CLI** | Off by default = opensfm/ is preserved. Verify WebODM default. |
| Align to prior DEM/cloud | `--align` | None | **ODM CLI** | Exists since ODM 3.0.2. Takes GeoTIFF DEM or LAS/LAZ. Aligns reconstruction post-hoc. Directly supports Level 4 (multi-temporal). |
| Reuse camera calibration | `--cameras` | None | **ODM CLI** | Path to cameras.json from a previous run. Useful for post-crash consistency check and cross-run stability. |
| Feature type | `--feature-type` | dspsift | **ODM CLI** | Options: akaze, dspsift, hahog, orb, sift. Could experiment. |
| GPS accuracy / prior weight | `--gps-accuracy` | 3 | **ODM CLI** | Sets DOP in meters. Lower = tighter GPS constraint in BA. |
| Matching strictness | `robust_matching_min_match` | 20 | **OpenSfM config** | Min pairwise matches to accept a pair. Could raise. |
| Lowes ratio test | `lowes_ratio` | 0.8 | **OpenSfM config** | Lower = stricter matching. Could tighten to 0.7. |
| BA outlier filtering | `bundle_outlier_filtering_type` | FIXED | **OpenSfM config** | Could try AUTO (data-driven threshold). |
| BA outlier threshold | `bundle_outlier_fixed_threshold` | 0.006 | **OpenSfM config** | Tightening this rejects more outlier projections. |
| Feature process size | `feature_process_size` | 2048 | **OpenSfM config** | Image resize during feature extraction. Raising = more features at finer scale but slower. |
| Triangulation min ray angle | `triangulation_min_ray_angle` | 1.0 | **OpenSfM config** | Min angle between views (degrees). Raising rejects shallow-angle triangulations. |
| Geometric priors in BA | (does not exist) | -- | **OpenSfM fork** | Would require adding custom Ceres cost functions. |
| DEM-guided feature masking | (does not exist) | -- | **Pre-processing script** | External to ODM. Mask images before feeding to pipeline. |

### Key discoveries

- **`--align` is already built into ODM** but is limited to post-hoc rigid transformation (ICP-like) of an independently completed reconstruction to a reference. Useful for multi-temporal *coordinate alignment* (Level 4 absolute positioning), but does NOT help when new images can't independently reconstruct (e.g. leafed-in canopy). For that case, frozen-skeleton localization (asymmetric BA with fixed prior points) is needed, which requires OpenSfM modification. Time-SIFT (shared SfM block across epochs) is a middle ground but treats all images equally.
- **`--cameras` lets us reuse calibration.** Important for post-crash verification and for ensuring consistency across runs.
- **The config-edit workflow is explicitly supported.** `--end-with opensfm` + edit config + `--rerun-from opensfm` is the documented approach for parameters not exposed in ODM CLI.
- **We do NOT need to leave WebODM entirely.** For standard runs, WebODM is fine. For experimental runs with custom OpenSfM config, we need ODM CLI (via Docker). The two can coexist.
- **Forking OpenSfM is only needed for geometric priors in BA** (the Ceres cost function changes). Everything else -- min_track_length, resection_min_inliers, texturing-data-term, align, cameras, matching params -- is reachable without forking.

### Practical workflow for experiments

1. Run via ODM CLI in Docker (not WebODM) with `--end-with opensfm` and desired ODM-level flags.
2. Edit `<output>/opensfm/config.yaml` to set `min_track_length`, `resection_min_inliers`, etc.
3. Run `--rerun-from opensfm` to complete processing with modified config.
4. For the `min_track_length` test: this means we can do the cheapest experiment (Phase A) using Docker on lancer right now, no cluster needed.

---

## Link to Deliverable 3 (data capture)

The inventory of "data we need" and concrete implementation steps (ODM run record script, imageset mission params, optional image-quality script) are tracked in the tiles repo: **https://github.com/symmatree/tiles/issues/343**
