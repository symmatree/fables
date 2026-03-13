# GNSS Base Station Validation: Attic Environment

**Hardware:** u-blox ZED-F9P receiver + SparkFun SPK6618H Multi-Band Antenna

**Baseline Environment:** High winds, mostly clear sky with cumulus clouds. (Note: Attic enclosure proved highly beneficial for physical stability during wind).

## Objective

To definitively verify that an attic-mounted GNSS antenna provides a valid, high-quality environment for generating RTK (Real-Time Kinematic) base station corrections, circumventing potentially misleading UI states in u-center.

## Phase 1: Verifying Base Station State (`TIME` Mode)

_The u-blox F9P must be in `TIME` mode to generate fixed stationary RTCM messages. u-center's UI can misleadingly display `3D/DGNSS` if it is only reading NMEA strings._

1. **The Test:** In u-center, navigated to `View -> Messages View -> UBX -> NAV -> PVT`. Clicked **Poll** to force a proprietary status update.
    
2. **The Result:** The UI temporarily updated to `TIME/DGNSS`.
    
3. **The Conclusion:** The receiver successfully accepted the hardcoded `TMODE3` ECEF coordinates (and accepted the `0.000m` accuracy threshold as an absolute override). The receiver's internal state machine is correctly configured and operating as a fixed base station.
    

## Phase 2: Validating RF Transparency & Signal Health

_A receiver in `TIME` mode will broadcast corrections even if the signal is terrible. We needed to verify the roofing materials were not overly attenuating the L1/L2 bands or introducing severe multipath._

1. **The Test:** Monitored the Carrier-to-Noise Density (C/N0) values for satellite pairs.
    
2. **The Result:** * Strong L1 signals (~44 dBHz).
    
    - Healthy L2 signals (~37 dBHz).
        
3. **The Conclusion:** The roof attenuation is minimal (only roughly a 4-7 dBHz drop compared to open-sky). L2 signals remain well above the ~30 dBHz threshold required for reliable RTK carrier phase tracking.
    

## Phase 3: Validating Carrier Phase Lock (The Absolute Truth)

_RTK requires an unbroken lock on the physical radio wave. Multipath (signals bouncing off attic trusses) causes cycle slips, which destroy locktimes._

1. **The Test:** Navigated to `View -> Messages View -> UBX -> RXM -> RAWX` (Multi-GNSS Raw Measurement) to view unfiltered receiver metrics. (Required enabling the message or polling it, as lean configurations disable it to save serial bandwidth).
    
2. **The Metrics Checked:**
    
    - **`cpValid` (Carrier Phase Valid):** Must be `Y` (Yes) for active tracking.
        
    - **`Locktime`:** An unsigned 16-bit integer (maxing out at `64500` ms, or 64.5 seconds) indicating the duration of unbroken phase lock.
        
3. **The Result:** Observed 30+ satellites across multiple constellations with `cpValid: Y` and `Locktime` pegged at or near the `64500` maximum.
    
4. **The Conclusion:** The attic environment is completely viable. The receiver is holding millimeter-level phase locks across the visible sky without suffering from cycle slips. Occasional drops to zero on individual satellites (e.g., GLONASS birds) are normal orbital/atmospheric events and do not indicate a local environmental failure.
    

## Summary Verdict

The attic is a highly RF-transparent, weatherproof, and stable environment for this hardware. The RTCM 1074/1084 messages generated from these raw measurements are mathematically sound and reliable for rover corrections.
