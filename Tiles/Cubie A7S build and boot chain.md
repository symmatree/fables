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

## Talos kernel: config

Files are in `datasets/cubie-a7s/talos-kernel/`:

- `a733-cubie-a7s.fragment`: the options added to Talos's config, with a comment
  per group.
- `config-arm64`: Talos's `config-arm64` (pkgs `f4bda77`) plus the fragment,
  expanded with `merge_config.sh` + `olddefconfig` in the patched 6.18.58 tree
  (Talos's 15 patches, then DockSeed's 264).
- `config-arm64.diff-vs-talos-f4bda77`: the diff against Talos's file.
- `apply-series.sh`: applies a `series` file at fuzz 0 and reports exact / offset /
  fail per patch.

How it was chosen: the options set (`y`/`m`) in DockSeed's expanded config but not in
Talos's number 244, mostly distro choices (filesystems, Bluetooth, sound, media, debug).
Talos already has the generic Allwinner drivers this board uses: `MMC_SUNXI`,
`STMMAC_ETH` + `DWMAC_SUN55I`/`SUN8I`/`SUNXI`, `MFD_AXP20X`, `REGULATOR_AXP20X`,
`RTC_DRV_SUN6I`, `SUN8I_THERMAL`, `SUNXI_WATCHDOG`, `NVMEM_SUNXI_SID`,
`ARM_ALLWINNER_SUN50I_CPUFREQ_NVMEM`, `BLK_DEV_NVME`, `USB_DWC3`, `PCIE_DW_HOST`.
The fragment adds what a headless node needs from the rest:

| Area | Options |
|---|---|
| PMIC on I2C (AXP318W) | `MFD_AXP20X_I2C` |
| Power domains, IOMMU | `SUN20I_PPU`, `SUN60I_IOMMU` |
| GbE PHY (MaxIO MAE0621A) | `MAXIO_PHY` |
| PCIe / NVMe | `PCIE_SUN60I_A733`, `PHY_SUN60I_A733_PCIE_COMBO` |
| USB | `PHY_SUN60I_A733_USB2`, `PHY_SUN60I_A733_COMBO`, `USB_ONBOARD_DEV` (m, CH334 hub), `TYPEC_TCPM`/`TCPCI`/`RT1711H` (m) |
| Fan PWM | `PWM_SUN60I_A733` |
| Thermal | `IDLE_INJECT`, `CPU_IDLE_THERMAL` (idle-injection cooling on the CPU zones; the zones use `step_wise`) |
| DSU frequency | `ARM_SUN60I_A733_DSU_DEVFREQ` |

The A733 clock and pinctrl drivers from the series (`SUN60I_A733_*CCU`,
`PINCTRL_SUN60I_A733`, `_R`) and `MMC_HSQ` default to `y` with Talos's config.
The result differs from Talos's file only in the options above and the toolchain
version lines (this run used conda-forge clang 23.1.4 and Ubuntu pahole 1.25;
Talos's toolchain has clang 22.1.8 and pahole 1.31). pkgs' `make kernel-olddefconfig`
rewrites those lines in Talos's own toolchain.

Not added: display / GPU / NPU (`DRM_SUN60I_*`, `DRM_POWERVR`, `DRM_ETNAVIV`), sound,
camera, IR, Wi-Fi (AIC8800 is out of tree), `SPI_SUN6I`. Also left at Talos's default
is `ENERGY_MODEL`. DockSeed enables it, with a measured `dynamic-power-coefficient` in
the device tree, so that Energy Aware Scheduling runs across the A55 / A76 split. It
is a scheduler policy choice.

`arch/arm64/boot/dts/allwinner/Makefile` in the patched tree has
`dtb-$(CONFIG_ARCH_SUNXI) += sun60i-a733-cubie-a7s.dtb`. Talos builds dtbs for arm64
(`make dtbs`), so the board's dtb comes out of the Talos kernel build.

## Talos build: what it looks like

- **Kernel** (siderolabs/pkgs, `make kernel`): `docker buildx` with the `bldr`
  frontend (`# syntax = ghcr.io/siderolabs/bldr:...`). That needs BuildKit, so
  docker + buildx, not podman. `kernel/build/pkg.yaml` takes `ARCH` from the build
  platform and sets `LLVM=1` with no `CROSS_COMPILE`, so an arm64 kernel builds in an
  arm64 container. On an arm64 host that is native. On an x86 host buildx runs the
  arm64 stages under qemu-user emulation. The stage runs `make`, `make modules`,
  `make dtbs`, and a `kernel-hardening-checker` pass over the config.
- **Overlay**: Go, cross-compiles on any host. Modeled on `sbc-allwinner`'s Pine64
  installer: write `u-boot-sunxi-with-spl.bin` at 128 KiB, copy the dtb, set kernel
  args, and set a partition offset past the end of the boot chain (1314 KiB).
- **Image** (Talos imager): assembles the kernel, the overlay and Talos into a
  `metal-arm64` image and installer. image-factory cannot take a custom kernel, so
  the installer is served from our own registry.

## Talos kernel build (board)

Docker from Debian trixie (`docker.io` / `docker-cli` 26.1.5, `docker-buildx` 0.13.1;
the install adds `containerd`, `runc`, `tini` and nothing else):

```sh
sudo apt-get install -y --no-install-recommends docker.io docker-cli docker-buildx
sudo usermod -aG docker radxa
# the default `docker` driver fails with "requested experimental feature mergeop has
# been disabled ... only enabled with containerd image store backend"
docker buildx create --name local --use
```

pkgs tree: DockSeed's series renamed `1001-a733-*` .. `1264-a733-*` so it sorts after
Talos's 15, and `config-arm64` replaced by the merged config:

```sh
git clone https://github.com/siderolabs/pkgs ~/pkgs && cd ~/pkgs && git checkout f4bda77
# copy the renamed patches into kernel/build/patches/, the config to kernel/build/config-arm64
nohup bash -c 'time make local-kernel PLATFORM=linux/arm64 DEST=_out/kernel PROGRESS=plain' \
  > ~/talos-kernel.log 2>&1 < /dev/null &
```

Run 1, 2026-11-09 09:39-13:53 UTC (4 h 13 min), failed:

- All 279 patches applied; the hardening check passed; compile started 09:57.
- `vmlinux.o` linked at 13:08. `pahole -J -j8` (BTF for `.tmp_vmlinux1`) was
  OOM-killed at 13:47: 6.1 GB RSS, 10.9 GB virtual. The board has 7.7 GiB RAM and
  4 GiB of swap, all of it zram. The link went on without BTF and `resolve_btfids`
  failed with `load BTF from vmlinux.unstripped: Invalid argument`.
- The failed step is one BuildKit `RUN`, so the objects compiled before it are not
  cached for a rerun.
- Temperatures through the compile: 59-62.6 C, the vendor kernel's 60 C passive trip.
  A55 at 1404-1508 MHz (max 1794), A76 mostly 1508 (max 2002), load about 8.5.

Run 2, 2026-11-09 14:41-22:44 UTC (8 h 03 min), succeeded, with an 8 GiB swapfile
added (not in fstab, so gone at reboot):

```sh
sudo fallocate -l 8G /swapfile && sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon -p 10 /swapfile
```

| Phase | UTC | Notes |
|---|---|---|
| compile | 14:42-18:29 | same pace as run 1; 59-63.5 C, same caps |
| `pahole -J -j8` on `.tmp_vmlinux1` | 18:29-21:31 | 5.9 GB RSS, 13 GB virtual; zram full, up to 7.6 GB swap; CPU 73-79% idle, 10-18% iowait, swap-in 7-16 MB/s; single-threaded and in `D` state for most of it |
| `vmlinux`, `Image`, modules + module BTF, dtbs | 21:31-22:36 | back to 8 cores at the trip point |
| `kernel` stage (`modules_install`, export) | 22:36-22:44 | |

The vendor kernel has no `/proc/pressure`, so the I/O numbers are from `vmstat` and
`ps`.

Output (`~/pkgs/_out/kernel`, 243 MB; copy in
`datasets/cubie-a7s/talos-kernel/build-6.18.58-talos-a733-r1/` with the build and
temperature logs):

- `boot/vmlinuz`: `6.18.58-talos`, arm64 EFI-stub image, sha256
  `b70b75e8a2d264be06f472b3dd908f1cf48b9a5bc35d03df0122b41d59d7d7a8`.
- `dtb/allwinner/sun60i-a733-cubie-a7s.dtb`, sha256
  `37a76a375d310edf142106b3b4f1b196857db058689d57e33bb0f9b088d7079c`.
- `usr/lib/modules/6.18.58-talos/`: 424 modules, signed (`Module signature appended`).
  `certs/` in the output is empty: the signing key stays in the BuildKit cache of the
  `kernel-build` stage.
- `System.map` has the fragment's built-in drivers: `axp20x_i2c`, MaxIO PHY,
  `sun20i_ppu`, `sun60i_iommu`, `sun60i_a733_pcie`, the A733 USB2 / combo / PCIe PHYs,
  `a733_pwm`, `sun60i_a733_dsu`. `tcpci`, `tcpci_rt1711h`, `onboard_usb_dev` are
  modules.

### Provenance of build r1

Everything that went into `build-6.18.58-talos-a733-r1`. Scripts and checksums are
in `datasets/cubie-a7s/talos-kernel/build-6.18.58-talos-a733-r1/provenance/`.

| Input | Identity |
|---|---|
| Build host OS | Radxa `radxa-a733_trixie_cli_t6` (`rsdk-t6` release), vendor kernel 6.6.98-5-aw2511, on microSD; its manifest, config and sha512sums are in `provenance/` |
| Host packages added | `podman` 5.4.2 (DockSeed build only); `docker.io` + `docker-cli` 26.1.5+dfsg1-9+deb13u1, `docker-buildx` 0.13.1+ds1-3, pulling in `containerd` 1.7.24~ds1-6+deb13u1, `runc` 1.1.15+ds1-2+b4, `tini` 0.19.0-3+b8 (Debian trixie / trixie-security; no upgrade run) |
| BuildKit | `docker buildx create --name local --use`, image `moby/buildkit:buildx-stable-1`, pulled 2026-11-09; digest not yet recorded (it is in the Radxa card's docker store) |
| Host memory | 7.7 GiB RAM, 4 GiB zram, plus an 8 GiB swapfile added for run 2 |
| pkgs | `siderolabs/pkgs` `f4bda77` (Talos 1.14.5), unmodified except the two below; toolchain and bldr images as pinned there |
| `kernel/build/patches/` | Talos's 15, plus DockSeed `a7s-linux-lts` `d1176934016f` `kernel/6.18/series` (264) renamed `1001-a733-*`..`1264-a733-*` by `stage-patches.sh`; per-file sha256 in `patches-renamed.sha256` |
| `kernel/build/config-arm64` | `datasets/cubie-a7s/talos-kernel/config-arm64`, sha256 `4927b4317e4d44c90fd8b5ff12eb50c463cdedee4cdd436074f07ac035e06c81`; made by `make-config.sh` from Talos's file (sha256 `4c7fb4e8...7109587`) and the fragment (sha256 `77db57d9...b1e2bd0`) on the pod with conda-forge clang 23.1.4 and Ubuntu pahole 1.25. The build's own `make` re-syncs it against Talos's clang 22.1.8 / pahole 1.31 |
| Command | `make local-kernel PLATFORM=linux/arm64 DEST=_out/kernel PROGRESS=plain` |
| Output | `kernel.tar.zst` of `_out/kernel`, sha256 in `kernel.tar.zst.sha256` |

Manual steps on the host, in order: `apt-get update`; installs above; `usermod -aG
docker radxa`; `buildx create`; clone pkgs and checkout; scp patches and config;
run 1; `fallocate`/`mkswap`/`swapon` 8 GiB `/swapfile`; run 2. The module signing
key exists only in that BuildKit cache.

Nothing has booted this kernel yet.

## Test card: DockSeed image + Talos kernel

`vmlinuz` from pkgs is an EFI zboot image (`CONFIG_EFI_ZBOOT`, zstd payload), which
U-Boot's extlinux `booti` cannot boot. The raw `Image` is the payload: the zboot
header has `zimg` at offset 4, the payload offset and size as le32 at 8 and 12, and
the compression name at 24. Extracted, it is 75563008 B with the arm64 `ARMd` magic;
U-Boot's `kernel_addr_r` (0x40080000) plus that size ends below `fdt_addr_r`
(0x4FA00000). DockSeed's U-Boot binary also carries `bootefi` and `bootmeth_efi`
(from its strings; not exercised).

`a7s-tiles-test.img.xz` in `datasets/cubie-a7s/` (260746040 B, sha256
`2743469df359544b33e699cefb9e7cf0f32d78dbf652fd69956d08b395060ebd`) is
`a7s-trixie-minimal.img.xz` with, on the root partition (loop-mounted on the board,
changes made with `chroot`, by `provenance/test-card-mkimg.sh`; compressed with
`xz -T0 -6`):

- `a7s`: the session's `cubie_ed25519` public key in `authorized_keys`, password
  field `*` (key-only, no console login), expiry cleared, `NOPASSWD` sudo in
  `/etc/sudoers.d/90-a7s-tiles-test`. This replaces DockSeed's expired empty password.
- `/etc/systemd/network/10-cubie-mac.link`: `OriginalName=eth0` gets
  `40:fe:0d:00:08:03`, with `99-default.link`'s naming policies. NetworkManager
  keeps the udev-set MAC by default.
- `/boot/Image-6.18.58-talos`, `/boot/sun60i-a733-cubie-a7s-6.18.58-talos.dtb`,
  `/usr/lib/modules/6.18.58-talos` (`depmod` run), and an extlinux label `talos`.
  The default label stays DockSeed's `a7s`; `extlinux-fallback.conf` is untouched.

Switching to the Talos kernel is changing `default a7s` to `default talos`. After
three failed boots U-Boot's `altbootcmd` boots `extlinux-fallback.conf`, which is
DockSeed's kernel.

### First boots (2026-11-10)

DockSeed kernel (`6.18.62-r1`), first boot: up in about a minute at 10.0.7.226 (the
MAC pin held), key login and sudo work, root grown to 58 GB, no failed units. First
boot rewrites the disk ID (`a7s-root-identity`) and the `root=PARTUUID=` of every
extlinux label, the added `talos` one included (`a7530001` became `f68f3d29`).

Talos kernel (`6.18.58-talos`), `default talos`: up in about 2 minutes.

| Area | Under the Talos kernel |
|---|---|
| Ethernet | `end0`, `dwmac-sun55i` (module), 1000/full, pinned MAC |
| SD | `SD64G`, SDR104 at 200 MHz |
| CPU | 8 cores; `cpufreq-dt` with all OPPs (A55 to 1794, A76 to 2002 MHz); `psci_idle`, 3 states |
| Thermal | 5 zones, `step_wise`; trips 60 active (fan), 90 / 100 passive, 110 critical; cooling devices `cpufreq-cpu0/6`, `idle-cpu2..7`, `pwm-fan` |
| Other | PCIe root port `0000:00:00.0`, `sunxi-wdt`, `dsu` devfreq, `pwmchip0`, `rtc0`; xHCI / EHCI / OHCI, `onboard_usb_dev`, `tcpci_rt1711h` loaded |
| Not there | no `/dev/mem` (Talos config); no `binfmt_misc`; no `zram` module (zram-generator fails, so no swap) |

### microSD fsync (etcd-style fio)

Talos kernel, the test card (`SD64G`, manfid `0x000027`, oemid `0x5048`, date
06/2026, SDR104), ext4 `noatime`, board idle. fio 3.39 from Debian:

```sh
fio --rw=write --ioengine=sync --fdatasync=1 --directory=. --size=22m --bs=2300 --name=etcd
```

| Run | p50 | p90 | p99 | p99.9 | max | IOPS |
|---|---|---|---|---|---|---|
| 1 | 3.75 ms | 5.7 ms | 16.2 ms | 61 ms | 2429 ms | 241 |
| 2 | 3.69 ms | 5.9 ms | 16.5 ms | 52 ms | 107 ms | |
| 3 | 3.52 ms | 5.5 ms | 16.5 ms | 52 ms | 63 ms | |

For comparison, tiles' etcd `etcd_disk_wal_fsync_duration_seconds` over the day
to 2026-11-10 12:04 UTC (Mimir, `histogram_quantile` over 1 d rates): p50 1.5 /
1.0 / 2.3 ms and p99 63 / 278 / 7.9 ms for `tiles-cp-1` / `-2` / `-3`. fio on an
idle board and etcd's own WAL under cluster load are different workloads. etcd's
hardware guidance asks for p99 WAL fsync under 10 ms.

`a7s-boot-good.service` fails under the Talos kernel: it clears U-Boot's boot counter
(RTC `GP_DATA_REG7`) with `busybox devmem`, and there is no `/dev/mem`. The counter is
not cleared on these boots, so after the boot limit U-Boot boots
`extlinux-fallback.conf`. A boot of the DockSeed kernel clears it.

The RTC driver exposes the eight GP_DATA registers as nvmem
(`/sys/devices/platform/soc/7090000.rtc/nvmem0/nvmem`, 32 bytes, "Battery backed");
REG7 is at offset 28 and read `0xb0010001` (magic `0xB001`, count 1) on the first
Talos-kernel boot. On the test card a drop-in,
`/etc/systemd/system/a7s-boot-good.service.d/10-nvmem.conf`, runs DockSeed's
`devmem` command and otherwise writes 4 zero bytes there with `dd`. Checked across a
reboot: the service succeeds and REG7 reads 0.

On a Talos disk the counter has no effect: per DockSeed's safe-mode patch, past the
limit U-Boot reruns its normal scan and boots `extlinux-fallback.conf` only on a disk
that has one; a disk without it boots normally.

## Building elsewhere

- **The tiles JupyterHub pod cannot build it.** It has no container daemon. Rootless
  buildah works with storage on local `/tmp` (not the NFS home, where `vfs` fails
  creating its pivot dir). But the Talos kernel has no `binfmt_misc`
  (`mount -t binfmt_misc` gives `unknown filesystem type`), so it cannot emulate the
  arm64 root filesystem. The same goes for any tiles node.
- **An x86-64 host** needs Linux >= 6.7 or a `qemu-aarch64` binfmt handler with the
  `F` flag, plus podman >= 4 or docker >= 24 (DockSeed README).
