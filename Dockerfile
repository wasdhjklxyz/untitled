FROM alpine:latest AS base
RUN apk add --no-cache \
    wget \
    build-base \
    linux-headers \
    bash \
    bc \
    bison \
    flex \
    elfutils-dev

FROM base AS kernel-builder
WORKDIR /src
RUN wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.47.tar.xz \
    && tar -xf linux-6.12.47.tar.xz \
    && cd linux-6.12.47 \
    && make O=/kernel allnoconfig
WORKDIR /kernel
RUN /src/linux-6.12.47/scripts/config \
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
    --enable CONFIG_SYS \
    --enable CONFIG_MODULES \
    --enable CONFIG_MODULE_UNLOAD \
    && make olddefconfig \
    && make -j$(nproc)

FROM kernel-builder AS untitled-builder
WORKDIR /untitled
COPY ./src ./
RUN make -C /kernel M=$PWD

FROM base AS busybox-builder
WORKDIR /src
RUN wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2 \
    && tar -xf busybox-1.36.1.tar.bz2 \
    && cd busybox-1.36.1 \
    && mkdir -p /busybox \
    && make O=/busybox defconfig
WORKDIR /busybox
RUN sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config \
    && sed -i 's/CONFIG_TC=y/# CONFIG_TC is not set/' .config \
    && make oldconfig \
    && make -j$(nproc) \
    && make install

FROM base AS initramfs-builder
COPY scripts/initramfs-init.sh /tmp/init
RUN mkdir -p /initramfs
COPY --from=busybox-builder /busybox/_install/bin /initramfs/bin
COPY --from=busybox-builder /busybox/_install/sbin /initramfs/bin
COPY --from=busybox-builder /busybox/_install/usr/bin /initramfs/usr/bin
COPY --from=busybox-builder /busybox/_install/usr/sbin /initramfs/usr/sbin
COPY --from=untitled-builder /untitled /initramfs/lib/modules/6.12.47/untitled
RUN cp /tmp/init /initramfs/init \
    && chmod +x /initramfs/init
WORKDIR /initramfs
RUN find . | cpio -ov --format=newc > /initramfs.cpio
