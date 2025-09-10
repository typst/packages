#let coverpage(
  title: none,
  subtitle: none,
  department: none,
  faculty: none,
  university: none,
  academic-year: none,
  degree: none,
  logo: none,
  authors: (),
  supervisors: (),
  is-thesis: false,
) = {
  set page(numbering: none)
  set align(center)

  text(32pt, weight: "bold")[#title]

  if subtitle != none {
    linebreak()
    v(1em)
    text(18pt)[#subtitle]
  }

  if logo == none {
    logo = image("../assets/figures/logo.svg", width: 40%)
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
      grid(
        columns: 1fr,
        row-gutter: 15pt,
        align(left, [
          #strong(sups-title)
          #linebreak()

          #stack(
            dir: ttb,
            spacing: 12pt,
            ..supervisors.map(s => [#text(size: 14pt, s)]),
          )
        ]),
      ),
      grid(
        columns: 1fr,
        align(right, [
          #strong(authors-title)
          #linebreak()

          #stack(
            dir: ttb,
            spacing: 12pt,
            ..authors.map(a => [#text(size: 14pt, a)]),
          )
        ]),
      ),
    )
  }
  set text(14pt)
  v(3em)
  strong(faculty)
  linebreak()
  strong(department)
  linebreak()
  strong(degree)
  v(3em)
  if academic-year != none { 
    [Academic year #academic-year]
  }
}
