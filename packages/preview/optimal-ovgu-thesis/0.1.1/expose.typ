#import "components.typ": body-font, sans-font, author-fullname

#let oot-expose = (
  title: "",
  author: none,
  lang: "en",
  document-type: "",
  city: "",
  date: "",
  organisation: [],
  body,
) => {
  set document(title: title, author: author-fullname(author))
  set page(
    margin: (left: 30mm, right: 30mm, top: 27mm, bottom: 27mm),
    numbering: "1",
    number-align: center,
  )

  block(inset: 0cm)[
    #set align(center)
    #text(2em, weight: 700, "Exposé: " + document-type)
    #par(leading: 0.6em)[
      #text(1.6em, weight: 500, title)
    ]
    #text(1.2em, weight: 500)[
      #v(0.3em)
      #author-fullname(author)
      #v(0.3em)
      #organisation
    ]
  ]

  v(2em)

  show par: set block(spacing: 1em) if sys.version <= version(0, 11, 1)
  set par(spacing: 1em) if sys.version >= version(0, 12, 0)
  
  set par(leading: 0.7em, justify: true, first-line-indent: 1em)

  set text(font: body-font, size: 10pt, lang: lang)

  show heading: set text(size: 11pt)

  // Remove level 1 headings
  show heading.where(level: 1): h => []

  body
}