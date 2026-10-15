https://www.gmktec.com/products/intel-twin-lake-n150-mini-pc-nucbox-g2-plus

Dual GbE LAN
Wifi 6 + BT 5.2
3 display (HDMI + DP Type C)

Bought 2x 12GB RAM + 512GB SSD 2025-06-21 ($158 apiece)

## Storage

The 512 GB drive in these presents as **SATA** (`sda`), not NVMe -- unlike the
[[GMKtec Nucbox G3 Plus N150 16GB]], whose drive is `nvme0n1`. So the two box
generations are not comparable for storage behaviour, and only the two G3 Plus
boxes are a like-for-like pair.

Both `nuc-g2p-1` and `nuc-g2p-2` have sustained roughly 42 - 48 GiB/day of writes
without the latency collapse seen on [[nuc-g3p-2]] -- but these are cheap OEM
drives from the same vendor at the same price point, so assume the sustained-write
caveat on the G3 Plus page applies here too until measured otherwise.
