#import "@preview/polylux:0.4.0": *
#import "@preview/jotter-polylux:0.1.0": setup, title-slide, fancy-block

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
]

#slide[
  = Title of this slide

  The content of this slide.

  Some text is *bold*, some text is _emphasized_.

  #fancy-block(inset: 1em, sloppiness: .05)[
    A very important formula:

    $
      hat(mu) = 1 / n sum_(i = 1)^n x_i
    $
  ]
]

#slide[
  = Another slide

  #toolbox.side-by-side[
    Maxwell says:
    $
      integral.surf_(partial Omega) bold(B) dot dif bold(S) = 0
    $
  ][

    - a bullet point
    - another bullet point

    + first point
    + second point

    Compute the answer:
    ```rust
    pub fn main() {
        dbg!(42);
    }
    ```
  ]
]

