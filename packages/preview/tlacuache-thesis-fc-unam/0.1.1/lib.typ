
#let bib = state("bib", none)

#let currentH(level: 1)={
  let elems = query(selector(heading.where(level: level)).after(here()))
  if elems.len() != 0 and elems.first().location().page() == here().page() {
    return elems.first().body
  } else {
    elems = query(selector(heading.where(level: level)).before(here()))
    if elems.len() != 0 {
      return elems.last().body
    }
  }
  return ""
}

#let thesis(
  titulo: [Titulo],
  grado: [Licenciatura],
  autor: [Autor],
  asesor: [Asesor],
  lugar: [Ciudad de México, México],
  agno: [#datetime.today().year()],
  bibliography: [],
  body,
)={
  // configuración páginas y contadores
  set document(title: titulo)
  set page("us-letter", margin: (top: 4cm, bottom: 2cm), header: context{
    if here().page() == 1 {
      return
    }
    if calc.rem(here().page(), 2) == 0 [
      #align(left, text(currentH(), size: 18pt))
      #line(length: 100%, start: (0%, -7%))
    ] else [
      #align(right, currentH(level: 2))
      #line(length: 100%)
    ]
  })
  set text(font: "New Computer Modern", lang: "es")
  set heading(numbering: "1.1.")

  set math.equation(
    numbering: num =>
    "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")",
  )

  set par(first-line-indent: 1em)

  set block(spacing: 1.5em)

  // Portada
  place(line(length: 70%, start: (30%, 10%), stroke: 3pt))
  place(line(length: 70%, start: (30%, 13%)))

  place(line(length: 60%, start: (10%, 20%), angle: 90deg, stroke: 3pt))
  place(line(length: 60%, start: (13%, 20%), angle: 90deg))

  place(image("./escudos/UNAM_crest_black.svg", width: 100pt))
  place(bottom, image("./escudos/FC_crest_black.svg", width: 100pt))

  set align(center)
  move(dx: 70pt, [
    #v(1.2cm)
    #text(1.5em, [Universidad Nacional Autónoma de México])

    #v(1.2cm)
    #text(1.5em, [Facultad de Ciencias])

    #v(2cm)
    #text(1.5em, [#titulo])

    #v(2cm)
    #text(3em, spacing: 200%, [T e s i s])

    #upper([QUE PARA OPTAR POR EL GRADO DE:])

    #grado

    #v(1cm)
    #upper([Presenta])

    #autor

    #v(1cm)
    #upper([DIRECTOR DE TESIS:])

    #asesor

    #v(1cm)
    #lugar, #agno.
  ])

  pagebreak()

  // Table of contents.
  outline(depth: 3, indent: true)
  set page(numbering: "1")
  counter(page).update(1)

  let line-spacing = 0.65em * 1.5
  set par(justify: true, leading: line-spacing)
  show heading.where(level: 1): it => [
    #pagebreak(to: "even")
    #set align(right)
    #v(40%)
    #set text(font: "Inria Serif", size: 40pt)
    #it.body
    #line(length: 100%, start: (0%, 0%), stroke: gray)
    #pagebreak(weak: true)
  ]

  set align(left)

  body

  if not bibliography == [] {
    [#bibliography <bib>]
  }
}

#let chapter(bibliography: [], body) = {
  set math.equation(
    numbering: num =>
    "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")",
  )

  body

  context(if query(<bib>).len() != 1 and bibliography == [] {
    pagebreak()
    bibliography
  })
}

#let section(bibliography: [], body) = {
  set math.equation(
    numbering: num =>
    "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")",
  )

  body

  context(if query(<bib>).len() != 1 and bibliography == [] {
    pagebreak()
    bibliography
  })
}
