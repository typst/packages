version=0.2.5

local:
	mkdir -p ~/.local/share/typst/packages/local/glossarium/${version}
	cp -r * ~/.local/share/typst/packages/local/glossarium/${version}

all:
	typst compile --root . example/example.typ 

watch:
	typst watch --root .  example/example.typ 

fmt:
	find -name "**.typ" -exec typstfmt {} \;
