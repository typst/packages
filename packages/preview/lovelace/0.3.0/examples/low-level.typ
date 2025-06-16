#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 1em)
#set text(font: "TeX Gyre Pagella")
#show math.equation: set text(font: "TeX Gyre Pagella Math")

#pseudocode(
  [do something],
  [do something else],
  [*while* still something to do],
  indent(
    [do even more],
    [*if* not done yet *then*],
    indent(
      [wait a bit],
      [resume working],
    ),
    [*else*],
    indent(
      [go home],
    ),
    [*end*],
  ),
  [*end*],
)
