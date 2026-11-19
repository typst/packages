#import "../constants.typ" as constants
#import "units.typ" as units


// labelled abstract, set slightly smaller and indented
#let abstract-block(abstract) = pad(x: units.space.md, {
  set text(size: units.font.sm)
  set par(justify: true, leading: .72em)

  text(weight: "bold", fill: constants.palette.grey.dark)[Abstract]
  h(units.space.sm)
  abstract
})


// title block: ?meta-top, title, ?subtitle, ?authors, ?abstract
#let title-content(
  title,
  subtitle: none,
  authors: none,
  meta-top: none,
  abstract: none,
  highlight: constants.palette.red,
) = block(width: 100%, below: units.space.base, {
  if meta-top != none {
    text(size: units.font.sm, fill: constants.palette.grey.medium, meta-top)
    v(units.space.sm)
  }

  block(below: units.space.sm, {
    set par(leading: 0.5em, justify: false)
    text(size: units.font.xl, weight: "bold", title)
  })

  if subtitle != none {
    block(above: units.space.md, below: units.space.sm, {
      set par(leading: 0.6em, justify: false)
      text(size: units.font.lg, fill: constants.palette.grey.medium, subtitle)
    })
  }

  block(above: units.space.md, below: units.space.md, line(
    length: constants.span.p2,
    stroke: units.weight.xl + highlight,
  ))

  if authors != none {
    set par(justify: false)
    authors
  }

  if abstract != none {
    v(units.space.sm)
    abstract-block(abstract)
  }
})


// base, title block + body in ?columns
#let base(
  title: none,
  subtitle: none,
  authors: none,
  meta-top: none,
  abstract: none,
  highlight: constants.palette.red,
  columns: 2,
  body
  ) = {
  if title != none {
    title-content(
      title,
      subtitle: subtitle,
      authors: authors,
      meta-top: meta-top,
      abstract: abstract,
      highlight: highlight,
    )
  }

  if columns > 1 {
    std.columns(columns, gutter: units.space.base, body)
  } else {
    body
  }
}
