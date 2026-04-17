# GPS mast ("funnel")

[Back to index](README.md)

This component mounts an F9P breakout board and a helical antenna. This mount may not always be fitted, but when it is, it talks to the FC to get RTCM corrections and to provide RTK positions. It also sends a PPS signal to the camera pods to allow them to synchronize their clocks to the microsecond level.

## Requirements

- GPS antenna wants a **rigid mount** -- unlike a camera, it only cares about its phase center. Vibration that moves the antenna even 2 cm is indistinguishable from actual motion and creates noise in position/velocity estimates. Bolt it down hard.
- The F9P breakout board needs cooling (pulls ~600 mA at 3.3 V when tracking 40+ satellites on L1/L2/L5). Must be in open air, not buried inside the funnel.
- The SMA connection must be mechanically solid and electrically snug. A loose SMA under vibration creates micro-intermittency that drops RTK Fixed status.

### Design: PLA "ship's funnel" with side-mounted F9P

- **Shape:** A funnel-like structure with a central tunnel (min 15 mm internal radius so SMA cables maintain impedance without kinking), a strong flat on top for the antenna, and a wide base flange.
- **Base:** Bolts to the rear four top-plate screws. A forward "tongue" tucks under the battery strap for anti-rotation, even if only the rear two screws are structural. (If the battery conflicts with the tongue, the battery goes underslung.)
- **F9P "Aegis" mount:** The breakout board mounts on the outside face of the funnel, exposed to prop wash for cooling. Connected to the antenna only via SMA (there is no physical mounting relationship between the F9P and the ground plane -- they're on different faces of the funnel).
- **Material:** PLA is what's available. Check for white stress marks around screws after first flights (PLA is brittle under vibration). PETG would be preferable.

## RF Shield option

I have an Ardusimple PCB ground plane designed for ceramic antennas, which we could use as an RF shield if we get too much noise from the USB3 payloads. It's a lot simpler without it, so check signal-to-noise from the GPS with the payload systems up and down and see if they hurt too much. Default current plan is NOT to mount the RF shield.

If we DO use it, there are complexities because there's no room for a nut between the shield and the antenna, so we have to jump through various hoops to avoid too much structural load on the antenna SMA connector (which in turn requires controlling the angle where it bottoms out, to have mounting holes aligned). This is vastly simplified to a normal bulkhead connection, still with a match the antenna mounting holes but far more simply.

### SMA bulkhead assembly ("sinking stud" method)

ONLY if we need to mount the RF shield.

The antenna sits on the ground plane PCB, which is bolted to the top of the funnel. The SMA connection passes through the PCB and funnel via a long-reach bulkhead adapter. The assembly sequence:

1. **Start proud:** Install the bulkhead adapter through the funnel, intentionally too tall, with a captive hex nut in a pocket on the funnel and a second nut below.
2. **Bottom out the SMA:** Screw the antenna/PCB assembly onto the bulkhead until the RF connection seats (hard stop). At this point the PCB floats above the funnel.
3. **Sync-spin down:** Keep turning the entire sensor head. The captive nut is in its hex pocket; as you spin, the bulkhead screws itself downward through the nut.
4. **Arrive at flush:** Stop when the PCB meets the funnel surface and the M4 holes align.
5. **Lock:** Tighten the near-side (bottom) nut against the underside of the funnel, sandwiching the funnel between the two nuts. The bottom nut is snug against the bulkhead and slightly loose against the ground plane, ensuring the bulkhead is tightly captured and the SMA is bottomed out.

This ensures the SMA is in **slight compression** (not tension), which is safer for the RF connection. The steel antenna-to-PCB bolts act as a rigid backstop preventing the SMA from yielding.

**Clocking:** The funnel top has a **4-hole cross pattern** (90 degrees apart); the PCB has two holes 180 degrees apart. This gives a stop every 90 degrees, reducing maximum height error from a full turn (0.7 mm) to a quarter turn (0.175 mm).

**Ground plane RF bonding:** The PCB is conformal-coated on both sides with unplated holes. The nylon mounting bolts don't provide electrical contact. RF ground continuity relies on the SMA barrel-to-ground-plane interface. The conformal coating should be **scraped at the SMA contact area** on the PCB to ensure the SMA barrel's outer conductor makes clean contact with the copper ground plane.

---

## Connections (end-to-end endpoints)

### F9P / GPS (RTK)

* Board power TBD, ideally off FC not UBEC for resilience
* UART RX/TX to FC UART 7 (3.3V) -- ArduPilot SERIAL7
* SMA to bulkhead connector to antenna
* [SparkFun GPS-RTK-SMA](https://www.sparkfun.com/sparkfun-gps-rtk-sma-breakout-zed-f9p-qwiic.html) ZED-F9P breakout board
* **RTCM corrections path:** Base station -> house WiFi -> `boxer-txbp` backpack (UDP) -> ELRS MAVLink uplink -> ArduPilot -> `GPS_RTCM_DATA` forwarded to F9P on UART7. Requires ELRS in MAVLink mode (not normal CRSF). Current Rekon profile is **333 Hz Full, 1:2 telemetry** with about **13211 baud** telemetry budget reported on the handset; final RTCM traffic volume depends on selected message types, constellations, and update rates. See [ardupilot.md](ardupilot.md) (SERIAL6 / RTCM bandwidth).

## TODO: RTCM traffic shaping for ELRS link budget

Define an explicit RTCM profile that fits the available ELRS telemetry budget:

* Choose constellations to transmit corrections for (GPS/GLO/GAL/BDS).
* Choose RTCM message set (MSM type + support messages).
* Choose message update rates per type.
* Measure resulting RTCM traffic on the live stream and record sustained / peak baud.
* Confirm remaining baud margin for non-RTCM MAVLink traffic at target packet rate.

### Helical antenna

* SMA to bulkhead connector to F9P
* Hardware: GNSS multi-band helix antenna, SparkFun `GPS-30249` (locking SMA)
* Optional RF shield/ground-plane source: Ardusimple PCB ground plane
