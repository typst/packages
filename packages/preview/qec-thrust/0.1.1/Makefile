.PHONY: all clean

EXAMPLES_DIR = examples
SOURCES = $(wildcard $(EXAMPLES_DIR)/*.typ)
OUTPUTS = $(SOURCES:.typ=.png)

all: $(OUTPUTS)

$(EXAMPLES_DIR)/%.png: $(EXAMPLES_DIR)/%.typ
	typst compile $< --root=. --format=png

clean:
	rm -f $(EXAMPLES_DIR)/*.png
