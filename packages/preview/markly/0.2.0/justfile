# This file is used just to generate the thumbnail so that is looks good on the
# typst universe.
PAGE := "1"
DPI := "250"

alias c := compile
alias tt := template_thumbnail
alias pt := preview_thumbnail

[doc('Compiles the template to PDF')]
compile:
    cd template; \
    typst compile main.typ ../main.pdf

[doc('Generates template thumbnail from PDF')]
template_thumbnail:
    cd template; \
    typst compile --pages {{PAGE}} --ppi {{DPI}} main.typ ../template.png

    oxipng -o 4 --strip safe --alpha template.png

[doc('Previews the generated thumbnail')]
preview_thumbnail: template_thumbnail
    ls -l template.png
    open -a Acorn.app template.png

clean:
    rm template.png
