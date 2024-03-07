#let exam(
  title: "Título",
  professor: "Professor",
  email: "email@example.com",
  program: "Engenharia de Programação",
  course: "Progrmação I",
  semester: "2023.2",
  doc,
) = {
  set page(
    margin: (top: 4.25cm, bottom: 3.25cm, left: 2.25cm, right: 2.25cm),
    header: image("../assets/ifsc-header.png"),
    footer: [
      #set text(font: "Fira Sans", stretch: 50%, size: 0.65em)
      #set align(center)
      #text(
        rgb(50, 160, 65),
      )[*Instituto Federal de Santa Catarina -- Câmpus São José*]\
      Rua José Lino Kretzer, 608 --- Praia Comprida --- São José, SC --- CEP:
      88130-310\
      Fone: (48) 3381-2800 --- #link("www.ifsc.edu.br") \
      página #counter(page).display("1 de 1", both: true)
    ],
  )

  set text(font: "Latin Modern Roman", size: 1em, lang: "br")
  set par(justify: true)
  show link: underline

  show heading.where(level: 1): it => [
    #set align(center)
    #set text(size: 0.9em)
    #v(3em, weak: true)
    #it.body
    #v(3em, weak: true)
  ]

  show heading.where(level: 2): it => [
    #v(3em, weak: true)
    #it.body
    #v(2em, weak: true)
  ]

  show heading: set text(font: "Latin Modern Sans")

  set enum(spacing: 2em)

  box(
    width: 100%,
    stroke: 0.25pt + luma(150),
    fill: luma(240),
    inset: 1.25em,
  )[
      #align(center)[
        #set text(font: "Latin Modern Sans")
        #text(course, size: 1.1em) \
        #text(program, size: 0.9em)
      ]
    ]

  text(professor, size: 0.9em, font: "Latin Modern Sans")
  h(1fr)
  text(semester, size: 0.9em, font: "Latin Modern Sans")

  heading(title, level: 1)

  doc
}
