#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 1em)
#set text(font: "TeX Gyre Pagella")
#show math.equation: set text(font: "TeX Gyre Pagella Math")

#pseudocode(
  with-line-label(<start>)[do something],
  with-line-label(<important>)[do something important],
  [go back to @start],
)

The relevance of the step in @important cannot be overstated.
