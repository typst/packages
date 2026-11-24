///! Theme presets.
///!
///! Each preset is an option dictionary, so themes compose with table-options()
///! rather than being a separate kind of thing. Striping is an option on any of
///! them, and academic three-line style is theme-booktabs plus options: a theme
///! that differs by one boolean is not a theme.

#let theme-default() = (
  "column-labels-border-bottom": 0.5pt + luma(120),
  "table-border-top": 0.8pt + luma(60),
  "table-border-bottom": 0.8pt + luma(60),
  "footer-border-top": 0.5pt + luma(180),
  "summary-border-top": 0.5pt + luma(180),
  "grand-summary-border-top": 0.8pt + luma(60),
)

// The three-line rule: a heavy rule above and below, a light one under the
// column labels, and nothing else.
#let theme-booktabs() = (
  "table-border-top": 1pt + black,
  "table-border-bottom": 1pt + black,
  "column-labels-border-bottom": 0.5pt + black,
  "spanner-border-bottom": 0.5pt + black,
  "footer-border-top": none,
  "summary-border-top": 0.5pt + black,
  "grand-summary-border-top": 0.5pt + black,
  "cell-inset": 0.45em,
)

#let theme-compact() = (
  ..theme-default(),
  "cell-inset": 0.3em,
  "table-font-size": 0.9em,
)

#let theme-minimal() = (
  "table-border-top": none,
  "table-border-bottom": none,
  "column-labels-border-bottom": 0.5pt + luma(200),
  "footer-border-top": none,
)
