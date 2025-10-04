#let IMAGE_BOX_MAX_WIDTH = 120pt
#let IMAGE_BOX_MAX_HEIGHT = 50pt

#let project(title: "", subtitle: none, school-logo: none, company-logo: none, authors: (), mentors: (), jury: (), branch: none, academic-year: none, french: false, footer-text: "ENSIAS", body) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)
  set page(
    numbering: "1",
    number-align: center,
    footer: context {
      let current = counter(page).get().at(0)
      if current > 1 {
        block[
          #line(length: 100%, stroke: 0.5pt)
          #v(-2pt)
          #text(size: 12pt, weight: "regular")[
            #footer-text
            #h(1fr)
            #counter(page).display()
            #h(1fr)
            #academic-year
          ]
        ]
      } else {
        none
      }
    }
  )
  let dict = json("resources/i18n/en.json")
  let lang = "en"
  if french {
    dict = json("resources/i18n/fr.json")
    lang = "fr"
  }

//   set text(font: "Linux Libertine", lang: lang, size: 13pt)
  set text(font: "Libertinus Serif", lang: lang, size: 13pt)
  set heading(numbering: "1.1")
  
  show heading: it => {
    if it.level == 1 and it.numbering != none {
      pagebreak()
      v(40pt)
      text(size: 30pt)[#dict.chapter #counter(heading).display() #linebreak() #it.body ]
      v(60pt)
    } else {
      v(5pt)
      [#it]
      v(12pt)
    }
  }

  block[
    #box(height: IMAGE_BOX_MAX_HEIGHT, width: IMAGE_BOX_MAX_WIDTH)[
      #align(left + horizon)[
        #company-logo
      ]
    ]
    #h(1fr)
    #box(height: IMAGE_BOX_MAX_HEIGHT, width: IMAGE_BOX_MAX_WIDTH)[
      #align(right + horizon)[
        #if school-logo == none {
          image("images/ENSIAS.svg")
        } else {
          school-logo
        }
      ]
    ]
  ]
  
  // Title box  
  align(center + horizon)[
    #if subtitle != none {
      text(size: 14pt, tracking: 2pt)[
        #smallcaps[
          #subtitle
        ]
      ]
    }
    #line(length: 100%, stroke: 0.5pt)
    #text(size: 20pt, weight: "bold")[#title]
    #line(length: 100%, stroke: 0.5pt)
  ]

  // Credits
  box()
  h(1fr)
  grid(
    columns: (auto, 1fr, auto),
    [
      // Authors
      #if authors.len() > 0 {
        [
          #text(weight: "bold")[
            #if authors.len() > 1 {
              dict.author_plural
            } else {
              dict.author
            }
            #linebreak()
          ]
          #for author in authors {
            [#author #linebreak()]
          }
        ]
      }
    ],
    [
      // Mentor
      #if mentors != none and mentors.len() > 0 {
        align(right)[
          #text(weight: "bold")[
            #if mentors.len() > 1 {
              dict.mentor_plural
            } else {
              dict.mentor
            }
            #linebreak()
          ]
          #for mentor in mentors {
            mentor
            linebreak()
          }
        ]
      }
      // Jury
      #if jury != none and jury.len() > 0 {
        align(right)[
          *#dict.jury* #linebreak()
          #for prof in jury {
            [#prof #linebreak()]
          }
        ]
      }
    ]
  )

  align(center + bottom)[
    #if branch != none {
      branch
      linebreak()
    }
    #if academic-year != none {
      [#dict.academic_year: #academic-year]
    }
  ]
  
  pagebreak()

  // Table of contents.
//   outline(depth: 3, indent: true)
  outline(depth: 3, indent: 1em)

  pagebreak()

  // Table of figures.
  outline(
    title: dict.figures_table,
    target: figure.where(kind: image)
  )

  pagebreak()

  outline(
    title: dict.tables_table,
    target: figure.where(kind: table)
  )

  pagebreak()
  
  // Main body.
  body
}
