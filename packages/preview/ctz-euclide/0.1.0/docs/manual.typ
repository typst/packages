#import "@preview/ctz-euclide:0.1.0": *
#import "helpers.typ": *

// ==============================================================================
// DOCUMENT SETUP
// ==============================================================================

#set page(margin: (x: 1.8cm, y: 2cm))
#set text(size: 10.5pt, font: "New Computer Modern")
#set heading(numbering: "1.")
#set par(justify: true)

#show raw.where(lang: "typst"): it => block(
  fill: luma(97%),
  radius: 3pt,
  inset: 8pt,
  stroke: 0.5pt + luma(85%),
)[#it]

// ==============================================================================
// TITLE PAGE
// ==============================================================================

#align(center)[
  #v(2cm)
  #text(size: 28pt, weight: "bold")[ctz-euclide]
  #v(0.5em)
  #text(size: 16pt)[Typst Port]
  #v(1em)
  #text(size: 12pt, style: "italic")[Euclidean Geometry for Typst]
  #v(2cm)
  #line(length: 60%, stroke: 0.5pt)
  #v(1cm)
  #text(size: 11pt)[
    A comprehensive geometry package built on CeTZ\
    Version 0.1.0\
    Nathan Scheinmann
  ]
]

#pagebreak()

// ==============================================================================
// TABLE OF CONTENTS
// ==============================================================================

#outline(indent: 1em)

#pagebreak()

// ==============================================================================
// CONTENT SECTIONS
// ==============================================================================

#include "sections/01-introduction.typ"

#include "sections/02-core-concepts.typ"

#include "sections/03-point-definitions.typ"

#include "sections/04-line-constructions.typ"

#include "sections/05-intersections.typ"

#include "sections/06-triangle-centers.typ"

#include "sections/07-transformations.typ"

#include "sections/08-drawing-styling.typ"

#include "sections/09-circles.typ"

#include "sections/10-conics.typ"

#include "sections/11-clipping.typ"

#include "sections/12-grid-annotation.typ"

#include "sections/13-raw-algorithms.typ"

#include "sections/14-function-reference.typ"

#include "sections/15-gallery.typ"

#include "sections/16-advanced-examples.typ"
