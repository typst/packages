PAGES=1 3 17 25

$(PAGES):
	@cd example && typst compile --root "../" --pages $@ --ppi 250 main.typ thumbnail-$@.png

thumbnail.webp: $(PAGES)
	@montage $(foreach file,$(PAGES),example/thumbnail-$(file).png) -geometry +2+2 thumbnail.webp
	@rm $(foreach file,$(PAGES),example/thumbnail-$(file).png)

all: thumbnail.webp
