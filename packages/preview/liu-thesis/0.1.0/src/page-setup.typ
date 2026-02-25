// Compute margins from a format dict.
// margin-ratio = edge/spine. 1 = symmetric, 1.5 = asymmetric two-sided.
#let compute-margins(format) = {
  let total = format.page-width - format.type-block-width
  let spine = total / (1 + format.margin-ratio)
  let edge = format.margin-ratio * spine
  (inside: spine, outside: edge)
}

#let compute-margin-bottom(format) = {
  format.page-height - format.margin-top - format.type-block-height
}

#let setup-page(format, language, body) = {
  let margins = compute-margins(format)

  set page(
    width: format.page-width,
    height: format.page-height,
    margin: (
      inside: margins.inside,
      outside: margins.outside,
      top: format.margin-top,
      bottom: compute-margin-bottom(format),
    ),
  )

  set text(
    font: "New Computer Modern",
    size: 10pt,
    lang: if language == "swedish" { "sv" } else { "en" },
  )

  set par(
    justify: true,
    leading: 0.57em,
    spacing: 0.57em,
    first-line-indent: (amount: 1.5em, all: false),
  )

  set heading(numbering: "1.1.1")

  show figure: set block(above: 20pt, below: 20pt)
  show figure.caption: set block(above: 10pt)

  body
}
