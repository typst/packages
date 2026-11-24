// font, language, links, table cells.
#let text-rules(cfg, body) = {
  let font = cfg.typography.font-family
  set text(
    ..if font != auto { (font: font) },
    size: cfg.typography.font-size,
    lang: cfg.lang,
  )

  show link: it => {
    if type(it.dest) == str {
      text(fill: blue.darken(20%), underline(it))
    } else {
      it
    }
  }

  show table.cell: it => {
    set text(size: cfg.typography.table-size)
    set par(justify: false, leading: 0.5em, first-line-indent: 0pt)
    it
  }

  body
}

// paragraph and list layout.
// front matter and appendices should also get it.
#let para-rules(cfg, body) = {
  let p = cfg.paragraph
  set par(
    justify: p.justify,
    first-line-indent: (amount: p.indent, all: true),
    leading: p.leading,
    spacing: p.spacing,
  )
  let w = p.marker-width
  set enum(
    indent: p.list-indent,
    body-indent: 0pt,
    number-align: start + top,
    numbering: (..n) => box(width: w, align(left, numbering("1.", ..n))),
  )
  set list(
    indent: p.list-indent,
    body-indent: 0pt,
    marker: ([•], [‣], [–]).map(m => box(width: w, align(left, m))),
  )
  body
}
