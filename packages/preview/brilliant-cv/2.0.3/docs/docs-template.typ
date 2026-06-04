#let template(
  title: "",
  subtitle: "",
  authors: "",
  date: "",
  version: "",
  doc,
) = {
  import "@preview/codly:0.2.0": *
  set document(author: authors, title: title)
  set page(numbering: "1", number-align: center)
  set text(font: "Source Sans 3", lang: "en")
  show link: set text(fill: rgb("#1e8f6f"))
  show link: underline

  show: codly-init.with()

  align(
    center,
    text(17pt, weight: "bold")[
      #title

      #subtitle
    ],
  )

  h(10pt)

  align(
    center,
    rect[
      _Authors: #authors _

      _Build Date: #datetime.today().display()_

      _Version: #version _
    ],
  )

  outline(depth: 2)

  pagebreak()

  doc
}
