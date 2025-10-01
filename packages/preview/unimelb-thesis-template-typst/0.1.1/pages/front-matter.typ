#import "../utils/style.typ": *

#let toc-page() = {
  set page(
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
    numbering: "i"
  )

  align(center)[
    #text(size: 16pt, weight: "bold")[Table of Contents]
  ]

  v(2em)

  set text(size: 11pt, font: "Source Sans Pro")
  outline(depth: 3, indent: 1em)

  pagebreak()
}

#let lof-page() = {
  set page(
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
    numbering: "i"
  )

  align(center)[
    #text(size: 16pt, weight: "bold")[List of Figures]
  ]

  v(2em)

  set text(size: 11pt, font: "Source Sans Pro")
  outline(
    title: none,
    target: figure.where(kind: image),
  )

  pagebreak()
}

#let lot-page() = {
  set page(
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
    numbering: "i"
  )

  align(center)[
    #text(size: 16pt, weight: "bold")[List of Tables]
  ]

  v(2em)

  set text(size: 11pt, font: "Source Sans Pro")
  outline(
    title: none,
    target: figure.where(kind: table),
  )

  pagebreak()
}

#let loa-page() = {
  set page(
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
    numbering: "i"
  )

  align(center)[
    #text(size: 16pt, weight: "bold")[List of Algorithms]
  ]

  v(2em)

  set text(size: 11pt, font: "Source Sans Pro")
  outline(
    title: none,
    target: figure.where(kind: "algorithm"),
  )

  pagebreak()
}
