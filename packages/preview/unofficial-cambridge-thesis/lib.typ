#let cam-dark-blue = rgb(19, 56, 68)
#let cam-blue = rgb(142, 232, 216)
#let cam-light-blue = rgb(209, 249, 241)
#let cam-warm-blue = rgb(0, 189, 182)
#let cam-slate-1 = rgb(236, 238, 241)
#let cam-slate-2 = rgb(181, 189, 200)
#let cam-slate-3 = rgb(84, 96, 114)
#let cam-slate-4 = rgb(35, 40, 48)

#let _author-state = state("author", "")
#let _date-state = state("date", "")

#let title_page(
  title: "",
  subtitle: none,
  author: "",
  crest: none,
  college_crest: none,
  department: "",
  university: "University of Cambridge",
  college: "",
  submission_text: "This dissertation is submitted for the degree of",
  degree_title: "Doctor of Philosophy",
  date: datetime.today().display("[month repr:long] [year]"),
) = {
  _author-state.update(author)
  _date-state.update(date)

  // Set page properties for the title page
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm),
    numbering: none,
  )
  set text(fill: cam-slate-4)

  set align(center)

  // 1. University Crest (if college crest exists, university crest goes at the top)
  if college_crest != none and crest != none {
    box(width: 10cm, crest)
    v(2fr)
  }

  // 2. Title and Subtitle
  block(spacing: 2em, {
    text(font: "Feijoa Bold-Cambridge", weight: "bold", fill: cam-dark-blue, size: 2.5em, title)
    if subtitle != none {
      parbreak()
      text(font: "Feijoa Medium-Cambridge", weight: "medium", size: 1.5em, subtitle)
    }
  })

  v(3fr)

  // 3. Crest Logic (if no college crest, university crest goes here)
  if college_crest != none {
    box(width: 5cm, college_crest)
  } else if crest != none {
    box(width: 5cm, crest)
  }

  v(3fr)

  text(font: "Feijoa Bold-Cambridge", size: 1.5em, fill: cam-dark-blue, author)
  v(1em)

  // 6. Department and University
  text(font: "Open Sans", size: 1.2em, department)
  parbreak()
  text(font: "Open Sans", size: 1.2em, university)

  v(2fr)

  // 7. Submission Text
  block(width: 80%, {
    text(font: "Open Sans", submission_text)
    parbreak()
    text(font: "Open Sans", weight: "bold", fill: cam-dark-blue, degree_title)
  })

  v(1fr)

  grid(
    columns: (1fr, 1fr),
    align: (left + bottom, right + bottom),
    text(font: "Open Sans", college), text(font: "Open Sans", date),
  )
  pagebreak(weak: true)
}

#let _common-section(body) = {
  set text(font: "Open Sans", size: 1em, fill: cam-slate-4)
  set par(justify: true)
  show heading: set text(font: "Feijoa Bold-Cambridge", fill: cam-dark-blue)


  show heading.where(level: 1): set text(size: 2em)
  show heading.where(level: 2): set text(size: 1.5em)
  show heading.where(level: 3): set text(size: 1.5em)

  show heading.where(level: 2): it => {
    v(0.5em)
    it
    v(0.2em)
  }

  body
}


#let preamble-section(body) = {
  show: _common-section
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm),
    numbering: none,
  )
  set heading(outlined: false)
  show heading.where(level: 1): it => {
    align(center, it)
    v(1em)
  }
  body
  pagebreak()
}


#let main-section(body) = {
  show: _common-section

  set heading(numbering: "1.1.1")

  show heading.where(level: 1): it => {
    // Start chapters on a new page
    pagebreak(weak: true)

    v(3em)
    block(spacing: 2em, {
      // Undo the default header scaling
      set text(size: 0.5em)
      text(font: "Feijoa Medium-Cambridge", size: 1.3em, fill: cam-slate-4, "Chapter " + counter(heading).display())
      linebreak()
      linebreak()
      text(font: "Feijoa Bold-Cambridge", size: 2em, fill: cam-dark-blue, it.body)
    })
  }

  set page(
    paper: "a4",
    margin: (left: 3cm, right: 3cm, top: 3cm + 2em, bottom: 3cm),
    numbering: none,
    header-ascent: 2em,
    header: context {
      // Look for a heading on the current page
      // If a heading exists on this page, return nothing (skip header)
      let headings = query(heading.where(level: 1)).filter(h => h.location().page() == here().page())
      if headings.len() > 0 {
        return none
      }

      // Otherwise, find the "active" heading to display
      let before = query(heading.where(level: 1).before(here()))
      let current_title = if before.len() > 0 { before.last().body } else { "" }

      grid(
        columns: (1fr, 1fr),
        align(left)[#text(weight: "bold", fill: cam-dark-blue, font: "Open Sans", counter(page).display())],
        align(right)[#text(font: "Feijoa Bold-Cambridge", fill: cam-dark-blue, [#current_title])],
      )
      v(-8pt)
      line(length: 100%, stroke: 1pt + cam-dark-blue)
    },
  )
  set math.equation(numbering: n => {
    let chapter = counter(heading).at(here()).at(0)
    numbering("(1.1)", chapter, n)
  })
  show math.equation: set text(font: "Fira Math", fill: cam-dark-blue)

  body
}


#let declaration() = {
  show: preamble-section

  [
    = Declaration
    This thesis is the result of my own work and includes nothing which is the outcome of work done in collaboration except as declared in the preface and specified in the text. It is not substantially the same as any work that has already been submitted, or is being concurrently submitted, for any degree, diploma or other qualification at the University of Cambridge or any other University or similar institution except as declared in the preface and specified in the text. It does not exceed the prescribed word limit for the relevant Degree Committee.
    #align(right, [
      #text(font: "Feijoa Bold-Cambridge", fill: cam-dark-blue, context _author-state.get())
      \
      #context _date-state.get()
    ])
  ]
}

#let acknowledgements(body) = {
  show: preamble-section

  [
    = Acknowledgements
    #body
  ]
}

#let abstract(body) = {
  show: preamble-section

  [
    = Abstract
    #body
  ]
}

#let table-of-contents() = {
  show: preamble-section
  show outline.entry.where(level: 1): it => {
    v(1.5em, weak: true)
    show: strong
    set text(fill: cam-dark-blue)
    it
  }
  [
    = Table of Contents
    #outline(
      title: none,
      indent: auto,
      depth: 3,
    )
  ]
}
