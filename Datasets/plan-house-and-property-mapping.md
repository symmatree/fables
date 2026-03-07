# House and property mapping: overall plan

**Experiment tracker for current (house) phase:** [[experiments-house-model]]

---

## Staged goals

### Stage 1 (current): House 3D model

- **Goal:** Capture data and produce a 3D model of the house with a high overall success rate.
- **Geo-referencing:** GCPs established via RTK-corrected GPS or a total-station chain from the reference GPS antenna in the attic down to each GCP.
- **Success:** Iterate until empirically acceptable to you (you don't see anything wrong) — qualitative, by your judgment. No pre-committed checklist; declare Stage 1 done when it looks right, then expand.

### Stage 2: Yard/driveway surface height field

- **Goal:** Same area (or similar) as Stage 1, but the primary product is a surface height field (DEM/DSM) over lawn and driveway with high, repeatable precision and accuracy.
- **Geo-referencing:** Same GCP approach as Stage 1.
- **Success:** Define repeatability/accuracy targets (e.g. cm-level, or "match total-station check points within X"). Declare success before moving to Stage 3.

*Initially using the imagesets from the house missions; separate flight only if needed.*

### Stage 3: Full property (~10 acres)

- **Products:**
  - **House, garden, yard:** Textured 3D model (same style as Stage 1).
  - **Woods:** (1) Conservative height field — the ODM product that does *not* rely on point classification by a model — to detect downed trees; (2) Point cloud → naive canopy representation, e.g. DEM using something like 95th percentile z within each cell.
- **Geo-referencing:** Same GCP approach; scale may require more GCPs or different placement.
- **Success:** Define what "good enough" is for woods (e.g. downed-tree detection rate, canopy height sanity checks).

*One of the Stage 3 tasks: determine the exact ODM recipe for the conservative heightfield (e.g. dsm without pc-classify).*

---

## Principle: iterate then expand

At each stage:

1. Vary **controlled** parameters (collection and processing).
2. Evaluate resulting outputs for usability.
3. Use that to iterate (fix collection/processing) or to proceed to the next level of complexity.
4. Only after declaring success at a stage do we expand (e.g. to yard, then to full property) or add new processing (e.g. canopy DEM).

---

## Tooling

- **Collection:** DroneLink (machine-controlled flightpaths) + DJI Mini 3 Pro. Primary missions so far: lawnmower grid at -70° gimbal, orbit around house with house as POI; optional manual "close orbit" to fill gaps.
- **Processing:** ODM / WebODM (e.g. on [[Lancer]]).
- **Documentation and data:** Facts repo — [[data-collection]], [[imagesets-data-collection]], [[odm-maps-data-collection]]. Datasets live under `Datasets/`; imageset and ODM map docs link to NAS paths and to each other.

---

## Data we need (inventory)

So we can reason from summaries instead of raw maps and DroneLink UI:

- **DroneLink (planned):** Altitude, overlap (front/side), speed, pattern, gimbal, capture interval, orbit radius, POI, mission link. Prefer getting these from DroneLink (export or API if available) and recording locally; manual entry only if there's no export path.
- **DroneLink (executed):** Same + actual path/timestamps if exportable (for ground speed per image/segment).
- **Images:** Already from EXIF: count, altitude range, bbox. Desired: blur/focus indicators; estimated ground speed (from EXIF timestamps + GPS or DroneLink).
- **ODM:** Processing time, area, capture window, benchmarks (runtime per stage), options/boundary. Today this is manual paste; goal is a script that extracts it from ODM output and we add an "ODM run record" section to each map doc.

Implementation tracked in tiles repo (public): [[experiments-house-model#Link to Deliverable 3 (data capture)]].

---

## Over-ambition check

- **Stages 2 and 3:** Written down to capture intent, but we are *not* committing to doing them on a fixed timeline. Stage 1 first.
- **GCPs:** Attic reference + RTK or total-station chain is the plan; we have not yet placed or measured GCPs for the current house runs. So current maps are not yet geo-referenced the way we want for "final" products.
- **Full property:** 10 acres and woods/canopy is a big step. The plan is to get there incrementally; the exact flight strategy is to be determined when we reach that stage.
