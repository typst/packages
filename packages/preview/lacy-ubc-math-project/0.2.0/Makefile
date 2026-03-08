VER = 0.2.0
SRC = $(wildcard src/*.typ)

clean:
	find src/ -type f -name '*.pdf' -exec rm -f {} +
	rm -f template/*.pdf
	rm -f test/*.pdf

thumbnail:
	typst compile --pages=1 template/project-1.typ thumbnail.png

repo: thumbnail clean
	rm -rf ~/src/my-typst/lacy-ubc-math-project/*
	cp -r * ~/src/my-typst/lacy-ubc-math-project/

