# =============================================================================
# 跨越晨昏 项目构建文件 (Project Makefile)
# =============================================================================
# 此 Makefile 用于：
# 1. 开发阶段：创建本地符号链接以测试包
# 2. 构建 HTML：调用 template/Makefile 将 Typst 源码编译为 HTML 网站
# 3. 打包发布：创建可提交到 Typst Universe 的 zip 包
# =============================================================================

# --- 从 typst.toml 提取版本号 ---
# 使用 grep + sed 从 TOML 文件中提取 version 字段的值
# 例如 version = "0.1.1" → 0.1.1
VERSION := $(shell grep '^version = ' typst.toml | sed 's/version = "\(.*\)"/\1/')

# --- 获取项目根目录的绝对路径 ---
# 用于创建符号链接时指向正确的位置
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# --- 声明伪目标 (Phony Targets) ---
# 这些目标不对应实际文件，始终执行
.PHONY: link link-macos link-linux link-windows sync-assets check build html pdf

# -----------------------------------------------------------------------------
# link：创建符号链接，将本地开发版本链接到 Typst 包缓存
# -----------------------------------------------------------------------------
# 作用：让 Typst 编译器能够通过 @preview/kych:VERSION 引用本地开发中的包
# 根据操作系统自动选择对应的子目标
link:
ifeq ($(OS),Windows_NT)
	$(MAKE) link-windows
else
ifeq ($(shell uname), Darwin)
	$(MAKE) link-macos
else ifeq ($(shell uname), Linux)
	$(MAKE) link-linux
else
	@echo "Unsupported OS"
	@exit 1
endif
endif

# macOS 符号链接：Typst 包缓存在 ~/Library/Caches/typst/packages/
link-macos:
	mkdir -p ~/Library/Caches/typst/packages/preview/kych
	ln -sf $(ROOT_DIR) ~/Library/Caches/typst/packages/preview/kych/$(VERSION)

# Linux 符号链接：Typst 包缓存在 ~/.cache/typst/packages/
link-linux:
	mkdir -p ~/.cache/typst/packages/preview/kych
	ln -sf $(ROOT_DIR) ~/.cache/typst/packages/preview/kych/$(VERSION)

# Windows 符号链接（尚未充分测试）
# TODO: 在 Windows 上测试此目标
link-windows:
	if not exist "%LOCALAPPDATA%\typst\packages\preview\kych" mkdir "%LOCALAPPDATA%\typst\packages\preview\kych"
	mklink /D "%LOCALAPPDATA%\typst\packages\preview\kych\$(VERSION)" .

# --- 同步静态资源 ---
# 将 template/assets/ 中的资源文件复制到项目根目录的 assets/ 目录
# 这些是包级别的资源（如缩略图），与模板中的资源保持同步
ASSETS := devices.webp
sync-assets:
	@mkdir -p assets
	@for asset in $(ASSETS); do \
		rm -f "assets/$$asset"; \
		cp "template/assets/$$asset" "assets/$$asset"; \
	done

# --- 清理构建产物 ---
clean:
	rm -rf template/_site        # 删除生成的 HTML 网站文件
	rm -rf template/_pdf         # 删除生成的 PDF 文件
	find . -name ".DS_Store" -delete  # 删除 macOS 系统文件

# --- 包检查 ---
# 使用 typst-package-check 工具检查包的常见问题
check:
	typst-package-check check

# --- 构建 HTML 网站 ---
# 先创建符号链接（确保模板能引用本地包），再调用模板目录中的 Makefile
html: link
	$(MAKE) -C template html

# --- 构建 PDF 文档 ---
# 先创建符号链接（确保模板能引用本地包），再调用模板目录中的 Makefile
pdf: link
	$(MAKE) -C template pdf

# --- 打包发布 ---
# 创建用于提交到 Typst Universe 的 zip 归档文件
# 包含：源码、模板、资源、许可证、说明文件、包配置
build: sync-assets clean
	zip -r kych-${VERSION}.zip src/ template/ assets/ LICENSE README.md typst.toml