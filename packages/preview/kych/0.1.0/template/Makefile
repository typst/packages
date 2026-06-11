# =============================================================================
# 网站构建 Makefile (Website Build System)
# =============================================================================
# 此 Makefile 负责将 Typst 源文件编译为静态 HTML 网站或 PDF 文档：
# 1. 自动发现 content/ 目录下所有 .typ 文件（排除以下划线开头的）
# 2. 生成对应的输出路径映射（content/ → _site/ 或 _site/pdf/）
# 3. html: 使用 typst compile --format html 编译为 HTML
# 4. pdf:  使用 typst compile          编译为 PDF
# 5. 复制静态资源（CSS、图片等）到 _site/assets/
# =============================================================================

# --- 找到所有需要编译的 Typst 源文件 ---
# 排除以下划线开头的路径（约定：_ 前缀表示私有/辅助文件，不生成独立页面）
TYP_FILES := $(shell find content -name '*.typ' -not -path '*/_*')

# --- 生成对应的 HTML 输出路径 ---
# 例如：content/blog/index.typ  →  _site/blog/index.html
#       content/index.typ       →  _site/index.html
HTML_FILES := $(patsubst content/%.typ,_site/%.html,$(TYP_FILES))

# --- 生成对应的 PDF 输出路径 ---
# 例如：content/blog/index.typ  →  _pdf/blog/index.pdf
PDF_FILES := $(patsubst content/%.typ,_pdf/%.pdf,$(TYP_FILES))

# --- 主构建目标 ---
# html 目标依赖于所有 HTML 文件和资源文件
html: $(HTML_FILES) assets

# pdf 目标：将所有 .typ 文件编译为 PDF，放入 _pdf/ 目录
pdf: $(PDF_FILES)

# --- 模式规则：将 .typ 文件编译为 .html 文件 ---
# Makefile 自动变量说明：
#   $<   = 第一个依赖（即 .typ 源文件）
#   $@   = 目标文件（即输出的 .html 文件）
#   $(@D) = 目标文件的目录部分
#
# typst compile 参数说明：
#   --root ..        — 设置项目根目录为 template/ 的父目录（即包根目录）
#   --features html  — 启用 HTML 导出特性（实验性功能，需要 Typst 0.14+）
#   --format html    — 输出格式为 HTML
_site/%.html: content/%.typ
	@mkdir -p $(@D)
	typst compile --root .. --features html --format html $< $@

# --- 模式规则：将 .typ 文件编译为 .pdf 文件 ---
# 添加 --features html 使 target() 函数可用（返回 "pdf"）
# 这样 kych-web() 可以自动检测输出目标来适配排版
_pdf/%.pdf: content/%.typ
	@mkdir -p $(@D)
	typst compile --root .. --features html $< $@

# --- 复制静态资源 ---
# 将 assets/ 目录中的所有文件复制到 _site/assets/
# 包括 CSS 样式表、图片等
assets:
	@mkdir -p _site/assets
	@cp -r assets/* _site/assets/

# --- 清理构建产物 ---
# 删除 _site/ 目录下所有生成的文件
clean:
	rm -rf _site/*

# 声明这些目标是伪目标（不对应实际文件）
.PHONY: html pdf clean assets