# OpenMower OS Stack Discovery

This document summarizes how the OpenMower stack is orchestrated, where payload and configuration come from, and how to identify OS vs application versions. It is based on the OpenMowerOS, open_mower_ros, OpenMower, and openmower-cli repositories.

---

## 1. Build and Image Layout

### pi-gen.config

OpenMowerOS uses the pi-gen build system. The config file (`pi-gen.config`) defines:

- **Image identity:** `IMG_NAME="OpenMowerOS"`, `PI_GEN_RELEASE="OpenMowerOS v2.x"`
- **Platform:** `ARCH=arm64`, `RELEASE=trixie` (Debian Trixie)
- **Default user:** `TARGET_HOSTNAME="openmower"`, `FIRST_USER_NAME="openmower"`, SSH enabled
- **Locale:** `LOCALE_DEFAULT="en_GB.UTF-8"`, `KEYBOARD_KEYMAP="us"`, `TIMEZONE_DEFAULT="Europe/London"`
- **Stage list:** pi-gen stages 0, 1, 2 (lite) plus a single custom stage: `/stage-openmower`
- **Export:** `DEPLOY_COMPRESSION=zip`, `COMPRESSION_LEVEL=6`

### build_image.sh

- Wrapper that runs the pi-gen submodule build inside Docker.
- Requires the `ext/pi-gen` submodule to be initialized.
- Mounts `stage-openmower` into the build container as `/stage-openmower:ro`.
- Injects OpenMowerOS Git metadata into the container: `OMOS_GIT_HASH`, `OMOS_GIT_HASH_FULL`, `OMOS_GIT_DESCRIBE`, `OMOS_GIT_BRANCH` (used by stage 05-version-info).
- Optional: `GITHUB_TOKEN` for openmower-cli fetch; `MAP_LOOP_DEVICES=1` for loop devices; `FRESH=1` for clean build; `CLEAN_LOOPS=1` for loop cleanup.
- Invokes `./build-docker.sh -c pi-gen.config` in the pi-gen directory.

### stage-openmower and Stage List

The custom stage is one pi-gen "stage" directory that itself runs multiple sub-stages in order via a prerun that rsyncs the previous rootfs. The effective order and purpose of each sub-stage:

| Stage | Purpose |
|-------|---------|
| **05-version-info** | Writes OS version metadata to `/usr/share/openmoweros/` (version.json, version.yaml, version.sh, version.txt) from pi-gen.config and injected Git env (OMOS_*). |
| **10-pi-serial** | Frees serial for hardware: removes serial console from cmdline.txt, masks serial-getty units (ttyAMA0-4, ttyS0, serial0). |
| **15-pi-config** | Raspberry Pi imager/customization: installs `imager_custom`, `userconf`, and a boot config addendum; chroot appends addendum to `/boot/firmware/config.txt`. |
| **20-comitup** | WiFi provisioning: installs comitup, NetworkManager, wpasupplicant; configures AP name `OpenMower-<nnn>` and external callback for dnsmasq; enables comitup and comitup-nm-wifi-ensure. |
| **25-lan** | LAN/network: NetworkManager conf for LAN, `/etc/network/interfaces`, dnsmasq config for OpenMower; disables pi-gen export-image resolv.conf injection. |
| **30-docker** | Docker Engine: official Docker APT repo, docker-ce and compose plugin; enables docker and docker-preload-images; adds user `openmower` to docker group; journald log driver; optional bundled images under `/opt/docker-images`. |
| **32-dockge** | Dockge: installs dockge.service (WorkingDirectory=/opt/dockge, `docker compose up -d` / `down`), `/opt/dockge/data` (e.g. db-config.json); on start, service updates `HOSTNAME` in `/opt/stacks/openmower/.env` from `hostname -f`; enables dockge.service. |
| **35-webterminal** | Web terminal stack at `/opt/stacks/webterminal` and webterminal.service; enabled for automatic start. |
| **40-openmower** | OpenMower stack: copies compose, .env, mosquitto.conf and default `mower_params.yaml` into image; creates/openmower dirs and installs openmower-cli from GitHub; no systemd unit that auto-starts the OpenMower compose stack (stack is started via Dockge UI or `openmower start`). |
| **45-openocd** | OpenOCD for xCore: builds and installs Raspberry Pi OpenOCD (bootstrap/configure/make) with ftdi, sysfsgpio, bcm2835gpio, linuxgpiod; installs `xcore.cfg` for openmower-cli (SWD via linuxgpiod, GPIO 27/22) under `~/.config/openmower-cli/` for openmower and root. |

There are also **50-extras**, **99-cleanup**, and **EXPORT_IMAGE** in the tree; the table above covers the main sequence you asked about.

---

## 2. Where the Payload Comes From

### compose.yaml and .env

- **Location on image:** `/opt/stacks/openmower/compose.yaml` and `/opt/stacks/openmower/.env` (installed by stage 40-openmower).
- **ROS image:** `ghcr.io/clemenselflein/open_mower_ros:${VERSION}`. The `VERSION` variable comes from `.env` (e.g. `latest`, `x.y.z`, or `edge`). After changing `VERSION`, users must run "Update" in Dockge or `openmower pull` (and typically restart).
- **Other services in compose:** Mosquitto (eclipse-mosquitto:2), OpenMowerApp (ghcr.io/clemenselflein/openmowerapp:latest). The open_mower_ros service uses `env_file: .env` and mounts `/home/openmower/ros`, `/home/openmower/recordings`, `/home/openmower/params` to `/data/ros`, `/data/recordings`, `/data/params` with matching environment variables.

### .env Variables and Their Use

| Variable | Role |
|----------|------|
| **VERSION** | Container image tag for open_mower_ros (e.g. `latest`, `x.y.z`, `edge`). |
| **HARDWARE_PLATFORM** | `1` = v1 hardware, `2` = v2 boards. Used by open_mower_ros launch files (e.g. `_params.launch`, `_comms.launch`) and by openmower-cli to choose command set. |
| **MOWER** | Mower model: YardForce500, YardForceSA650, Worx, Sabo, CUSTOM, etc. Drives which hardware_specific params are loaded (e.g. `params_v2.yaml`, comms files). |
| **FIRMWARE** | Robot/firmware variant (e.g. yardforce, sabo for v2; 0_13_X, 0_12_X_LSM6DSO, etc. for v1). Used for firmware update and compatibility. |
| **ESC_TYPE** | V1 only: xesc_mini, xesc_mini_w_r4ma, xesc_2040, etc. Selects `comms_$(ESC_TYPE)_params.yaml`. |
| **DEBUG** | Log verbosity; set to False in production to reduce log volume and SD wear. Passed into the container via env_file. |
| **HOSTNAME** | Written by dockge.service on start (from `hostname -f`); used in compose x-dockge URLs and for UI access. |

---

## 3. Where Config and State Live on the Image

### Paths

- **`/home/openmower/params`** – User-editable parameters. Contains at least `mower_params.yaml` (datum, NTRIP, mower_logic, etc.). For CUSTOM mower, `custom_params.yaml` is loaded from here. Mounted into the container as `/data/params` and exposed as `PARAMS_PATH`.
- **`/home/openmower/ros`** – ROS state: maps, bag files, and other runtime data. Mounted as `/data/ros`; `ROS_HOME` is set to `/data/ros`.
- **`/home/openmower/recordings`** – Recording output (e.g. rosbag). Mounted as `/data/recordings`; `RECORDINGS_PATH` set in compose.
- **`/opt/stacks/openmower/`** – Stack definition: `compose.yaml`, `.env`, `mosquitto.conf`. Edited via Dockge UI or directly; dockge.service updates `HOSTNAME` in `.env` on start.

### Boot-Time / First-Run Creation

- **40-openmower (00-run.sh):** Copies a single default `mower_params.yaml` into `ROOTFS_DIR/home/openmower/params/` and creates `/opt/stacks/openmower` with compose, .env, mosquitto.conf.
- **40-openmower (00-run-chroot.sh):** Runs inside chroot: sets ownership to `openmower` for `/home/openmower/` and `/opt/stacks/openmower/`; adds user to docker group; creates directories `recordings`, `ros`, `params` under `/home/openmower` and sets ownership (1000:1000); creates `/data` and symlink `/data/ros` -> `/home/openmower/ros`; installs openmower-cli from GitHub (latest release zip) to `/usr/local/bin/openmower` and installs shell completion. No separate first-boot or one-shot service was found that creates these dirs; they are created at image build time in this chroot step.

---

## 4. How the Stack Is Started

### Dockge vs Direct Compose

- **Dockge:** The `dockge.service` runs in `/opt/dockge` and executes `docker compose up -d` / `docker compose down` for the Dockge stack itself (the orchestrator UI). The OpenMower stack is not started by this unit; it is a separate stack that users add and manage in the Dockge UI (pointing at `/opt/stacks/openmower`), or start/stop from the CLI.
- **Direct compose:** The openmower-cli always uses the compose file at `/opt/stacks/openmower/compose.yaml` (overridable with `OPENMOWER_COMPOSE_FILE`) and runs `docker compose -f <that file> ...`.

### dockge.service

- **Unit:** Installed under `/etc/systemd/system/dockge.service` by stage 32-dockge.
- **ExecStartPre:** Updates `HOSTNAME` in `/opt/stacks/openmower/.env` from `hostname -f` (or hostname / /etc/hostname).
- **ExecStart:** `/usr/bin/docker compose up -d` (in `/opt/dockge` – i.e. starts Dockge, not the openmower stack).
- **ExecStop:** `/usr/bin/docker compose down`.
- **Wants/After:** network-online, docker, docker-preload-images, time-sync.

### openmower CLI

- **Compose file:** Default `/opt/stacks/openmower/compose.yaml` (env: `OPENMOWER_COMPOSE_FILE`).
- **Commands:** `pull` (stops, pulls images, starts), `start`, `stop`, `restart`, `status` (compose ps), `logs` (follow, optional service filter), `shell` / `exec` (default service `open_mower_ros`). All use `docker compose -f /opt/stacks/openmower/compose.yaml`.
- **Environment:** CLI reads `/opt/stacks/openmower/.env` (or `OPENMOWER_ENV_PATH`) for variables such as `HARDWARE_PLATFORM`; `.env` is not necessarily loaded into the shell, but the CLI uses it for compose and for its own logic (e.g. firmware/update commands).

---

## 5. Version and Identity

### OS Version: /usr/share/openmoweros/

Written by stage **05-version-info** (outside chroot, using Git env and pi-gen.config):

- **version.json** – Machine-readable: name, display_version, release, arch, git (hash, hash_full, describe, branch), build_time_utc.
- **version.yaml** – Same fields in YAML.
- **version.sh** – Sourced to set `OPENMOWEROS_*` variables (name, display_version, release, arch, git.*, build_time_utc).
- **version.txt** – Human-readable one-line summary plus Git and build time.

So **OS version** is the OpenMowerOS image build identity (PI_GEN_RELEASE, Git describe, build time). It is fixed at image build and does not change when the container image is updated.

### ROS / Container Version

- **Application (ROS) version** is determined by the container image tag: `${VERSION}` in `.env` (e.g. `latest` or `x.y.z`) for `ghcr.io/clemenselflein/open_mower_ros:${VERSION}`. Inspect with `docker inspect` on the running container or by reading `.env` and the image digest/tag after `openmower pull` or Dockge "Update".

**Summary:** Use `/usr/share/openmoweros/version.*` for OS/build identity; use `.env` (VERSION) and the actual image tag/digest for the application (ROS) version.

---

## 6. xCore / OpenOCD Stage (45-openocd) and Mainboard Firmware

- **45-openocd** installs OpenOCD from the Raspberry Pi openocd repo (bootstrap, configure with ftdi/sysfsgpio/bcm2835gpio/linuxgpiod, make install). It does not install mainboard firmware; it provides the tooling to flash and debug the xCore.
- **xcore.cfg** is installed for openmower-cli: adapter `linuxgpiod`, SWD on GPIO chip 0, pins 27 (swclk) and 22 (swdio). This is used when running OpenOCD (e.g. for firmware upload or debugging) from the Pi against the xCore board.
- **Mainboard firmware** for v2 comes from the firmware repo (e.g. xtech/fw-openmower-v2); the openmower-cli uses `OPENMOWER_FW_REPO` and related env to download and flash. The OpenMower hardware repo (OpenMower) contains v1 firmware under `Firmware/` and `Hardware/`; v2 firmware and robots are documented in the OpenMower docs and the firmware repo. The 45-openocd stage only provides the OpenOCD binary and the xcore.cfg so that openmower-cli (or manual OpenOCD) can talk to the xCore over GPIO for flashing/debugging.

---

## Repositories Referenced

- **OpenMowerOS** – pi-gen image build, stage-openmower stages, compose and .env in `stage-openmower/40-openmower/files/opt/stacks/openmower/`.
- **open_mower_ros** – ROS workspace: params, launch files (e.g. `_params.launch`, `_comms.launch`), config schema, services.
- **OpenMower** – Main hardware repo; v1 firmware under Firmware/, Hardware/.
- **openmower-cli** – CLI that drives the stack (pull, start, stop, status, shell, logs, etc.) using `/opt/stacks/openmower/compose.yaml`.
