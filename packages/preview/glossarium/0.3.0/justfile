version := "0.3.0"


# copy typst package to local registry
local:
	mkdir -p ~/.local/share/typst/packages/local/glossarium/{{version}}
	cp -r * ~/.local/share/typst/packages/local/glossarium/{{version}}

build-examples: 
	@find examples/**/*.pdf -delete
	@find examples/**/*.typ -type f -exec sh -c "echo --------- Compiling {} && time typst compile --root . {}" \;

# format typst code (use typstfmt)
fmt:
	find -name "**.typ" -exec typstfmt {} \;