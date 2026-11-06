#let project(
  title: [],
  course-name: [],
  course-abrev: [],
  organization: [],
  logo: image("Graphics/ru-logo.svg", width: 40%),
  authors:(),
  author-columns:1,
  supervisors:(),
  supervisors-columns:1,
  bibliography:none,
  paper-size:"a4",
  lang:"is",
  body
) = {
  set document(
    title: title, 
    author: authors.map(author => author.name)
  )
  
  set page(
    footer: context [#datetime.today().display()],
    paper: "a4",
  )

  set text(lang:lang)

  set math.equation(numbering: "(1)")

  set heading(numbering: "1.1")

  set table(stroke: none)

  show figure.where(
    kind: table
  ): set figure.caption(position: top)

  show ref: it => {
    if it.element == none {
      return it
    }

    let counter = if it.element.has("counter") {
      it.element.counter
    } else {
      counter(it.element.func())
    }

    link(it.element.location(), numbering(
      it.element.numbering,
      ..counter.at(it.element.location())
    ))
  }


  show std.bibliography: set text(10pt)
  show std.bibliography: set block(spacing: 0.5em, breakable: false)
  set std.bibliography(title: text(10pt)[References], style: "ieee")

  show link: underline
  show link: set text(stroke: blue + 0.2pt, )

  figure(logo, numbering: none, caption: none)

  
  align(center, text(20pt)[#smallcaps[
    #organization
  ]])

  align(center, text(17pt)[#smallcaps[
    #course-abrev \ #course-name
  ]])

  align(center, pad(y:0.5em,text(26pt)[
    #title
  ]))

  let auths = authors.map(auth=>[
    #auth.name \ 
    #if auth.keys().contains("email") {
      [#link("mailto:" + auth.email) \ ]
    } 
    #if auth.keys().contains("phone") {
      link("tel:" + auth.phone)
    }
  ])
  let auths-align = auths.slice(
    0,
    auths.len() - calc.rem(auths.len(), author-columns)
  )
  let auths-rest = auths.slice(
    auths.len() - calc.rem(auths.len(), author-columns)
  )

  v(1fr)


  grid(
      align:center,
      gutter: 1.5em,
      columns: (1fr,)*author-columns,
      grid.cell(colspan:author-columns,
        text(14pt,smallcaps(align(center)[*Authors*]))
      ),
      ..auths-align,
      if calc.rem(auths.len(),author-columns) != 0 {grid.cell(
        colspan:author-columns,
        grid(
          columns: (1fr,)*auths-rest.len(),
          column-gutter: 3em,
          ..auths-rest
        )
      )}
    )


  let sups = supervisors.map(sup=>[
    #sup.name \ 
    #if sup.keys().contains("title") {
      [#sup.title \ ]
    } 
    #if sup.keys().contains("email") {
      [#link("mailto:" + sup.email) \ ]
    } 
    #if sup.keys().contains("phone") {
      link("tel:" + sup.phone)
    }
  ])
  let sups-align = sups.slice(
    0,
    sups.len() - calc.rem(sups.len(), supervisors-columns)
  )
  let sups-rest = sups.slice(
    sups.len() - calc.rem(sups.len(), supervisors-columns)
  )


  v(1fr)

  grid(
    align:center,
    gutter: 1.5em,
    columns: (1fr,)*supervisors-columns,
    grid.cell(colspan:supervisors-columns,
        text(14pt,smallcaps(align(center)[*Supervisors*]))
      ),
    ..sups-align,
    if calc.rem(sups.len(),supervisors-columns) != 0 {grid.cell(
      colspan:supervisors-columns,
      grid(
        columns: sups-rest.len(),
        column-gutter: 3em,
        ..sups-rest
      )
    )}
  )

  v(1fr)

  
  pagebreak()

  outline()

  pagebreak()

  counter(page).update(1)
  set page(footer: context [
    #datetime.today().display()
    #h(1fr)
    #counter(page).display("1")]
  )

  body

  bibliography
}
