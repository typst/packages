#let labeling(separator: [:#h(0.6em)], indent: 0pt, spacing: auto, body) = {
  grid(
    columns: (indent, auto, auto, auto),
    stroke: none,
    inset: (x: 0pt),
    row-gutter: 0.65em,
    ..(for (k, v) in body {
      ([], align(right + top, k), align(left + top, separator), align(left + top, v),)
    }),
  )
}
