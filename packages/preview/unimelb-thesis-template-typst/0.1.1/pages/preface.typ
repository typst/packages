#import "../utils/style.typ": *

// =================================
// Preface Page
// =================================

#let preface-page(content) = {
  // Page setup
  set page(
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
    numbering: "i"
  )

  // Heading
  align(center)[
    #text(size: 16pt, weight: "bold")[Preface]
  ]

  v(2em)

  // Content
  set par(justify: true, first-line-indent: 1em)
  set text(size: 11pt, font: "Source Sans Pro")

  content

  pagebreak()
}
