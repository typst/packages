#import "@preview/codelst:2.0.1": sourcecode
#import "titlepage.typ": *
#import "confidentiality-statement.typ": *
#import "declaration-of-authorship.typ": *
#import "acronyms-list.typ": *
#import "template/appendix.typ": *

// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

#let supercharged-dhbw(
  title: "",
  authors: (:),
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
  abstract: "",
  course-of-studies: "",
  university: "",
  university-location: "",
  supervisor: "",
  date: datetime.today(),
  bibliography: none,
  logo-left: none,
  logo-right: none,
  body,
) = {
  // set the document's basic properties
  set document(title: title, author: authors.map(author => author.name))

  // save heading and body font families in variables
  let body-font = "Open Sans"
  let heading-font = "Montserrat"
  
  // customize look of figure
  set figure.caption(separator: [ --- ], position: bottom)

  // set body font family
  set text(font: body-font, lang: "en", 12pt)
  show heading: set text(font: heading-font)

  //heading numbering
  set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    // only level 1 and 2 are numbered
    let pattern = if level == 1 {
      "1."
    } else if level == 2 {
      "1.1."
    } else if level == 3 {
      "1.1.1."
    }
    if pattern != none {
      numbering(pattern, ..nums)
    }
  })
 
  // set link style
  show link: it => underline(text(it))
  
  show heading.where(level: 1): it => {
    pagebreak()
    v(2em) + it + v(1em)
  }
  show heading.where(level: 2): it => v(1em) + it + v(0.5em)
  show heading.where(level: 3): it => v(0.5em) + it + v(0.25em)

  titlepage(authors, title, date, at-dhbw, logo-left, logo-right, course-of-studies, university, university-location, supervisor, heading-font)

  set page(
    margin: (top: 8em, bottom: 8em),
    header: {
      stack(dir: ltr,
        spacing: 1fr,
        box(width: 180pt,
        emph(align(center,text(size: 9pt, title))),
        ),
        stack(dir: ltr,
          spacing: 1em,
          if logo-left != none {
            set image(height: 1.2cm)
            logo-left
          },
          if logo-right != none {
            set image(height: 0.8cm)
            logo-right
          }
        )
      )
      line(length: 100%)
    }
  )

  // set page numbering to roman numbering
  set page(
    numbering: "I", 
    number-align: center, 
  )
  counter(page).update(1)

  if (not at-dhbw and show-confidentiality-statement) {
    confidentiality-statement(authors, title, university, university-location, date)
  }

  if (show-declaration-of-authorship) {
    declaration-of-authorship(authors, title, date)
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
        title: [#heading(level: 3)[List of Figures]],
        target: figure.where(kind: image),
      )
    }
  }

  context {
    let elems = query(figure.where(kind: table), here())
    let count = elems.len()

    if (show-list-of-tables) {
      outline(
        title: [#heading(level: 3)[List of Tables]],
        target: figure.where(kind: table),
      )
    }
  }

  context {
    let elems = query(figure.where(kind: raw), here())
    let count = elems.len()

    if (show-code-snippets) {
      outline(
        title: [#heading(level: 3)[Code Snippets]],
        target: figure.where(kind: raw),
      )
    }
  }
  
  if (show-table-of-contents) {
    outline(title: "Table of contents", indent: auto, depth: 3)
  }
    
  if (show-acronyms) {
    acronyms-list()
  }

  set par(justify: true)

  context {
    let has-content = abstract.len() > 0
    
    if (show-abstract and has-content) {
      align(center + horizon, heading(level: 1, numbering: none)[Abstract])
      text(abstract)
    }
  }
  
  
  // reset page numbering and set to arabic numbering
  set page(
    numbering: " 1 of 1", 
    number-align: center, 
  )
  counter(page).update(1)

  body

  // Display bibliography.
  if bibliography != none {
    set std-bibliography(title: [References], style: "ieee")
    bibliography
  }

  if (show-appendix) {
    heading(level: 1, numbering: none)[Appendix]
    appendix
  }
  
}