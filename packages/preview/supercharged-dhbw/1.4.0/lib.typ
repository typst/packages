#import "@preview/codelst:2.0.1": *
#import "@preview/acrostiche:0.3.1": *
#import "titlepage.typ": *
#import "confidentiality-statement.typ": *
#import "declaration-of-authorship.typ": *

// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

#let supercharged-dhbw(
  title: "",
  authors: (:),
  language: "en",
  at-dhbw: false,
  show-confidentiality-statement: true,
  show-declaration-of-authorship: true,
  show-table-of-contents: true,
  show-acronyms: true,
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-code-snippets: true,
  show-appendix: false,
  show-abstract: true,
  show-header: true,
  numbering-alignment: center,
  toc-depth: 3,
  abstract: none,
  appendix: none,
  acronyms: none,
  university: "",
  university-location: "",
  supervisor: "",
  date: datetime.today(),
  bibliography: none,
  logo-left: none,
  logo-right: none,
  logo-size-ratio: "1:1",
  body,
) = {
  // set the document's basic properties
  set document(title: title, author: authors.map(author => author.name))
  let author-count = authors.len()
  let many-authors = author-count > 4

  init-acronyms(acronyms)

  // define logo size with given ration
  let left-logo-height = 2.4cm // left logo is always 2.4cm high
  let right-logo-height = 2.4cm // right logo defaults to 1.2cm but is adjusted below
  let logo-ratio = logo-size-ratio.split(":")
  if (logo-ratio.len() == 2) {
    right-logo-height = right-logo-height * (float(logo-ratio.at(1)) / float(logo-ratio.at(0)))
  }

  // save heading and body font families in variables
  let body-font = "Open Sans"
  let heading-font = "Montserrat"
  
  // customize look of figure
  set figure.caption(separator: [ --- ], position: bottom)

  // set body font family
  set text(font: body-font, lang: language, 12pt)
  show heading: set text(weight: "semibold", font: heading-font)

  //heading numbering
  set heading(numbering: "1.")
 
  // set link style
  show link: it => underline(text(it))
  
  show heading.where(level: 1): it => {
    pagebreak()
    v(2em) + it + v(1em)
  }
  show heading.where(level: 2): it => v(1em) + it + v(0.5em)
  show heading.where(level: 3): it => v(0.5em) + it + v(0.25em)

  titlepage(authors, title, language, date, at-dhbw, logo-left, logo-right, left-logo-height, right-logo-height, university, university-location, supervisor, heading-font, many-authors)

  set page(
    margin: (top: 8em, bottom: 8em),
    header: {
      if (show-header) {
        grid(
          columns: (1fr, auto),
          align: (left, right),
          gutter: 2em,
          emph(align(center + horizon,text(size: 10pt, title))),
          stack(dir: ltr,
            spacing: 1em,
            if logo-left != none {
              set image(height: left-logo-height / 2)
              logo-left
            },
            if logo-right != none {
              set image(height: right-logo-height / 2)
              logo-right
            }
          )
        )
        v(-0.75em)
        line(length: 100%)
      }
    }
  )

  // set page numbering to roman numbering
  set page(
    numbering: "I",
    number-align: numbering-alignment,
  )
  counter(page).update(1)

  if (not at-dhbw and show-confidentiality-statement) {
    confidentiality-statement(authors, title, university, university-location, date, language, many-authors)
  }

  if (show-declaration-of-authorship) {
    declaration-of-authorship(authors, title, date, language, many-authors)
  }

  show outline.entry.where(
    level: 1,
  ): it => {
    v(18pt, weak: true)
    strong(it)
  }

  context {
    let elems = query(figure.where(kind: image), here())
    let count = elems.len()
    
    if (show-list-of-figures and count > 0) {
      outline(
        title: [#heading(level: 3)[#if (language == "de") {
          [Abbildungsverzeichnis]
        } else {
          [List of Figures]
        }]],
        target: figure.where(kind: image),
      )
    }
  }

  context {
    let elems = query(figure.where(kind: table), here())
    let count = elems.len()

    if (show-list-of-tables and count > 0) {
      outline(
        title: [#heading(level: 3)[#if (language == "de") {
          [Tabellenverzeichnis]
        } else {
          [List of Tables]
        }]],
        target: figure.where(kind: table),
      )
    }
  }

  context {
    let elems = query(figure.where(kind: raw), here())
    let count = elems.len()

    if (show-code-snippets and count > 0) {
      outline(
        title: [#heading(level: 3)[#if (language == "de") {
          [Codeverzeichnis]
        } else {
          [Code Snippets]
        }]],
        target: figure.where(kind: raw),
      )
    }
  }
  
  if (show-table-of-contents) {
    outline(title: [#if (language == "de") {
      [Inhaltsverzeichnis]
    } else {
      [Table of Contents]
    }], indent: auto, depth: toc-depth)
  }
    
  if (show-acronyms and acronyms.len() > 0) {
    heading(level: 1, outlined: false, numbering: none)[#if (language == "de") {
      [Abkürzungsverzeichnis]
    } else {
      [List of Acronyms]
    }]

    state("acronyms", none).display(acronyms => {

      // Build acronym list
      let acr-list = acronyms.keys()

      // order list
      acr-list = acr-list.sorted()

      // print the acronyms
      for acr in acr-list{
        let acr-long = acronyms.at(acr)
        let acr-long = if type(acr-long) == array {
          acr-long.at(0)
        } else {
          acr-long
        }
        grid(
          columns: (0.8fr, 1.2fr),
          gutter: 1em,
          [*#acr*], [#acr-long\ ]
        )
      }
    })
  }

  set par(justify: true, leading: 1em)
  set block(spacing: 2em)

  if (show-abstract and abstract != none) {
    align(center + horizon, heading(level: 1, numbering: none)[Abstract])
    text(abstract)
  }
  
  
  // reset page numbering and set to arabic numbering
  set page(
    numbering: "1",
    footer: context align(numbering-alignment, numbering(
    "1 / 1", 
    ..counter(page).get(),
    ..counter(page).at(<end>),
    ))
  )
  counter(page).update(1)

  body

  [#metadata(none)<end>]
  // reset page numbering and set to alphabetic numbering
  set page(
    numbering: "a",
    footer: context align(numbering-alignment, numbering(
      "a", 
      ..counter(page).get(),
    ))
  )
  counter(page).update(1)

  // Display bibliography.
  if bibliography != none {
    set std-bibliography(title: [#if (language == "de") {
      [Literatur]
    } else {
      [References]
    }], style: "ieee")
    bibliography
  }

  if (show-appendix and appendix != none) {
    heading(level: 1, numbering: none)[#if (language == "de") {
      [Anhang]
    } else {
      [Appendix]
    }]
    appendix
  }
  
}