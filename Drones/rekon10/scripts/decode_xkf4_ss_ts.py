#!/usr/bin/env python3
"""Decode XKF4 SS and TS bitmasks; print transitions. See ArduPilot logmessages XKF4."""
from __future__ import annotations

import argparse
from pathlib import Path

from pymavlink.DFReader import DFReader_binary

SS_BITS = [
    (1, "ATTITUDE_VALID"),
    (2, "HORIZ_VEL"),
    (4, "VERT_VEL"),
    (8, "HORIZ_POS_REL"),
    (16, "HORIZ_POS_ABS"),
    (32, "VERT_POS"),
    (64, "TERRAIN_ALT"),
    (128, "CONST_POS_MODE"),
    (256, "PRED_HORIZ_POS_REL"),
    (512, "PRED_HORIZ_POS_ABS"),
    (1024, "TAKEOFF_DETECTED"),
    (2048, "TAKEOFF_EXPECTED"),
    (4096, "TOUCHDOWN_EXPECTED"),
    (8192, "USING_GPS"),
    (16384, "GPS_GLITCHING"),
    (32768, "GPS_QUALITY_GOOD"),
    (65536, "INITIALIZED"),
    (131072, "REJECTING_AIRSPEED"),
    (262144, "DEAD_RECKONING"),
]
TS_BITS = [
    (1 << 0, "timeout_POS"),
    (1 << 1, "timeout_VEL"),
    (1 << 2, "timeout_HGT"),
    (1 << 3, "timeout_MAG"),
    (1 << 4, "timeout_ARSP"),
    (1 << 5, "timeout_DRAG"),
]


def decode(val: int, bits: list) -> list[str]:
    return [n for m, n in bits if val & m]


def diff_sets(prev: int, cur: int, bits: list) -> tuple[list[str], list[str]]:
    a, b = set(decode(prev, bits)), set(decode(cur, bits))
    return sorted(b - a), sorted(a - b)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--bin", type=Path, required=True)
    ap.add_argument("--core", type=int, default=0, choices=(0, 1))
    args = ap.parse_args()

    log = DFReader_binary(str(args.bin))
    arm_on = None
    while True:
        m = log.recv_match(type=["ARM"])
        if m is None:
            break
        if m.ArmState == 1 and arm_on is None:
            arm_on = m.TimeUS
            break

    seq = []
    log = DFReader_binary(str(args.bin))
    while True:
        m = log.recv_match(type=["XKF4"])
        if m is None:
            break
        if m.C != args.core:
            continue
        seq.append((m.TimeUS, m.SS, m.TS, m.GPS))

    prev_ss = prev_ts = None
    for t, ss, ts, gps in seq:
        if prev_ss is None:
            rel = (t - arm_on) / 1e6 if arm_on else 0
            print(f"t={t} rel_arm={rel:+.2f}s  SS={ss} TS={ts} GPS={gps}")
            print("  SS:", ", ".join(decode(ss, SS_BITS)))
            print("  TS:", decode(ts, TS_BITS) or ["(none)"])
            prev_ss, prev_ts = ss, ts
            continue
        if ss != prev_ss or ts != prev_ts:
            g, l = diff_sets(prev_ss, ss, SS_BITS)
            gt, lt = diff_sets(prev_ts, ts, TS_BITS)
            rel = (t - arm_on) / 1e6 if arm_on else 0
            print(f"t={t} rel_arm={rel:+.2f}s  SS={ss} TS={ts} GPS={gps}")
            if g or l:
                print(f"  SS: +{g or '-'}  -{l or '-'}")
            if gt or lt:
                print(f"  TS: +{gt or '-'}  -{lt or '-'}")
            prev_ss, prev_ts = ss, ts


if __name__ == "__main__":
    main()
