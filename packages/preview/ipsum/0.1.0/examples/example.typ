#import "@preview/ipsum:0.1.0": *

#set page(
  paper: "us-letter",
  margin: (x: 1.5cm, y: 2cm),
  columns: 2,
  numbering: "1/1",
)

#set par(justify: true)
#set text(size: 10pt)

#show heading.where(level: 1): it => [
  #v(1.5em)
  #set text(14pt, weight: "bold")
  #block(below: 0.8em, stroke: (bottom: 1pt + black))[
    #smallcaps(it.body)
  ]
]
#show heading.where(level: 2): it => [
  #v(1em)
  #set text(11pt, weight: "bold", style: "italic")
  #it.body
  #v(0.5em)
]

// document title
#place(float: true, top + center, scope: "parent")[
  #text(18pt, weight: "bold")[#lorem(6)] \
  #v(0.5em)
  #text(12pt, style: "italic")[By John Doe, PhD]
  #line(length: 100%, stroke: 0.5pt)
  #v(2em)
]

#smallcaps[*Abstract*]
#ipsum(
  mode: "fade",
  pars: 3,
  start: 60,
  ratio: 0.7,
  spacing: 0.5em,
)

= #lorem(4)

== #lorem(15)

// Using "natural" mode for body to look like real writing
#ipsum(
  mode: "natural",
  pars: 4,
  average: 55,
  var: 15,
)

= #lorem(5)

// "grow" implies increasing complexity in technical sections
== #lorem(3)
#ipsum(
  mode: "grow",
  pars: 4,
  base: 25,
  factor: 20,
)

== #lorem(4)
#ipsum(mode: "natural", pars: 2)

= #lorem(5)

The following transcript demonstrates the interview process:

#v(0.5em)
#box(
  fill: luma(240),
  inset: 1em,
  radius: 5pt,
  width: 100%,
)[
  // Using "dialogue" mode to simulate an interview transcript
  #set text(size: 9pt, font: "Roboto Mono")
  #ipsum(
    mode: "dialogue",
    events: 8,
    ratio: 0.7, // High chance of dialogue
    spacing: 0.5em,
  )
]

= #lorem(3)

// Here we need to fill space to push the next section to the
// end of the column using "fit".
#ipsum(
  mode: "fit",
  total: 250,
  pars: 4,
  ratio: 0.9, // Consistent paragraph sizes
)

= #lorem(2)

#ipsum(
  mode: "fade",
  pars: 3,
  start: 80,
  ratio: 0.5, // Sharp decay to end the paper
)
