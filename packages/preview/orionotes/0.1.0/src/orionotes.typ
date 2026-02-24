// LTeX: language=en
#import "utils.typ": *

#let orionotes(
  // The language of the work.
  // NOTE: If you change this consider changing also the following
  // parameters and set them into the language of your choice:
  //  - pre-authors
  //  - pre-professors
  //  - top-sec-name
  language: "en",
  // The title of the work.
  title: [Course title],
  // The authors of the work. This should be an array (also if there is just one).
  authors: ("Student 1",),
  // The professors of the course. This should be an array (also if there is just one).
  // Set to none if you don't want to show it.
  professors: ("Professor 1",),
  // The university where the course took place. Set to none to disable.
  university: [University of Turin UniTo],
  // The degree of the course. Set to none to disable.
  degree: [Master degree in Astrophysics],
  // The date of the work. Set to none to disable.
  date: "Academic Year",
  // What to write before the authors (the semicolon is not needed).
  pre-authors: (sing:"Author", plur:"Authors"),
  // What to write before the professors (the semicolon is not needed).
  pre-professors: (sing:"Professor", plur:"Professors"),
  // The typographic name of the level 1 section.
  // TODO: Check the language dependency.
  top-section-name: "Chapter",
  // The image to insert in the first page. Set to none to disable.
  // This should be an image object.
  front-image: none,
  // The preface of the notes. Set to none to disable.
  preface: none,
  // The table of contents function. Set to none to disable.
  table-of-contents: outline(),
  // The appendix
  appendix: (
    enabled: false,
    title: "",
    body: none,
  ),
  // The bibliography.
  // Should be a call to `bibliography` (e.g. `bibliography("refs.bib")`) or `none`
  bib: none,
  // The content of the work
  body
) = {
  set document(title: title, author: authors)
  set text(font: "New Computer Modern", size: 11pt, lang: language)
  set page(paper: "a4", margin: auto)

  // Front page
  page(
    align(
      center + horizon,
      block(width: 90%)[
        #let v-space = v(2em, weak: true)
        #text(3em)[*#title*]

        #v-space
        #align(left)[
          #text(1.6em)[#get-auth-str(authors, pre-authors)]\
          #text(1.6em)[#get-prof-str(professors, pre-professors)]
        ]

        #if front-image!=none {
          v-space
          front-image
        } else {
          line(length: 100%)
        }

        #if university!="" or degree!= "" {
          v-space
          text(1.3em)[#university\ #degree]
        }

        #if date != none {
          v-space
          text(1.2em, date)
        }
      ],
    ),
  )

  // Paragraph settings
  set par(justify: true)
  show link: it => {
    if type(it.dest) != str {it}
    else {
      set text(blue)
      underline(it)
    }
  }

  // Preface page settings
  set page(numbering: "i")

  show heading: set text(hyphenate: false) // Don't hyphenate headings

  // Preface
  if preface != none {
    page[
      #set text(style: "italic")
      #preface
    ]
  }

  // Table of contents
  if table-of-contents != none {
    table-of-contents
  }

  // Normal page settings
  set page(
    header: context {
      let phys-page = here().page()
      let is-odd = calc.odd(phys-page)
      let alignment = if is-odd {right} else {left}

      // NOTE: If there are also parts level should be 2
      let chap-heading = heading.where(level: 1)

      // Using only the page where there are chapter headins
      if query(chap-heading).any(it => it.location().page() == phys-page) { return }

      // Find the chapter of the section we are currently in.
      let chap-before = query(chap-heading.before(here()))
      if chap-before.len() > 0 {
        let current-chap = chap-before.last()
        let chapter-title = upper(current-chap.body)
        let chapter-number = counter(chap-heading).display()
        let chapter-string = [#chapter-number #chapter-title]
        if chapter-number != none {
          align(alignment, text(size: 0.68em, chapter-string))
        }
      }
    },
    numbering: "1",
  )
  // Reset page numbering
  counter(page).update(1)

  // Per chapter equations
  set math.equation(numbering: it => {
    let chapter-count = counter(heading).get().first()
    numbering("(1.1)", chapter-count, it)
  })

  // Break large tables across pages.
  show figure.where(kind: table): set block(breakable: true)
  set table(
    // Increase the table cell's padding
    inset: 7pt, // default is 5pt
    stroke: (0.5pt + luma(200)),
  )
  show table.cell.where(y: 0): smallcaps // Use smallcaps for table header row.

  // Body. Wrapped so set rules apply only to it
  {
    set heading(numbering: "1.")
    // TODO: Finish
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      counter(math.equation).update(0)
      let header = smallcaps[#top-section-name #counter(heading).display("1")]
      [
        #text(1em, header)
        #v(1em, weak: true)
        #text(1.4em)[#it.body]
        #v(1.5em, weak: true)
      ]
    }
    body
  }

  // Appendix
  if appendix.enabled {
    pagebreak()
    heading(level: 1)[
      #smallcaps[#appendix.at("title", default: "Appendix")]
    ]

    // For heading prefixes in the appendix, the standard convention is A.1.1.
    let num-fmt = "A.1.1."

    counter(heading).update(0)
    set heading(
      outlined: false,
      numbering: (..nums) => {
        let vals = nums.pos()
        if vals.len() > 0 {
          let v = vals.slice(0)
          return numbering(num-fmt, ..v)
        }
      },
    )
    appendix.body
  }

  // Bibliography.
  if bib != none {
    pagebreak()
    show bibliography: set text(0.85em)
    // Use default paragraph properties for bibliography.
    show bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto)
    bib
  }

}
