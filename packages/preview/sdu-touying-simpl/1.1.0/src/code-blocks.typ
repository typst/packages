#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

// Code block configuration function, accepts theme color parameters
#let configure-codly(
  primary: rgb("#880000"),
  neutral-light: rgb("#f0f0f0"),
  neutral-lightest: rgb("#ffffff"),
) = {
  codly(
    languages: codly-languages,
    display-name: true,
    display-icon: true,
    radius: 4pt,
    inset: 0.32em,
    stroke: 1pt + neutral-light,
    zebra-fill: primary.lighten(95%),
    number-format: (number) => text(fill: luma(120))[#number],
    number-align: right + horizon,
  )
}

// Code block wrapper with line highlighting support
#let sdu-code(highlight-lines: none, highlight-color: none, body) = {
  if highlight-lines != none {
    let color = if highlight-color != none { highlight-color } else { rgb("#880000").lighten(90%) }
    codly(highlighted-lines: highlight-lines, highlighted-default-color: color)
  }
  body
  if highlight-lines != none {
    codly(highlighted-lines: ())
  }
}
