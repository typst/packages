#import "../utils.typ": styled

// Rules for the font, the language, links and table cells.
#let text-rules(cfg, body) = {
  let font = cfg.typography.font-family
  set text(
    ..if font != auto { (font: font) },
    size: cfg.typography.font-size,
    lang: cfg.lang,
  )

  show link: it => {
    if type(it.dest) == str {
      let style = cfg.typography.url
      if style.at("font", default: auto) == auto {
        style.font = if cfg.code.font == auto { "DejaVu Sans Mono" } else {
          cfg.code.font
        }
      }
      styled(style, it)
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

// Rules for the paragraph and list layout.
// The front matter and the appendices get them too.
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
