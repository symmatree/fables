#!/usr/bin/env python3
"""
P1 figures from first-flight DataFlash .bin (default: MP download, RTC unset -> 1980 filename).

Writes (under attachments/logs/ by default):
  - p1-roll-ekf-desroll.png -- RCIN.C1, XKF4 GPS+SV, ATT.DesRoll
  - p1-rc-desroll-roll.png -- RCIN.C1 vs ATT.DesRoll vs ATT.Roll (plan primary plot)
  - p1-motors.png -- RCOU.C1..C4

Usage:
  python3 -m venv .venv && .venv/bin/pip install -r requirements-p1-plot.txt
  .venv/bin/python plot_first_flight_roll_ekf_desroll.py [--bin PATH] [--out-dir DIR]
"""
from __future__ import annotations

import argparse
import math
from pathlib import Path

import matplotlib.pyplot as plt
from pymavlink.DFReader import DFReader_binary


def find_arm_window(log: DFReader_binary) -> tuple[int, int]:
    arm_on = arm_off = None
    while True:
        m = log.recv_match(type=["ARM"])
        if m is None:
            break
        if m.ArmState == 1 and arm_on is None:
            arm_on = m.TimeUS
        elif m.ArmState == 0 and arm_on is not None and arm_off is None and m.TimeUS > arm_on:
            arm_off = m.TimeUS
            break
    if arm_on is None or arm_off is None:
        raise SystemExit("Could not find ARM on/off pair in log")
    return arm_on, arm_off


def collect(
    bin_path: Path, arm_on: int, arm_off: int, pad_pre: float, pad_post: float
) -> dict:
    t0 = arm_on - int(pad_pre * 1e6)
    t1 = arm_off + int(pad_post * 1e6)
    data = {
        "rc_t": [],
        "rc_c1": [],
        "att_t": [],
        "des_r_deg": [],
        "roll_deg": [],
        "xkf_t": [],
        "xkf_gps": [],
        "xkf_sv": [],
        "rcou_t": [],
        "rcou_m": [],  # list of (c1,c2,c3,c4)
    }
    log = DFReader_binary(str(bin_path))
    while True:
        m = log.recv_match(type=["RCIN", "ATT", "XKF4", "RCOU"])
        if m is None:
            break
        t = m.TimeUS
        if t < t0 or t > t1:
            continue
        rel = (t - arm_on) / 1e6
        g = m.get_type()
        if g == "RCIN":
            data["rc_t"].append(rel)
            data["rc_c1"].append(m.C1)
        elif g == "ATT":
            data["att_t"].append(rel)
            data["des_r_deg"].append(math.degrees(m.DesRoll))
            data["roll_deg"].append(m.Roll)
        elif g == "XKF4" and m.C == 0:
            data["xkf_t"].append(rel)
            data["xkf_gps"].append(m.GPS)
            data["xkf_sv"].append(m.SV)
        elif g == "RCOU":
            data["rcou_t"].append(rel)
            data["rcou_m"].append((m.C1, m.C2, m.C3, m.C4))
    return data


def ekf_gps_drop_mark(xkf_gps: list, xkf_t: list) -> float | None:
    for i in range(1, len(xkf_gps)):
        if xkf_gps[i - 1] >= 4 and xkf_gps[i] == 0:
            return xkf_t[i]
    return None


def plot_roll_ekf_desroll(
    out: Path,
    data: dict,
    arm_off: int,
    arm_on: int,
    ekf_mark: float | None,
) -> None:
    rc_t, rc_c1 = data["rc_t"], data["rc_c1"]
    att_t, des_r_deg = data["att_t"], data["des_r_deg"]
    xkf_t, xkf_gps, xkf_sv = data["xkf_t"], data["xkf_gps"], data["xkf_sv"]

    fig, axes = plt.subplots(3, 1, sharex=True, figsize=(11, 8.5), dpi=120)
    fig.subplots_adjust(left=0.08, right=0.92, top=0.92, bottom=0.12, hspace=0.35)
    fig.suptitle(
        "Rekon10 first flight: roll stick, EKF GPS health (XKF4 core 0), desired roll",
        fontsize=12,
    )

    ax0, ax1, ax2 = axes
    ax0.plot(rc_t, rc_c1, color="C0", lw=1.2, label="RCIN.C1 (roll PWM, us)")
    ax0.axvline(0.0, color="gray", ls="--", lw=0.8, alpha=0.7)
    ax0.axvline((arm_off - arm_on) / 1e6, color="gray", ls="--", lw=0.8, alpha=0.7)
    ax0.set_ylabel("RCIN.C1 (us)")
    ax0.legend(loc="upper right", fontsize=8)
    ax0.grid(True, alpha=0.3)
    ax0.set_title("Flight control roll input (flat = no roll stick command)")

    ax1b = ax1.twinx()
    (ln1,) = ax1.plot(xkf_t, xkf_gps, color="C2", drawstyle="steps-post", lw=1.4, label="XKF4.GPS (core 0)")
    (ln2,) = ax1b.plot(xkf_t, xkf_sv, color="C3", lw=1.0, alpha=0.85, label="XKF4.SV (core 0)")
    ax1.set_ylabel("XKF4.GPS (EKF diag)", color="C2")
    ax1.tick_params(axis="y", labelcolor="C2")
    ax1b.set_ylabel("XKF4.SV", color="C3")
    ax1b.tick_params(axis="y", labelcolor="C3")
    ax1.grid(True, alpha=0.3)
    ax1.set_title("EKF: GPS field steps 8 -> 0 near the DesRoll spike (see ArduPilot XKF4 docs for bit meaning)")
    ax1.legend(handles=[ln1, ln2], loc="upper left", fontsize=8)
    if ekf_mark is not None:
        for ax in (ax0, ax1, ax2):
            ax.axvline(ekf_mark, color="red", ls=":", lw=1.2, alpha=0.85)

    ax2.plot(att_t, des_r_deg, color="C1", lw=1.2, label="ATT.DesRoll (deg, from log rad)")
    ax2.set_ylabel("DesRoll (deg)")
    ax2.set_xlabel("Time (s) relative to ARM")
    ax2.legend(loc="upper right", fontsize=8)
    ax2.grid(True, alpha=0.3)
    ax2.set_title("Desired roll (controller target; spike without roll stick is anomalous in Stabilize)")

    fig.text(
        0.5,
        0.01,
        "Stabilize flight; RCMAP_ROLL=1 so RCIN.C1 is roll. ATT.DesRoll is radians in .bin; converted here. "
        "Vertical dashed: ARM (0 s) and DISARM. Red dotted: first XKF4.GPS drop from >=4 to 0 on core 0.",
        ha="center",
        fontsize=8,
        wrap=True,
    )

    fig.savefig(out)
    print("Wrote", out)


def plot_rc_desroll_roll(
    out: Path,
    data: dict,
    arm_on: int,
    arm_off: int,
    ekf_mark: float | None,
) -> None:
    fig, ax1 = plt.subplots(figsize=(11, 4.5), dpi=120)
    ax1.plot(data["rc_t"], data["rc_c1"], "b-", lw=1.1, alpha=0.85, label="RCIN.C1 (us)")
    ax1.set_ylabel("RCIN.C1 (PWM us)", color="b")
    ax1.tick_params(axis="y", labelcolor="b")
    ax1.axvline(0.0, color="gray", ls="--", lw=0.8, alpha=0.7)
    ax1.axvline((arm_off - arm_on) / 1e6, color="gray", ls="--", lw=0.8, alpha=0.7)
    if ekf_mark is not None:
        ax1.axvline(ekf_mark, color="red", ls=":", lw=1.1, alpha=0.85)

    ax2 = ax1.twinx()
    ax2.plot(data["att_t"], data["des_r_deg"], "g--", lw=1.2, label="ATT.DesRoll (deg)")
    ax2.plot(data["att_t"], data["roll_deg"], "r-", lw=1.0, alpha=0.8, label="ATT.Roll (deg, log)")
    ax2.set_ylabel("Angle (deg)", color="k")
    h1, l1 = ax1.get_legend_handles_labels()
    h2, l2 = ax2.get_legend_handles_labels()
    ax2.legend(h1 + h2, l1 + l2, loc="upper left", fontsize=8)
    ax1.set_xlabel("Time (s) relative to ARM")
    ax1.set_title("P1: RC roll input vs desired roll vs actual roll (first flight)")
    ax1.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(out)
    print("Wrote", out)


def plot_motors(out: Path, data: dict, arm_on: int, arm_off: int, ekf_mark: float | None) -> None:
    t, rows = data["rcou_t"], data["rcou_m"]
    if not t:
        print("Skip motors plot: no RCOU in window")
        return
    fig, ax = plt.subplots(figsize=(11, 4.5), dpi=120)
    for i, c in enumerate(["C1", "C2", "C3", "C4"]):
        ax.plot(t, [r[i] for r in rows], lw=1.0, label=f"RCOU.{c}")
    ax.axvline(0.0, color="gray", ls="--", lw=0.8, alpha=0.7)
    ax.axvline((arm_off - arm_on) / 1e6, color="gray", ls="--", lw=0.8, alpha=0.7)
    if ekf_mark is not None:
        ax.axvline(ekf_mark, color="red", ls=":", lw=1.1, alpha=0.85)
    ax.set_xlabel("Time (s) relative to ARM")
    ax.set_ylabel("PWM (us)")
    ax.set_title("P1: motor outputs RCOU.C1..C4 (first flight)")
    ax.legend(loc="upper left", fontsize=8)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(out)
    print("Wrote", out)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--bin",
        type=Path,
        default=Path("/mnt/c/Users/symmetry/Documents/1980-01-12 14-29-50.bin"),
        help="DataFlash .bin path",
    )
    ap.add_argument(
        "--out-dir",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "attachments" / "logs",
    )
    ap.add_argument("--pad-pre", type=float, default=0.8)
    ap.add_argument("--pad-post", type=float, default=1.2)
    args = ap.parse_args()

    if not args.bin.is_file():
        raise SystemExit(f"Missing log file: {args.bin}")

    log = DFReader_binary(str(args.bin))
    arm_on, arm_off = find_arm_window(log)
    data = collect(args.bin, arm_on, arm_off, args.pad_pre, args.pad_post)
    ekf_mark = ekf_gps_drop_mark(data["xkf_gps"], data["xkf_t"])

    args.out_dir.mkdir(parents=True, exist_ok=True)
    plot_roll_ekf_desroll(args.out_dir / "p1-roll-ekf-desroll.png", data, arm_off, arm_on, ekf_mark)
    plot_rc_desroll_roll(args.out_dir / "p1-rc-desroll-roll.png", data, arm_on, arm_off, ekf_mark)
    plot_motors(args.out_dir / "p1-motors.png", data, arm_on, arm_off, ekf_mark)


if __name__ == "__main__":
    main()
