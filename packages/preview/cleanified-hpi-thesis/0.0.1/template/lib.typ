#import "hpi-title-page.typ": *

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(
  // The title of the thesis
  title: "",

  // The translated title of the thesis
  translation: "",

  // The name of the student writing the thesis
  name: "",

  // Date of handing in the thesis
  date: none,

  // "Bachelor" or "Master"
  type: "",

  // Study Program of the student
  study-program: "",

  // Chair where the thesis is written
  chair: "",

  // First advising professor
  professor: "",

  // List of Advisors (e.g., ("Karla Musterfrau", "Max Mustermann"))
  advisors: (),

  // The abstract of the thesis
  abstract: "",

  // The German translation of the abstract
  // If not given, the page for German translation of abstract will not appear
  abstract-de: "",

  // The student may want to add acknowledgements
  // If not giving, the page for acknowledgements will not appear
  acknowledgements: "",

  // Determines if the document is intended for print or electronic use. 
  // If for_print: true is set, additional pages will be added.
  for-print: true,
  
  body,
) = {  
  // Set the document's basic properties.
  set document(author: name, title: title)
  set page(
    margin: (left: 35mm, right: 35mm, top: 30mm, bottom: 30mm),
    numbering: "1",
    number-align: end,
  )
  set text(font: "New Computer Modern", lang: "en")
  show math.equation: set text(weight: 400)

  hpi-title-page(
    professor: professor,
    name: name,
    advisors: advisors,
    title: title,
    translation: translation,
    study-program: study-program,
    chair: chair,
    type: type,
    date: date
  )
    
  // Configure chapter headings.
  show heading.where(level: 1): it => {
    // Always start on odd pages.
    
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }
    
    v(5%)
    text(size: 20pt, fill: blue, weight: "bold", block([#number #it.body]))
    line(length: 100%, stroke: 2pt + blue)
    v(1.25em)
  }
  show heading: set text(11pt, weight: 400)

  // Configure chapter headings.
  show heading.where(level: 2): it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }
    
    v(2%)
    text(size: 16pt, fill: rgb("#404040"), weight: "bold", block([#number #it.body]))
    v(0.5em)
  }

  // Configure chapter headings.
  show heading.where(level: 3): it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }
    
    v(2%)
    text(size: 14pt, fill: rgb("#404040"), weight: "bold", block([#number #it.body]))
  }

  
  // Configure chapter headings.
  show heading.where(level: 4): it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }
    
    v(2%)
    text(size: 12pt, fill: rgb("#404040"), weight: "bold", block([#number #it.body]))
  }
  
  set page(numbering: none)

  // Count the number of intro pages
  let intro-pages = 1
  
  pagebreak()
  intro-pages += 1
  
  set page(numbering: none)
  if for-print {
    pagebreak()
    intro-pages += 1
  }
  counter(page).update(1)
  set page(numbering: "i")

  heading(level: 1, numbering: none, "Abstract")
  v(0.5cm)
  text(abstract)

  pagebreak()
  intro-pages += 1
  set page(numbering: none)
  if for-print { 
    pagebreak()
    intro-pages += 1
  }
  set page(numbering: "i")

  if abstract-de != "" {
    set page(numbering: "i")
    heading(level: 1, numbering: none, "Zusammenfassung")
  v(0.5cm)
    text(abstract-de)
  
    pagebreak()
    intro-pages += 1
    set page(numbering: none)
    if for-print { 
      pagebreak()
      intro-pages += 1
    }
    set page(numbering: "i")
  }

  if acknowledgements != "" {
    set page(numbering: "i")
    heading(level: 1, numbering: none, "Acknowledgements")
    v(0.5cm)
    text(acknowledgements)
  
    pagebreak()
    intro-pages += 1
    set page(numbering: none)
    if for-print {
      pagebreak()
      intro-pages += 1
    }
    set page(numbering: "i")
  }
  
  // Table of contents.
  outline(title: [
    #text(size: 20pt, fill: blue, "Contents")
  ], depth: 4)
  
  pagebreak()
  intro-pages += 1
  set page(numbering: none)
  if for-print {
    pagebreak()
    intro-pages += 1
  }


  // Main body.
  set par(justify: true)
  
  // Creates a pagebreak to the given parity where empty pages
  // can be detected via `is-page-empty`.
  let detectable-pagebreak(to: "odd") = {
    [#metadata(none) <empty-page-start>]
    pagebreak(to: to)
    [#metadata(none) <empty-page-end>]
  }

  // Workaround for https://github.com/typst/typst/issues/2722
  let is-page-empty() = {
    let page-num = here().page()
    query(<empty-page-start>)
      .zip(query(<empty-page-end>))
      .any(((start, end)) => {
        (start.location().page() < page-num
          and page-num < end.location().page())
      })
  }
  
  // Configure page properties.
  set page(
    header: context {
      if is-page-empty() {
        return
      }

      // Are we on a page that starts a chapter?
      let i = here().page() - intro-pages + 1
      if query(heading).any(it => it.location().page() == i) {
        return
      }

      // Find the heading of the section we are currently in.
      let before = query(selector(heading).before(here()))
      if before != () {
        set text(0.95em)
        let header = before.last().body
        let author = text(style: "italic", name)
        grid(
          columns: (1fr, 10fr, 1fr),
          align: (left, center, right),
          if calc.even(i) [#i],
          // Swap `author` and `title` around, or possibly with `heading`
          // to change what is displayed on each side.
          if calc.even(i) { author } else { title },
          if calc.odd(i) [#i],
        )
      }
      align(center, line(length: 100%, stroke: 0.5pt))
    }
  )
  set heading(numbering: "1.1.1.1.1 --")
  
  counter(page).update(1)
  body

  pagebreak()
  heading(level: 1, numbering: none, "Declaration of Authorship")

  v(0.5cm)
  block[
    I hereby declare that this thesis is my own unaided work. All direct or indirect sources used are acknowledged as references.
  ]

  v(1.5cm)
  block[
    Potsdam, #date
    #block[
      #line(start: (5cm, -0.3cm), length: 50%, stroke: 0.5pt)
      #v(-0.6cm)
      #h(5cm)
      #text(name)
    ]
  ] 
}
