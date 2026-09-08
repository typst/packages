// ==========================================================================
//  Packages
// ==========================================================================

#import "@preview/subpar:0.2.2"

// ==========================================================================
//  Typography Constants
// ==========================================================================

#let _default-font-body = "New Computer Modern"
#let _default-font-mono = "New Computer Modern Mono"
#let _font-size = 11pt
#let _line-spacing = 0.65em
#let _par-spacing = 1.2em

// ==========================================================================
//  Header
// ==========================================================================

#let _current-chapter = state("chapter", none)
#let _current-section = state("section", none)

#let _build-main-header(content) = {
  align(center, smallcaps(content))
  line(length: 100%)
}

#let _build-secondary-header(chapter, section) = {
  smallcaps(chapter)
  h(1fr)
  emph(section)
  line(length: 100%)
}

#let _header = context {
  let chapter = _current-chapter.get()
  let section = _current-section.get()

  let next-chapter = query(heading.where(level: 1)).find(h => (
    h.location().page() == here().page()
  ))

  if next-chapter != none {
    _build-main-header(next-chapter.body)
  } else if chapter == none {
    []
  } else if section != none {
    _build-secondary-header(chapter, section)
  } else {
    _build-main-header(chapter)
  }
}

// ==========================================================================
//  Footer
// ==========================================================================

#let _build-footer(
  school-logo,
  company-logo,
) = context {
  line(length: 100%)
  grid(
    columns: (1fr, 1fr, 1fr),
    align: (left, center, right),
    if (company-logo != none) {
      company-logo
    } else {
      []
    },
    text(1.2em, counter(page).display("1 / 1", both: true)),
    school-logo,
  )
}
// ==========================================================================
//  Subfigures
// ==========================================================================

#let subfig = subpar.grid.with(
  numbering: n => {
    let chapter = counter(heading.where(level: 1)).get().first()
    numbering("I", chapter) + "." + str(n)
  },
  numbering-sub: (m, n) => {
    let chapter = counter(heading.where(level: 1)).get().first()
    numbering("I", chapter) + "." + str(m) + " (" + numbering("a", n) + ")"
  },
  numbering-sub-ref: (m, n) => {
    let chapter = counter(heading.where(level: 1)).get().first()
    numbering("I", chapter) + "." + str(m) + " (" + numbering("a", n) + ")"
  },
)

// ==========================================================================
//  Page Components
// ==========================================================================

#let _person-grid(people, columns) = {
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

#let _title-page(
  school-logo,
  company-logo,
  sector,
  document-type,
  title,
  authors,
  author-columns,
  advisers,
  adviser-columns,
  date,
) = {
  if (company-logo != none) {
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      school-logo, company-logo,
    )
  } else {
    align(center, school-logo)
  }

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
  _person-grid(authors, author-columns)

  if advisers.len() > 0 {
    v(8em)
    align(center, text(1.2em, smallcaps[Supervisé par]))
    v(0.8em)
    _person-grid(advisers, adviser-columns)
  }

  place(bottom + center, text(1.2em, date))
  pagebreak()
}

#let _abstract-page(abstract) = {
  if (abstract != none) {
    v(1fr)
    align(center, heading(outlined: false, numbering: none, text(
      0.85em,
      smallcaps[Abstract],
    )))
    abstract
    v(1.618fr)
    pagebreak()
  }
}

#let _toc-page() = {
  outline(depth: 3)
  pagebreak()
}

#let _heading-num(it) = {
  if it.numbering != none {
    numbering(it.numbering, ..counter(heading).at(it.location()))
    [ ]
  }
  it.body
}

// ==========================================================================
//  Template
// ==========================================================================

#let template(
  school-logo: image("./assets/logo.png", width: 50%),
  company-logo: none,

  sector: none,
  document-type: none,
  title: "",
  authors: (),
  author-columns: 1,
  advisers: (),
  adviser-columns: 1,
  date: datetime.today().display("[month repr:long] [year]"),
  abstract: [],

  font-body: "Linux Libertine",
  font-mono: "JetBrains Mono",
  chapter-break: true,

  body,
) = {
  // --  Document metadata ---------------------------------------------------
  set document(author: authors.map(a => a.name), title: title)

  // -- Page -----------------------------------------------------------------

  set page(paper: "a4", margin: 2.5cm)

  // -- Text -----------------------------------------------------------------

  set text(
    font: (font-body, _default-font-body),
    size: _font-size,
    lang: "fr",
  )

  set par(
    justify: true,
    leading: _line-spacing,
    first-line-indent: 1.5em,
    spacing: _par-spacing,
  )

  // -- Math -----------------------------------------------------------------

  set math.equation(numbering: it => {
    let chapter = counter(heading.where(level: 1)).get().first()
    numbering("(I.1)", chapter, it)
  })

  show math.equation: it => {
    set text(weight: "regular")
    it
  }

  // -- Code blocks ----------------------------------------------------------

  show raw: set text(
    font: (font-mono, _default-font-mono),
    size: 0.9em,
  )

  // -- Figures --------------------------------------------------------------

  set figure(
    numbering: n => {
      let chapter = counter(heading.where(level: 1)).get().first()
      numbering("I", chapter) + "." + str(n)
    },
    placement: none,
  )

  show figure: it => {
    v(1em)
    it
    v(1em)
  }

  show figure.where(kind: raw): it => {
    show raw: it => block(
      stroke: 1pt + luma(150),
      fill: luma(240),
      inset: 1em,
      radius: 2pt,
      width: auto,
      it,
    )
    it
  }

  // -- Headings --------------------------------------------------------------

  set heading(numbering: "I.1.a")

  show heading.where(level: 1): it => {
    if it.outlined {
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
      counter(math.equation).update(0)
      if chapter-break { pagebreak(weak: true) }
      _current-chapter.update(it.body)
      _current-section.update(none)
    }
    v(2em)
    block(
      width: 100%,
      inset: (left: 1em),
      stroke: (left: 3pt + black),
      text(1.6em, weight: "bold", _heading-num(it)),
    )
    v(1em)
  }

  show heading.where(level: 2): it => {
    if it.outlined { _current-section.update(it.body) }
    v(1.2em)
    {
      set par(first-line-indent: 0em)
      text(1.2em, weight: "bold", smallcaps(_heading-num(it)))
    }
    v(0.6em)
  }

  show heading.where(level: 3): it => {
    v(0.8em)
    {
      set par(first-line-indent: 0em)
      text(1em, weight: "bold", style: "italic", _heading-num(it))
    }
    v(0.4em)
  }

  show heading: it => {
    if (it.level > 3) {
      set par(first-line-indent: 0em)
      text(1em, weight: "bold", style: "italic", it.body)
    } else {
      it
    }
  }

  // -- Front matter --------------------------------------------------------------

  _title-page(
    school-logo,
    company-logo,
    sector,
    document-type,
    title,
    authors,
    author-columns,
    advisers,
    adviser-columns,
    date,
  )

  _abstract-page(abstract)

  _toc-page()

  set page(
    header: _header,
    footer: _build-footer(
      school-logo,
      company-logo,
    ),
    numbering: "1",
  )

  counter(page).update(1)

  body
}
