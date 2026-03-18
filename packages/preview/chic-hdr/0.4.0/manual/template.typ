#import "@preview/showybox:2.0.1": *

#let chic-version = "0.4.0"

#let title-page() = {
  block(
    width: 100%,
    height: 55%,
    align(center, {
      text(size: 30pt, "Chic-header's Manual")

      v(10pt)

      text(size: 20pt, "Version " + chic-version)

      v(5pt)

      text(size: 18pt, emph("Elegant headers and footers for Typst."))

      v(10pt)

      text(size: 14pt, "Pablo González Calderón \n & \n Chic-header's Contributors")

      v(15pt)

      text(size: 20pt, weight: 900, "Abstract")
      align(left)[
        Usually, setting a header and a footer for our Typst document is quite annoying and tedious. Also, this task can easily turn hard if we want to set different behaviors for odd pages and even pages, or if we want to implement a custom separator for headers and footers. This package comes to solve those (and more) problems, providing a new alternative for setting headers and footers in your Typst documents.
      ]

    })
  )

  columns(2, outline(depth: 2, indent: true))
}

#let document-props(body) = {
  set document(author: "Chic-hdr Contributors", title: "Chic-header's Manual")

  set heading(numbering: "1.")
  set text(size: 12pt)

  show heading.where(level: 3) : it => {
    list(
      text(font: "Cascadia Code", size: 11pt, it.body),
      marker: sym.floral.r
    )
  }

  show heading: set block(spacing: 1em)

  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  set par(justify: true)

  body
}

#let line-raw(code: true, value) = raw(
  lang: if code {"typc"} else {"typ"},
  block: false,
  value
)

#let types-color-dict = (
  "string": rgb("#d1ffe2"),
  "dictionary": rgb("#eff0f3"),
  "alignment": rgb("#eff0f3"),
  "2d-alignment": rgb("#eff0f3"),
  "array": rgb("#eff0f3"),
  "array-of-functions": rgb("#eff0f3"),
  "none": rgb("#ffcbc4"),
  "content": rgb("#a6ebe6"),
  "boolean": rgb("#ffedc1"),
  "length": rgb("#e7d9ff"),
  "integer": rgb("#e7d9ff"),
  "relative-length": rgb("#e7d9ff"),
  "function": rgb("#e7d9ff"),
  "chic-function": rgb("#e7d9ff"),
  "body": rgb("#a6ebe6"),
  "color": gradient.linear(rgb("#7cd5ff"), rgb("#a6fbca"), rgb("#fff37c"), rgb("#ffa49d"))
)

#let type-block(type) = box(
  fill: types-color-dict.at(type, default: white),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
  text(
    font: "Cascadia Code",
    size: 10.5pt,
    type
  )
)

#let observation(..body) = showybox(
  frame: (
    title-color: blue.darken(40%),
    border-color: blue.darken(40%),
    body-color: blue.lighten(95%),
    radius: 0pt
  ),
  title: [*Observation*],
  ..body
)

#let example-box(images) = box(
  fill: luma(220),
  inset: 11pt,
  grid(
    columns: (1fr,) * images.len(),
    column-gutter: 11pt,
    ..images.map(img => image(img))
  )
)

#let chic-parameters() = showybox(
  frame: (
    radius: 3pt,
    inset: 1em,
    body-color: luma(250),
    border-color: luma(200),
    thickness: 0.6pt
  ),
  shadow: (
    offset: 1.5pt,
    color: luma(200)
  ),
  breakable: true,
  text(
    font: "Cascadia Code",
    size: 10.5pt
  )[
    #text(rgb("#d73a49"), "#show"): chic.#text(rgb("#4b69c6"), "with")\(

    #h(12pt) width: #type-block("relative-length")

    #h(12pt) skip: #type-block("array")

    #h(12pt) even: #type-block("array-of-functions") #type-block("none")

    #h(12pt) odd: #type-block("array-of-functions") #type-block("none")

    #h(12pt) ..#type-block("chic-function")

    ) -> #type-block("body")
  ]
)

#let chic-header-footer-parameters(h-or-f) = showybox(
  frame: (
    radius: 3pt,
    inset: 1em,
    body-color: luma(250),
    border-color: luma(200),
    thickness: 0.6pt
  ),
  shadow: (
    offset: 1.5pt,
    color: luma(200)
  ),
  breakable: true,
  text(
    font: "Cascadia Code",
    size: 10.5pt
  )[
    #text(rgb("#4b69c6"), if h-or-f == "header" {"chic-header"} else {"chic-footer"})\(

    #h(12pt) v-center: #type-block("boolean")

    #h(12pt) side-width: #type-block("length") #type-block("relative-length") 3-item-#type-block("array")

    #h(12pt) left-side: #type-block("string") #type-block("content")

    #h(12pt) center-side: #type-block("string") #type-block("content")

    #h(12pt) right-side: #type-block("string") #type-block("content")

    )
  ]
)

#let chic-separator-parameters() = showybox(
  frame: (
    radius: 3pt,
    inset: 1em,
    body-color: luma(250),
    border-color: luma(200),
    thickness: 0.6pt
  ),
  shadow: (
    offset: 1.5pt,
    color: luma(200)
  ),
  breakable: true,
  text(
    font: "Cascadia Code",
    size: 10.5pt
  )[
    #text(rgb("#4b69c6"), "chic-separator")\(

    #h(12pt) on: #type-block("string")

    #h(12pt) outset: #type-block("relative-length")

    #h(12pt) gutter: #type-block("relative-length")

    #h(12pt) #type-block("length") #type-block("stroke") #type-block("content")

    )
  ]
)

#let chic-styled-separator-parameters() = showybox(
  frame: (
    radius: 3pt,
    inset: 1em,
    body-color: luma(250),
    border-color: luma(200),
    thickness: 0.6pt
  ),
  shadow: (
    offset: 1.5pt,
    color: luma(200)
  ),
  breakable: true,
  text(
    font: "Cascadia Code",
    size: 10.5pt
  )[
    #text(rgb("#4b69c6"), "chic-styled-separator")\(

    #h(12pt) color: #type-block("color")

    #h(12pt) outset: #type-block("string")

    )
  ]
)

#let chic-height-parameters() = showybox(
  frame: (
    radius: 3pt,
    inset: 1em,
    body-color: luma(250),
    border-color: luma(200),
    thickness: 0.6pt
  ),
  shadow: (
    offset: 1.5pt,
    color: luma(200)
  ),
  breakable: true,
  text(
    font: "Cascadia Code",
    size: 10.5pt
  )[
    #text(rgb("#4b69c6"), "chic-height")\(

    #h(12pt) on: #type-block("string")

    #h(12pt) #type-block("relative-length")

    )
  ]
)

#let chic-offset-parameters() = showybox(
  frame: (
    radius: 3pt,
    inset: 1em,
    body-color: luma(250),
    border-color: luma(200),
    thickness: 0.6pt
  ),
  shadow: (
    offset: 1.5pt,
    color: luma(200)
  ),
  breakable: true,
  text(
    font: "Cascadia Code",
    size: 10.5pt
  )[
    #text(rgb("#4b69c6"), "chic-offset")\(

    #h(12pt) on: #type-block("string")

    #h(12pt) #type-block("relative-length")

    )
  ]
)

#let chic-heading-name-parameters() = showybox(
  frame: (
    radius: 3pt,
    inset: 1em,
    body-color: luma(250),
    border-color: luma(200),
    thickness: 0.6pt
  ),
  shadow: (
    offset: 1.5pt,
    color: luma(200)
  ),
  breakable: true,
  text(
    font: "Cascadia Code",
    size: 10.5pt
  )[
    #text(rgb("#4b69c6"), "chic-heading-name")\(

    #h(12pt) dir: #type-block("string")

    #h(12pt) fill: #type-block("boolean")

    #h(12pt) level: #type-block("integer")

    )
  ]
)