#import "@preview/polylux:0.4.0": *

#let ukj-blue = rgb(0, 84, 163)

#let setup(body) = {
  set page(
    paper: "presentation-16-9",
    margin: (top: 30mm, x: 18mm, bottom: 10mm),
    header-ascent: 0mm,
    header: toolbox.full-width-block(
      inset: (left: 5%, bottom: 1cm),
      image("img/header-decoration.svg", width: 100%),
    ),
    footer: {
      h(1fr)
      set text(size: 12pt)
      toolbox.slide-number
    },
  )

  set text(
    font: "Fira Sans",
    size: 18pt,
  )
  show math.equation: set text(font: "Fira Math")

  show heading.where(level: 1): set text(size: 23pt, fill: ukj-blue)
  show heading.where(level: 1): set block(spacing: 30pt)

  set list(marker: text(fill: ukj-blue, sym.square.filled), indent: 1em)

  body
}

#let title-slide(group: [], title: [], subtitle: [], extra: []) = slide[
  #set page(
    margin: 0pt,
    header: none,
    footer: none,
    background: align(top, image("img/title-decoration.svg", width: 100%)),
  )

  #block(
    inset: (left: 10.5cm, right: 5cm),
    height: 2.5cm,
    spacing: 0cm,
    {
      set align(bottom)
      set text(size: 14pt, fill: ukj-blue)
      group
    },
  )

  #block(
    inset: (left: 10.5cm, top: 3cm, right: 5cm),
    {
      text(size: 32pt, fill: ukj-blue, weight: "bold", title)
      v(5mm)
      text(size: 24pt, fill: ukj-blue, weight: "regular", subtitle)
      v(5mm)
      extra
    },
  )
]


