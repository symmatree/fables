# Privacy review: facts/Datasets

This document summarizes what was reviewed in `Datasets/`, what is likely fine to share given your comfort with "general area and collection timing," and what you may want to keep private or generalize before sharing the repo or excerpts.

**Scope:** Directory structure, file names, and the contents of all markdown and text files under `facts/Datasets/`. Image and PDF contents were not inspected (preview images, map outputs, reports).

---

## Framing: one repo as a blog of experiments

You've indicated:

- Your ownership of this address is already searchable (county website, credit report), and your name is publicly associated with this repo.
- You prefer to treat this as a **single set of books**—a blog of ongoing experiments—rather than maintaining separate "public" vs "private" versions.
- You want to share the **worked example** with people who might benefit—friends and family are one such audience; the value is a particular homestead and mapping effort, what did and didn't work, and the troubles along the way.
- You don't discuss family or share personal photos; content is descriptions and maps. Overhead imagery is already available (e.g. Google) for any location.

**Broader context (for this and other directory reviews):**

- The **tiles** repo is fully public and built on the model that **security is delivered by crypto and keys, not obscurity**. So hiding hostnames or internal paths for "security" is not a goal; you're not relying on obscurity.
- You'd rather **share possibly useful setup** with people who might benefit (including AI scrapes) than marginally harden a homelab network against attackers who would ultimately be targeting things like a game account anyway.
- **This review applies only to this directory** (`Datasets/`). You intend to do the same kind of review for other directories; each gets its own scope and red lines.
- **Real red lines:** Passwords, private keys, medical data, names of family—things on that order. Not "stay anonymous." You're not trying to hide who you are or where you live.
- **Positive goal:** You want this to be **helpful professionally** as a shareable resource into your thinking and problem-solving—something you *can* share, which is true of none of your actual professional work.

**Context:** This repo will be public (indexed, permanent). The review scanned for keys and identifiers that might concern you. One file should be excluded; everything else in this directory is fine to include as-is.

---

## What was reviewed

### Structure

- **Root-level docs:** `plan-house-and-property-mapping.md`, `experiments-house-model.md`
- **DroneLink:** `DroneLink/dronelink-missions.tsv` (export of mission runs)
- **Imageset docs:** Multiple `imagesets-*.md` files (one per imageset), with optional `imageset_preview-*.png`
- **ODM map docs:** Per-run folders (e.g. `odm-maps-bond_ave-2026-02-16`, `odm-maps-bond_ave-2026-02-21-house`, `-house-2`, `-uncrop`), each with a main `.md`, `dropped-images.md`, and references to previews/reports

### Kinds of data documented

- **Locations:** Site/label "bond_ave"; island/location "chebeague"; geographic bounds (lat/lon) in imageset EXIF summaries and in dropped-image tables; region mentioned as "western PA" in experiments.
- **Dates:** Collection dates (e.g. 2023-02, 2024-04-22, 2026-01-xx, 2026-02-16, 2026-02-21) and capture time windows.
- **Image sets:** Count, altitude range, bounding box (lon/lat), mission type (grid, orbit, close-orbit, casual), links to DroneLink missions where present.
- **Drone/ODM runs:** Mission parameters (altitude, overlap, speed, gimbal, radius), ODM options and run records, processing host ("Lancer"), qualitative notes and experiment outcomes.
- **Plans:** Staged goals (house 3D, yard DEM, full property ~10 acres), GCP/RTK plans, tooling (DroneLink, DJI Mini 3 Pro, ODM/WebODM), references to "attic" reference antenna and property layout (house, garage, yard, woods).
- **House/property mapping:** Descriptions of buildings (house, garage), features (spa, water feature), and property extent (~10 acres, woods).

---

## Exclude from repo

**DroneLink/dronelink-missions.tsv** — Contains identifiers you asked to screen for: drone serial number, user ID, exact lat/lon, device model/OS, and DroneLink URLs. We won't include this file.

---

## Everything else in this directory: fine to include

You're okay with the types of data documented here (property, location, names, internal hostnames, links, layout). Red lines (passwords, keys, medical, family names) do not appear. The rest of what was reviewed is included as-is:

- **Location/site:** bond_ave, lat/lon, chebeague, western PA
- **Names/usernames:** seth-porter in DroneLink URLs
- **Internal infra:** raconteur, Lancer, file paths
- **Links:** DroneLink mission URLs, GitHub symmatree/tiles
- **Property detail:** house, garage, attic, spa, acreage, etc.

---

This review applies only to `facts/Datasets/`. You intend to do the same kind of directory-specific review for other directories.
