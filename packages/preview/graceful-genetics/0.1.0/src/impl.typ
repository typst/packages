#let make-venue = {
  box(rect(fill: luma(140), inset: 10pt, height: 2.5cm)[
    #set text(font: "TeX Gyre Pagella", fill: white, weight: 700, size: 20pt)
    #align(bottom)[OXFORD]
  ])
  set text(22pt, font: "TeX Gyre Heros")
  box(pad(left: 10pt, bottom: 10pt, [PHYSICS]))
}

#let template(
    title: [],
    authors: (),
    date: [],
    doi: "",
    keywords: (),
    abstract: [],
    body,
) = {
    set page(
      paper: "a4",
      margin: (top: 1.9cm, bottom: 1in, x: 1.6cm),
    )
    set text(10pt, font: "TeX Gyre Pagella")
    set list(indent: 8pt)
    // show link: set text(underline: false)
    show heading: set text(size: 11pt)
    show heading.where(level: 1): set text(font: "TeX Gyre Heros", fill: rgb("004b71"), size: 12pt)
    show heading: set block(below: 8pt)
    show heading.where(level: 1): set block(below: 12pt)

    place(top, dy: -1.9cm, make-venue)

    v(80pt)
    strong(text(24pt, font: "TeX Gyre Heros", fill: rgb("004b71"), title))
    v(-10pt)
    text(12pt, font: "TeX Gyre Heros",
      authors.enumerate().map(((i, author)) => author.name + [ ] + super[#(i+1)]).join(", "))
    v(4pt)
    for (i, author) in authors.enumerate() [
      #set text(8pt)
      #super[#(i+1)]
      #author.institution
      #link("mailto:" + author.mail) \
    ]

    v(8pt)
    set text(10pt)
    set par(justify: true)

    [
      = Abstract
      #text(font: "TeX Gyre Heros", abstract)
      #v(3pt)
      *Keywords:* #{keywords.join("; ")}
    ]
    v(18pt)

    show figure: align.with(center)
    show figure: set text(8pt)
    show figure.caption: pad.with(x: 10%)

    show: columns.with(2)
    body
  }