// elsearticle.typ
// Author: Mathieu Aucejo
// Github: https://github.com/maucejo
// License: MIT
// Date : 11/2024
#import "@preview/equate:0.2.1": *
#import "_globals.typ": *
#import "_environment.typ": *
#import "_utils.typ": *
#import "_template_info.typ": *

#let elsearticle(
  // The article's title.
  title: none,

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // Your article's abstract. Can be omitted if you don't have one.
  abstract: none,

  // Journal name
  journal: none,

  // Keywords
  keywords: none,

  // For integrating future formats (1p, 3p, 5p, final)
  format: "review",

  // Number of columns
  numcol: 1,

  // Line numbering
  line-numbering: false,

  // The document's content.
  body,
) = {
  // Text
  set text(size: font-size.normal, font: "New Computer Modern")

  // Conditional formatting
  let els-linespace = if format == "review" {linespace.review} else {linespace.preprint}

  let els-margin = if format == "review" {margins.review}
  else if format == "preprint" {margins.preprint}
  else if format == "1p" {margins.one_p}
  else if format == "3p" {margins.three_p}
  else if format == "5p" {margins.five_p}
  else {margins.review}

  let els-columns = if format == "1p" {1}
  else if format == "5p" {2}
  else {if numcol > 2 {2} else {if numcol <= 0  {1} else {numcol}}}

  // Heading
  set heading(numbering: "1.")

  show heading: it => block(above: els-linespace, below: els-linespace)[
    #if it.numbering != none {
      if it.level == 1 {
        set par(leading: 0.75em, hanging-indent: 1.25em)
        set text(font-size.normal)
        numbering(it.numbering, ..counter(heading).at(it.location()))
        text((" ", it.body).join())

        // Update math counter at each new appendix
        if isappendix.get() {
          counter(math.equation).update(0)
          counter(figure.where(kind: image)).update(0)
          counter(figure.where(kind: table)).update(0)
        }
      } else {
        set text(font-size.normal, weight: "regular", style: "italic")
        numbering(it.numbering, ..counter(heading).at(it.location()))
        text((" ", it.body).join())
      }
    } else {
      text(size: font-size.normal, it.body)
    }
  ]

  // Equations
  show: equate.with(breakable: true, sub-numbering: true)
  set math.equation(numbering: (..n) => numbering("(1a)", ..n) , supplement: [Eq.])

  // Figures, subfigures, tables
  show figure.where(kind: table): set figure.caption(position: top)
  set ref(supplement: it => {
    if it.func() == figure and it.kind == image {
      "Fig."
    } else {
      it.supplement
    }
  })

  // Page
  let footer = context{
    let i = counter(page).at(here()).first()
    if i == 1 {
      set text(size: font-size.small)
      emph(("Preprint submitted to ", journal).join())
      h(1fr)
      emph(datetime.today().display("[month repr:long] [day], [year]"))
    } else {align(center)[#i]}
  }

  set page(
    paper: "a4",
    numbering: "1",
    margin: els-margin,
    columns: els-columns,
    // Set journal name and date
    footer: footer
  )

  // Paragraph
  let linenum = none
  if line-numbering {
    linenum = "1"
  }
  set par(justify: true, first-line-indent: indent-size, leading: els-linespace)
  set par.line(numbering: linenum, numbering-scope: "page")

  // Define Template info
  let els-info = template_info(title, abstract, authors, keywords, els-columns)

  // Set document metadata.
  set document(title: title, author: els-info.els-meta)

  place(
    top,
    float: true,
    scope: "parent",
    [
      #els-info.els-authors
      #els-info.els-abstract
    ]
  )
  // Corresponding author
  hide(footnote(els-info.coord, numbering: "*"))
  counter(footnote).update(0)

  // bibliography
  set bibliography(title: "References")
  show bibliography: set heading(numbering: none)
  show bibliography: set text(size: font-size.normal)

  v(-2em)
  body
}
