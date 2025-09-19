IMAGE_NAME := untitled
BUILD_DIR := build

.PHONY: all build extract rebuild test clean help

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
		$(IMAGE_NAME)-initramfs sh -c "cp /initramfs.cpio /host"

extract-all: build
	mkdir -p $(BUILD_DIR)
	docker run --rm -v $(shell pwd)/$(BUILD_DIR):/host \
		$(IMAGE_NAME)-kernel sh -c "cp -r /kernel /host"
	docker run --rm -v $(shell pwd)/$(BUILD_DIR):/host \
		$(IMAGE_NAME)-busybox sh -c "cp -r /busybox /host"
	docker run --rm -v $(shell pwd)/$(BUILD_DIR):/host \
		$(IMAGE_NAME)-initramfs \
		sh -c "cp -r /initramfs /host && cp /initramfs.cpio /host"

rebuild:
	docker build --no-cache \
		--target kernel-builder -t $(IMAGE_NAME)-kernel .
	docker build --no-cache \
		--target busybox-builder -t $(IMAGE_NAME)-busybox .
	docker build --no-cache \
		--target initramfs-builder -t $(IMAGE_NAME)-initramfs .
	$(MAKE) extract

test: extract
	qemu-system-x86_64 \
		-kernel $(BUILD_DIR)/bzImage \
		-initrd $(BUILD_DIR)/initramfs.cpio \
		-nographic \
		-append "console=ttyS0 panic=1" \
		-no-reboot \
		-enable-kvm 2>/dev/null || \
	qemu-system-x86_64 \
		-kernel $(BUILD_DIR)/bzImage \
		-initrd $(BUILD_DIR)/initramfs.cpio \
		-nographic \
		-no-reboot \
		-append "console=ttyS0 panic=1"

clean:
	sudo rm -rf $(BUILD_DIR)
	docker rmi \
		$(IMAGE_NAME)-kernel \
		$(IMAGE_NAME)-busybox \
		$(IMAGE_NAME)-initramfs 2>/dev/null || true

help:
	@echo "Available targets:"
	@echo "  extract      - Build and extract kernel, busybox, and initramfs"
	@echo "  extract-all  - Build and extract all artifacts"
	@echo "  rebuild      - Clean build without cache, then extract"
	@echo "  clean        - Remove build artifacts and project Docker images"
	@echo "  test         - Boot kernel in QEMU"
	@echo "  help         - Show this help"
