#import "@preview/showybox:2.0.2": showybox

#let problem_counter = counter("problem")

#let prob(title: "", color: green, ..body) = {
  [== Problem #problem_counter.step() #context {problem_counter.display()}]
  showybox(
    frame: (
      border-color: color.darken(10%),
      title-color: color.lighten(85%),
      body-color: color.lighten(90%)
    ),
    title-style: (
      color: black,
      weight: "bold",
    ),
    title: title,
    ..body
  )
}

#let homework(
  title: "Homework Assignment",
  author: "John Doe",
  collaborators: [],
  course-id: "ILY143",
  instructor: "Prof. Smith",
  semester: "Summer 1970",
  due-time: "Feb 29, 23:59",
  accent-color: rgb("#000000"),
  body,
) = {
  // Document Metadata
  set document(title: title, author: author)

  set page(paper: "us-letter")

  // Cover Page (centered vert + horiz)
  align(center + horizon)[
    #strong(text(size: 24pt, fill: accent-color)[#title])

    #text(size: 18pt)[#course-id]

    #text(size: 18pt)[#due-time]

    #emph(text(size: 18pt)[#instructor])

    #v(24em)

    #strong(text(size: 18pt)[#author])
  ]

  // Page Layout (incl. Header, Footer)
  set page(
    header: [
      #author #h(1fr) #title
    ],
    footer: [
      #align(center)[Page #context counter(page).display() of #context counter(page).final().first()]
    ],
  )

  pagebreak()

  // Header and Footer Info
  // Main content
  body
}

