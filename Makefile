IMAGE_NAME := untitled
BUILD_DIR := build

.PHONY: all build extract rebuild clean

all: extract

build:
	docker build --target kernel-builder -t $(IMAGE_NAME)-kernel .
	docker build --target busybox-builder -t $(IMAGE_NAME)-busybox .

extract: build
	mkdir -p $(BUILD_DIR)
	docker run --rm -v $(shell pwd)/$(BUILD_DIR):/host $(IMAGE_NAME)-kernel \
		sh -c "cp -r /kernel /host"
	docker run --rm -v $(shell pwd)/$(BUILD_DIR):/host $(IMAGE_NAME)-busybox \
		sh -c "cp -r /busybox /host"

rebuild:
	docker build --no-cache --target kernel-builder -t $(IMAGE_NAME)-kernel .
	docker build --no-cache --target busybox-builder -t $(IMAGE_NAME)-busybox .

clean:
	sudo rm -rf $(BUILD_DIR)
	docker rmi $(IMAGE_NAME)-kernel $(IMAGE_NAME)-busybox 2>/dev/null || true
