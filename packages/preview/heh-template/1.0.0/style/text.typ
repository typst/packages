#import "/utils/states.typ": heh-config

#let heh-headings-defaults(doc) = context {
  let config = heh-config.get()
  let decorations-color = config.campus.style.decorations-color

  show heading: set text(weight: "medium") if not config.print.monochrome
  show heading.where(level: 1): set text(
    fill: decorations-color,
  ) if not config.print.monochrome
  show heading.where(level: 2): set text(
    fill: decorations-color.lighten(5%),
  ) if not config.print.monochrome
  show heading.where(level: 3): set text(
    fill: decorations-color.lighten(10%),
  ) if not config.print.monochrome

  set par(spacing: 2em, leading: 0.8em)
  show heading: set text(top-edge: 1.6em, bottom-edge: "descender")

  doc
}

#let heh-links-defaults(doc) = context {
  let config = heh-config.get()
  let decorations-color = config.campus.style.decorations-color

  show link: set text(
    fill: decorations-color.lighten(15%),
  ) if not config.print.monochrome
  show link: it => if config.print.monochrome { underline(it) } else { it }

  doc
}

#let heh-raw-defaults(doc) = context {
  let config = heh-config.get()
  set raw(theme: none) if config.print.monochrome

  doc
}

