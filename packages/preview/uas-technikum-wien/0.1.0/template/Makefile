################################################################################
# USAGE:
# make                                              .... build the main document
# make clean                                        .... cleanup generated files

MAIN       = thesis.typ
SOURCES    = $(wildcard sections/*.typ)
PDF        = $(MAIN:.typ=.pdf)

OUTPUT_DIR = .
STYLE_DIR  = ./styles

#### Rules ####
all: $(MAIN) $(SOURCES)
	typst compile --font-path=$(STYLE_DIR) $(MAIN)
clean:
	rm -f $(OUTPUT_DIR)/$(PDF) 
