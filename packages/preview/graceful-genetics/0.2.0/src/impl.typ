#let make-venue = move(dy: -1.9cm, {
  box(rect(fill: luma(140), inset: 10pt, height: 2.5cm)[
    #set text(font: "TeX Gyre Pagella", fill: white, weight: 700, size: 20pt)
    #align(bottom)[OXFORD]
  ])
  set text(22pt, font: "TeX Gyre Heros")
  box(pad(left: 10pt, bottom: 10pt, [PHYSICS]))
})

#let make-title(
  title,
  authors,
  abstract,
  keywords,
) = {
  set par(spacing: 1em)
  set text(font: "TeX Gyre Heros")
  
  par(
    justify: false,
    text(24pt, fill: rgb("004b71"), title, weight: "bold")
  )

  text(12pt,
    authors.enumerate()
    .map(((i, author)) => box[#author.name #super[#(i+1)]])
    .join(", ")
  )
  parbreak()

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
    #heading(outlined: false, bookmarked: false)[Abstract]
    #text(font: "TeX Gyre Pagella", abstract)
    #v(3pt)
    *Keywords:* #keywords.join(text(font: "TeX Gyre Pagella", "; "))
  ]
  v(18pt)
}

#let template(
    title: [],
    authors: (),
    date: [],
    doi: "",
    keywords: (),
    abstract: [],
    make-venue: make-venue,
    make-title: make-title,
    body,
) = {
    set page(
      paper: "a4",
      margin: (top: 1.9cm, bottom: 1in, x: 1.6cm),
      columns: 2
    )
    set par(justify: true)
    set text(10pt, font: "TeX Gyre Pagella")
    set list(indent: 8pt)
    // show link: set text(underline: false)
    show heading: set text(size: 11pt)
    show heading.where(level: 1): set text(font: "TeX Gyre Heros", fill: rgb("004b71"), size: 12pt)
    show heading: set block(below: 8pt)
    show heading.where(level: 1): set block(below: 12pt)

    place(make-venue, top, scope: "parent", float: true)
    place(
      make-title(title, authors, abstract, keywords), 
      top, 
      scope: "parent",
      float: true
    )


    show figure: align.with(center)
    show figure: set text(8pt)
    show figure.caption: pad.with(x: 10%)

    // show: columns.with(2)
    body
  }