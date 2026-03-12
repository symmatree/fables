# OpenMower Documentation Summary

Summary of the official OpenMower documentation (from [openmower.de](https://openmower.de) docs under `content/en/docs/`). Covers configuration, testing, monitoring, debugging, and customization/replacement of the stack.

---

## 1. Step-by-step build and setup

### 1.1 Prepare SD Card

- **Lite CM4 only** (no eMMC): Flash OpenMowerOS with Raspberry Pi Imager.
- **Image:** [OpenMowerOS releases](https://github.com/ClemensElflein/OpenMowerOS/releases) (download from Assets; no need to unpack).
- **Steps:** Imager -> Raspberry Pi 4 -> Use Custom (select image) -> Choose SD card (min 16 GB) -> Write. User is always `openmower`; older Imager cannot rename user.
- **CM4 with eMMC:** Skip SD step; flash eMMC per [Raspberry Pi CM4 docs](https://www.raspberrypi.com/documentation/computers/compute-module.html#flash-compute-module-emmc).
- **Ref:** `content/en/docs/step-by-step/2-robot-modification/prepare-the-parts/prepare-sd-card/index.md`

### 1.2 Prepare mainboard

- Assemble xCore + CM4 (+ optional heat sink), insert xCore into mainboard, then xESCs and GPS. Insert SD before closing if using Lite CM4.
- **Ref:** `content/en/docs/step-by-step/2-robot-modification/prepare-the-parts/prepare-mainboard/index.md`

### 1.3 Prepare GPS

- **Ardusimple F9P:** Update to ZED-F9P HPG 1.51 (L1+L2 variants: ZED-F9P-02B/04B/05B only). Use u-center v1 (not v2), load `robot-fw-1_51.txt` via Tools -> Receiver Configuration, then save to Flash (CFG -> Save current configuration, BBR + FLASH, Send).
- **WitMotion UM9xx:** Serial at 115200 (CR/LF); `FRESET` then `CONFIG COM1 921600`; apply rover config commands and `SAVECONFIG`.
- **Ref:** `content/en/docs/step-by-step/2-robot-modification/prepare-the-parts/prepare-the-gps/index.md`

### 1.4 Software setup (overview)

- Ensure mower does not run out of power (e.g. in dock) during setup.
- **Ref:** `content/en/docs/step-by-step/3-software-setup/_index.md`

### 1.5 Connect WiFi

- Power on; connect to hotspot `OpenMower-<number>`; open [http://10.41.0.1/](http://10.41.0.1/) to configure WiFi; enter home network and connect. Verify: `ping openmower.local`, SSH to `openmower@openmower.local`, browser terminal at [http://openmower.local:7681/](http://openmower.local:7681/).
- **Ref:** `content/en/docs/step-by-step/3-software-setup/connect-wifi/index.md`

### 1.6 Basic configuration (env, firmware, xESC)

- **Terminal:** SSH or browser terminal at [http://openmower:7681](http://openmower:7681).
- **openmower CLI:** Edit env/ROS, install firmware, start/stop ROS, show logs, ROS shell. Update tool: `sudo openmower update-self`.
- **Checks:** `df -h /`; if filesystem nearly full, run `sudo raspi-config` -> Advanced -> Expand Filesystem, then reboot.
- **Environment:** `openmower configure env` -> set mower model and hardware version; tool fetches selected ROS (~30 min).
- **Firmware (xCore):** `openmower update-firmware`. If timeouts, run `openmower update-bootloader` then retry.
- **xESC:** Stop ROS first (`openmower stop`); configure via VESC Tool over TCP (see Knowledge Base: Configuring xESC).
- **Ref:** `content/en/docs/step-by-step/3-software-setup/basic-configuration/index.md`

### 1.7 Configure ROS

- `openmower configure ros` to edit ROS parameters. Set at least: `gps/baud_rate`, `gps/protocol`, `gps/datum_lat`, `gps/datum_long`, and `ntrip_client/*` for base station.
- **Ref:** `content/en/docs/step-by-step/3-software-setup/setup-ros/index.md`

### 1.8 Record areas and use the mower

- **Prereqs:** Robot on network, OpenMower running, dock powered, mower charged. **GPS:** Mower outside; wait for RTK Fixed (up to ~30 min) in OpenMower app.
- **Orientation:** Drive 50 m+ (straight + figure eights) via app joystick or USB gamepad (hold A). Do not lift mower.
- **Map:** Docking position + at least one mowing area + optional navigation areas. Outline: drive counterclockwise, Start/Stop Recording. Exclusions: clockwise. Finish Area -> save as mowing or navigation. Docking: record point ~2 m in front, then at dock edge (wheels at edge), then drive in. Exit Recording -> IDLE -> Start to mow.
- **Ref:** `content/en/docs/step-by-step/4-record-areas-and-use-it/index.md`, `content/en/docs/Knowledge-Base/record-areas/index.md`

---

## 2. Knowledge base (key topics)

| Topic | Summary | Doc path |
|-------|---------|----------|
| **Compatible mowers** | YardForce (Classic 500(B), SA/SC/LUV/N/NX 2019+; not Amiro/Compact/EasyMow/MowBest/XPower/MB). SABO MOWit 500F, John Deere Tango E5 (Series I/II). Universal board: Husqvarna, Gardena, Fuxtec/Redback, custom. | `Knowledge-Base/compatible-mowers/index.md` |
| **Change hostname** | `sudo raspi-config` -> System Options -> Hostname; reboot. | `Knowledge-Base/change-hostname/index.md` |
| **External WiFi antenna** | Edit `/boot/firmware/config.txt` in `[cm4]`: comment `# dtparam=ant1`, uncomment `dtparam=ant2`; reboot. | `Knowledge-Base/external-wifi-antenna/index.md` |
| **Record areas** | See step 1.8; app at `http://openmower.local:8080` or `http://<IP>:8080`. | `Knowledge-Base/record-areas/index.md` |
| **Hardware versions / known issues** | v2: check YardForce/SABO/Universal repos. Legacy v1: 0.13/0.12/0.11/0.10/0.9.3; errata (Outdated Firmware, IC2 chip wrong, rain sensor cable) linked from archive. | `Knowledge-Base/hardware-versions/index.md` |
| **Configuring xESC** | `openmower stop`; `openmower expose-xesc [left|right|mower]` -> VESC Tool TCP to `openmower:65102`. Preset configs (e.g. YardForce) or SABO/John Deere tuning (FOC calibration, motor/app XML). | `Knowledge-Base/configure-xesc/index.md` |
| **Firmware update** | xCore: `openmower update-firmware` (and `openmower update-bootloader` if timeouts). | `Knowledge-Base/firmware-update/index.md` |
| **GPS / coordinate system** | Local 2D ENU; origin user-chosen or base station; VRP + orientation. | `Knowledge-Base/rtk-gps/index.md` |
| **GPS base setup** | Example: RPi 0W + ZED-F9P + RTKBase; NTRIP caster for mower. | `Knowledge-Base/rtk-base-setup/index.md` |
| **Shopping list** | Mower, OpenMower kit (v2: contact @Apehaenger on Discord), Ardusimple RTK2B or UM9xx, RPi4, SD 16GB+ (32GB recommended). Optional: USB WiFi dongle, left-angle USB adapter. Base station only if no external NTRIP. | `Knowledge-Base/shopping-list/index.md`, `docs/getting-started/index.md` |
| **The map** | Stored in `/home/openmower/ros_home/map.json`. Defines navigation areas, mowing areas, exclusions (outline + obstacles), docking position. | `Knowledge-Base/the-map/index.md` |

---

## 3. Troubleshooting

### 3.1 GPS-RTK

- Follow [GPS setup](content/en/docs/step-by-step/2-robot-modification/prepare-the-parts/prepare-the-gps/index.md). Connect GPS to PC; in u-center ensure "Protocol of received messages" is UBX (re-upload config if NMEA). Antenna connected, test outside; Deviation Map (View -> Deviation Map, F12) ~1 m for single; clean with File -> Database clean. Configure NTRIP (Receiver -> NTRIP Client) same as ROS; green status, deviation at center, "No RTK" gone. On mainboard, wait for green or green/red LED. In ROS: `rostopic echo --clear -w 5 /ll/position/gps`: `flags: 3` = RTK fix, `position_accuracy` in meters (e.g. 0.024 = ~2.5 cm).
- **Ref:** `content/en/docs/troubleshooting/gps-rtk/index.md`

### 3.2 Map / recording areas

- Map path: `/home/openmower/ros_home/map.json`. Backup: copy `map.json` (e.g. via SSH/SFTP). Delete map: `openmower stop`; `rm /home/openmower/ros_home/map.bag /home/openmower/ros_home/map.json`; restart.
- **Ref:** `content/en/docs/troubleshooting/map/index.md`

---

## 4. Firmware, ROS/params, monitoring, debugging

### 4.1 Firmware (mainboard, xESC, GPS)

- **xCore (mainboard):** `openmower update-firmware`; on timeout run `openmower update-bootloader` then retry. Uses env to pick correct binary, upload via Ethernet.
- **xESC:** No separate "firmware update" in docs; configuration only via VESC Tool (motor/app XML).
- **GPS:** Ardusimple F9P: update to HPG 1.51 via u-blox/Ardusimple procedure; config via u-center and save to Flash. UM9xx: serial commands only.

### 4.2 Inspect or change ROS / params

- **Edit params:** `openmower configure ros` (opens editor, typically `mower_params.yaml` under `/home/openmower/params/`). Env: `openmower configure env`.
- **Params include:** GPS (baud_rate, protocol, datum), NTRIP client, MQTT/smart-home, mowing behavior, etc.

### 4.3 Monitoring and debugging

- **OpenMower app (web):** `http://openmower.local:8080` or `http://<IP>:8080` — GPS quality, map, recording, joystick, start/stop mowing.
- **Browser terminal:** [http://openmower.local:7681](http://openmower.local:7681) (no credentials).
- **SSH:** `ssh openmower@openmower.local` (see docs for credentials).
- **openmower tool:** Start/stop ROS, show ROS logs, enter ROS shell for debugging.
- **ROS:** e.g. `rostopic list`, `rostopic echo /ll/position/gps` for GPS; run from ROS shell after starting ROS.
- **MQTT / Home Assistant:** ROS parameters include MQTT configuration for smart-home; Overview and updates mention Home Assistant integration (community).

### 4.4 Replace or customize software (own images, params)

- **Params:** Edit `mower_params.yaml` (via `openmower configure ros`) and env (via `openmower configure env`); no need to replace images for param-only changes.
- **OS image:** OpenMowerOS is a custom RPi image (Docker, hotspot, networking); custom images would replace this (build from OpenMowerOS/community sources).
- **ROS:** Env selects ROS version; tool fetches it. Custom ROS would require changing how the stack is launched (open_mower_ros repo).
- **Ref:** Overview states firmware, app, and ROS are open source for inspection, customization, and contribution; Links point to OpenMower (hardware/firmware), open_mower_ros, xESC repos.

---

## 5. v1-specific notes and errata

- **v1 legacy docs:** For v1 hardware (full-size Raspberry Pi, mainboard v0.xx), use legacy docs: [https://openmower.de/archive/v1.0.2/docs](https://openmower.de/archive/v1.0.2/docs). v1 also requires modifying the docking station; current step-by-step is v2-only for YardForce.
- **v1 hardware redirect:** [YardForce Classic 500(B) v1 Hardware](https://openmower.de/archive/v1.0.2/docs) linked from `robot-specific-guides/YardForce-Classic-500-B-v1-Hardware/index.md`.
- **Errata (v1, referenced in hardware-versions):**
  - **Outdated Firmware:** Kits shipped before May'23 — [openmower.de/archive/v1.0.2/docs/versions/errata/outdated-firmware/](https://openmower.de/archive/v1.0.2/docs/versions/errata/outdated-firmware/).
  - **IC2 chip wrong:** Kits shipped before May'23 — [openmower.de/archive/v1.0.2/docs/versions/errata/ic2-is-wrong/](https://openmower.de/archive/v1.0.2/docs/versions/errata/ic2-is-wrong/).
  - **Rain sensor cable:** Female but needs male — [wrong-rain-sensor-cable](https://openmower.de/archive/v1.0.2/docs/versions/errata/wrong-rain-sensor-cable/).
- **v2 recommended:** New builds should use v2 hardware; v1 remains supported for existing owners.

---

## 6. Doc links (published URLs)

- **Docs home:** [https://openmower.de/docs](https://openmower.de/docs)
- **Getting started:** [https://openmower.de/docs/getting-started](https://openmower.de/docs/getting-started)
- **Step-by-step:** [https://openmower.de/docs/step-by-step](https://openmower.de/docs/step-by-step)
- **Knowledge Base:** [https://openmower.de/docs/Knowledge-Base](https://openmower.de/docs/Knowledge-Base)
- **Troubleshooting:** [https://openmower.de/docs/troubleshooting](https://openmower.de/docs/troubleshooting)
- **Compatible mowers:** [https://openmower.de/docs/Knowledge-Base/compatible-mowers](https://openmower.de/docs/Knowledge-Base/compatible-mowers)
- **Record areas:** [https://openmower.de/docs/Knowledge-Base/record-areas](https://openmower.de/docs/Knowledge-Base/record-areas)
- **Firmware update:** [https://openmower.de/docs/Knowledge-Base/firmware-update](https://openmower.de/docs/Knowledge-Base/firmware-update)
- **Configure xESC:** [https://openmower.de/docs/Knowledge-Base/configure-xesc](https://openmower.de/docs/Knowledge-Base/configure-xesc)
- **GPS-RTK troubleshooting:** [https://openmower.de/docs/troubleshooting/gps-rtk](https://openmower.de/docs/troubleshooting/gps-rtk)
- **Map troubleshooting:** [https://openmower.de/docs/troubleshooting/map](https://openmower.de/docs/troubleshooting/map)
- **v1 archive:** [https://openmower.de/archive/v1.0.2/docs](https://openmower.de/archive/v1.0.2/docs)

Source of this summary: OpenMower docs in workspace at `/home/symmetry/openmower.de`, directory `content/en/docs/`.
