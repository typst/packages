VER = 0.2.0
SRC = $(wildcard src/*.typ)

clean:
	rm -f src/**/*.pdf
	rm -f template/*.pdf
	rm -f test/*.pdf

prepare:
	(cd src/ && ls -1 *.typ > internal.txt)

thumbnail:
	typst compile --pages=1 template/project-1.typ thumbnail.png

repo: thumbnail clean
	rm -rf ~/src/my-typst/lacy-ubc-math-project/*
	cp -r * ~/src/my-typst/lacy-ubc-math-project/

