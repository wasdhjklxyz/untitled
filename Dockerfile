FROM alpine:latest AS base
RUN apk add --no-cache wget build-base

FROM base AS kernel-builder
RUN apk add --no-cache linux-headers bash bc bison flex elfutils-dev
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
    && make olddefconfig \
    && make -j$(nproc)

FROM base AS busybox-builder
WORKDIR /src
RUN wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2 \
    && tar -xf busybox-1.36.1.tar.bz2 \
    && cd busybox-1.36.1 \
    && mkdir -p /busybox \
    && make O=/busybox allnoconfig
WORKDIR /busybox
RUN make LDFLAGS="-static" CONFIG_STATIC=y -j$(nproc) \
    && make install

FROM base AS initramfs-builder
COPY scripts/initramfs-init.sh /tmp/init
COPY --from=busybox-builder /busybox/_install /initramfs
RUN mkdir -p /initramfs/{bin,sbin,etc,proc,sys,usr/bin,usr/sbin} \
    && cp /tmp/init /initramfs/init \
    && chmod +x /initramfs/init \
    && cd /initramfs \
    && find . -print0 \
        | cpio --null -ov --format=newc \
        | gzip -9 \
        > /initramfs.cpio.gz
