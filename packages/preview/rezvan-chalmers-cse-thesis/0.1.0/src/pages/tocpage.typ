#let in-outline = state("in-outline", false)

#let flex-caption(short, long) = context if in-outline.get() { short } else { long }

#let odd-or-next(oneside) = {
  if oneside {
    pagebreak()
  } else {
    pagebreak(to: "odd")
  }
}

#let tocpage(figures, tables, listings, oneside: false) = {
  set page(numbering: "i")

  v(100pt)

  show heading: set text(size: 24pt)
  align(center, heading(outlined: false)[Contents])

  v(55pt)

  show outline.entry: set outline.entry(fill: repeat("." + h(6pt)))
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }
  {
    show outline.entry.where(level: 1): set outline.entry(fill: none)
    show outline.entry.where(level: 1): it => {
      v(8pt)
      strong(it)
    }
    outline(title: none, indent: auto)
  }

  if figures {
    odd-or-next(oneside)
    v(100pt)
    align(center, text(24pt)[= List of Figures])
    outline(
      title: none,
      target: figure.where(kind: image),
    )
  }
  if tables {
    odd-or-next(oneside)
    v(100pt)
    align(center, text(24pt)[= List of Tables])
    outline(title: none, target: figure.where(kind: table))
  }
  if listings {
    odd-or-next(oneside)
    v(100pt)
    align(center, text(24pt)[= List of Listings])
    outline(title: none, target: figure.where(kind: raw))
  }
}
