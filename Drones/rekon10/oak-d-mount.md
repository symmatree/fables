# OAK-D forehead mount

[Back to index](README.md)

## Background

The OAK-D works with software on the central MAVlink-speaking RPi to compute VIO position estimates and send them to the FC for combination with other signals. This is expected to be moderately helpful in open terrain, very helpful even alongside GPS when flying in risky situations near trees, and vital when flying under a tree canopt with degraded or lost GPS pose.

The OAK-D and Coordinator also compute a depth field and send obstacle-distance messages to the FC covering the forward field of view.

The OAK-D imagery is not synchronized to the payload pod cameras, and is not used for mapping. In fact both the obstacle field and the VIO depend on high frequency global-shutter imagery from the mono stereo pair, rather than high resolution color imagery from the central sensor; we MIGHT capture occasional frames for logging purposes or to provide a time-lapse "fly-through" but not for the core photogrammetry mission.

## Requirements

- **Rigid to frame for VIO:** The OAK-D must be structurally rigid relative to the IMU on the H7 FC. Any independent wobble (GoPro-style hinge, soft TPU) causes VIO failure because the "visual" and "inertial" data disagree, leading to EKF variances and potential flyaways.
- **Isolated from high-frequency vibration:** Propeller buzz ("jello") from the 10" props blurs the stereo image and ruins depth sensing. The stereo-matching algorithm needs clean features to work in a forest environment (leaves, branches).
- **Cooling:** Forestry surveys are slow-speed, high-load flights. The OAK-D's aluminum heat-sink fins must be exposed to prop wash.

## Design notes

### Rekon10 mounting holes in front:

Using "measure" tool in OpenSCAD, measuring approx outermost point on each side, then innermost, and averaging.

* Front hole side-to-side hole spacing 30.47mm so calling it 30.5mm
* Rear hole 29.4mm

In their STL using measure tool,
* First hole on R: y=3, y=6
* Second hole on R: y=3.54, 6.54

* First pair, lateral: M3, 30.5mm center to center
* Second pair, lateral: M3, 29.4mm center to center
* First-to-second, axial: 40.7mm center to center

So the outer edges of those are +/- 1.5mm. Let's allow 3mm of boss around each screwhole for bearing. It looks like their TPU footer is 3mm thick, that seems fine, and they also used a 3mm boss. (TPU not PLA but whatever.)

So our footing is a rounded rectangle of those dimensions, then we'll cut back at the corners with a cylinder (with a generous fillet or webbing to the screw boss) to leave the screw boss and clearance for a tool. It flares wider laterally, the front goes straight up (approx; some overhang on drone to tilt down, some underhang on rover to point up). The back end swoops inward pretty fast to a 1cm (initial idea) thick pillar, from there on everything is parallel except for teh angling for the oak-d.

I'm going to use 3mm as a somewhat arbitrary "thick enough to be rigid" number, and say that, from the initial footprint, by the bottom of the oak-d we should be a vertical rectangular prism, 6mm wider than the upright of the oak-d's "t" and 1cm deep. EXCEPT we have interfaces at the bottom of the oak-d which need to get backwards to the rpi and to power. So actually it should be a U shaped riser when seen from above, with the legs being at least 6mm wide, 1cm deep, and the front of the U being at least 3mm solid crossing the gap in front of the oak-d's base, culminating in a lip capturing the front of the oak-d's base and stopping before it interferes with a 90-degree USB-C plug and a power jack.

From there, going upward, we become a somewhat wider U (since before we were narrowed to catch the shoulders) or even just pillars with cross-bands. Then a countersunk, solid through-boss for the main mounting 1/4-20 bolt, with skin-thickness support planes going sideways to the skin as well as up and down for a ways at least.

From the 1/4-20 we can arc out in wings to cover the locating holes, with either a straight boss if they're threaded, or a boss with an inset nut to anchor a bolt square if it just stands out as a pin.

We COULD go upward over the top to catch the front with a snap-fit lip coming downward. That might really help maintain against twisting, since the 1/4-20 won't hold it *down* against the shoulders, but it does add some print time and might be an issue with build volume. Probably worth it, that positive connection would be nice. Could actually put the bigger lip on top and the little one on the bottom so you rotate it upwards to snap in, then anchor with the 1/4-20. 

### RPi mounting holes

The rpi side is far easier, it needs standoffs for clearance and plug access and cooling. Cables (usb-c to USB-A, as well as barrel jack for OAK-D power) need to get through the tunnel and out around the pi to connect to it and/or to the BEC.

4x M2.5 brass heat-set inserts

Design the Hole: In your CAD software, you model a blind, straight-walled cylindrical hole wherever you want a thread. The diameter of this hole needs to be slightly smaller than the outer diameter of the insert (the insert manufacturer will provide the exact hole dimensions, usually something like a 4.0mm hole for a 4.6mm wide M3 insert).

Position the Insert: Set the cold brass insert onto the top of the hole in your printed part. It will sit there, resting on the rim.

Apply Heat: Press the hot tip of your soldering iron lightly into the center hole of the insert.

Push Gently: As the brass heats up, it conducts heat into the surrounding PLA. Within a few seconds, the PLA begins to soften and melt. The insert will slowly sink into the hole under the light downward pressure of the iron.

Flush and Cool: Once the top of the insert is flush with the surface of your print, pull the iron straight up and out. The melted PLA flows into the knurled ridges of the brass. As it cools (which only takes a few seconds), the plastic hardens, permanently locking the metal threads into the part.

### BEC

Should we put the BEC with the coordinator? We need it immediately, for the RPi and the OAK-D. Alternatively we could mount it standalone and then later with one or both of the usb hubs, the PPS isolator or isolators, and so forth. I guess short term I can just put it on a standoff on the rover and worry about the drone in a minute. On the rover, the rpi / oak-d / bec might all need active cooling, so if it was a tower with all three, we could put a fan at the top or bottom to blow along their heatsinks, across the rpi board.


## OAK-D Specs

[mfg page](https://docs.luxonis.com/hardware/products/OAK-D)

* RVC2 with BNO086 IMU
* 2x OV9282 72 HFOV 49 VFOV, global shutter, fixed focus, 1280x800@120FPS
  * Stereo pair has 75mm baseline center-to-center
* 1x IMX378 69 HFOV 55 VFOV, rolling shutter, auto focus, 4056x3040@60fps

[Mechanical designs repo](https://github.com/luxonis/oak-hardware/blob/master/Mechanical-Designs.md)

* SIZE (WxHxD) 97mm x 29.5mm x 22.9mm
* Power draw: Max of 2A at 5.5V
* Main mounting hole 1/4x20, 24.5mm from bottom to center

## Rejected alternative: GoPro mounting

The Rekon10 frame comes with a TPU base for a standard GoPro "tab-style" mount. This provides convenient angle adjustment and a pre-built attachment point, but we believe it would buffer too much low-frequency signal, letting the camera lag the vehicle movements and confusing the FC. We need it to stay rigid to the FC in a macro sense, and only remove high frequency vibration.

## Solution: rigid skeleton + rubber bobbins

The theory is these should be soft enough to stop high frequency noise but firm enough to pass frame movements. This is an interplay between the hardness (and geometry) of the bobbin material versus the weight (or properly the various moment arms) of the suspended payload. The OAK-D being a dense chunk of metal and glass dominates the payload center of gravity.

#### Bobbin amazon specs

uxcell M3 Thread Rubber Mounts, Vibration Isolators, Cylindrical Shock Absorber with Studs 8 x 8mm 8pcs

* Brand:	uxcell
* Exterior: Finish	Zinc, Black
* Material:	Metal, Rubber
* Extended Length:	14 mm
* OEM: Part Number	a24073100ux2318
* ASIN B0DCTNY463

#### Bobbin possibly-mfg page specs

[possibly mfg](https://www.harfington.com/products/p-1538470)

Specifications :

* Product Name : Rubber Mounts
* Material : Metal, Rubber
* Color : Black, Silver Tone
* Metal Surface Treatment : Plated Zinc
* Rubber Size : 8 x 8mm / 0.31" x 0.31" (D*H)
* Male Thread Size : M3 x 6mm / M3 x 0.24" (D x L)
* Total Size : 14mm x 8mm / 0.55" x 0.31" (H x D)

Description:

1. Universal Design - 0.31" x 0.31" rubber mount with M3 x 6mm Studs , set of 8 pieces.
2. Durable, high durometer, resilient, anti-vibration, the metal stud is one pieces terminated and bonded within the rubber that perform better isolation .
3. Damping Capacity - rubber vibration isolation cushion, the rubber has large elasticity and is light and high, which plays a good buffering role and can protect the machine well for shock absorption and reduce noise.
4. They absorb vibrations caused by appliances, reduces noise and structural damage caused by these vibrations.Adapt to many kinds of motors make machine more stable supports dynamic performance and stability.
5. Rubber vibration isolator is mainly used for Fitness equipment, air conditioning, bicycle,air compressors, engines, gasoline engines, water pumps ,Welding machine and other equipment as a damping element.

#### Mount design

The mount is a **truncated 30/60/90 wedge** acting as a central spine:

- **Base:** Mounts to the Rekon 10's front four top-plate holes using **M3 rubber vibration bobbins** (uxcell M3 Thread Rubber Mounts 8 x 8mm) to decouple flight-frame vibration from the camera. The bobbins provide high-frequency isolation while maintaining structural rigidity -- the camera's pose never changes, but the "buzz" is absorbed.
- **Front face (vertical):** Holds the OAK-D tilted downward. Exact angle TBD (discussions ranged from 15 to 20 degrees); will be a parameter in the OpenSCAD model and iterated after test flights.
- **Rear face (slanted):** Mounts the **Pi 4B**, keeping mass centralized and protecting it from frontal impacts. Four M2.5 cylindrical bosses protruding from the slanted face; the board is not recessed (preserves airflow and port access).
- **Profile:** A squared-off **C-shape** when viewed from the side. The sides remain open to expose the OAK-D's aluminum heat sinks directly to prop wash. The structural spine is only as wide as the OAK-D's rear mounting plate (~40 mm), with T-flanges at top and bottom to capture mounting holes.

### Mounting the OAK-D

Three-point anchor: 1/4"-20 tripod bolt from the bottom (into a shallow pocket/recess matching the OAK-D footprint), plus two M4 screws through the back of the spine into the OAK-D's top-rear mounting holes. This locks the camera's pose permanently for VIO -- it cannot nod or vibrate independently.

Connectors: The design accommodates a **right-angle USB-C** (SuperSpeed 5 Gbps) and a **5.5x2.5 mm right-angle barrel jack**, with a 3D-printed strain-relief loop on the spine to prevent cable tugs from ruining VIO isolation.

Connector sourcing references: right-angle USB-C cable (`YACSEJAO`, Amazon) and 5.5 mm x 2.5 mm right-angle DC barrel pigtail (`Fancasee`, Amazon).

### CSG erode-and-merge clearance workflow (OpenSCAD)

To create perfect slip-fit cavities without shifting mounting hole alignments, use this boolean trick instead of expensive Minkowski sums:

1. **The Ghost:** Scale the imported OAK-D STL slightly (e.g. `scale([1.02, 1.02, 1.02])`) to create the oversized clearance jacket.
2. **The Core Punch:** Subtract cylinders at the *unscaled* mounting coordinates to punch holes through the ghost.
3. **The Union:** Merge the original, unscaled STL back into those punched holes.
4. **The Cut:** Subtract this composite tool from the solid wedge block.

Result: a cavity with ~1 mm air-gap everywhere *except* the mounting pads, which remain perfectly flush and zero-tolerance at the correct spacing.

**Tolerance:** Melted plastic shrinks and printers over-extrude on perimeters. A direct boolean subtraction of the exact STL creates a cavity the part won't fit into. The scaling step provides 0.2-0.4 mm of interference offset. The camera slides in and the screws provide tension.

**Heatsink cutout:** Rather than subtracting complex fin geometry, punch a single large rectangular hole through the wedge behind the OAK-D. Let the aluminum backplate hang in open air.

**Connector clearance:** The cylinder subtraction at the bottom must be wide enough for the hard plastic over-mold of the specific right-angle cables, not just the metal plugs.

### Structural design: semi-monocoque

**Model it solid in OpenSCAD; let the slicer build the torsion box.** Do not try to model internal webbing in CAD.

- **Perimeters (skin):** 3 or 4 wall loops = 1.2-1.6 mm solid outer shell. This carries almost all bending and torsional stress.
- **Infill (support):** 25-30% using a 3D structural pattern (Gyroid, Cubic, or Triangles). This prevents the skin from buckling inward under load.
- **Top/bottom layers:** 4-5 layers to cap the torsion box.

The 30/60/90 wedge flares outward laterally from the narrow bobbin base to the wide camera mounting holes, but does not capture the entire back of the camera. Keep flare angles below 45 degrees from vertical to avoid needing print supports. At 15-20 degrees of tilt, the overhang is ~75 degrees from the build plate -- the printer won't even notice.

### Fastener logic: long bolts, not deep counterbores

Deep counterbores break the structural skin (the perimeters), create stress risers at sharp 90-degree internal corners where layer lines will delaminate, and require bridging over thin air during printing. They weaken the semi-monocoque.

**Preferred: long bolts through the full part.** A through-hole allows the slicer to draw continuous perimeters around the bolt shaft from front to back, creating a solid internal pipe connecting both skins. The part becomes crush-resistant.

- **Spot-faces:** Where a bolt exits an angled surface (e.g. the slanted Pi mount), subtract a very shallow cylinder (1-2 mm) to create a flat shelf normal to the bolt axis. No deeper.
- **Washers are mandatory.** PLA/PETG suffer from compressive creep. A bare bolt head will slowly crush into 25% infill and become loose. A stainless steel flat washer under every bolt head distributes force 3-4x. Dimension counterbores for the washer: M3 washer ~7 mm OD, make counterbore d=7.5-8.0. M4 washer ~9 mm OD, make counterbore d=9.5-10.0.
- **Modifier meshes:** Only needed if bolting through thick, mostly-hollow sections where the slicer would put infill under a deep counterbore floor. Export solid cylinders around bolt positions as a separate "modifier" STL; in the slicer, set those zones to 100% Rectilinear infill. For thin flanges (3-5 mm), the slicer naturally makes them solid with 4 perimeters + 4 top/bottom layers.

### Edge breaking

- **Outer hull:** Build using `hull()` around cylinders at corners. The resulting shape has naturally rounded vertical edges.
- **Bolt holes:** Use chamfers (45-degree cones), not fillets. Subtract a small cone at each end of every bolt cylinder:

```
module clean_bolt_hole(diameter, length) {
    union() {
        cylinder(d=diameter, h=length, center=true);
        translate([0, 0, length/2])
            cylinder(d1=diameter, d2=diameter+1.5, h=1, center=true);
        translate([0, 0, -length/2])
            cylinder(d1=diameter+1.5, d2=diameter, h=1, center=true);
    }
}
```

This guides bolts in, removes sharp plastic edges, and preserves internal clearance.

- **Horizontal holes:** May sag slightly on top during printing. For small M3/M4 holes, the 0.4 mm clearance usually absorbs sag. For larger holes, use a "teardrop" shape (45-degree point on top).

---

## Connections

### OAK-D

* [central-hub.md](central-hub.md): OAK-D power input: 5V from BEC/stripboard via 5.5x2.5 right-angle barrel pigtail
* OAK-D data into Pi 4B USB 3.0 port (right-angle USB-C / USB 3.0 cable to USB-A)

* uxcell M3 Thread Rubber Mounts, Vibration Isolators, Cylindrical Shock Absorber with Studs 8 x 8mm  ASIN B0DCTNY463
