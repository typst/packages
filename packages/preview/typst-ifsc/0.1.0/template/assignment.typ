#let lista(title: "Título", course: "Programação I", doc) = {
  set text(font: "Latin Modern Roman", size: 1.1em, lang: "pt")
  set par(justify: true)
  show link: underline

  show heading.where(level: 1): it => [
    #set align(center)
    #v(3em, weak: true)
    #it.body
    #v(2em, weak: true)
  ]

  show heading.where(level: 2): it => [
    #v(3em, weak: true)
    #it.body
    #v(2em, weak: true)
  ]

  show heading: set text(font: "Latin Modern Sans")

  set enum(spacing: 2em)

  grid(
    columns: (auto, 1fr),
    gutter: 1em,
    image("../assets/ifsc-logo.png", height: 3.5em),
    [
      #set text(font: "Latin Modern Sans")
      Instituto Federal de Santa Catarina\
      Campus São José\
      Área de Telecomunicações
    ],
  )

  heading(level: 1, course + " - " + title)

  doc
}