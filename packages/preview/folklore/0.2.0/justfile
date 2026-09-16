list:
    just --list --

thumbnail page:
    cd template && typst compile -f png --pages {{page}} --ppi 250 main.typ thumbnail.png
    mv template/thumbnail.png .
    oxipng thumbnail.png