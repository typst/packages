#let report(
  title: "Typst IFSC",
  subtitle: none,
  authors: ("Gabriel Luiz Espindola Pedro",),
  date: none,
  doc,
) = {
  // Define metadados do documento
  set document(title: title, author: authors)

  set page(
    numbering: "1",
    paper: "a4",
    margin: (top: 3cm, bottom: 2cm, left: 3cm, right: 2cm),
  )
  set text(size: 12pt)
  // TODO: verificar se há necessidade de colocar espaçamento de 1.5
  set par(
    first-line-indent: 1.5cm,
    justify: true,
    leading: 0.65em,
    linebreaks: "optimized",
  )
  set heading(numbering: "1.")
  set math.equation(numbering: "(1)")

  align(center)[
    #image("assets/ifsc-v.png", width: 10em)
  ]

  align(horizon + center)[
    #text(20pt, title, weight: "bold")
    #v(1em)
    #text(subtitle, weight: "regular")
  ]

  align(bottom + left)[
    #text(list(..authors, marker: "", body-indent: 0pt), weight: "semibold")
    #text(date)
  ]

  pagebreak()

  show outline.entry.where(level: 1): it => {
    strong(it)
  }

  // TODO: Verificar maneira melhor de alterar espaçamento entre titulo e corpo
  outline(title: [Sumário #v(1em)], indent: 2em)

  pagebreak()

  doc
}