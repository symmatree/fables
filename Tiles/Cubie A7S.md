# Radxa Cubie A7S (Allwinner A733)

General notes on the Cubie A7S as a Linux / Talos host: what the hardware is, which
software trees support it, where the board-level configuration lives, and what has been
learned bringing it up. Not specific to how tiles deploys it -- the tiles deployment
gets its own doc in the tiles repo once a board is running there.

Tracking issue for the tiles bring-up: [tiles#886](https://github.com/symmatree/tiles/issues/886).

Status: research only. No board has been powered up yet. Everything below comes from
docs and source. Nothing has been measured on our own hardware.

## Hardware

From Radxa's spec page ([docs](https://docs.radxa.com/en/cubie/a7s), source in
[radxa-docs/docs](https://github.com/radxa-docs/docs/tree/main/docs/cubie/a7s)):

| | |
|---|---|
| SoC | Allwinner A733 (`sun60i` family; Allwinner-internal name `sun60iw2`) |
| CPU | 2x Cortex-A76 + 6x Cortex-A55, up to 2.0 GHz |
| RAM | LPDDR5, up to 16 GB (ours: 8 GB) |
| Storage | microSD; optional onboard eMMC up to 256 GB (footprint unpopulated on no-eMMC SKUs); NVMe via PCIe 3.0 x1 FPC connector (needs an FPC-to-M.2 adapter) |
| Network | 1x GbE; Wi-Fi 6 / BT 5.4 (AIC8800D80, USB-attached) |
| USB | USB-C 1: 5 V power in + USB 2.0 OTG. USB-C 2: USB 3.2 + DP alt mode + OTG. USB-A: USB 2.0 host |
| Power | 5 V over USB-C only |
| Other | USB BOOT (FEL) button, fan header, 15-pin + 30-pin GPIO headers, MIPI CSI, RISC-V E902 MCU, 3 TOPS NPU, PowerVR BXM-4-64 GPU |
| Size | 51 x 51 mm, 0-60 C |

Hardware design files (schematic V1.10, placement map, 2D/3D) are linked from
Radxa's [download page](https://docs.radxa.com/en/cubie/a7s/download), for example the
[schematic PDF](https://dl.radxa.com/cubie/a7s/hw/radxa_cubie_a7s_schematic_v1.10.pdf).

Other details:

- **Boot ROM** loads the SPL from sector 256 (128 KiB offset) on the card or eMMC.
  Source: DockSeed `a733-bootchain` docs (see below).
- **Boot order** in DockSeed's U-Boot is card or eMMC first, then NVMe. Radxa's own
  U-Boot order has not been checked here.
- **MAC address**: the kernel carries none. U-Boot writes `local-mac-address` from its
  `ethaddr`. With `CONFIG_NET_RANDOM_ETHADDR=y` and no stored `ethaddr`, every boot
  gets a new MAC, so DHCP sees a new machine each time (DockSeed kernel docs). Whatever
  OS runs here needs a stable MAC for DHCP reservations and node identity.
- **No RTC battery**: the clock starts wherever it was left until NTP sets it.
- **Serial console**: `ttyS0`, 115200 baud, on the GPIO header (DockSeed README). This
  is the console to use for bring-up. Community reports say Radxa's server images
  show nothing on the display and need the UART.

## Software tracks

There are three lineages. Which one a project uses depends mostly on which kernel it
needs.

### 1. Radxa / Allwinner vendor BSP (Tina 5.0 AIoT SDK)

Radxa OS (Debian bullseye or trixie) on Allwinner's vendor kernel.

- Images: [radxa-build/radxa-a733 releases](https://github.com/radxa-build/radxa-a733/releases)
  (one generic image for all A733 boards; versions starting `r` are stable, `t` are
  test). The per-board repos (`radxa-build/radxa-cubie-a7z`, `-a7a`) now point here.
  These images boot from microSD, NVMe or eMMC. Flash with `dd` or Etcher. The FEL /
  Phoenix-tool images are for eMMC recovery and mass flashing.
  Default login `radxa` / `radxa`.
- Kernel packaging: [radxa-pkg/linux-a733](https://github.com/radxa-pkg/linux-a733)
  (the repo the docs link to) and [radxa-pkg/linux-aw2501](https://github.com/radxa-pkg/linux-aw2501).
  Both build **5.15.147** from
  [radxa/kernel](https://github.com/radxa/kernel) branch `allwinner-aiot-linux-5.15`,
  with [radxa/allwinner-bsp](https://github.com/radxa/allwinner-bsp) (out-of-tree
  vendor drivers) as a submodule. `radxa/kernel` also has an
  `allwinner-aiot-linux-6.6` branch. Kernel config changes go in
  `debian/patches/linux/0001-feat-Radxa-common-kernel-config.patch` (per Radxa docs).
- U-Boot: [radxa-pkg/u-boot-aw2501](https://github.com/radxa-pkg/u-boot-aw2501) uses
  Allwinner's boot0 + `boot_package.fex` layout from
  [radxa/u-boot](https://github.com/radxa/u-boot) branch `cubie-aiot-v1.4.6`.
  [radxa-pkg/u-boot-dlan17](https://github.com/radxa-pkg/u-boot-dlan17) is a newer
  package that builds a mainline-style `u-boot-sunxi-with-spl.bin`. Its SPL embeds the
  closed DRAM-init blob `ddr.bin`, and DockSeed builds on it.
- **Board configuration**: [radxa/allwinner-device](https://github.com/radxa/allwinner-device),
  branch `device-a733-v1.4.6` (the default branch is the A527 one),
  `configs/cubie_a7s/`:
  - `linux-5.15/board.dts`, `linux-6.6/board.dts`: the board device tree (GMAC,
    `&sdc2` eMMC, `&pcie_rc` with its regulator supplies, and so on). Use these as
    the reference for pin and regulator wiring.
  - `uboot-board.dts`, `sys_config.fex`: the U-Boot side and Allwinner's legacy board
    config.
  - `debian/sys_partition.fex`, `debian/env.cfg`: partition layout and U-Boot env for
    the FEL image.
  - `dtbo/`: overlays.
- Overlays for HATs and peripherals: [radxa-pkg/radxa-overlays](https://github.com/radxa-pkg/radxa-overlays).
- Image builder: [RadxaOS-SDK/rsdk](https://github.com/RadxaOS-SDK/rsdk).
- Allwinner's own docs (mostly Chinese): [Tina 5.0 AIoT docs](https://gitlab.com/tina5.0_aiot/product/docs/),
  including the A733 user manual and datasheets. CNX Software
  [reported](https://www.cnx-software.com/2025/07/07/allwinner-a527-t527-and-a733-datasheets-user-manuals-and-linux-sdk-released/)
  that the SDK will not be upstreamed and that its roadmap stays on 5.15.

### 2. Mainline Linux (linux-sunxi)

A733 support is landing upstream now. Status as of 2026-10-03, from DockSeed's
[help-wanted.md](https://github.com/DockSeed/a7s-build/blob/main/docs/help-wanted.md):

| Area | Series | State |
|---|---|---|
| RTC + RTC clocks | [v7](https://lore.kernel.org/all/20260723-a733-rtc-v7-0-8fd68aab94ae@baylibre.com/) | merged |
| Power domains (PCK600) | [v2](https://lore.kernel.org/all/20260305-b4-pck600-a733-v2-0-ba6bbed7d253@gmail.com/) | accepted |
| Pinctrl | [series](https://lore.kernel.org/all/20260910133519.459011-1-andre.przywara@arm.com/) | applied for 7.4 |
| Clocks (CCU + R-CCU) | [v5](https://lore.kernel.org/all/20260930-a733-clk-v5-0-11175b41cd2d@pigmoral.tech/) | under review |
| DMA | [v5](https://lore.kernel.org/all/20260826-sun60i-a733-dma-v5-0-abc5229b441e@gmail.com/) | under review |
| Ethernet (GMAC) | [v3](https://lore.kernel.org/all/20260923-allwinner-a733-gmac-support-v3-0-15735155a789@baylibre.com/) | under review |
| PMIC regulators (AXP318) | [v8](https://lore.kernel.org/all/20260910-axp318-regulator-v8-0-e906a61a7f3d@baylibre.com/) | under review |
| Cubie A7S device tree | [v1](https://lore.kernel.org/all/20260613-a733-dts-v1-public-ready-v1-0-7787c94681db@gmail.com/) | waiting on clocks and pinctrl |

There is no A733 support in upstream U-Boot `arch/arm/mach-sunxi` yet. TF-A has
patches carried out of tree (see DockSeed below).

Tracking page: [linux-sunxi Mainlining Effort](https://linux-sunxi.org/Mainlining_Effort).

### 3. Patched LTS kernels (community)

**DockSeed** is the closest thing to an upstream-shaped A7S stack right now. It is
three repos, each pinned by commit:

- [DockSeed/a7s-linux-lts](https://github.com/DockSeed/a7s-linux-lts): **Linux 6.18.59**
  plus a 263-patch series: backports (stmmac, AXP318W, `drm/imagination`, MAE0621A
  PHY), `soc/` (A733 clk, pinctrl, mmc incl. eMMC HS400, PCIe, USB/combophy, thermal,
  display, power domains, cpufreq) and `board/dts/` (Cubie A7S wiring). The patches
  must apply at fuzz 0, so each 6.18.y bump means regenerating any that moved. The
  config covers containers / Kubernetes (VETH, bridge netfilter, overlayfs, IPVS,
  VXLAN, nftables, BPF/BTF). Output includes `sun60i-a733-cubie-a7s.dtb`.
- [DockSeed/a733-bootchain](https://github.com/DockSeed/a733-bootchain): U-Boot (from
  Radxa's `u-boot-dlan17` frame plus patches) and TF-A BL31 built from upstream master
  plus an A733 series. The output is one `u-boot-sunxi-with-spl.bin` written at 128 KiB.
  The only closed part is `ddr.bin` inside the SPL. It does not start the E902 ARISC
  co-processor, so there is no suspend-to-RAM. The docs say an EFI boot path does not
  go through the extlinux ARISC hook, which suggests U-Boot's EFI boot is in use or
  available. I have not checked this beyond that one sentence.
- [DockSeed/a7s-build](https://github.com/DockSeed/a7s-build): assembles both into a
  Debian 13 image with `./build.sh` (podman or docker, about 1 hour). It ships no
  prebuilt image because of blob licensing, so you build it yourself.
  `docs/benchmarks.md` has sbc-bench results.

Talos 1.13 (tiles' current version) runs kernel 6.18.y, the same LTS line DockSeed
tracks.

**opentina-org**: Allwinner-community forks for the A733.
[linux](https://github.com/opentina-org/linux) branch `tina-dev` is 6.18.14 with
`sun60i-a733.dtsi` and DTs for `radxa-a7a` and the Allwinner demo board, but no A7S DT.
There are also [u-boot](https://github.com/opentina-org/u-boot),
[trusted-firmware-a](https://github.com/opentina-org/trusted-firmware-a), and
[build](https://github.com/opentina-org/build) (Yocto / Debian / Ubuntu; board configs
`radxa_a7a` and `demo_aiot_a733_v3`; README in Chinese).

**Others** (single-maintainer, kernel-specific):
[Rabs9/radxa-cubie-a7a-kernel](https://github.com/Rabs9/radxa-cubie-a7a-kernel),
[cuihuir/radxa-a7z-debian12](https://github.com/cuihuir/radxa-a7z-debian12),
[hqu-little-boy/archlinuxarm-a733](https://github.com/hqu-little-boy/archlinuxarm-a733),
[chainsx/openwrt-sunxi-aiot](https://github.com/chainsx/openwrt-sunxi-aiot).
Index: [lilyco-42/awesome-radxa-a733](https://github.com/lilyco-42/awesome-radxa-a733).

### Armbian

There is no official A7S support. In this
[forum thread](https://forum.armbian.com/topic/59021-are-there-any-plans-to-create-an-armbian-image-for-the-radxa-cubie-a7s-its-a-really-cute-single-board-computer-with-a-powerful-allwinner-a733-soc/)
the answer is that new boards need funding. A community vendor-kernel build exists for
the A7A/A7Z ([thread](https://forum.armbian.com/topic/56130-radxa-cubie-a7aa7z-allwinner-a733/)).

## Talos

Stock Talos has no A733 kernel support and no Allwinner overlay for it.
[siderolabs/sbc-allwinner](https://github.com/siderolabs/sbc-allwinner) covers only
A64/H3/H5 boards (Pine64, Banana Pi M64, Libre Computer ALL-H3-CC). Until mainline
coverage reaches a Talos release, running Talos here needs both:

- **A custom Talos kernel**: Talos's kernel build ([siderolabs/pkgs](https://github.com/siderolabs/pkgs))
  with an A733 patch series (DockSeed's is on the same 6.18 line), with Talos's
  required config on top.
- **A board overlay** (Talos's SBC overlay mechanism, modeled on `sbc-allwinner`) that installs `u-boot-sunxi-with-spl.bin` at
  sector 256 and ships `sun60i-a733-cubie-a7s.dtb`.

My understanding is that Talos arm64 SBC images boot through U-Boot's EFI support, so
the boot chain's EFI path matters. I have not verified that against the
`sbc-allwinner` installer source yet.

## Local clones

Shallow clones (about 3.8 GB) are in `~/upstream/cubie/` on the JupyterHub home, named
`<org>_<repo>`. `radxa_allwinner-device-a733` is the `device-a733-v1.4.6` branch.
`radxa-docs_docs` is the Radxa documentation source, and the English pages are under
`i18n/en/docusaurus-plugin-content-docs/current/cubie/a7s/`.

## Open questions

- Do our boards have eMMC? Without eMMC, etcd needs NVMe (FPC adapter) or a microSD
  card.
- Boot order and FEL / maskrom behavior on Radxa's own U-Boot. How to hold the USB
  BOOT button while powering on.
- 5 V USB-C power budget with an NVMe drive attached.
- DockSeed's measured status of GbE, PCIe/NVMe and eMMC on a real board (the build
  repo says statements are made only after measurement; see its `docs/`).
