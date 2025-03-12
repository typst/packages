.PHONY: all
all: compile-first compile-second

# `typst` does not support compiling several files at once...
.PHONY: compile-first compile-second
compile-first:
	typst compile first-proposal.typ
compile-second:
	typst compile second-proposal.typ

# `typest` does not support watching several files at once...
.PHONY: watch-first watch-second
watch-first:
	typst watch first-proposal.typ
watch-second:
	typst watch second-proposal.typ

# Typst packaging rules require thumbnails for templates,
# that show a PNG rendering of the first page of the document.
thumbnails: first-proposal-thumbnail.png second-proposal-thumbnail.png

%-thumbnail.png: %.pdf
	magick -density 250 $<[0] -flatten $@
	oxipng -o 2 $@

first-proposal.pdf: compile-first
second-proposal.pdf: compile-second
