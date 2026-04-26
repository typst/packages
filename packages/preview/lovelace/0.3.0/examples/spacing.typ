#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 1em)
#set text(font: "TeX Gyre Pagella")
#show math.equation: set text(font: "TeX Gyre Pagella Math")

#pseudocode-list(indentation: 3em, line-gap: 1.5em)[
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
