SEVERITIES = HIGH,CRITICAL

UNAME_M = $(shell uname -m)
ifndef TARGET_PLATFORMS
	ifeq ($(UNAME_M), x86_64)
		TARGET_PLATFORMS:=linux/amd64
	else ifeq ($(UNAME_M), aarch64)
		TARGET_PLATFORMS:=linux/arm64
	else 
		TARGET_PLATFORMS:=linux/$(UNAME_M)
	endif
endif

BUILD_META=-build$(shell date +%Y%m%d)
PKG ?= github.com/kubernetes/autoscaler
SRC ?= github.com/kubernetes/autoscaler
TAG ?= ${GITHUB_ACTION_TAG}
export DOCKER_BUILDKIT?=1

ifeq ($(TAG),)
TAG := 1.8.22$(BUILD_META)
endif

REPO ?= rancher
IMAGE = $(REPO)/hardened-addon-resizer:$(TAG)
BUILD_OPTS = \
	--platform=$(TARGET_PLATFORMS) \
	--build-arg PKG=$(PKG) \
	--build-arg SRC=$(SRC) \
	--build-arg TAG=$(TAG:$(BUILD_META)=) \
	--tag "$(IMAGE)"

.PHONY: image-build
image-build:
	docker buildx build \
		$(BUILD_OPTS) \
		--load \
		.

.PHONY: push-image
push-image:
	docker buildx build \
		$(BUILD_OPTS) \
		$(IID_FILE_FLAG) \
		--sbom=true \
		--attest type=provenance,mode=max \
		--push \
		.

.PHONY: log
log:
	@echo "TAG=$(TAG:$(BUILD_META)=)"
	@echo "REPO=$(REPO)"
	@echo "IMAGE=$(IMAGE)"
	@echo "PKG=$(PKG)"
	@echo "SRC=$(SRC)"
	@echo "BUILD_META=$(BUILD_META)"
	@echo "UNAME_M=$(UNAME_M)"
	@echo "TARGET_PLATFORMS=$(TARGET_PLATFORMS)"

