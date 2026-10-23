# 模板仓库根 Makefile:开发期把本仓库软链进 Typst 的本地包缓存,
# 于是 `@preview/underhell:<版本>` 直接读工作区,改完即可编译,不必先发布。
# / Root Makefile: symlink this repo into Typst's local package cache so
# `@preview/underhell:<version>` resolves to the working tree during development.
#
#   make link     # 建链,之后 template/、example/ 的 import 即可编译
#   make unlink   # 拆链

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
VERSION  := $(shell sed -n 's/^version = "\(.*\)"/\1/p' "$(ROOT_DIR)/typst.toml")

ifeq ($(shell uname), Darwin)
CACHE := $(HOME)/Library/Caches/typst/packages/preview
else
CACHE := $(HOME)/.cache/typst/packages/preview
endif

.PHONY: link unlink

link:  ## 把本仓库链进 Typst 本地包缓存
	@mkdir -p "$(CACHE)/underhell"
	@ln -sfn "$(ROOT_DIR)" "$(CACHE)/underhell/$(VERSION)"
	@echo "linked: $(CACHE)/underhell/$(VERSION) -> $(ROOT_DIR)"

unlink:  ## 移除软链
	@rm -f "$(CACHE)/underhell/$(VERSION)"
	@echo "unlinked: $(CACHE)/underhell/$(VERSION)"
