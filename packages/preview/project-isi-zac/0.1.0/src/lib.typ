#import "title-page.typ": title-page
#import "@preview/hydra:0.6.1": hydra, anchor
// #import "@preview/i-figured:0.2.4" // List of figures and better figures

#let config(
  display : (),
  title: [],
  authors: (),
  uni-info : (
    department: none,
    university: none,
    faculty: none,
    academic_year: none,
  ),
  date: none,
  img: none,
  body
) = {

  // Set initial page setitngs
  set page(
    paper: "a4", 
  )
  
  // font settings 
  set text(lang: "eng",
  size: 12pt,
  font: "New Computer Modern"
  )

  // Set distance below headings
  // show heading.where(level: 1): it => pagebreak(weak: true) + it
  show heading: set block(spacing: 1.5em)
  show par: set par(spacing: 1.25em)
  set par(leading: 0.85em)
  set par(justify: true)
  
  // Set type of heading
  set heading(numbering: "1.1")

  // --------------------- START title-page --------------------- 

  if display.contains("title-page") [
    #title-page(title, authors, uni-info, date, img)
  ]
  
  set page(margin: (left: 30mm, right: 30mm, top: 45mm, bottom: 45mm))
  
  // --------------------- TABLE OF CONTENT --------------------- 

  /*
  if display.contains("toc"){
    import "@preview/outrageous:0.4.0"
    
    set outline(indent: auto)
    {
      show outline.entry: outrageous.show-entry.with(
        font: (auto,),
    )
  
      outline(title: "Table Of Content")
    }
    // set heading(outlined: true, numbering: "1.1")
  }
  */

  show outline.entry.where(
    level: 1
  ):set block(above: 1.25em)
  show outline.entry.where(
    level: 2
  ):set block(above: 1em)

  outline(depth: 3, title: heading("Table Of Content", level: 2, outlined: false))
  
  // --------------------- DOCUMENT BODY --------------------- 
  
  // Including code
  import "structure.typ"
  let chapter = "Chapter"
  let section = "Section"

  set page(
      header-ascent: 15%,
      header: context {
      if structure.is-chapter-page() {
        // no header
      } else if structure.is-empty-page() {
        // no header
      } else {
        hydra(
          1,
          prev-filter: (ctx, candidates) => candidates.primary.prev.outlined == true,
          display: (ctx, candidate) => {
            grid(
              columns: (auto, 1fr),
              column-gutter: 3em,
              align: (left+top, right+top),
              title,
              {
                set par(justify: false)
                if candidate.has("numbering") and candidate.numbering != none {
                  chapter
                  [ ]
                  numbering(candidate.numbering, ..counter(heading).at(candidate.location()))
                  [. ]
                }
                candidate.body
              }
            )
            line(length: 100%, stroke: 0.5pt)
          },
        )
        anchor()
      }
    },
  )

  show: structure.mark-empty-pages()
  show: structure.chapters-and-sections(
    chapter: chapter,
    section: section,
  )
  
  set page(
    numbering: "1",
    number-align: center,
)

  // Main body.
  body
}
