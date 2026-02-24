
// Main template function to be used by the document
#let examify(
  paper-size: "a4",
  fonts: "New Computer Modern",
  language: "EN",
  institute: none,
  author: none,
  contact-details: none,
  exam-name: none,
  subject-label: "Subject",
  subject: none,
  marks-label: "Full Marks",
  marks: none,
  class-label: "Class",
  class: none,
  time-label: "Time",
  time: none,
  content,
) = {
  // Document metadata
  set document(
    title: [#subject - #class],
    author: author,
    date: auto,
  )

  // Page setup
  set page(
    paper: paper-size,
    footer: context [
      #line(length: 100%)
      // Name, Contact Details & Page Number at footer
      #grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        if author != none {
          author
        },
        if contact-details != none {
          [#sym.diamond.filled #link(contact-details) #sym.diamond.filled]
        },
        counter(page).display(
          "(1/1)",
          both: true,
        ),
      )
    ],
  )

  // Numbered list style
  set enum(numbering: "1.i)")

  // Text settings
  set text(
    font: fonts,
    size: 12pt,
    lang: language,
  )

  // Paragraph settings
  set par(justify: true)

  // Institute name
  if institute != none {
    grid(
      columns: 1fr,
      align: (center),
      text(weight: "extrabold", size: 20pt, [#sym.angle.l.double #institute #sym.angle.r.double]),
    )
  }

  // Exam name
  if exam-name != none {
    grid(
      columns: 1fr,
      align: (center),
      text(weight: "bold", size: 15pt, exam-name),
    )
  }

  // Subject
  grid(
    columns: 1fr,
    align: (center),
    text(weight: "bold", [#subject-label: #subject]),
  )

  // Marks, Class & Time
  grid(
    columns: (1fr, 1fr, 1fr),
    align(left)[
      #text(weight: "bold", [#marks-label: #marks])
    ],
    align(center)[
      #text(weight: "bold", [#class-label: #class])
    ],
    align(right)[
      #text(weight: "bold", [#time-label: #time])
    ],
  )

  // Horizontal line
  line(length: 100%)

  // Main content
  set align(left)
  content
}
