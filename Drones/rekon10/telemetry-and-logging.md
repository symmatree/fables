# Telemetry and logging (Rekon10)

Long-form telemetry topology, bench validation, and task notes for the Rekon10. Index and dependency graph: Cursor plan `~/.cursor/plans/rekon10_post-first-flight_debrief_033b686b.plan.md`.

---

## P6 GPS bench validation (M100 Pro, u-center2)

**Bench chain:** FT232H -> known-good pigtail -> **new JST 4-pin plug** -> M100 Pro pigtail -> M100 Pro. FC validation stays in **P7** (SERIAL2 GPS on the Lucid stack).

### What we actually saw (2026-04-19)

**u-center2 (Windows, current install):** Main UI **`interface: unknown`**. **Configuration Send** and UBX **Enable / Disable / Poll** (including for **NAV-PVT**) are **greyed**; this session did not use those controls. The log still decodes **UBX-NAV-PVT** at **10 Hz** on the bench link. **MON-VER** was read once; text captured below.

**Same session, beyond u-center2 menus:** The unit **ACKs** other traffic in the tool's indicators, but **VALGET does not populate** and **enabling messages does not change what flows**. Recorded as-is for P7; no separate root-cause pass here.

**Baud:** **115200** on the ArduPilot side is already how the Rekon10 stack is set (**`SERIAL2_BAUD = 115`** with GPS on **SERIAL2**). The module presents **UBX-NAV-PVT at 10 Hz** on the bench path; nothing in this write-up re-opens baud as an open question.

### MON-VER (verbatim capture)

| Field | Value |
|-------|--------|
| `swVersion` | ROM SPG 5.10 (7b202e) |
| `hwVersion` | 000A0000 |
| Extensions | `FWVER=SPG 5.10`, `PROTVER=34.10`, `GPS;GLO;GAL;BDS SBAS;QZSS` |

No separate **`MOD=`** line appeared in the UI capture.

### Working model for this module (bench + FC planning)

Firmware behaves as **minimal host-facing UBX**: steady **UBX-NAV-PVT at 10 Hz**, **MON-VER** for identification, and **little or no effective CFG / VALGET** from the paths we tried. That is enough for stacks that only need a **PVT stream** at a known baud. A full u-center2 / textbook u-blox **CFG** workflow is not the right expectation for this unit.

The original P6 **u-center2 checklist** (MON-COMMS, MSG toggle ACK, VALSET bake-in, `.ubx` export, and so on) is **dropped**: the tool **cannot** drive CFG on this link, and the module **does not** expose the scripted readbacks. That procedure was written for a cooperative u-blox + u-center2 pair; **this bench session is not that**.

### Bench takeaway (not a u-center2 scorecard)

- **JST + UART path:** Continuous **UBX-NAV-PVT at 10 Hz** through the new plug chain is **consistent with a good physical link** for the data the FC actually needs first.
- **ArduPilot next step (P7, not guessed here):** With **`GPS_AUTO_CONFIG = 0`**, stop asking the FC to **push** a full u-blox autoconfig sequence against a module that does not behave like a textbook responder; then judge **fix, HDOP, STATUSTEXT, and Loiter pre-arm** on the real **SERIAL2** wiring. Whether Loiter arms is **unknown until that run**; that is normal troubleshooting, not a missing promise from this section.

**No `GPS1_TYPE` change is required** for the argument above: the stack already showed **3D fix** with detection as-is.

---

## P1 First-flight log analysis

Stub for Task P1 from the debrief plan. Content to be filled when the .BIN is processed.

---

## P2 OSD/SRT replay

Stub for Task P2. Content to be filled when walksnail-osd-tool runs are captured.

---

## P3 Telemetry scaffold reference (SR6)

Stub: SR6 bandwidth budget and lean `SR6_*` proposal live in the plan body until merged here under a dedicated reference heading.

---

## P4 UDP MAVLink over WiFi

Stub for Task P4.

---

## P5 USB telemetry

Stub for Task P5.

---

## P7 GPS reinstall and FC verification

Stub for Task P7. Do not reinstall the GPS on the FC until P6 verdict is green.

---

## P8 OSD screens on P3

Stub for Task P8.

---

## P9 Switch bug, logging tiering, build log

Stub for Task P9.

---

## P10 Tooling inventory

Stub for Task P10.
