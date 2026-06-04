# Makefile for Typst UCAS Thesis
# 使用 typstyle 格式化 Typst 代码

# 定义变量
TYPSTYLE = typstyle
TYPST_FILES = $(shell find . -name "*.typ" -not -path "./node_modules/*" -not -path "./.git/*")
MAIN_FILES = lib.typ template/thesis.typ

# 默认目标
.PHONY: help
help:
	@echo "可用的命令："
	@echo "  make format        - 格式化所有 .typ 文件"
	@echo "  make format-main   - 仅格式化主要文件 (lib.typ, template/thesis.typ)"
	@echo "  make format-check  - 检查代码格式但不修改文件"
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
