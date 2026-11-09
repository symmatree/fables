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

Ran 2026-11-09 02:37-03:06 UTC (29 min), all stages done. What each stage did at
this commit:

| Stage | What happened |
|---|---|
| builder | builder container built from snapshot.debian.org (pinned 2026-11-01) |
| bootchain | **built from source** on the board: `u-boot-sunxi-with-spl.bin`, 1214141 B, sha256 `4d60771167ca9da247b29a5945be68485b6b87dc844332e36b293c40da9819e8`, radxa/u-boot `9da4b3e8` + series |
| kernel | **downloaded, not built**: DockSeed release [`v6.18.62-R1`](https://github.com/DockSeed/a7s-linux-lts/releases/tag/v6.18.62-R1) (`linux-image-6.18.62-r1`, headers, `a7s-kernel-hook`), sha256-pinned, recipe `d1176934016f` |
| wifi | AIC8800 DKMS package + 7 firmware files |
| gpu-firmware | `rogue_36.56.104.183_v1.fw` + `LICENSE.powervr` |
| orc, rootfs, image | Debian trixie minimal, 1792 MiB image, ext4 root at 16 MiB, boot chain at 128 KiB |
| compress | single-threaded xz, about 14 min |

Output: `~/a7s-build/out/a7s-trixie-minimal.img.xz`, 206912540 B, sha256
`6a94253c44e13f6e581febf027861aa0c31c08e1b46daf40a866db654749d73b`. It contains
non-redistributable vendor firmware, so it stays private.

The kernel stage downloading a prebuilt release is new since the October docs, which
described a source build on 6.18.59. Building the A733 kernel from source has not been
exercised on the board yet. Talos needs that, through its own kernel build.

### Temperatures under the build (heatsink + fan, vendor kernel)

Five-minute samples:

| UTC | Load | `cpub` / `cpul` C | cpufreq state (A55 / A76) | Caps MHz (A55 / A76) | Stage |
|---|---|---|---|---|---|
| 02:37 | 1.8 | 43.6 / 44.8 | 0 / 0 | 1794 / 2002 | builder |
| 02:43 | 6.5 | 60.6 / 62.1 | 3/8 / 3/11 | 1508 / 1794 | bootchain compile |
| 02:48 | 1.9 | 39.2 / 39.1 | 0 / 0 | 1794 / 2002 | rootfs |
| 02:54-03:04 | 1.0-5.2 | 44.6-48.9 | 0 / 0 | 1794 / 2002 | image, compress |

With all cores busy, the vendor kernel throttles at its 60 C passive trip even with
cooling. DockSeed's kernel puts the passive trip at 90 C.

### First boot of the DockSeed image

Login is `a7s` with an empty password that must be changed at the first login, which
happens on tty1 (display) or the serial console. SSH accepts logins only once a
password is set (DockSeed README). Under this boot chain, the MAC comes from U-Boot's
`ethaddr`, and with none stored it is random per boot.

## Talos kernel: patch-series check

Talos builds its kernel in [siderolabs/pkgs](https://github.com/siderolabs/pkgs):
`kernel/prepare` fetches the kernel.org tarball, `kernel/build` applies every
`kernel/build/patches/*.patch` in sorted order (`patch -p1`, default fuzz) and builds
with `config-arm64`. Talos 1.14.5 is pkgs `f4bda77`: Linux 6.18.58, 15 patches.

Checked 2026-11-09 by applying DockSeed's series (`a7s-linux-lts` `d1176934016f`, 264
patches, written for 6.18.62) with `patch -p1 --fuzz=0`. Apply only; nothing was
compiled.

| Tree | Result |
|---|---|
| 6.18.62 (DockSeed's base) | 264 apply exactly |
| 6.18.58 | 264 apply at fuzz 0; 7 at a line offset |
| 6.18.58 + Talos's 15 patches first, then DockSeed's 264 | Talos's 15 apply; DockSeed's 264 apply at fuzz 0, the same 7 at an offset |

The 7 offset patches are #5 `pinctrl-sunxi-fix-irq-bank-numbering-without-bank-a`,
#137/#138 the stmmac MSI / channels-IRQ backports, #142
`net-stmmac-retry-a-failed-rx-refill-from-a-timer`, #148
`bluetooth-btusb-request-the-reset-gpio-only-where-a-handler-uses-it`, and #230/#231
the PCI root-port error-reset / link-down backports. DockSeed's own policy treats
an offset as "regenerate the patch". `patch` applies them with every context line
matching.

Still needed for a Talos kernel: the A733 / A7S options in Talos's `config-arm64`
(DockSeed's defconfig is `kernel/6.18/config`) and a compile. The pkgs build runs in
docker buildx, which this pod cannot run (no daemon).

## Building elsewhere

- **The tiles JupyterHub pod cannot build it.** It has no container daemon. Rootless
  buildah works with storage on local `/tmp` (not the NFS home, where `vfs` fails
  creating its pivot dir). But the Talos kernel has no `binfmt_misc`
  (`mount -t binfmt_misc` gives `unknown filesystem type`), so it cannot emulate the
  arm64 root filesystem. The same goes for any tiles node.
- **An x86-64 host** needs Linux >= 6.7 or a `qemu-aarch64` binfmt handler with the
  `F` flag, plus podman >= 4 or docker >= 24 (DockSeed README).
