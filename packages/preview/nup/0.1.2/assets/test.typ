// #import "@preview/nup:0.1.2": nup
#import "@local/nup:0.1.2": nup

// with native support for pdf import
// #nup("2x3", range(1,13).map(p => image("preview.pdf", page: p)))

// with muchpdf
#import "@preview/muchpdf:0.1.1": muchpdf
#let images = muchpdf(read("preview.pdf", encoding: none))

#nup("4x3", images.children, row-first: true)

// with a list of images
#let pages = range(1, 12).map(i => image("images/preview" + str(i) + ".svg"))
#nup("2x3", pages)

