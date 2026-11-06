#import "@preview/tidy:0.3.0"
#import "@preview/codly:0.1.0": *
#import "@preview/cvssc:0.1.0" as cvssc

#let docs = tidy.parse-module(
  read("cvssc.typ"),
  scope: (cvssc: cvssc)
)

#set text(font: "Inter", lang: "en")
#show raw: it => {
  set text(font: "Lilex Nerd Font")
  set block(inset: 0.5em)
  it
}

// #show list: pad.with(x: 5%)
#show link: set text(fill: rgb("#1e8f6f"))
#show link: underline

#v(4em)
// Title row.
#align(center)[
  #block(text(weight: 700, 1.75em, [cvssc]))
  #block(text(1.0em, [Common Vulnerability Scoring System Calculator]))
  #v(4em, weak: true)
  v#cvssc.version
  #block(link("https://github.com/DrakeAxelrod/cvssc"))
  #v(1.5em, weak: true)
]

// Author information.
#pad(
  top: 0.5em,
  x: 2em,
  grid(
    columns: (1fr,) * calc.min(3, 1),
    gutter: 1em,
    align(center, [Created by #link("https://github.com/DrakeAxelrod", strong("Drake Axelrod"))]),
  ),
)

#v(3cm, weak: true)

// Abstract.
#pad(
  x: 3.8em,
  top: 1em,
  bottom: 1.1em,
  align(center)[
    #heading(
      outlined: false,
      numbering: none,
      text(0.85em, smallcaps[Summary]),
    )
    #[
      This package provides a set of functions for parsing CVSS strings and vectors. It includes functions for converting CVSS strings to dictionaries, dictionaries to strings, and calculating CVSS scores from dictionaries. The package also includes functions for converting strings to vectors and vectors to strings. The package is designed to be used with the Typst programming language.
    ],
  ]
)
#pagebreak(weak: true)

#show heading.where(level: 3): it => colbreak(weak: true) + [cvssc.] + text(font: "Lilex Nerd Font", fill: rgb("#1e8f6f"), it.body) + linebreak()
#set par(justify: true, hanging-indent: 0em, first-line-indent: 0em,)
#let style = tidy.styles.default
#tidy.show-module(
  docs,
  style: style,
  first-heading-level: 2,
  // break-param-descriptions: true,
  show-outline: false,
)