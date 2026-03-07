#import "@preview/cross-circle:1.0.0":  cross-circle

#set page(width: 12cm, margin: 4mm, height: auto)

#let game = cross-circle()[1697]

#grid(columns: (3cm,1fr),
  column-gutter: 1em,
  game.field,
  [
    = Cross'n'Circle

    Solve any conflict with a game of competitive _cross'n'circle_ (aka. tic tac toe)).
    #v(1fr)
    ```typst
    #import "@preview/cross-circle:1.0.0"
    #cross-circle.cross-circle[1697].field
    ```
    #v(1fr)
  ]
)