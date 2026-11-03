#import "../brand.typ": colour

/// Two labelled panels that accept arbitrary Typst content, including code.
#let comparison(
  before,
  after,
  labels: ([Before], [After]),
  columns: (1fr, 1fr),
  gap: 1em,
  accent: colour.primary,
  ink: colour.neutral-dark,
  fill: colour.neutral-light,
  size: 1em,
  inset: .8em,
  radius: .25em,
) = {
  assert(type(labels) == array and labels.len() == 2, message: "comparison needs exactly two labels")
  assert(type(columns) == array and columns.len() == 2, message: "comparison needs exactly two column widths")
  let panel(label, body) = block(
    width: 100%, fill: fill, inset: inset, radius: radius, breakable: false,
    {
      set text(size: size, fill: ink)
      set par(spacing: .55em, leading: .4em)
      stack(dir: ttb, spacing: .65em, text(weight: "semibold", fill: accent, label), body)
    },
  )
  grid(columns: columns, column-gutter: gap, align: top,
    panel(labels.first(), before), panel(labels.last(), after),
  )
}
