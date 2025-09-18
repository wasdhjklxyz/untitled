FROM alpine:latest AS builder

RUN apk add --no-cache \
  wget \
  build-base \
  linux-headers \
  bash \
  bc \
  bison \
  flex \
  elfutils-dev

WORKDIR /build

ENV LINUX_BUILD=/build/linux
RUN wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.47.tar.xz && \
  tar -xf linux-6.12.47.tar.xz && \
  cd linux-6.12.47 && \
  make O=$LINUX_BUILD allnoconfig && \
  cd $LINUX_BUILD && \
  /build/linux-6.12.47/scripts/config \
    --enable CONFIG_64BIT \
    --enable CONFIG_INITRAMFS_SOURCE \
    --enable CONFIG_BLK_DEV_INITRD \
    --enable CONFIG_PRINTK \
    --enable CONFIG_BINFMT_ELF \
    --enable CONFIG_BINFMT_SCRIPT \
    --enable CONFIG_DEVTMPFS \
    --enable CONFIG_DEVTMPFS_MOUNT \
    --enable CONFIG_TTY \
    --enable CONFIG_SERIAL_8250 \
    --enable CONFIG_SERIAL_8250_CONSOLE \
    --enable CONFIG_PROC_FS \
    --enable CONFIG_SYS && \
  make olddefconfig && \
  make -j$(nproc)
