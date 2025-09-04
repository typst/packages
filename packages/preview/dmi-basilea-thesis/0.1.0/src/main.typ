#import "lib.typ": *

/*
Re-export functionality to be accessible via the public API
*/
#let todo = todo
#let todo-missing = todo-missing
#let todo-check = todo-check
#let todo-revise = todo-revise
#let todo-citation = todo-citation
#let todo-language = todo-language
#let todo-question = todo-question
#let todo-note = todo-note

#let unnumbered-chapter = unnumbered-chapter
#let algorithm = algorithm
#let important = important
#let definition = definition
#let theorem = theorem

#let ie = ie
#let eg = eg
#let cf = cf
#let etal = etal


/*
This is the main function to setup a thesis
*/
#let thesis(
  // Metadata
  title: "Thesis Title",
  author: "Author Name",
  email: "",
  immatriculation: "",
  supervisor: "",
  examiner: "",
  department: "Department of Mathematics and Computer Science",
  faculty: "Faculty of Science, University of Basel",
  research-group: "",
  website: "",
  thesis-type: "Bachelor Thesis",
  date: datetime.today(),
  language: "en",

  // Pass your own fonts
  body-font: default-fonts.body,
  sans-font: default-fonts.sans,
  mono-font: default-fonts.mono,

  logo: auto, // options: auto | none | path | image-element
  logo-width: 4.5cm,

  // compile mode
  draft: true,        // displays todos
  colored: false,      // Use colors for definitions, theorems, etc.

  // Content
  abstract: [],
  acknowledgments: none,
  chapters: (),
  appendices: (),
  bibliography-content: none,
  body,
) = {

  // Set the configuration states (add this at the beginning)
  thesis-draft-state.update(draft)
  thesis-color-state.update(colored)
  set document(title: title, author: author)

  // Page setup - matches LaTeX template exactly
  set page(
     paper: "a4",
     margin: 3.5cm,
     header: context {
       if counter(page).get().first() > 1 {
         // Check if we're on a chapter page (level 1 heading)
         let on-chapter-page = query(heading.where(level: 1)).any(h =>
           h.location().page() == here().page()
         )

         // Only show header if not on a chapter page
         if not on-chapter-page {
           set text(size: 9pt, font: body-font, fill: gray)

           // Get current chapter name
           let headings = query(heading.where(level: 1).before(here()))
           let chapter-name = if headings.len() > 0 {
             headings.last().body
           } else {
             []
           }

           grid(
             columns: (1fr, auto),
             align: (left, right),
             chapter-name,
             counter(page).display()
           )

           v(-0.65em)
           line(length: 100%, stroke: 0.2pt + gray)
         }
       }
     },
     footer: []  // Empty footer as in LaTeX
   )

  // Typography - matching LaTeX \setlength and font definitions
  set text(
    font: body-font,  // Main text font
    size: 10pt,
    lang: language
  )

  show raw: set text(
    font: mono-font,
    size: 10pt,
    lang: language
  )

  // Paragraph settings - matching LaTeX
  set par(
    justify: true,
    leading: 0.65em * 1.5,  // 1.5 line spacing
    first-line-indent: 0pt,  // No indent as in LaTeX
  )

  // Footnote settings
  set footnote.entry(
    separator: line(length: 30%, stroke: 0.5pt),
    gap: 0.65em,
  )

  // Heading numbering
  set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    if level == 1 {
      // Chapter: no dot
      numbering("1", ..nums)
    } else {
      // Sections and subsections: with dots
      numbering("1.", ..nums)
    }
  })

  // Equation numbering
  set math.equation(numbering: "1.")

  // Chapter style - large gray number as in LaTeX
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(50pt)

    align(right)[
      #grid(
        columns: 1,
        rows: (auto, auto),
        row-gutter: 20pt,  // midchapskip
        align: right,  // Ensure grid content is right-aligned

        // Chapter number
        if it.numbering != none [
          #text(
            size: 100pt,
            font: sans-font,
            weight: "bold",
            fill: rgb(179, 179, 179),  // 0.7 gray
            counter(heading).display()
          )
        ],

        // Chapter title
        text(
          size: 24pt,
          font: sans-font,
          weight: "bold",
          it.body
        )
      )
    ]

    v(30pt)  // Space after chapter title
  }

  // Section styles with widow/orphan control
  show heading.where(level: 2): it => {
    v(25pt, weak: true)  // beforesubsecskip
    block(breakable: false, below: 2em)[
      #text(size: 14pt, font: sans-font, weight: "bold")[
        #counter(heading).display() #it.body
      ]
      #v(1pt, weak: true)  // aftersubsecskip
    ]
  }

  show heading.where(level: 3): it => {
    v(20pt, weak: true)
    block(breakable: false, below: 2em)[
      #text(size: 11pt, font: sans-font, weight: "bold")[
        #counter(heading).display() #it.body
      ]
      #v(1pt, weak: true)  // Add spacing after level 3 headings
    ]
  }

  show heading.where(level: 4): it => {
    v(15pt, weak: true)
    block(breakable: false, below: 2em)[
      #text(size: 11pt, font: sans-font, weight: "bold")[
        #counter(heading).display() #it.body
      ]
      #v(1pt, weak: true)  // Add spacing after level 4 headings too
    ]
  }

  // Title page - matching LaTeX layout
  align(center)[
    // Automatically select logo based on language
    #if logo != none [
      #let logo-to-use = if logo == auto {
        // Auto-select based on language
        if language == "en" {
          image("assets/logo-en.svg", width: logo-width)
        } else {
          image("assets/logo-de.svg", width: logo-width)
        }
      } else {
        // User provided logo
        if type(logo) == "string" {
          image(logo, width: logo-width)
        } else {
          // Assume it's already an image element
          logo
        }
      }
      #place(top + left, logo-to-use)
    ]

    #if draft [
      #place(top + right,
        rect(
          fill: red.lighten(90%),
          stroke: red,
          inset: 10pt,
        )[
          #text(size: 11pt, fill: red, weight: "bold")[DRAFT VERSION] \
          #text(size: 9pt, fill: red)[
            #datetime.today().display("[day].[month].[year]")
          ]
        ]
      )
    ]

    #v(4cm)

    #text(size: 24pt, font: sans-font, weight: "bold")[#title]

    #v(0.5cm)
    #text(size: 11pt)[#thesis-type]

    #v(3cm)

    #text(size: 11pt)[
      #faculty \
      #department \
      #if research-group != "" [
        #research-group \
      ]
      #if website != "" [
        #website \
      ]
    ]

    #v(1.5cm)

    #text(size: 11pt)[
      #if language == "en" [Examiner] else [Beurteiler]: #examiner \
      #if language == "en" [Supervisor] else [Zweitbeurteiler]: #supervisor
    ]

    #v(1.5cm)

    #text(size: 11pt)[
      #author \
      #email \
      #if immatriculation != "" [
        #immatriculation
      ]
    ]

    #v(1fr)

    #text(size: 11pt)[
      #date.display(
        if language == "en" { "[month repr:long] [day], [year]" }
        else { "[day]. [month repr:long] [year]" }
      )
    ]
  ]

  // Abstract
  if abstract != [] {
    pagebreak()
    unnumbered-chapter[
      #if language == "en" [Abstract] else [Zusammenfassung]
    ]
    abstract
  }

  // Acknowledgments
  if acknowledgments != none {
    pagebreak()
    unnumbered-chapter[
      #if language == "en" [Acknowledgments] else [Danksagung]
    ]
    acknowledgments
  }

  // Table of contents
  pagebreak()
  unnumbered-chapter[
    #if language == "en" [Table of Contents] else [Inhaltsverzeichnis]
  ]

  outline(depth: 3, indent: auto, title: none)

  // Main content chapters
  pagebreak()
  for chapter-content in chapters {
    chapter-content
  }

  // Additional body content
  body

  // Bibliography
  if bibliography-content != none {
    pagebreak()
    unnumbered-chapter[
      #if language == "en" [Bibliography] else [Literaturverzeichnis]
    ]
    bibliography-content
  }

  // Appendices
  if appendices.len() > 0 {
    pagebreak()
    set heading(numbering: (..nums) => {
      let level = nums.pos().len()
      if level == 1 {
        // Appendix chapters: no dot
        numbering("A", ..nums)
      } else {
        // Appendix sections and subsections: with dots
        numbering("A.1", ..nums)
      }
    })
    counter(heading).update(0)

    for appendix-content in appendices {
      appendix-content
    }
  }
}
