ROOT_DIR = .
FONT_DIR = fonts

all: compile

compile:
	typst compile --root $(ROOT_DIR) --font-path $(FONT_DIR) template/main.typ
watch:
	typst watch --root $(ROOT_DIR) --font-path $(FONT_DIR) template/main.typ
