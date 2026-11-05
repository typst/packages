#import "../lib.typ": report, callout
#show: report.with(config: (
  toc: (depth: 0), lof: (depth: 0), lot: (depth: 0),
  page: (paper: "a6", margin: 12mm),
  typography: (hyphenate: true),
))

= A comprehensible heading without awkward hyphenation

#callout(title: [A finding with an attached title])[
  A short introduction to the result.

  #lorem(130)

  `a_smaller_code_only_line`

  A final paragraph with the same body rhythm.
]

#figure(
  callout(title: [A box inside a figure])[
    This text keeps its reading alignment instead of inheriting the figure's
    centered alignment.
  ],
  kind: image,
  caption: [An explanatory box inside a figure.],
)
