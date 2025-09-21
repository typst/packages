#let coverpage(
  title: none,
  subtitle: none,
  department: none,
  faculty: none,
  university: none,
  academic-year: none,
  degree: none,
  logo: none,
  supervisors: (),
  authors: (),
  is-thesis: true,
) = {
  set page(numbering: none)
  set align(center + horizon)

  text(32pt, weight: "bold")[#title]

  if subtitle != none {
    linebreak()
    v(1em)
    text(18pt)[#subtitle]
  }

  if logo == none {
    logo = image("../figures/logo.svg", width: 37%)
  }

  block(above: 4em, below: 4em, logo)

  set text(16pt)

  if supervisors.len() == 0 and authors.len() > 0 {
    let ncols = calc.max(calc.div-euclid(authors.len(), 3), 1)

    grid(
      columns: (1fr,) * ncols,
      row-gutter: 15pt,
      ..authors.map(author => [#text(size: 14pt, upper(author))])
    )
  } else {
    let authors-title = if is-thesis {
      if authors.len() > 1 { text("CANDIDATES") } else { text("CANDIDATE") }
    } else {
      if authors.len() > 1 { text("AUTHORS") } else { text("AUTHOR") }
    }

    let sups-title = if supervisors.len() > 1 { text("SUPERVISORS") } else {
      text("SUPERVISOR")
    }
    grid(
      columns: (1fr, 1fr),
      align(left, [

        #strong(sups-title)
        #v(0.35em)
      ]),
      align(right, [

        #strong(authors-title)
        #v(0.35em)
      ]),
    )
    grid(
      columns: (1fr, 1fr),
      align(left, grid(
        columns: 1fr,
        row-gutter: 15pt,
        ..supervisors.map(s => [#text(size: 14pt, s)#linebreak()])
      )),

      align(right, grid(
        columns: 1fr,
        ..authors.map(a => [#text(size: 14pt, a)#linebreak()]),
      )),
    )
  }
  set text(14pt)
  v(3em)
  strong(faculty)
  linebreak()
  strong(department)
  linebreak()
  strong(degree)
  linebreak()
  strong(university)
  v(3em)

  if academic-year != none {
    [Academic year #academic-year]
  }
}
