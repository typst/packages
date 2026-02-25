# Find all .typ files in content/ that don't start with an underscore in their path
TYP_FILES := $(shell find content -name '*.typ' -not -path '*/_*')

# Generate corresponding HTML file paths in _site/
HTML_FILES := $(patsubst content/%.typ,_site/%.html,$(TYP_FILES))

# The main target 'html' depends on all generated HTML files and assets
html: $(HTML_FILES) assets

# Pattern rule to compile .typ files to .html files
# $< is the first prerequisite (the .typ file)
# $@ is the target (the .html file)
# $(@D) is the directory part of the target
_site/%.html: content/%.typ
	@mkdir -p $(@D)
	typst compile --root .. --features html --format html $< $@

assets:
	@mkdir -p _site/assets
	@cp -r assets/* _site/assets/

# A clean rule to remove generated files
clean:
	rm -rf _site/*

.PHONY: html clean assets
