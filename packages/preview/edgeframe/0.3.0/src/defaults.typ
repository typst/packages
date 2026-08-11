/*
  File: defaults.typ
  Author: neuralpain
  Date Modified: 2025-12-09

  Description: Default page styling settings.
*/

// Standard page margins
#let margin = (
  normal: 2.54cm,
  narrow: 1.27cm,
  moderate: (x: 2.54cm, y: 1.91cm),
  wide: (x: 5.08cm, y: 2.54cm),
  a4: (x: 2.5cm, y: 2cm),
  a5: (x: 2cm, y: 2.5cm),
)

// Biased defaults for documents
#let ef-defaults = (
  paper: "a4",
  margin: margin.a4,
  paragraph: (
    justify: false,
    leading: 0.8em,
    spacing: 1.5em,
    first-line-indent: 0em,
  ),
)
