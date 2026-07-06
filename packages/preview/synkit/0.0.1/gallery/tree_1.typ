#import "@preview/synkit:0.0.1": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))

Tree from Carnie (2013).

#tree(
  "[ CP [] [ C' [ C Ø_{[+Q]}+T+Mangez ] [ TP [ DP vous ] [ T' [ T *t*_i ] [ VP [ *t*_DP ] [ V' [V *t*_i ] [DP des pommes] ] ]  ] ] ] ]",
  arrows: (
    (from: "trace3", to: "T1"),
    (from: "trace2", to: "DP1"),
    (from: "trace1", to: "C1"),
  ),
  curved: true,
)
