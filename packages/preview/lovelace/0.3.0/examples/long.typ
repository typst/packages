#import "../lib.typ": *
#set page(width: auto, height: 50em, margin: 1em)
#set text(font: "TeX Gyre Pagella")
#show math.equation: set text(font: "TeX Gyre Pagella Math")

#pseudocode(
  booktabs: true,
  // title: [My title],
  ..(([a line], ) * 100)
)
