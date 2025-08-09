#import "author-marker.typ": author

#let project(
  title: "",
  subtitle: "",
  authors: (),
  uni-name: "",
  uni-logo: none,
  uni-supervisor: "",
  company-name: "",
  company-logo: none,
  company-supervisor: "",
  line-spacing: none,
  legend-on-outline: none,
  heading-font: "",
  text-font: "",
  body,
) = {
  if (type(authors) != array) {
    panic("put a trailing comma after the author's object")
  }

  if (authors.len() > 6) {
    panic("this template is not made for more than 6 authors")
  }


  // Fonts & Measures
  let body-font = text-font
  let body-size = 12pt
  let heading-font = heading-font
  let h1-size = 2em
  let h2-size = 1.2em
  let h3-size = 1em
  let h4-size = 1em
  let page-grid = 16pt // vertical spacing on all pages

  set document(author: authors.map(a => a.name), title: title)
  set page(margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm)) //formal requirement
  show math.equation: set text(weight: 400)

  // === Cover ===
  set text(font: heading-font, lang: "de", region: "DE", size: body-size)

  v(0.6fr)

  if (company-logo == none) {
    align(end, uni-logo)
  } else {
    grid(
      columns: (1fr, 1fr),
      align(start + horizon, uni-logo), align(end + horizon, company-logo),
    )
  }

  v(7fr)

  grid(
    rows: 2,
    gutter: 1em,
    text(size: 4em, weight: "bold", title),
    text(size: 1.2em, subtitle),
  )

  v(1.5fr)

  grid(
    gutter: .7em,
    strong(company-name),

    [Betreuer im Unternehmen: #company-supervisor],

    v(.2em),

    strong(uni-name),
    [Betreuer an der Hochschule: #uni-supervisor],
  )

  v(6fr)

  if (authors.len() > 1) {
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1.8em,
      ..authors.map(author => [
        #author.name \
        Matrikelnummer: #author.studentId
      ])
    )
  } else {
    align(end, grid(
      columns: 1,
      gutter: .7em,
      ..authors.map(author => [
        #set align(start)
        #author.name \
        Matrikelnummer: #author.studentId
      ]),
    ))
  }

  v(0.2fr)


  // === Document ===

  show heading: set text(font: heading-font, lang: "de", region: "DE")
  set heading(numbering: "1.1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set text(size: h1-size)
    block(below: 1em, it.body)
  }

  show heading.where(level: 2): it => {
    v(1em)
    text(size: h2-size, it)
  }

  show heading.where(level: 3): set text(size: h3-size)

  show heading.where(level: 4): set text(size: h4-size)

  // Outline
  show outline.entry.where(level: 1): it => {
    set block(above: 2em)
    set text(weight: "semibold")
    link(
      it.element.location(), // make entry linkable
      it.indented(it.prefix(), it.body() + box(width: 1fr)),
    )
  }
  outline()
  show outline.entry: it => {
    link((it.element.location()))
  }

  if (legend-on-outline) {
    v(1fr)
    [*Autorenkennzeichnung*]
    grid(
      columns: calc.min(authors.len(), 3),
      gutter: 1.2em,
      ..authors.map(author => [
        #box(fill: author.color, width: 1em, height: 1em, radius: 1em, baseline: .2em)
        #author.name
      ])
    )
  }

  // Body
  set text(font: body-font)
  set par(justify: true, leading: calc.min(line-spacing, 1.2em)) //layout requirement
  set page(
    numbering: "1",
    number-align: center,
  )
  counter(page).update(1)

  body
}
