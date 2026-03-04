#let _heading-block(it, size: 11pt, above: 1em, below: 0.5em) = block(
  above: above,
  below: below,
  text(size: size, weight: "bold")[
    #if it.numbering != none {
      numbering("1.1", ..counter(heading).at(it.location()))
      h(0.5em)
    }
    #it.body
  ],
)

#let configure-document-styles(lang, bib-title, body) = {
  set text(font: "Arial", size: 11pt, lang: lang, hyphenate: true)
  set par(justify: true, leading: 0.65em, first-line-indent: 0em)
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.0cm, left: 4.0cm, right: 2.0cm),
  )

  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    _heading-block(it, size: 12pt, above: 1.5em, below: 0.8em)
  }
  show heading.where(level: 2): it => _heading-block(it, above: 1.2em, below: 0.6em)
  show heading.where(level: 3): it => _heading-block(it, above: 1em, below: 0.5em)
  show heading.where(level: 4): it => _heading-block(it, above: 0.9em, below: 0.4em)

  show outline.entry: set block(above: 1em)

  show figure.caption: set text(size: 10pt)
  show figure.where(kind: table): set figure(kind: image)

  show bibliography: set heading(numbering: "1.")
  set bibliography(title: bib-title, style: "../din-1505-2.csl")

  body
}
