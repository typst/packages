#import "@preview/tictactoe:1.0.0":  tictactoe

#set page(width: 12cm, margin: 4mm, height: auto)

#let game = tictactoe[1697]

#grid(columns: (3cm,1fr),
  column-gutter: 1em,
  game.field,
  [
    = Tic Tac Toe

    Solve any conflict with a game of competitive tic-tac-toe.
    #v(1fr)
    ```typst
    #import "@preview/tictactoe:1.0.0"
    #tictactoe.tictactoe[1697].field
    ```
    #v(1fr)
  ]
)