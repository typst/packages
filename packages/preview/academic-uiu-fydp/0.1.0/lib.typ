// SPDX-License-Identifier: CC-BY-4.0
// Typst adaptation: Shaad Ahmmed. Original LaTeX: Swakkhar Shatabda.
// Source, license, and changes: see NOTICE and LICENSE.

// A separate helper lets student chapters use the same guidance styling.
#let guidance(body) = block(inset: (left: 8pt), stroke: (left: 1pt + luma(65%)))[
  #text(size: 9pt, style: "italic", fill: luma(35%), body)
]

#let preliminary(title, body) = {
  align(center, heading(level: 1, numbering: none, outlined: false, bookmarked: true, title))
  line(length: 100%, stroke: 0.5pt)
  v(1em)
  body
  pagebreak()
}

#let running-header() = context {
  let chapters = query(heading.where(level: 1))
  let previous = chapters.filter(h => h.location().position().page <= here().position().page)
  if previous.len() > 0 {
    let chapter = previous.last()
    // Chapter opening pages have the same quiet appearance as LaTeX report.
    if chapter.location().position().page < here().position().page {
      text(size: 9pt)[
        #chapter.body
      ]
      v(3pt)
      line(length: 100%, stroke: 0.4pt)
    }
  }
}

#let fydp-report(
  title: [Title of Your Final Year Design Project],
  students: ((name: "Student Name", id: "011 XXX XXX"),),
  date: [Month Year],
  university: [United International University],
  department: [Department of Computer Science and Engineering],
  degree: [Bachelor of Science in Computer Science and Engineering],
  supervisors: (),
  logo: none,
  abstract: none,
  acknowledgements: none,
  publications: none,
  show-figure-list: true,
  show-table-list: true,
  outline-depth: 3,
  font: "New Computer Modern",
  font-size: 11pt,
  margin: 3cm,
  body,
) = {
  assert(students.len() > 0, message: "Provide at least one student.")
  set document(title: title, author: students.map(s => s.name))
  set text(font: font, size: font-size, lang: "en")
  // Typst leading is the gap between lines; this approximates LaTeX onehalfspacing.
  set par(justify: true, leading: 0.8em, spacing: 0.85em)
  set page(paper: "a4", margin: margin, numbering: none, header: none, footer: none)
  set heading(numbering: "1.1", supplement: [Chapter])
  show heading: set text(fill: black)
  show heading.where(level: 1): set text(size: 24pt)
  show heading.where(level: 2): set text(size: 15pt)
  show heading.where(level: 3): set text(size: 12pt)
  set figure(supplement: auto)
  set math.equation(numbering: "(1)")
  show figure.where(kind: table): set figure.caption(position: top)
  set table(inset: 6pt, stroke: 0.5pt + luma(50%))
  set outline(indent: auto)

  // Title page; explicit date keeps rebuilds stable.
  align(center)[
    #set par(justify: false)
    #v(8mm)
    #line(length: 100%, stroke: 0.7pt)
    #v(4mm)
    #text(size: 25pt, weight: "bold", title)
    #v(4mm)
    #line(length: 100%, stroke: 0.7pt)
    #v(1fr)
    By
    #v(4mm)
    #for student in students {
      block(spacing: 4pt)[#text(size: 13pt, weight: "bold", student.name) #linebreak() ID: #student.id]
      v(2mm)
    }
    #if supervisors.len() > 0 {
      v(6mm)
      [Supervised by #linebreak()]
      v(2mm)
      supervisors.join(linebreak())
    }
    #v(1fr)
    Submitted in partial fulfilment of the requirements #linebreak()
    of the degree of #degree
    #v(1fr)
    #date
    #v(1fr)
    #if logo != none { logo; v(5mm) }
    #smallcaps(department) #linebreak()
    #smallcaps(university)
  ]
  pagebreak()

  set page(numbering: "i", number-align: center, footer: auto)
  counter(page).update(1)
  if abstract != none { preliminary([Abstract], abstract) }
  if acknowledgements != none { preliminary([Acknowledgements], acknowledgements) }
  if publications != none { preliminary([Publication List], publications) }
  outline(title: [Table of Contents], depth: outline-depth)
  pagebreak()
  if show-figure-list {
    heading(level: 1, numbering: none)[List of Figures]
    outline(title: none, target: figure.where(kind: image))
    pagebreak()
  }
  if show-table-list {
    heading(level: 1, numbering: none)[List of Tables]
    outline(title: none, target: figure.where(kind: table))
    pagebreak()
  }

  set page(numbering: "1", header: running-header())
  counter(page).update(1)
  // No blank page before the first chapter; all later chapters start afresh.
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    if it.numbering != none {
      block(above: 16pt, below: 20pt)[
        #text(size: 17pt, weight: "bold")[Chapter #context counter(heading).display("1")]
        #v(10pt)
        #text(size: 24pt, weight: "bold", it.body)
      ]
    } else {
      block(above: 16pt, below: 20pt, it)
    }
  }
  body
}
