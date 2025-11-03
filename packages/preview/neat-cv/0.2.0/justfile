target := "local"

default: compile-pdf

compile-pdf:
    @if [ "{{ target }}" = "published" ]; then \
    	just _compile_pdf template/cv.typ; \
    elif [ "{{ target }}" = "local" ]; then \
    	just _compile-with-local-lib pdf; \
    fi

compile-png:
    @just target={{ target }} compile-png-page 1
    @just target={{ target }} compile-png-page 2

compile-png-page page:
    @if [ "{{ target }}" = "published" ]; then \
    	just _compile_png_page template/cv.typ {{ page }}; \
    elif [ "{{ target }}" = "local" ]; then \
    	just _compile-with-local-lib png {{ page }}; \
    fi

clean:
    rm -f template/cv.tmp.typ template/cv.pdf assets/cv_p*.png

format:
    typstyle -i lib.typ template/cv.typ

_compile-with-local-lib format *args:
    @sed 's|#import "@preview/neat-cv:[0-9.]*"|#import "../lib.typ"|' template/cv.typ > template/cv.tmp.typ
    @if [ "{{ format }}" = "pdf" ]; then \
    	just _compile_pdf template/cv.tmp.typ; \
    elif [ "{{ format }}" = "png" ]; then \
    	just _compile_png_page template/cv.tmp.typ {{ args }}; \
    fi
    @rm template/cv.tmp.typ

_compile_png_page input page:
    typst compile --root . --format png --pages {{ page }} {{ input }} assets/cv_p{{ page }}.png
    oxipng assets/cv_p{{ page }}.png

_compile_pdf input:
    typst compile --root . {{ input }} template/cv.pdf
