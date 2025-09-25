#import "@preview/linguify:0.4.2": *

#let vde(
  title: "Title",
  authors: "Authors",
  affiliations: "Affiliation",
  email: "Email",
  abstract: "Abstract",
  lang: "en",
  doc
) = {

  set page(
    paper: "a4",
    margin: (
      top: 2cm,
      left: 2cm,
      right: 2cm,
      bottom: 2.5cm,
    ),
  )

  set columns(gutter: 16pt)

  set text(
    font: "Times New Roman",
    size: 10pt,
    lang: lang,
    hyphenate: auto,
    spacing: .22em // Distance between letters
  )

  set par(
    first-line-indent: 0pt,
    justify: true,
    linebreaks: "optimized",
    leading: 0.55em,
    spacing: 1em
  )

  // Language:
  let lang-data = toml("lang.toml")
  set-database(lang-data)

  // Bibliography:
  set bibliography(style: "ieee")

  // Headings:
  set heading(
    numbering: "1.1.1",
    hanging-indent: 2em
  )
  show heading.where(level: 1): set text(size: 14pt)
  show heading.where(level: 2): set text(size: 12pt)
  show heading.where(level: 3): set text(size: 10pt)

  show heading: set block(below: 1.2em)
  show heading: it => if it.numbering == none { it } else { block(counter(heading).display(it.numbering) + h(1.5em) + it.body) }

  show selector(<nonumber>): set heading(numbering: none)

  // Tables:
  show table: set par(justify: false)
  show table.cell.where(y: 0): strong
  set table(
    stroke: (x, y) => {
      (top: 0.7pt + black)
      (bottom: 0.7pt + black)
    },
    align: (x, y) => (
      if x > 0 { center }
      else { left }
    )
  )

  // Header and Document:
  text(size: 16pt, weight: "bold", title)
  v(0pt)
  linebreak()
  for (author) in (authors) {
    author.name + super[#author.affiliation] + if author != authors.last() { ", " } else { "" }
  }
  linebreak()
  for(affiliation) in (affiliations) {
    [#affiliation.id:] + " " + affiliation.name + if affiliation != affiliations.last() { ", " } else { "" }
  }
  linebreak()
  email
  [
    #v(0.5cm)

    #heading(numbering: none, linguify("abstract"))

    #abstract

    #v(0.75cm)

    #columns(2,doc)
  ]
}