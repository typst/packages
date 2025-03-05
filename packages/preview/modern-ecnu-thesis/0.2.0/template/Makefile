TYP_SRC = $(shell find . -name '*.typ')

TARGET = thesis.pdf
TARGET_TYP = thesis.typ
TYPST_FLAGS = --pdf-standard 1.7 --root ..

$(TARGET): $(TYP_SRC)
	typst compile $(TYPST_FLAGS) (TARGET_TYP)
	@echo "Build successful: $(shell du -h $(TARGET_TYP) | cut -f1)"

.PHONY: clean, watch, count
clean:
	rm -f $(TARGET)

watch:
	typst watch $(TYPST_FLAGS) $(TARGET_TYP)

# Count words and characters in mainmatter and backmatter
count:
	@echo "#words: $(shell typst query $(TARGET_TYP) '<total-words>' 2>/dev/null --field value --one)"
	@echo "#chars: $(shell typst query $(TARGET_TYP) '<total-chars>' 2>/dev/null --field value --one)"

build-dev:
	typst compile $(TYPST_FLAGS) --input doctype=bachelor $(TARGET_TYP) modern-ecnu-thesis-bachelor.pdf
	typst compile $(TYPST_FLAGS) --input doctype=master --input degree=academic $(TARGET_TYP) modern-ecnu-thesis-master-academic.pdf
	typst compile $(TYPST_FLAGS) --input doctype=master --input degree=professional $(TARGET_TYP) modern-ecnu-thesis-master-professional.pdf
	typst compile $(TYPST_FLAGS) --input doctype=doctor --input degree=academic $(TARGET_TYP) modern-ecnu-thesis-doctor-academic.pdf
	typst compile $(TYPST_FLAGS) --input doctype=doctor --input degree=professional $(TARGET_TYP) modern-ecnu-thesis-doctor-professional.pdf