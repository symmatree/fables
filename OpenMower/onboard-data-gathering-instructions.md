# Onboard data-gathering: instructions for the agent

This document is for the "future self": an agent (or you) working **on the mower** via Remote-SSH or an SSH terminal. It provides context and step-by-step instructions for the next phase of work. The holistic picture (repos, plans, discovery docs) lives on the **dev machine**; this file is the tendril so you can work onboard without needing everything checked out on the RPi.

---

## 1. Context

- **Robot:** OpenMower (v1 hardware: full-size Raspberry Pi or CM4, YardForce-style mainboard v0.xx). Hostname: **kikuyu.local.symmatree.com**.
- **Problem:** Robot has never worked well; it could get GPS lock but could not hold it. It is in an **indeterminate state**: older OS/software was used at the time, then some Docker images were replaced with custom ones for GPS troubleshooting. A newer release exists (allegedly backwards compatible); we may eventually run custom software, but the immediate goal is to establish current state and then decide whether to stay on the old stack or move to the new one.
- **Access:** User **openmower**. Credentials are in 1Password (e.g. "raspberry pi rpi" in the user's private vault); do not store passwords in this repo. SSH key or password auth both work; access has been re-established.
- **What is already done:** Discovery docs in this directory (openmower-os-stack.md, openmower-docs-summary.md, openmower-architecture.md) describe the stack, configurable pieces, and where indeterminate state can show up. The next step is **onboard data-gathering** to record actual versions and config so we can choose a target state and a path to get there.

---

## 2. Your role

You are working **on the device** (or in a terminal that is SSH'd to it). You have:

- **On the dev machine (workspace):** This directory (facts/fables/OpenMower/), the plan, OpenMowerOS / open_mower_ros / OpenMower / openmower.de / openmower-cli repos. Use those for reference; you do not need them on the RPi.
- **On the mower:** A shell (SSH or Remote-SSH). Run commands there to inspect OS version, .env, Docker, params, and optionally GPS/ROS. Record the results.

When something is **unexpected** (missing files, different paths, errors, version strings that don't match docs): note it clearly, do not assume, and suggest a sensible next step or ask the user. You are the same "agent" as the one that wrote the discovery docs; behave sensibly and conservatively.

---

## 3. Data-gathering: what to capture

Goal: produce a **current-state snapshot** of the mower so we can compare it to the architecture doc and decide next steps (reflash, update in place, or stay put).

Follow the **suggested inspection order** from openmower-architecture.md. For each step, run the commands and record the output (or a concise summary). Redact only secrets (passwords, tokens); hostnames, paths, and config are fine.

### 3.1 OS identity

```bash
cat /usr/share/openmoweros/version.txt
# If present and useful:
cat /usr/share/openmoweros/version.json
```

Record: display_version, git describe, build time. If the path does not exist or the image is old (e.g. CustomPiOS), note that.

### 3.2 Stack env and compose

```bash
cat /opt/stacks/openmower/.env
```

Record: VERSION, HARDWARE_PLATFORM, MOWER, FIRMWARE, ESC_TYPE, DEBUG, HOSTNAME. Redact any password if present.

```bash
cat /opt/stacks/openmower/compose.yaml
```

Note if it differs from stock (extra services, different image names, custom mounts).

### 3.3 Docker: what is actually running

```bash
docker ps -a
docker images | grep -E 'open_mower|openmower|mosquitto'
```

For the open_mower_ros container (if present):

```bash
docker inspect open_mower_ros --format '{{.Config.Image}}' 2>/dev/null || true
```

Record: which image (tag and digest if useful) is running vs what .env says.

### 3.4 openmower CLI and stack state

```bash
which openmower
openmower --version 2>/dev/null || true
openmower status 2>/dev/null || true
```

If the CLI is missing or fails, note it (e.g. old OS without openmower-cli).

### 3.5 Params and map

```bash
ls -la /home/openmower/params/
ls -la /home/openmower/ros/ 2>/dev/null || true
```

Spot-check (do not paste entire files if they are large; summarize or paste only relevant sections):

- GPS-related and NTRIP-related keys in `mower_params.yaml` (e.g. gps/baud_rate, gps/protocol, datum, ntrip_client).
- Whether `map.json` or `ros_home/map.json` exists and where.

```bash
head -100 /home/openmower/params/mower_params.yaml
```

Adjust if the file is huge; focus on identifying schema/version and gps/ntrip bits.

### 3.6 Optional: mainboard/firmware and GPS

- If you have a way to infer mainboard firmware version from the device (e.g. openmower-cli or a tool), run it and record.
- If the stack is running and we want to check GPS from ROS: `openmower shell` (or `docker exec -it open_mower_ros bash`) then e.g. `rostopic echo --noarr -n 1 /ll/position/gps` and note flags/position_accuracy. If the stack is stopped or topic missing, note that and skip.

---

## 4. Where to put the results

- **Preferred:** Write a single markdown file, e.g. **openmower-kikuyu-current-state.md**, in this directory (facts/fables/OpenMower/). Structure it with the same sections as above (OS identity, .env, Docker, CLI/status, params, optional firmware/GPS). So the "future self" or the user can commit it next to the other OpenMower docs. Use only ASCII straight quotes and apostrophes.
- **Alternative:** If you are truly onboard with no write access to the repo, write the file under `/home/openmower/` (e.g. `/home/openmower/openmower-current-state.md`) and tell the user to pull it back (scp, rsync, or paste) into facts/fables/OpenMower/ on the dev machine.

---

## 5. After data-gathering

Once the snapshot is done:

- Compare it to openmower-architecture.md (especially "Where indeterminate state can show up").
- Summarize: what matches stock, what is custom or old, and what is missing or broken.
- Suggest next steps: e.g. "reflash OS and set .env from scratch," "update only the ROS image and params," or "test GPS in isolation first (USB + u-center) then re-assess."

The user will use that summary to decide the path (reflash vs update in place vs stay put) and, if needed, to document access and state in a more permanent way.
