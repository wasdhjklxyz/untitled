IMAGE_NAME := untitled
BUILD_DIR := build

.PHONY: all build extract rebuild clean

all: extract

build:
	docker build --target kernel-builder -t $(IMAGE_NAME)-kernel .
	docker build --target busybox-builder -t $(IMAGE_NAME)-busybox .
	docker build --target initramfs-builder -t $(IMAGE_NAME)-initramfs .

extract: build
	mkdir -p $(BUILD_DIR)
	docker run --rm -v $(shell pwd)/$(BUILD_DIR):/host \
		$(IMAGE_NAME)-kernel sh -c "cp /kernel/arch/x86_64/boot/bzImage /host"
	docker run --rm -v $(shell pwd)/$(BUILD_DIR):/host \
		$(IMAGE_NAME)-initramfs sh -c "cp /initramfs.cpio.gz /host"

rebuild:
	docker build --no-cache \
		--target kernel-builder -t $(IMAGE_NAME)-kernel .
	docker build --no-cache \
		--target busybox-builder -t $(IMAGE_NAME)-busybox .
	docker build --no-cache \
		--target initramfs-builder -t $(IMAGE_NAME)-initramfs .
	$(MAKE) extract

clean:
	sudo rm -rf $(BUILD_DIR)
	docker rmi \
		$(IMAGE_NAME)-kernel \
		$(IMAGE_NAME)-busybox \
		$(IMAGE_NAME)-initramfs 2>/dev/null || true
