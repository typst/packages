#import "src/nup.typ": nup
// // #import "@preview/nup:0.1.0": nup
#import "@preview/muchpdf:0.1.0": muchpdf
#let images = muchpdf(read("preview.pdf", encoding: none))

// #nup("2x3", images.children.map(x => x.source))

#let pages = range(1,13).map(
  i => "/images/preview" + str(i) + ".svg")
#nup("2x3", pages)
