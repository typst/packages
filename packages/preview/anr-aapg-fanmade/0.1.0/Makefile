.PHONY: all
all: compile-first compile-second

# `typst` does not support compiling several files at once...
.PHONY: compile-first compile-second
compile-first:
	typst compile template/first-proposal.typ
compile-second:
	typst compile template/second-proposal.typ

# `typst` does not support watching several files at once...
.PHONY: watch-first watch-second
watch-first:
	typst watch template/first-proposal.typ
watch-second:
	typst watch template/second-proposal.typ

# Typst packaging rules require thumbnails for templates,
# that show a picture rendering of the first page of the document.
#
# We use webp to reduce file size in the typst-packages repository.
# See discussion in https://github.com/typst/packages/pull/2007
thumbnails: first-proposal-thumbnail.webp second-proposal-thumbnail.webp

%-thumbnail.png: template/%.typ
	typst compile $< $@ --pages 1 --ppi 250

%-thumbnail.webp: %-thumbnail.png
	magick $< -define webp:target-size=200000 $@

template/first-proposal.pdf: compile-first
template/second-proposal.pdf: compile-second

.PHONY: clean
clean:
	rm -f template/*.pdf
	rm -f *-thumbnail.png
	rm -f *-thumbnail.webp

# run this from within the typst-packages repository,
# after copying the git-versioned package.
.PHONY: prepare-package
prepare-package:
	$(MAKE) clean
	$(MAKE) thumbnails
	# currently we only export second-proposal as a template, so remove the first thumbnail
	rm first-proposal-thumbnail.webp
	git status
