#let labeling(separator: [:#h(0.6em)], indent: 0pt, spacing: auto, pairs) = {
  table(
    columns: (indent, auto, auto, auto),
    stroke: none,
    inset: (x: 0pt),
    row-gutter: spacing,
    ..(for (k, v) in pairs {
      ([], align(right + top, k), align(left + top, separator), align(left + top, v),)
    }),
  )
}
