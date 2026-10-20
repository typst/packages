# Optional local helpers for documents created with `typst init @preview/polycv`.
# (In the Typst web app, use the `typst`/UI equivalents instead.)
#   make        -> build every cv*/letter* whose source changed -> PDFs
#   make watch  -> live-preview them all (WATCH=<file> for one; Ctrl-C stops)
#
# Data is validated against the schema at compile time: an invalid field stops
# the build, naming it (e.g. /meta/locale). See FIELDS.md for every field.
#
# The prefix before the first '-' picks the template (cv-*.yml -> cv.typ,
# letter-*.yml -> letter.typ), so a bilingual CV is just cv-en.yml / cv-fr.yml
# (set `meta: locale` in each). To customize for a company, add a file that
# inherits a parent (cv-acme.yml with `inherit: cv-fr.yml`) and only the fields
# that differ; editing a parent rebuilds only what inherits it.
# Set FMT=toml to use the .toml data files.
FMT ?= yaml
EXT := $(if $(filter toml,$(FMT)),toml,yml)
WATCH ?=

CV_SRCS  := $(wildcard cv*.$(EXT))
LET_SRCS := $(wildcard letter*.$(EXT))
CV_PDFS  := $(CV_SRCS:.$(EXT)=.pdf)
LET_PDFS := $(LET_SRCS:.$(EXT)=.pdf)

.DEFAULT_GOAL := build
.PHONY: build watch

build: $(CV_PDFS) $(LET_PDFS)

$(CV_PDFS): %.pdf: %.$(EXT) cv.typ
	typst compile cv.typ $@ --input data=$< --input fmt=$(FMT)

$(LET_PDFS): %.pdf: %.$(EXT) letter.typ
	typst compile letter.typ $@ --input data=$< --input fmt=$(FMT)

# A PDF also depends on its `inherit:` ancestor chain, so editing a parent
# rebuilds only what inherits it - not unrelated CVs.
_inherit   = $(shell [ -f '$1' ] && sed -n 's/^[[:space:]]*inherit:[[:space:]]*//p' '$1' | head -n1)
_parent    = $(strip $(if $(call _inherit,$1),$(dir $1)$(call _inherit,$1)))
_ancestors = $(if $(call _parent,$1),$(call _parent,$1) $(call _ancestors,$(call _parent,$1)))
$(foreach s,$(CV_SRCS) $(LET_SRCS),$(eval $(s:.$(EXT)=.pdf): $(call _ancestors,$s)))

watch:
	@files="$(WATCH)"; [ -n "$$files" ] || files="$(wildcard cv*.$(EXT)) $(wildcard letter*.$(EXT))"; \
	echo "Watching $$files (Ctrl-C to stop)..."; \
	trap 'kill 0' EXIT INT TERM; \
	for f in $$files; do \
	  tmpl=$${f%.*}; tmpl=$${tmpl%%-*}; \
	  typst watch $$tmpl.typ $${f%.*}.pdf --input data=$$f --input fmt=$(FMT) & \
	done; \
	wait
