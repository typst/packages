// ==========================================================================
//        Typography
// ==========================================================================

#let default-font-body = "New Computer Modern"
#let default-font-mono = "New Computer Modern Mono"
#let font-size = 11pt
#let line-spacing = 0.65em


// ==========================================================================
//        Header
// ==========================================================================

#let current-chapter = state("chapter", none)
#let current-section = state("section", none)

#let build-main-header(content) = {
  align(center, smallcaps(content))
  line(length: 100%)
}

#let build-secondary-header(main-content, secondary-content) = {
  smallcaps(main-content)
  h(1fr)
  emph(secondary-content)
  line(length: 100%)
}

#let header = context {
  let chapter = current-chapter.get()
  let section = current-section.get()

  let next-chapter = query(heading.where(level: 1)).find(h => (
    h.location().page() == here().page()
  ))

  if next-chapter != none {
    build-main-header(next-chapter.body)
  } else if chapter == none {
    []
  } else if section != none {
    build-secondary-header(chapter, section)
  } else {
    build-main-header(chapter)
  }
}


// ==========================================================================
//        Footer
// ==========================================================================

#let footer = context {
  line(length: 100%)
  grid(
    columns: (1fr, 1fr, 1fr),
    align: (left, center, right),
    [],
    text(
      1.2em,
      counter(page).display("1 / 1", both: true),
    ),
    image("assets/logo.png", width: 50%),
  )
}


// ==========================================================================
//        Page Components
// ==========================================================================

#let person-grid(people, columns) = {
  let cols = calc.min(columns, people.len())
  grid(
    columns: (1fr,) * cols,
    gutter: 2em,
    ..people.map(p => align(center, text(1.2em, [
      #strong(p.name) \
      #emph(p.email)
    ])))
  )
}

#let title-page(
  logo,
  logo-width,
  sector,
  document-type,
  title,
  authors,
  author-columns,
  advisers,
  adviser-columns,
  date,
) = {
  align(center, image(logo, width: logo-width))

  if sector != none {
    align(center, smallcaps(text(1.4em, sector)))
  }

  v(4em)

  if document-type != none {
    align(center, smallcaps(text(1.6em, document-type)))
    v(1em)
  } else {
    v(4em)
  }

  align(center, text(2.6em, weight: "bold", title))

  align(center, [
    #line(length: 60%, stroke: 0.5pt + gray)
    #v(1em)
    #text(1.2em, smallcaps[Réalisé par])
    #v(1em)
  ])
  person-grid(authors, author-columns)

  if advisers.len() > 0 {
    v(8em)
    align(center, text(1.2em, smallcaps[Supervisé par]))
    v(0.8em)
    person-grid(advisers, adviser-columns)
  }

  place(bottom + center, text(1.2em, date))
  pagebreak()
}

#let abstract-page(abstract) = {
  v(1fr)
  align(center, heading(outlined: false, numbering: none, text(
    0.85em,
    smallcaps[Abstract],
  )))
  abstract
  v(1.618fr)
  pagebreak()
}

#let toc-page = {
  outline(depth: 3)
  pagebreak()
}

#let heading-num(it) = {
  if it.numbering != none {
    numbering(it.numbering, ..counter(heading).at(it.location()))
    [ ]
  }
  it.body
}


// ==========================================================================
//        Template
// ==========================================================================

#let template(
  logo: "assets/logo.png",
  logo-width: 50%,
  sector: none,
  document-type: none,
  title: "",
  authors: (),
  author-columns: 1,
  advisers: (),
  adviser-columns: 1,
  font-body: "Linux Libertine",
  font-mono: "JetBrains Mono",
  date: datetime.today().display("[month repr:long] [year]"),
  abstract: [],
  chapter-break: true,
  body,
) = {
  set document(author: authors.map(a => a.name), title: title)
  set page(
    paper: "a4",
    margin: 2.5cm,
  )

  set text(
    font: (font-body, default-font-body),
    size: font-size,
    lang: "fr",
  )

  set par(
    justify: true,
    leading: line-spacing,
    first-line-indent: 1.5em,
    spacing: 0.65em,
  )

  set heading(numbering: "I.1.1")

  show math.equation: it => {
    set text(weight: "regular")
    it
  }

  show raw: set text(
    font: (font-mono, default-font-mono),
    size: 0.9em,
  )

  set figure(
    numbering: "I.1",
    placement: none,
  )

  show figure.caption: it => {
    v(0.3em)
    context {
      let chapter = counter(heading.where(level: 1)).get().first()
      let fig = counter(figure).at(it.location()).first()
      text(0.9em, [*Figure #numbering("I", chapter).#fig* — #emph(it.body)])
    }
  }

  show figure: it => {
    v(1em)
    it
    v(1em)
  }

  show heading.where(level: 1): it => {
    if it.outlined {
      counter(figure).update(0)
      if chapter-break {
        pagebreak(weak: true)
      }
      current-chapter.update(it.body)
      current-section.update(none)
    }
    v(2em)
    block(
      width: 100%,
      inset: (left: 1em),
      stroke: (left: 3pt + black),
      text(1.6em, weight: "bold", heading-num(it)),
    )
    v(1em)
  }

  show heading.where(level: 2): it => {
    if it.outlined {
      current-section.update(it.body)
    }
    v(1.2em)
    text(1.2em, weight: "bold", smallcaps(heading-num(it)))
    v(0.6em)
  }

  show heading.where(level: 3): it => {
    v(0.8em)
    text(1em, weight: "bold", style: "italic", heading-num(it))
    v(0.4em)
  }

  title-page(
    logo,
    logo-width,
    sector,
    document-type,
    title,
    authors,
    author-columns,
    advisers,
    adviser-columns,
    date,
  )

  abstract-page(abstract)

  toc-page

  set page(
    header: header,
    footer: footer,
    numbering: "1",
  )

  counter(page).update(1)

  body
}
