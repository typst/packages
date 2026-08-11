# Makefile for Typst UCAS Thesis
# 使用 typstyle 格式化 Typst 代码

# 定义变量
TYPSTYLE = typstyle
TYPST_FILES = $(shell find . -name "*.typ" -not -path "./node_modules/*" -not -path "./.git/*")
MAIN_FILES = lib.typ template/thesis.typ
PACKAGE_CHECK = package-check

# 默认目标
.PHONY: help
help:
	@echo "可用的命令："
	@echo "  make format        - 格式化所有 .typ 文件"
	@echo "  make format-main   - 仅格式化主要文件 (lib.typ, template/thesis.typ)"
	@echo "  make format-check  - 检查代码格式但不修改文件"
	@echo "  make lint          - 运行包检查 (需要安装 package-check)"
	@echo "  make lint-install  - 安装 package-check 工具"
	@echo "  make list-files    - 列出所有将被格式化的 .typ 文件"
	@echo ""
	@echo "详细使用说明请参考: docs/FORMAT.md"

# 格式化所有 .typ 文件
.PHONY: format
format:
	@echo "正在格式化所有 Typst 文件..."
	@for file in $(TYPST_FILES); do \
		echo "格式化: $$file"; \
		$(TYPSTYLE) --inplace "$$file" || echo "警告: 格式化 $$file 失败"; \
	done
	@echo "格式化完成！"

# 仅格式化主要文件
.PHONY: format-main
format-main:
	@echo "正在格式化主要文件..."
	@for file in $(MAIN_FILES); do \
		if [ -f "$$file" ]; then \
			echo "格式化: $$file"; \
			$(TYPSTYLE) --inplace "$$file" || echo "警告: 格式化 $$file 失败"; \
		else \
			echo "文件不存在: $$file"; \
		fi; \
	done
	@echo "主要文件格式化完成！"

# 检查代码格式（不修改文件）
.PHONY: format-check
format-check:
	@echo "检查代码格式..."
	@failed=0; \
	for file in $(TYPST_FILES); do \
		echo "检查: $$file"; \
		if ! $(TYPSTYLE) --check "$$file" >/dev/null 2>&1; then \
			echo "❌ $$file 需要格式化"; \
			failed=1; \
		else \
			echo "✅ $$file 格式正确"; \
		fi; \
	done; \
	if [ $$failed -eq 1 ]; then \
		echo ""; \
		echo "有文件需要格式化，请运行 'make format'"; \
		exit 1; \
	else \
		echo ""; \
		echo "所有文件格式正确！"; \
	fi

# 列出所有将被格式化的文件
.PHONY: list-files
list-files:
	@echo "将被格式化的 .typ 文件："
	@for file in $(TYPST_FILES); do \
		echo "  $$file"; \
	done

# 清理生成的文件
.PHONY: clean
clean:
	@echo "清理生成的文件..."
	@find . -name "*.pdf" -not -path "./template/thesis.pdf" -delete
	@echo "清理完成！"

# 格式化指定文件（使用方法: make format-file FILE=path/to/file.typ）
.PHONY: format-file
format-file:
	@if [ -z "$(FILE)" ]; then \
		echo "错误: 请指定文件路径，例如: make format-file FILE=lib.typ"; \
		exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "错误: 文件不存在: $(FILE)"; \
		exit 1; \
	fi
	@echo "格式化文件: $(FILE)"
	@$(TYPSTYLE) --inplace "$(FILE)"
	@echo "格式化完成！"

# 显示项目统计信息
.PHONY: stats
stats:
	@echo "项目统计信息："
	@echo "  Typst 文件数量: $$(echo '$(TYPST_FILES)' | wc -w)"
	@echo "  总行数: $$(cat $(TYPST_FILES) | wc -l)"
	@echo "  主要文件: $(MAIN_FILES)"

# ============ 包检查 (Lint) ============

# 安装 package-check 工具
.PHONY: lint-install
lint-install:
	@echo "正在安装 typst/package-check..."
	@if command -v cargo >/dev/null 2>&1; then \
		echo "使用 cargo 安装..."; \
		cargo install --git https://github.com/typst/package-check.git; \
	else \
		echo "❌ 请先安装 Rust/Cargo: https://rustup.rs/"; \
		exit 1; \
	fi
	@echo "✅ package-check 安装完成！"

# 运行包检查（需要在本地有完整的 package index）
.PHONY: lint
lint:
	@echo "运行 Typst 包检查..."
	@if ! command -v $(PACKAGE_CHECK) >/dev/null 2>&1; then \
		echo "❌ package-check 未安装"; \
		echo "   请运行: make lint-install"; \
		exit 1; \
	fi
	@echo "检查包结构和元数据..."
	@$(PACKAGE_CHECK) . || (echo "❌ 包检查失败"; exit 1)
	@echo "✅ 包检查通过！"

# 快速检查（不依赖外部 index，仅检查基本结构）
.PHONY: lint-quick
lint-quick:
	@echo "运行快速包检查..."
	@echo "检查 typst.toml..."
	@if [ ! -f "typst.toml" ]; then \
		echo "❌ typst.toml 不存在"; \
		exit 1; \
	fi
	@echo "✅ typst.toml 存在"
	@echo "检查必要字段..."
	@grep -q "^name = " typst.toml || (echo "❌ 缺少 name 字段"; exit 1)
	@grep -q "^version = " typst.toml || (echo "❌ 缺少 version 字段"; exit 1)
	@grep -q "^entrypoint = " typst.toml || (echo "❌ 缺少 entrypoint 字段"; exit 1)
	@echo "✅ 基本字段完整"
	@echo "检查入口文件..."
	@entrypoint=$$(grep "^entrypoint = " typst.toml | sed 's/.*= "\(.*\)".*/\1/'); \
	if [ ! -f "$$entrypoint" ]; then \
		echo "❌ 入口文件 '$$entrypoint' 不存在"; \
		exit 1; \
	fi
	@echo "✅ 入口文件存在"
	@echo ""
	@echo "✅ 快速检查通过！"
