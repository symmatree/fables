# Luxonis OAK-D (original)

**Product:** [OAK-D](https://shop.luxonis.com/products/oak-d) -- the original model. Many systems/docs assume newer OAK-D-S2 or OAK-D-Pro; this doc is for the **first-generation OAK-D** (SKU A00110-INTL).

Superseded by OAK-D-S2 (more CCM options) and OAK-D-Pro (additional features). Stereo depth + center RGB + on-board NN inferencing and computer vision. USB-C for power and USB3. RVC2 architecture.

---

## Technical specifications

*Scraped from [Luxonis OAK-D product page](https://shop.luxonis.com/products/oak-d).*

### Awards

- 2021 Product of the Year, category Best Camera (AI and Vision Alliance)

### Camera specifications

**Sensors:**

| | Color camera | Stereo pair (L/R) |
|---|--------------|-------------------|
| **Sensor** | IMX378 (PY011) | OV9282 (PY010) |
| **DFOV / HFOV / VFOV** | 81° / 69° / 55° | 81° / 72° / 49° |
| **Resolution** | 12 MP (4056x3040) | 1 MP (1280x800) |
| **Focus** | AF: 8 cm - infinity | FF: 19.6 cm - infinity |
| **Max framerate** | 60 FPS | 120 FPS |
| **Spectral range** | Visible only | Visible only |
| **Shutter type** | Rolling | Global |
| **Sensor size** | 1/2.3" | 1/4" |
| **F-number** | 1.8 ± 5% | 2.0 ± 5% |
| **Effective focal length** | 4.81 mm | 2.35 mm |
| **Pixel size** | 1.55 µm | 3.0 µm |

### Processing and features

- **RVC2:** 4 TOPS total (1.4 TOPS for AI). Run any AI model (models need to be converted).
- **Encoding:** H.264, H.265, MJPEG -- 4K/30 FPS, 1080p/60 FPS.
- **Computer vision:** warp (undistortion), resize, crop (ImageManip), edge detection, feature tracking; custom CV functions.
- **Stereo depth:** filtering, post-processing, RGB-depth alignment, high configurability.
- **Object tracking:** 2D and 3D (ObjectTracker node).
- **Integrated IMU:** BNO085, 9-axis. See IMU node in API docs.

### Stereo depth perception

- **Baseline:** 75 mm (7.5 cm).
- **Ideal depth range:** 70 cm - 12 m.
- **MinZ:** ~20 cm (400p extended), ~35 cm (400p OR 800p extended), ~70 cm (800p).
- **Depth accuracy** (75 mm baseline, 800p): below 4 m under 2% absolute error; 4-7 m under 4%; 7-10 m under 6%.

### Power and connectivity

- **Connectivity:** USB-C (USB 3.2 Gen1, 5 Gbps) for power and data.
- **Power:** USB Type-C or 5 V, 5.5 mm x 2.5 mm barrel jack. Type-C 1.5 A or greater recommended (USB 3 spec 900 mA often sufficient but tight).
- **Power consumption:** Up to ~5 W total. Base + camera streaming 2.5-3 W; AI subsystem up to 1 W; stereo depth pipeline up to 0.5 W; video encoder up to 0.5 W. Lower FPS reduces consumption.
- **Other interfaces:** OAK-D connector pads J4, J5, J6 (Amphenol/FCI 20021121-00010T1LF or equivalent). See schematics for pinout. Reset: RST to ground (reset button not populated by default). LEDs: 5V (power present), PG (power good from SoM), RUN (SoM not in reset).

### Mechanical and environment

- **Housing:** Industrial aluminum, front Gorilla Glass. 1/4" tripod mount, 75 mm M4 VESA mount.
- **Dimensions:** 110 x 54.5 x 33 mm. **Weight:** 115 g.
- **Ambient operating temperature:** -20°C to 50°C (RVC2 fully utilized). See Luxonis operating temperature range docs.

### Package (from product page)

- OAK-D camera, power supply with international adapters, cable USB-CA-1m, cleaning cloth.

### Resources

In this directory:

* Enclosure 3d model in STL and STEP
* Datasheet and brochure
* Assembly and schematic drawings
* Product diagram graphics