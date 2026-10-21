#import "@preview/synkit:0.1.0": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))

Tree from Carnie (2013), with node labels displayed.

#tree(
  "[ CP [] [ C' [ C Ø_{\[+Q\]+T+Mangez} ] [ TP [ DP vous ] [ T' [ T *t*_i ] [ VP [ *t*_{DP} ] [ V' [V *t*_i ] [DP des pommes] ] ]  ] ] ] ]",
  arrows: (
    (from: "t3", to: "T1"),
    (from: "t2", to: "DP1"),
    (from: "t1", to: "C1"),
  ),
  curved: true,
  show-refs: true,
)
