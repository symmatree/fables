# Reproducible build of the rekon10's calibrated AM32 ESC firmware.
#
# The stack's TBS Lucid 60A 4-in-1 runs the AM32 `TBS_6S_4IN1_F421` target. The stock
# target ships generic current/voltage constants that read badly on this board (see README).
# This builds the v2.20 release + a 3-constant calibration patch, hermetically: AM32's
# `make arm_sdk_install` self-fetches the pinned xPack arm-none-eabi-gcc 10.3.1 into the
# tree, so no system cross-toolchain is needed. Building for the ESC MCU (bare-metal ARM
# Cortex-M / Artery AT32F421) is a cross-compile regardless of host arch.
#
#   docker build -t rekon10-esc .
#   docker run --rm -v "$PWD/out:/work/obj" rekon10-esc
#   # -> out/AM32_TBS_6S_4IN1_F421_2.20.hex  (should match the checked-in hex, md5 ab21eec3)
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      git make wget ca-certificates tar gzip xz-utils patch \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
# Pin to the exact release the ESCs shipped/were flashed with, so the ONLY difference from
# stock firmware is the calibration patch (identical motor drive / DShot / telemetry).
RUN git clone --depth 1 --branch v2.20 https://github.com/am32-firmware/AM32.git . \
    && make arm_sdk_install

COPY rekon10-cal.patch .
RUN git apply rekon10-cal.patch

CMD ["make", "TBS_6S_4IN1_F421"]
