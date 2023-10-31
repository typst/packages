all: docs

docs: docs/main.pdf docs/main.png docs/manual.pdf

%.pdf: %.typ
	typst compile --root . $< 

%.png: %.typ
	typst compile --root . $< $(basename $<).png