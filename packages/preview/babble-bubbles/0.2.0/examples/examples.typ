#import "../lib.typ": *

// Terse (wrapper)
#warning[Disk space is low.]

// Explicit
#callout(kind: "warning", width: auto)[Disk space is low.]

// Override a single property
#callout(kind: "warning", fill: rgb("2A2118"), stroke: 1pt + rgb("E9973F"), width: 50%)[
  Disk space is low.
]

// Custom kind without registry
#callout(title: "Tip", fill: rgb("1A1A2E"), title-color: rgb("E94560"))[
  You can also define ad-hoc callouts inline.
]

// Fully custom: no kind, every property passed explicitly
#callout(
  title: "Tip",
  fill: rgb("1A1A2E"),
  title-color: rgb("E94560"),
  body-color: rgb("EAEAEA"),
  icon: "★",
  width: auto,
  radius: 10pt,
  stroke: 1pt + rgb("E94560"),
)[
  This callout defines everything inline — no preset, no `kind`.
]

#pagebreak()

#info[This is information]

#success[I'm making a note here: huge success]

#fail[This has failed...]

#check[This is checked!]

#warning[First warning...]

#note[My incredibly useful note]

#question[Question?]

#example[An example make things interesting]

#quote[To be or not to be]
