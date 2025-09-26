#import "@preview/polylux:0.4.0": *
#import "@preview/jotter-polylux:0.1.0": (
  setup,
  title-slide,
  framed-block,
  post-it,
)

#set text(
  size: 25pt,
  font: "Kalam",
  fill: blue.darken(50%),
)

#show math.equation: set text(font: "Pennstander Math", weight: "light")

#show raw: set text(font: "Fantasque Sans Mono")

#show: setup.with(header: [A short title], highlight-color: red)

#title-slide[My interesting title][
  A subtitle

  The speaker

  Date, Place

  #place(
    horizon + right,
    post-it[
      #set align(horizon + left)
      #set text(size: .6em)
      Don't miss this talk!
    ],
  )
]

#slide[
  = Typography

  #toolbox.side-by-side[
    Style your content beautifully!

    Some text is *bold*, some text is _emphasized_.
  ][
    - a bullet point
    - another bullet point

    + first point
    + second point
  ]
]

#slide[
  = Maths and Code

  #toolbox.side-by-side[
    Maxwell says:
    $
      integral.surf_(partial Omega) bold(B) dot dif bold(S) = 0
    $
  ][
    Compute the answer:
    ```rust
    pub fn main() {
        dbg!(42);
    }
    ```
  ]
]

#slide[
  = Highlighting content

  // #framed-block and #post-it accept a sloppiness parameter that determine how
  // randomized they are.
  // #framed-block also accepts inset, width, and height like the standard
  // #block.

  #toolbox.side-by-side[
    #grid(
      columns: 2,
      gutter: 1em,
      framed-block[a], framed-block[couple],
      framed-block[of], framed-block[randomized],
      framed-block[framed], framed-block[boxes],
    )
  ][
    #box(post-it[a post-it])
    #box(post-it[another post-it])
  ]
]

