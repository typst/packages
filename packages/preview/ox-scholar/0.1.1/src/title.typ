#let title-page(
  title: none,
  author: none,
  college: none,
  degree: "Doctor of Philosophy",
  submission-term: none,
  logo: none,
) = {
  // Validate inputs
  assert(title != none, message: "Thesis title must be provided")
  assert(author != none, message: "Thesis author must be provided")

  let font-size = 15pt
  let title-size = 20pt
  let author-size = 17pt
  let line-spacing = 1em

  let title-block = block[
    #set par(justify: false, leading: 0.5em)
    #set text(size: title-size, weight: 700)
    #title
  ]

  let author-block = block[
    #text(author-size, author) \
    #text(college) \
    University of Oxford
  ]

  let degree-block = block[
    A thesis submitted for the degree of \
    #emph(degree)
    #v(0.4cm)
    #text(submission-term)
  ]

  // Title page style settings
  set page(
    margin: (
      left: 3.1cm,
      top: 2.7cm,
      right: 3.1cm,
      bottom: 2.1cm,
    ),
    numbering: none,
    header: none,
    footer: none,
  )
  set text(size: font-size)
  set par(leading: line-spacing)
  set align(center)

  // Content
  place(center + top, title-block, dy: 2.3cm)
  if logo != none {
    place(center + horizon, figure(logo), dy: -3.3cm)
  }
  place(center + horizon, author-block, dy: 3.2cm)
  place(center + bottom, degree-block, dy: -3cm)
}
