# Makefile for generating PDFs from Typst and generating thumbnails with ImageMagick

PDF_DIR = docs/builds
PDF_DIR_LOCALE = docs/locale/builds
TYP_DIR = docs
TYP_DIR_LOCALE = docs/locale
PREVIEW_DIR = previews
DENSITY = 250       # DPI 分辨率
QUALITY = 100       # 输出质量
SIZE = "1080x>"     # 目标缩略图大小

PDF_FILES = article book report
TEMPLATE_DOCS = $(foreach file, $(PDF_FILES), $(PDF_DIR)/$(file).pdf)
TEMPLATE_DOCS_LOCALE = $(PDF_DIR_LOCALE)/article-en.pdf
TEMPLATE_DOCS_ALL = $(TEMPLATE_DOCS) $(TEMPLATE_DOCS_LOCALE)

PREVIEW_IMAGES = $(foreach file, $(PDF_FILES), $(PREVIEW_DIR)/$(file)-1.png $(PREVIEW_DIR)/$(file)-2.png)

PREVIEW_EXTRA = $(PREVIEW_DIR)/article-12.png $(PREVIEW_DIR)/article-9.png

PREVIEW_ALL = $(PREVIEW_IMAGES) $(PREVIEW_EXTRA)

all: $(TEMPLATE_DOCS_ALL) $(PREVIEW_ALL) thumbnail.png

doc: $(TEMPLATE_DOCS_ALL)

preview: $(PREVIEW_ALL)

$(PDF_DIR)/%.pdf: $(TYP_DIR)/%.typ
	mkdir -p $(PDF_DIR)
	cd $(TYP_DIR) && typst compile $*.typ builds/$*.pdf

$(PDF_DIR_LOCALE)/article-en.pdf: $(TYP_DIR_LOCALE)/article-en.typ
	mkdir -p $(PDF_DIR_LOCALE)
	typst compile $(TYP_DIR_LOCALE)/article-en.typ $(PDF_DIR_LOCALE)/article-en.pdf

$(PREVIEW_DIR):
	mkdir -p $(PREVIEW_DIR)

$(PREVIEW_DIR)/%-1.png $(PREVIEW_DIR)/%-2.png: $(PDF_DIR)/%.pdf | $(PREVIEW_DIR)
	magick convert -density $(DENSITY) $<[0] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $(PREVIEW_DIR)/$*-1.png
	magick convert -density $(DENSITY) $<[1] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $(PREVIEW_DIR)/$*-2.png

$(PREVIEW_DIR)/article-12.png $(PREVIEW_DIR)/article-9.png: $(PDF_DIR)/article.pdf | $(PREVIEW_DIR)
	magick convert -density $(DENSITY) $<[11] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $(PREVIEW_DIR)/article-12.png
	magick convert -density $(DENSITY) $<[8] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $(PREVIEW_DIR)/article-9.png

thumbnail.png: template/main.typ
	typst compile template/main.typ previews/main.pdf
	magick convert -density $(DENSITY) previews/main.pdf[0] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove thumbnail.png
	rm previews/main.pdf

clean:
	rm -rf $(PREVIEW_DIR) $(TEMPLATE_DOCS)

.PHONY: all doc preview clean
