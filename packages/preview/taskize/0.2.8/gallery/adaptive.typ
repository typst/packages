// Adaptive row heights: row-gutter: "auto" keeps tall math out of the gutter.
#import "@preview/taskize:0.2.8": tasks

#set page(width: 11cm, height: auto, margin: 6mm)
#set text(size: 11pt)
#show math.frac: it => math.display(it)

*Fixed `row-gutter` — fraction ink bleeds into the gutter:*
#tasks(columns: 2)[
  + $1/2 + 1/3$
  + $3/4 - 1/8$
  + $5/6 dot 2/5$
  + $7/8 : 1/2$
]

*`row-gutter: "auto"` — rows sized to true ink, same gutter honored:*
#tasks(columns: 2, row-gutter: "auto")[
  + $1/2 + 1/3$
  + $3/4 - 1/8$
  + $5/6 dot 2/5$
  + $7/8 : 1/2$
]
