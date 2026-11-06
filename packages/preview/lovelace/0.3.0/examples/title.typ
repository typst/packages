#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 1em)
#set text(font: "TeX Gyre Pagella")
#show math.equation: set text(font: "TeX Gyre Pagella Math")

#pseudocode-list(stroke: none, title: smallcaps[Fancy-Algorithm])[
  + do something
  + do something else
  + *while* still something to do
    + do even more
    + *if* not done yet *then*
      + wait a bit
      + resume working
    + *else*
      + go home
    + *end*
  + *end*
]
