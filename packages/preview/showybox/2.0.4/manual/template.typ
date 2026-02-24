#import "../showy.typ": *

#let version = "2.0.4"

#let front-page(body) = {
  set document(author: "Showybox Contributors", title: "Showybox Manual")
  set page(numbering: "1", number-align: center)
  set text(size: 12pt, font: "HK Grotesk", lang: "en")

  set heading(numbering: "1.1.")

  show heading.where(level: 3) : it => {
    text(font: "Cascadia Code", size: 10.5pt, it.body.text)
  }

  show heading: set block(spacing: 1em)

  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  show link : it => {
    text(blue, it)
  }

  set list(indent: .5cm)

  v(1fr)

  showybox(
    frame: (
      inset: 2em,
      footer-inset: (x: 1em, y: 0.65em)
    ),
    title-style: (
      align: center
    ),
    body-style: (
      align: center
    ),
    footer-style: (
      align: center,
      weight: "regular"
    ),
    title: text(2.5em, weight: 700, "Showybox's Manual"),
    text(size: 1.5em, "Updated for version " + version),
    footer: [Colorful and customizable boxes for Typst #emoji.rocket]
  )

  v(2fr)
  pagebreak()


  outline(depth: 2, indent: true)
  pagebreak()


  set par(justify: true)

  body
}

#let line-raw(value) = raw(
  lang: "typc",
  block: false,
  value
)

#let types-color-dict = (
  "string": rgb("#d1ffe2"),
  "dictionary": rgb("#eff0f3"),
  "alignment": rgb("#eff0f3"),
  "2d-alignment": rgb("#eff0f3"),
  "array": rgb("#eff0f3"),
  "none": rgb("#ffcbc4"),
  "content": rgb("#a6ebe6"),
  "boolean": rgb("#ffedc1"),
  "length": rgb("#e7d9ff"),
  "integer": rgb("#e7d9ff"),
  "relative-length": rgb("#e7d9ff"),
  "body": rgb("#a6ebe6"),
)

#let type-block(type) = if type != "color"{
  return box(
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
} else {
  return box(
    height: 13pt,
    baseline: 3pt,
  )[
    #image("../assets/gradient.svg")
    #place(
      center + horizon,
      text(
        font: "Cascadia Code",
        size: 10.5pt,
        type
      )
    )
  ]
}

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

#let sbox-parameters() = showybox(
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
    #text(rgb("#4b69c6"), "showybox")\(

    #h(12pt) title: #type-block("string") #type-block("content")

    #h(12pt) footer: #type-block("string") #type-block("content")

    #h(12pt) frame: #type-block("dictionary")

    #h(12pt) title-style: #type-block("dictionary")

    #h(12pt) body-style: #type-block("dictionary")

    #h(12pt) footer-style: #type-block("dictionary")

    #h(12pt) sep: #type-block("dictionary")

    #h(12pt) shadow: #type-block("dictionary") #type-block("none")

    #h(12pt) width: #type-block("relative-length")

    #h(12pt) align: #type-block("alignment") #type-block("2d-alignment")

    #h(12pt) breakable: #type-block("boolean")

    #h(12pt) spacing: #type-block("relative-length")

    #h(12pt) spacing: #type-block("relative-length")

    #h(12pt) above: #type-block("relative-length")

    #h(12pt) below: #type-block("relative-length")

    #h(12pt) ..#type-block("body")

    ) -> #type-block("body")
  ]
)

#let frame-parameters() = showybox(
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
    ...

    frame: \(

    #h(12pt) title-color: #type-block("color")

    #h(12pt) body-color: #type-block("color")

    #h(12pt) footer-color: #type-block("color")

    #h(12pt) border-color: #type-block("color")

    #h(12pt) radius: #type-block("relative-length") #type-block("dictionary")

    #h(12pt) thickness: #type-block("length") #type-block("dictionary")

    #h(12pt) dash: #type-block("string")

    #h(12pt) inset: #type-block("relative-length") #type-block("dictionary")

    #h(12pt) title-inset: #type-block("relative-length") #type-block("dictionary")

    #h(12pt) body-inset: #type-block("relative-length") #type-block("dictionary")

    #h(12pt) footer-inset: #type-block("relative-length") #type-block("dictionary")

    ),

    ...
  ]
)

#let title-style-parameters() = showybox(
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
    ...

    title-style: \(

    #h(12pt) color: #type-block("color")

    #h(12pt) weight: #type-block("integer") #type-block("string")

    #h(12pt) align: #type-block("alignment") #type-block("2d-alignment")

    #h(12pt) sep-thickness: #type-block("length")

    #h(12pt) boxed-style: #type-block("dictionary") #type-block("none")

    ),

    ...
  ]
)

#let boxed-style-parameters() = showybox(
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
    ...

    title-style: \(

    #h(12pt) ...,

    #h(12pt) boxed-style \(

        #h(24pt) anchor: #type-block("dictionary")

        #h(24pt) offset: #type-block("dictionary")

        #h(24pt) radius: #type-block("relative-length") #type-block("dictionary")

    #h(12pt) ),

    #h(12pt) ...

    ),

    ...
  ]
)

#let body-style-parameters() = showybox(
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
    ...

    body-style: \(

    #h(12pt) color: #type-block("color")

    #h(12pt) align: #type-block("alignment") #type-block("2d-alignment")

    ),

    ...
  ]
)

#let footer-style-parameters() = showybox(
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
    ...

    footer-style: \(

    #h(12pt) color: #type-block("color")

    #h(12pt) weight: #type-block("integer") #type-block("string")

    #h(12pt) align: #type-block("alignment") #type-block("2d-alignment")

    #h(12pt) sep-thickness: #type-block("length")

    ),

    ...
  ]
)

#let sep-parameters() = showybox(
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
    ...

    sep: \(

    #h(12pt) thickness: #type-block("length")

    #h(12pt) dash: #type-block("string")

    #h(12pt) gutter: #type-block("relative-length")

    ),

    ...
  ]
)

#let shadow-parameters() = showybox(
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
    ...

    shadow: \(

    #h(12pt) color: #type-block("color")

    #h(12pt) offset: #type-block("relative-length") #type-block("dictionary")

    ),

    ...
  ]
)