# OpenMower kikuyu – current state snapshot

Gathered on device per onboard-instructions.md. No changes were made; this is inspection only.

---

## 1. OS identity

- **OpenMowerOS:** Not present. No `/usr/share/openmoweros/` (no version.txt or version.json).
- **Host OS:** Debian GNU/Linux 11 (bullseye), aarch64.
- **Kernel:** Linux kikuyu 6.1.21-v8+ #1642 SMP PREEMPT Mon Apr 3 17:24:16 BST 2023.
- **Conclusion:** This is a **legacy/CustomPiOS-style** setup, not the newer OpenMowerOS image. Stack is managed via systemd + podman and `/boot/openmower/`, not `/opt/stacks/openmower/`.

---

## 2. Stack env and compose

- **`/opt/stacks/openmower/`:** Does not exist. No `.env` or `compose.yaml` in the doc's sense.
- **Effective "stack" config:** `/boot/openmower/`:
  - **openmower_version.txt:** `OM_VERSION=beta` (and export).
  - **mower_config.txt:** Sourced as `/config/mower_config.sh` inside the container. Key values:
    - `OM_HARDWARE_VERSION="0_13_X"`
    - `OM_DATUM_LAT` / `OM_DATUM_LONG` set (Pennsylvania).
    - `OM_USE_NTRIP=True`, NTRIP host `acebase.ad.local.symmatree.com`, port 2101, endpoint ATTIC, user/password set.
    - `OM_MOWER="YardForce500"`, `OM_MOWER_ESC_TYPE="xesc_mini"`, `OM_USE_RELATIVE_POSITION=False`, `OM_GPS_PROTOCOL=UBX`, `OM_USE_F9R_SENSOR_FUSION=False`.
- No compose file; a single podman container is started by systemd.

---

## 3. Docker / Podman – what is actually running

- **Runtime:** **Podman** only (`/usr/bin/podman`). Docker is not used.
- **Containers:**
  - **openmower** (from openmower.service): Starts then exits in ~1 s; systemd restarts it every 15 s. Restart counter in the thousands (e.g. 5407). So **no stable running openmower container**.
  - **openmower-debug:** One container with image `ghcr.io/clemenselflein/open_mower_ros:releases-beta`, status **Created** (not running), ~18 months old.
- **Images (relevant):**
  - `docker.local.symmatree.com/open_mower_ros:latest-arm64` – used by both service files (openmower + openmower-debug), ~21 months old.
  - `docker.local.symmatree.com/open_mower_ros:kikuyu-latest` – same age.
  - `ghcr.io/clemenselflein/open_mower_ros:releases-beta` – ~2 years old.
- **Cause of exit:** The container entrypoint runs ROS Noetic setup then `roslaunch open_mower open_mower.launch`. The launch fails with: **`ROS_MASTER_URI: unbound variable`**. So the script uses strict mode and expects `ROS_MASTER_URI` to be set; it is not set in the service or container env, so the process exits and the container dies.

---

## 4. openmower CLI and stack state

- **CLI:** `openmower` is **not** installed (no `which openmower`). This matches an old OS without openmower-cli.
- **Stack state:** openmower.service is in a **crash loop**; openmower-debug is inactive. So there is no healthy "stack" from the service side.

---

## 5. Params and map

- **Paths:** No `/home/openmower/params/` in the doc's sense. Config and ROS home live under:
  - **`/root/ros_home/`** – used as container's `$HOME` (mount `-v /root/ros_home:/root`). Contains bag files, `.ros/`, `.config/`, README; no `mower_params.yaml` or `map.json` in the listing.
  - **`/boot/openmower/mower_config.txt`** – the main config (see section 2). Params are effectively driven by this file and the image's hardware-specific YAMLs.
- **Repo params (from /home/pi/open_mower_ros):** YardForce500 GPS uses **`/dev/ttyAMA1`**, low-level on ttyAMA0; ESCs on ttyAMA2/3/4. So **GPS serial = ttyAMA1**, 921600 in config comments.
- **map.json:** Not found under `/root/ros_home` or `/home/openmower` in the checks; may be created at runtime or live inside a different path.

---

## 6. Serial forwarding (ser2net) and u-center

- **ser2net:** Installed and **enabled**; service is **active (running)**.
- **Config:** `/etc/ser2net.yaml`. There is a **ublox** connection: **TCP 8900 → /dev/ttyAMA1, 921600n81, local**. So the intent is to expose the GPS serial port for u-center on port 8900.
- **Problem:** ser2net logs **"Invalid port name/number" / "Invalid data to parameter"** for several lines (e.g. 25, 36, 47, 58, 67). The connector is split across multiple lines; ser2net 4 expects a **single-line** connector, e.g. `connector: serialdev,/dev/ttyAMA1,921600n81,local`. With the current multiline form, the parser likely misreads the value, so the **ublox (port 8900) connection may not be active** even though the process runs.
- **For u-center:** From a Windows box, you would connect to **kikuyu (or kikuyu.local.symmatree.com):8900** as a raw TCP port. First step is to fix the ser2net connector syntax so that the 8900 line is valid, then test.

---

## 7. Systemd units

- **openmower.service:** Uses image `docker.local.symmatree.com/open_mower_ros:latest-arm64`; mounts `/boot/openmower/mower_config.txt`, `/root/ros_home`, `/root/rosconsole.config` as ROSCONSOLE_CONFIG_FILE; `EnvironmentFile=/boot/openmower/openmower_version.txt`. Type=forking, Restart=always, 15 s. **Conflict:** Conflicts with openmower-debug.service.
- **openmower-debug.service:** Same image (per current unit file); same mounts except no rosconsole.config; Restart=on-failure. Used for interactive/debug runs.
- **rosconsole.config:** `/root/rosconsole.config` exists: `log4j.threshold=OFF`.

---

## 8. Summary vs doc and suggested next steps

| Doc assumption | Actual state |
|----------------|--------------|
| OpenMowerOS, `/usr/share/openmoweros/` | Not present; Debian 11, legacy stack |
| `/opt/stacks/openmower/`, Docker, compose | No such path; Podman, no compose; config in `/boot/openmower/` |
| openmower CLI | Not installed |
| Stable running stack | openmower.service in crash loop (ROS_MASTER_URI unbound) |
| Serial forward for u-center | ser2net running but config syntax errors; port 8900 may not work |

**Suggested order of action (no changes made; for your approval):**

1. **Serial forwarder for u-center (first step):**  
   - Stop openmower.service so the container is not repeatedly starting and exiting (and so it is not holding `/dev/ttyAMA1` if it ever did).  
   - Fix `/etc/ser2net.yaml`: put every `connector:` value on a single line (e.g. `connector: serialdev,/dev/ttyAMA1,921600n81,local` for the ublox block). Restart ser2net and test from Windows: connect to `kikuyu:8900` with u-center (raw TCP). That gives "sky as seen by that GPS" without needing the full stack.

2. **Stable stack (after you're ready):**  
   - Set `ROS_MASTER_URI` for the openmower container (e.g. `ROS_MASTER_URI=http://localhost:11311` in the systemd service or in the image entrypoint) so the launch script does not hit "unbound variable" and the container can stay up.  
   - Then re-assess: try lock with current stack; if that works, you can defer upgrades. If not, consider updating images/params or moving to OpenMowerOS as in the discovery docs.

3. **Upgrade path:** The discovery docs (openmower-architecture.md etc.) describe the newer OpenMowerOS and `/opt/stacks/openmower/`. Getting there would mean reflashing or a larger migration; that's a separate decision once the current state is stable and GPS is observable via u-center.

---

*End of current-state snapshot.*
