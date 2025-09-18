FROM alpine:latest AS base

RUN apk add --no-cache wget build-base

FROM base AS kernel-builder
RUN apk add --no-cache \
  linux-headers \
  bash \
  bc \
  bison \
  flex \
  elfutils-dev

WORKDIR /src
ENV KERNEL_VERSION=6.12.47
ENV KERNEL_BUILD=/kernel

RUN wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz && \
  tar -xf linux-${KERNEL_VERSION}.tar.xz && \
  cd linux-${KERNEL_VERSION} && \
  make O=${KERNEL_BUILD} allnoconfig

WORKDIR ${KERNEL_BUILD}
RUN /src/linux-${KERNEL_VERSION}/scripts/config \
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

FROM base AS busybox-builder
WORKDIR /src
ENV BUSYBOX_VERSION=1.36.1
ENV BUSYBOX_BUILD=/busybox

RUN wget https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2 && \
  tar -xf busybox-${BUSYBOX_VERSION}.tar.bz2 && \
  cd busybox-${BUSYBOX_VERSION} && \
  mkdir -p ${BUSYBOX_BUILD} && \
  make O=${BUSYBOX_BUILD} allnoconfig

WORKDIR ${BUSYBOX_BUILD}
RUN make LDFLAGS="-static" CONFIG_STATIC=y -j$(nproc)
