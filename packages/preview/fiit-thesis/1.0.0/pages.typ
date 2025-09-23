#import "_pkgs.typ": hydra.hydra

#let abstract-page(
  title: "Anotácia",
  university: "Slovenská technická univerzita v Bratislave",
  faculty: "Fakulta informatiky a informačných technológií",
  program: (left: "Študijný program", right: "Informatika"),
  author: (left: "Autor", right: "Jožko Mrkvička"),
  thesis: (left: "Záverečná práca", right: "Téma záverečnej práce"),
  supervisor: (
    left: "Vedúci bakalárskeho projektu",
    right: "prof. Jožko Mrkvička",
  ),
  date: "Máj 2025",
  abstract,
) = {
  set text(1.1em)
  v(1fr)

  par(text(1.5em, weight: 700, title))

  text(university)
  linebreak()
  text(upper(faculty))
  linebreak()
  text([#program.left: #program.right])
  linebreak()
  v(1.5em)

  text([#author.left: #author.right])
  linebreak()
  text([#thesis.left: #thesis.right])
  linebreak()
  text([#supervisor.left: #supervisor.right])
  linebreak()
  text(date)
  v(1.5em)

  set par(justify: true)
  abstract

  v(1fr)
  pagebreak()
}

#let title-page(
  header: [
    Slovenská technická univerzita v Bratislave \
    Fakulta informatiky a informačných technológií
  ],
  id: "FIIT-12345-123456",
  author: "Jožko Mrkvička",
  title: "Téma záverečnej práce",
  type: "Záverečná práca",
  date: "Máj 2025",
  footer: (
    (left: "Študijný program", right: "Informatika"),
    (left: "Študijný odbor", right: "Informatika"),
    (
      left: "Miesto vypracovania",
      right: "Ústav počítačového inžinierstva a aplikovanej informatiky",
    ),
    (left: "Vedúci práce", right: "Jožko Mrkvička"),
  ),
) = {
  // top header
  align(
    center,
    text(1.3em, header),
  )
  // ID display
  pad(
    top: 1.2em,
    align(
      center,
      text(1.3em, id),
    ),
  )

  v(15em, weak: false)

  // author information
  pad(
    top: 0.7em,
    align(
      center,
      text(1.1em, author),
    ),
  )
  // title of the paper
  v(1.2em, weak: false)
  align(
    center,
    text(1.3em, title),
  )
  // type of the paper
  v(1.2em, weak: false)
  align(
    center,
    text(1.2em, type),
  )

  // other data goes to the bottom
  v(1fr, weak: false)
  for (left, right) in footer {
    par(text(1.1em)[#left: #h(1fr) #right #linebreak()])
  }
  text(1.1em, date)
  pagebreak()
}

#let list-of-abbreviations(
  title: "List of Abbreviations",
  abbreviations: ("SSL", "Secure socket layer"),
  use-binding: false,
) = {
  heading(title, numbering: none, outlined: false)
  grid(
    columns: (auto, 1fr),
    column-gutter: 5em,
    row-gutter: 1.4em,
    ..abbreviations
      .map(
        it => (
          strong(it.at(0)),
          it.at(1),
        ),
      )
      .flatten()
  )
  pagebreak()
}

