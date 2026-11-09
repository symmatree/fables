# Cubie A7S: build and boot chain

How we get an OS we control onto a Radxa Cubie A7S: the boot chain, the kernel, the
image build, and the commands actually run. Board-level background (hardware, the
vendor / mainline / community software lines, links) is in
[Cubie A7S.md](Cubie%20A7S.md). Tiles tracking issue:
[tiles#886](https://github.com/symmatree/tiles/issues/886).

What this is for:

- **Capacity for tiles**: Talos nodes, ideally control plane.
- **A generic Linux build**: for embedded uses, for example a board flown in a
  drone payload. The Debian 13 image below is that build.

## Boot chain and kernel: what we run

| Stage | Radxa test image (t6) | DockSeed build |
|---|---|---|
| SPL + DRAM init | `u-boot-dlan17` 2026.04-4, closed `ddr.bin` | same frame, same `ddr.bin` |
| BL31 | prebuilt `awbin/a733/bl31.bin` (TF-A v2.5) | upstream TF-A master + A733 series |
| U-Boot | Radxa `u-boot-dlan17` 2026.04 | same, plus DockSeed patches (watchdog, no ARISC start, NVMe, boot order card/eMMC then NVMe) |
| Kernel | vendor `6.6.98-5-aw2511` | Linux 6.18.59 + 263 patches ([DockSeed/a7s-linux-lts](https://github.com/DockSeed/a7s-linux-lts)) |
| Device tree | vendor `radxa,cubie-a7s` | `sun60i-a733-cubie-a7s.dtb` from the patch series |
| Userspace | Radxa OS (Debian 13 + Radxa repos) | plain Debian 13 from snapshot.debian.org |

The boot ROM loads the SPL from sector 256 (128 KiB) of the card. The Radxa image's
card layout is `p1` 16M `/config`, `p2` 300M `/boot/efi` (an EFI system partition),
`p3` the root filesystem.

Talos 1.13 and 1.14.5 run Linux 6.18.y (6.18.58 in 1.14.5), the line DockSeed's kernel
tracks.

## Board 1

- **Board**: 8 GB, no eMMC (`mmc0` host present, no card on it). 64 GB microSD.
- **Network**: `end0`, 1000 Mb/s, MAC `40:fe:0d:00:08:03`. The MAC and the DHCP lease
  (`radxa-cubie-a7s`, 10.0.7.226) were the same after a power cycle under Radxa's
  U-Boot. Under DockSeed's chain the MAC comes from U-Boot's `ethaddr`; that has not
  been checked yet.
- **Cooling**: heatsink on the SoC, fan wired to 5 V on GPIO header pins 4 and 6, so
  always on. The fan is not on the J7 PWM header, so the kernel's `pwm-fan` state
  has no effect on it.

### Idle temperatures (Radxa t6 image, vendor kernel)

| Zone | Bare board | Heatsink + fan |
|---|---|---|
| `cpub` (A76) | 62.9-64.0 C | 36.1 C |
| `cpul` (A55) | 63.1-65.0 C | 37.1 C |
| `ddr` | 59.4-63.0 C | 36.5 C |
| `gpu` | 60.7 C | 36.3 C |
| `skin` | 36.6 C | 31.4 C |

Vendor kernel trips: `cpub` and `cpul` active and passive at 60 C, critical at 110 C;
`gpu` passive at 60 and 90 C; `skin` critical at 50 C. Bare, the board idled above the
60 C passive trip (no throttling observed at idle: `cpufreq` cooling state 0). The
vendor kernel holds `pwm-fan` at 4/4 (PWM 255) even at 36 C. DockSeed's own
measurements (40 mm fan on 5 V, always on): 31-45 C idle, 68.2 C peak under sbc-bench,
no throttling.

## Command log

Run from the JupyterHub pod unless the prompt says the board.

### Flash and first boot (Radxa t6)

Image: [radxa-a733_trixie_cli_t6.output_512.img.xz](https://github.com/radxa-build/radxa-a733/releases/download/rsdk-t6/radxa-a733_trixie_cli_t6.output_512.img.xz)
(`512` = 512-byte-sector variant for microSD), SHA-512
`08c554b8e66fdeb645d20e43f1306f7f9e1676c4c75d9c1e8cfa7af764baa165936eb8f065efeed43ad225854e56da96fa0799d783ad266268e41dd716406244`.
Flashed from Windows with Raspberry Pi Imager ("Use custom"). It boots with SSH on,
DHCP on `end0`, and login `radxa` / `radxa`. The DHCP hostname is `radxa-cubie-a7s`.
The image's build config names the hostname `radxa-a733`, but that is not what the
board sends.

### SSH key

A dedicated key, so there is a second way in besides the default password:

```sh
ssh-keygen -t ed25519 -N '' -C "jovyan@jupyterhub cubie" -f ~/.ssh/cubie_ed25519
ssh radxa@10.0.7.226 'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys' < ~/.ssh/cubie_ed25519.pub
ssh -i ~/.ssh/cubie_ed25519 -o IdentitiesOnly=yes radxa@10.0.7.226
```

### Podman (board)

The image ships with empty apt lists. Installing only podman pulls in podman's own
dependencies. The image also has Radxa's `a733-trixie-test` and `trixie-test` repos
enabled, so `apt upgrade` would pull their test kernel / U-Boot; it was not run.

```sh
sudo apt-get update
sudo apt-get install -y podman     # 5.4.2; rootless, overlay, cgroup v2
```

`radxa` already has `/etc/subuid` and `/etc/subgid` ranges (`100000:65536`).

### DockSeed build (board)

Native aarch64, rootless podman. a7s-build commit
`1e82a35e3105cef0a3ecfe44aa88db5035c0b6c8` (2026-11-08).

```sh
git clone https://github.com/DockSeed/a7s-build ~/a7s-build
cd ~/a7s-build
nohup setsid ./build.sh > ~/a7s-build.log 2>&1 < /dev/null &
```

Started 2026-11-09 02:37 UTC. The first step builds the builder container from
snapshot.debian.org.

## Building elsewhere

- **The tiles JupyterHub pod cannot build it.** It has no container daemon. Rootless
  buildah works with storage on local `/tmp` (not the NFS home, where `vfs` fails
  creating its pivot dir). But the Talos kernel has no `binfmt_misc`
  (`mount -t binfmt_misc` gives `unknown filesystem type`), so it cannot emulate the
  arm64 root filesystem. The same goes for any tiles node.
- **An x86-64 host** needs Linux >= 6.7 or a `qemu-aarch64` binfmt handler with the
  `F` flag, plus podman >= 4 or docker >= 24 (DockSeed README).
