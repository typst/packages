// Semantic algorithm blocks for the thesis.

#import "@preview/lovelace:0.3.1": pseudocode-list

#let thesis-algorithm(content, caption: none, ..args) = {
  figure(
    block(
      width: 100%,
    )[
      #set align(left)
      #pseudocode-list(
        content,
        line-numbering: "1",
        indentation: 1.45em,
        line-gap: 0.38em,
        stroke: 0.45pt + rgb("#b8b8b8"),
        booktabs: true,
        booktabs-stroke: 1.1pt + rgb("#3f3f3f"),
      )
    ],
    caption: caption,
    kind: "algorithm",
    supplement: [Algorithm],
    ..args,
  )
}
