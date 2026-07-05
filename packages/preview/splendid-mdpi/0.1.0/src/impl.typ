#let make-venue(venue, publisher) = {
  box(venue)
  h(1fr)
  box(publisher)
  v(2pt)
  line(length: 100%)
  v(5pt)
}

#let template(
  title: [],
  authors: (),
  date: [],
  doi: "",
  keywords: (),
  abstract: [],
  venue: image("ijms.png", height: 1.2cm),
  venue-abbrv: [_Int. J. Mol. Sci._],
  venue-link: "https://www.mdpi.com/journal/anawesomejournal",
  publisher: image("mdpi.svg", height: 1.2cm),
  paper-type: [Article],
  details: auto,
  body,
) = {
  set page(
    paper: "a4",
    margin: (top: 1.9cm, bottom: 1.1in, x: 1.6cm),
    footer: {
      set text(8pt)
      v(1fr)
      line(length: 100%, stroke: 0.5pt)
      v(5pt)
      [#venue-abbrv *#date.year*, #date.day, #date.month. ]
      link("https://doi.org/" + doi)
      h(1fr)
      link(venue-link)
      v(0.75cm)
    }
  )

  set text(10pt, font: "TeX Gyre Pagella")
  set list(indent: 8pt)
  show heading: set block(below: 8pt)

  make-venue(venue, publisher)

  emph(paper-type)
  v(-4pt)
  strong({
    block(text(18pt, title))
    v(4pt)
    authors.enumerate().map(((i, author)) => author.name + [ ] + super[#{i+1}]).join(", ")
  })

  let details = [
    #set text(7pt)
    #set par(leading: 7pt)
    #show par: set block(spacing: 18pt)
    *Citation:* #{authors.map(author => author.name).join("; ")}.
    #title.
    #venue-abbrv 
    *#date.year,* #date.day, #date.month.
    #link("https://doi.org/" + doi)
    #details
  ]

  show: (body) => grid(
    columns: (120pt, 1fr),
    column-gutter: 10pt,
    align(bottom, details),
    align(bottom, body),
  )

  set par(justify: true)
  text(9pt)[
    #for (i, author) in authors.enumerate() [
      #super[#{i+1}]
      #{author.institution};
      #link("mailto:" + author.mail) \
    ]

    #v(8pt)
    *Abstract:* #abstract
    
    *Keywords:* #{keywords.join("; ")}.
  ]

  v(5pt)
  line(length: 100%, stroke: 0.5pt)
  v(0pt)

  show figure: align.with(center)
  show figure: set text(8pt)
  show figure.caption: pad.with(x: 10%)

  body
}