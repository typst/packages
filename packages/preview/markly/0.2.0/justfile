# This file is used just to generate the thumbnail so that is looks good on the
# typst universe.
PAGE := "1"
DPI := "250"

alias tt := template_thumbnail
alias pt := preview_thumbnail

[doc('Generates template thumbnail from PDF')]
template_thumbnail:
    cd template; \
    typst compile --pages {{PAGE}} --ppi {{DPI}} main.typ ../thumbnail.png

    oxipng -o 4 --strip safe --alpha thumbnail.png

[doc('Previews the generated thumbnail')]
preview_thumbnail: template_thumbnail
    ls -l thumbnail.png
    open -a Acorn.app thumbnail.png

clean:
    rm thumbnail.png
