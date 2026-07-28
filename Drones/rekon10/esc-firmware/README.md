# rekon10 ESC firmware -- calibrated AM32 build

Custom AM32 build for the rekon10's **TBS Lucid 60A 3-6S AM32 4-in-1** ESC, so ArduPilot's
ESC telemetry (`BATT_MONITOR=9`) reports usable **battery voltage and current / mAh**. This
exists because the FC's own analog current sensor is dead (arc-blown at first bring-up, PC1
stuck ~9.9 V) -- see [`../flight-platform.md`](../flight-platform.md) and
[coordinator#117](https://github.com/symmatree/coordinator/issues/117).

## What's wrong with stock, and the fix

The board's correct AM32 target, `TBS_6S_4IN1_F421` (firmware name `TBSlu6s4in1`), leaves the
current/voltage calibration constants **undefined**, so they fall back to file-global generics
in `Inc/targets.h` that don't match this board's hardware:

| Constant | Stock (generic fallback) | This board | How derived |
|----------|--------------------------|------------|-------------|
| `TARGET_VOLTAGE_DIVIDER` | 110 | **158** | `110 * 23.32 V(meter) / 16.2 V(ESC)` -- stock read ~1.44x low |
| `CURRENT_OFFSET` | 0 | **1600** | nulls the ~80 A/ESC zero-throttle phantom. `actual_current` is in 10 mA units, so 80 A/ESC = 8000 internal; null needs `OFFSET*100 = 8000 * MILLIVOLT_PER_AMP(20)` -> **1600** |
| `MILLIVOLT_PER_AMP` | 20 | **20** (unchanged) | current **scale** left generic -- see "Known limitation" |

These are **compile-time** `#define`s per target -- not EEPROM, not adjustable in the AM32
configurator, and ArduPilot has no scale/offset for ESC telemetry (`=9`). So the only place
to fix them is a firmware rebuild. The change is nothing but these three constants inside the
`#ifdef TBS_6S_4IN1_F421` block; motor drive, DShot, and telemetry are byte-identical to stock
v2.20. The patch is [`rekon10-cal.patch`](rekon10-cal.patch).

## Build

```sh
docker build -t rekon10-esc .
docker run --rm -v "$PWD/out:/work/obj" rekon10-esc
# -> out/AM32_TBS_6S_4IN1_F421_2.20.hex   (md5 ab21eec3...)
```

The Dockerfile clones AM32 at the **v2.20 tag** (the release the ESCs shipped with, so the only
delta is the patch), lets `make arm_sdk_install` self-fetch the pinned xPack arm-none-eabi-gcc
10.3.1 into the tree, applies the patch, and `make TBS_6S_4IN1_F421`. Builds are deterministic
(same md5 every run). The pre-built result is checked in as
[`AM32_TBS_6S_4IN1_F421_2.20_rekon10-cal.hex`](AM32_TBS_6S_4IN1_F421_2.20_rekon10-cal.hex).

To build without Docker: `git clone -b v2.20 ...AM32 && cd AM32 && make arm_sdk_install &&
git apply /path/rekon10-cal.patch && make TBS_6S_4IN1_F421`.

## Flash

All four ESCs, via ArduPilot passthrough (props off, battery connected):

1. Mission Planner: set `SERVO_BLH_AUTO = 1`, reboot the FC (`MOT_PWM_TYPE=6`/DShot and
   `BRD_SAFETY_DEFLT=0` are already set).
2. Disconnect Mission Planner (frees the COM port).
3. AM32 configurator -> interface "BLHeli32/AM32 Bootloader (Betaflight/Cleanflight)" ->
   Connect -> flash the `.hex` (local firmware) to each ESC.

Same version (2.20) as stock, so EEPROM config persists -- but **verify motor directions
after** (one ESC is reversed); backups in [`../config/am32-esc/`](../config/am32-esc/).

## Verify (`BATT_MONITOR=9`, disarmed)

- Voltage reads within ~1 % of a meter (was ~1.44x low).
- Current reads ~0 A summed (was ~320 A phantom).

## Known limitation -- current scale is uncalibrated

`MILLIVOLT_PER_AMP` is left at the generic **20**; only the zero-offset was calibrated. A
clean scale point needs a known load, which a no-prop bench spin (~3-5 A) can't provide above
the sensor noise. Consequence: **mAh is accurate to roughly +/-15 %**, which is fine for the
intended use (voltage-cliff and low-capacity "land now" detection) but not for precise energy
accounting. To refine later: fly a known-current profile (or bench a real load), then set
`MILLIVOLT_PER_AMP = 20 * reported_summed / true_current_summed` and rebuild.
