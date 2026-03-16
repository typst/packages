#import "@preview/zebraw:0.6.1": *

#let mark-display(switch, mark, inset, width) = {
  if switch == none {return}
  place(dx: -width)[
    #block(width: width)[
      #align(right, mark + h(inset))
    ]
  ]
}


