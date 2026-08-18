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

PREVIEW_EXTRA = $(PREVIEW_DIR)/article-ratchet.png $(PREVIEW_DIR)/article-countblocks.png
PREVIEW_FEATURES = $(PREVIEW_DIR)/countblock.png $(PREVIEW_DIR)/labelset.png
PREVIEW_LOCALE = $(PREVIEW_DIR)/article-en-1.png $(PREVIEW_DIR)/article-en-2.png $(PREVIEW_DIR)/article-en-ratchet.png $(PREVIEW_DIR)/article-en-countblocks.png

PREVIEW_ALL = $(PREVIEW_IMAGES) $(PREVIEW_EXTRA) $(PREVIEW_FEATURES) $(PREVIEW_LOCALE)

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
	magick -density $(DENSITY) $<[0] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $(PREVIEW_DIR)/$*-1.png
	magick -density $(DENSITY) $<[1] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $(PREVIEW_DIR)/$*-2.png

$(PREVIEW_DIR)/article-ratchet.png: $(PDF_DIR)/article.pdf | $(PREVIEW_DIR)
	magick -density $(DENSITY) $<[18] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $@

$(PREVIEW_DIR)/article-countblocks.png: $(PDF_DIR)/article.pdf | $(PREVIEW_DIR)
	magick -density $(DENSITY) $<[26] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $@

$(PREVIEW_DIR)/countblock.png: $(PDF_DIR)/article.pdf | $(PREVIEW_DIR)
	magick -density $(DENSITY) $<[21] -crop 1580x1290+240+800 +repage -quality $(QUALITY) -resize "1400x>" -background white -alpha remove $@

$(PREVIEW_DIR)/labelset.png: $(PDF_DIR)/article.pdf | $(PREVIEW_DIR)
	magick -density $(DENSITY) $<[18] -crop 1580x1200+240+180 +repage -quality $(QUALITY) -resize "1400x>" -background white -alpha remove $@

$(PREVIEW_DIR)/article-en-1.png: $(PDF_DIR_LOCALE)/article-en.pdf | $(PREVIEW_DIR)
	magick -density $(DENSITY) $<[0] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $@

$(PREVIEW_DIR)/article-en-2.png: $(PDF_DIR_LOCALE)/article-en.pdf | $(PREVIEW_DIR)
	magick -density $(DENSITY) $<[1] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $@

$(PREVIEW_DIR)/article-en-ratchet.png: $(PDF_DIR_LOCALE)/article-en.pdf | $(PREVIEW_DIR)
	magick -density $(DENSITY) $<[16] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $@

$(PREVIEW_DIR)/article-en-countblocks.png: $(PDF_DIR_LOCALE)/article-en.pdf | $(PREVIEW_DIR)
	magick -density $(DENSITY) $<[25] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove $@

thumbnail.png: template/main.typ
	typst compile template/main.typ previews/main.pdf
	magick -density $(DENSITY) previews/main.pdf[0] -quality $(QUALITY) -resize $(SIZE) -background white -alpha remove thumbnail.png
	rm previews/main.pdf

clean:
	rm -rf $(PREVIEW_DIR) $(TEMPLATE_DOCS)

.PHONY: all doc preview clean
