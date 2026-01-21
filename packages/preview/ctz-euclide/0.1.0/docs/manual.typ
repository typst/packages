#import "@preview/cetz:0.4.2" as cetz
#import "@preview/ctz-euclide:0.1.0" as ctz-lib

#let ctz = ctz-lib.create-api(cetz)

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
// HELPER FUNCTIONS
// ==============================================================================

/// Two-column example layout with code and figure
#let example(code, body, length: 0.75cm) = block(breakable: false)[
  #table(
    columns: (1fr, 1fr),
    stroke: none,
    inset: 6pt,
    align: (left + top, center + top),
    [
      #set text(size: 8.5pt)
      *Code*
      #v(0.3em)
      #code
    ],
    [
      *Figure*
      #v(0.3em)
      #box(
        inset: 4pt,
        radius: 3pt,
        stroke: 0.5pt + luma(85%),
        fill: luma(98%),
      )[
        #cetz.canvas(length: length, body)
      ]
    ],
  )
  #v(0.5em)
]

/// Full-page figure
#let full-figure(title, body, code: none, length: 1cm, caption: none) = {
  pagebreak()
  v(1fr)
  align(center)[
    #text(size: 12pt, weight: "bold")[#title]
    #v(1em)
    #box(
      inset: 8pt,
      radius: 4pt,
      stroke: 0.5pt + luma(80%),
      fill: luma(98%),
    )[
      #cetz.canvas(length: length, body)
    ]
    #if caption != none [
      #v(1.5em)
      #text(size: 10pt)[#caption]
    ]
    #if code != none [
      #v(1.5em)
      #align(left)[
        #box(
          width: 100%,
          inset: 10pt,
          radius: 3pt,
          stroke: 0.5pt + luma(70%),
          fill: luma(95%),
        )[
          #set text(size: 8pt, font: "DejaVu Sans Mono")
          #code
        ]
      ]
    ]
  ]
  v(2fr)
}

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
    Version 0.1.0
  ]
]

#pagebreak()

// ==============================================================================
// TABLE OF CONTENTS
// ==============================================================================

#outline(indent: 1em)

#pagebreak()

// ==============================================================================
// INTRODUCTION
// ==============================================================================

= Introduction

`ctz-euclide` is a geometry package for Typst, a port of the LaTeX package `tkz-euclide`. Built on top of CeTZ (a powerful drawing library), it provides high-level constructions for Euclidean geometry.

== Features

- *Point Registry*: Define points once, reference them by name throughout your figure
- *Geometric Constructions*: Perpendiculars, parallels, bisectors, mediators
- *Intersections*: Line–line, line–circle, circle–circle with multiple solution handling
- *Triangle Centers*: Centroid, circumcenter, incenter, orthocenter, and 10+ specialized centers
- *Special Triangles*: Medial, orthic, intouch triangles
- *Transformations*: Rotation, reflection, translation, homothety, projection
- *Drawing & Styling*: Points, labels, angles, segments with tick marks
- *Grid & Axes*: Coordinate systems with customizable appearance
- *Clipping*: Mathematical line clipping for clean bounded figures

== Installation

Import the package in your Typst document:

```typst
#import "@preview/cetz:0.4.2" as cetz
#import "@preview/ctz-euclide:0.1.0" as ctz-lib

#let ctz = ctz-lib.create-api(cetz)
```

All figures must begin with:

```typst
#cetz.canvas({
  import cetz.draw: *
  (ctz.init)()

  // Your geometry code here
})
```

The `(ctz.init)()` call initializes the point registry and coordinate resolver.

== Basic Usage

#example(
  [```typst
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    (ctz.init)()

    // Define points
    (ctz.pts)(A: (0, 0), B: (4, 0), C: (2, 3))

    // Draw triangle
    line("A", "B", "C", "A", stroke: black)

    // Find circumcenter and draw circumcircle
    (ctz.circumcenter)("O", "A", "B", "C")
    circle("O", "A", stroke: blue)

    // Draw and label points
    (ctz.points)("A", "B", "C", "O")
    (ctz.labels)("A", "B", "C", "O",
      A: "below left", B: "below right",
      C: "above", O: "below")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (4, 0), C: (2, 3))
    line("A", "B", "C", "A", stroke: black)
    (ctz.circumcenter)("O", "A", "B", "C")
    circle("O", "A", stroke: blue)
    (ctz.points)("A", "B", "C", "O")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "O",
      A: "below left",
      B: "below right",
      C: "above",
      O: "below",
    )
  },
)

#pagebreak()

// ==============================================================================
// CORE CONCEPTS
// ==============================================================================

= Core Concepts

== The Point Registry

The point registry is the heart of `ctz-euclide`. Once you define a point with a name, that name can be used directly in CeTZ drawing commands.

```typst
(ctz.pts)(A: (0, 0), B: (3, 4))  // Register points A and B
line("A", "B")                    // Use them directly in CeTZ
```

Under the hood, `(ctz.init)()` installs a coordinate resolver that translates `"A"` to the stored coordinates. Both `"A"` and `"tkz:A"` resolve to the same point.

== Figure Scaling

Control the size of your figures using CeTZ's `length` parameter:

```typst
#cetz.canvas(length: 0.8cm, { ... })
```

This scales everything proportionally, including stroke widths. Typical values:
- `0.6cm` – small inline figures
- `0.8cm` – standard examples
- `1.0cm` – large detailed figures

== Coordinate Systems

Points can be defined in multiple ways:

```typst
// Explicit coordinates
(ctz.pts)(A: (2, 3))

// Using existing CeTZ coordinates
(ctz.pts)(B: (rel: (1, 1), to: "A"))

// Mixed: numbers and existing points
(ctz.pts)(C: (4, 0), D: "A", E: (3, 2))
```

#pagebreak()

// ==============================================================================
// POINT DEFINITIONS
// ==============================================================================

= Point Definitions

== Basic Points — `pts`

Define one or more points at specific coordinates:

```typst
(ctz.pts)(A: (0, 0), B: (4, 0), C: (2, 3))
```

== Midpoint — `midpoint`

Find the midpoint of a segment:

#example(
  [```typst
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (5, 3))
    (ctz.midpoint)("M", "A", "B")

    line("A", "B", stroke: black)
    (ctz.points)("A", "B", "M")
    (ctz.labels)("A", "B", "M",
      A: "left", B: "right", M: "above")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (5, 3))
    (ctz.midpoint)("M", "A", "B")
    line("A", "B", stroke: black)
    (ctz.points)("A", "B", "M")
    (ctz.labels)("A", "B", "M", A: "left", B: "right", M: "above")
  },
)

== Regular Polygons — `regular-polygon`

Generate vertices of a regular $n$-gon:

#example(
  [```typst
  #cetz.canvas(length: 0.7cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(O: (0, 0), A: (3, 0))
    (ctz.regular-polygon)(("A", "B", "C", "D", "E", "F"), "O", "A")

    line("A", "B", "C", "D", "E", "F", "A", stroke: blue)
    (ctz.points)("A", "B", "C", "D", "E", "F", "O")
    (ctz.labels)("O", O: "below")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(O: (0, 0), A: (3, 0))
    (ctz.regular-polygon)(("A", "B", "C", "D", "E", "F"), "O", "A")
    line("A", "B", "C", "D", "E", "F", "A", stroke: blue)
    (ctz.points)("A", "B", "C", "D", "E", "F", "O")
    (ctz.labels)("O", O: "below")
  },
  length: 0.7cm,
)

== Linear Combination — `linear`

Define a point along a line: $P = A + k(B - A)$

```typst
(ctz.linear)("P", "A", "B", 0.3)  // P is 30% from A to B
(ctz.linear)("Q", "A", "B", 1.5)  // Q extends beyond B
```

#pagebreak()

// ==============================================================================
// LINE CONSTRUCTIONS
// ==============================================================================

= Line Constructions

== Perpendicular — `perp`

Construct a perpendicular line through a point:

#example(
  [```typst
  #cetz.canvas(length: 0.75cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (5, 1), C: (2, 3))
    (ctz.perp)("P1", "P2", ("A", "B"), "C")
    (ctz.project)("H", "C", "A", "B")

    line("A", "B", stroke: black)
    line("P1", "P2", stroke: blue)
    (ctz.mark-right-angle)("A", "H", "C", size: 0.3)

    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C",
      A: "left", B: "right", C: "above")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (5, 1), C: (2, 3))
    (ctz.perp)("P1", "P2", ("A", "B"), "C")
    (ctz.project)("H", "C", "A", "B")
    line("A", "B", stroke: black)
    line("P1", "P2", stroke: blue)
    (ctz.mark-right-angle)("A", "H", "C", size: 0.3)
    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C", A: "left", B: "right", C: "above")
  },
  length: 0.75cm,
)

== Parallel — `para`

Construct a parallel line through a point:

#example(
  [```typst
  #cetz.canvas(length: 0.75cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (5, 1), C: (1, 2.5))
    (ctz.para)("P1", "P2", ("A", "B"), "C")

    (ctz.set-clip)(-0.5, -0.5, 5.5, 3.5)
    (ctz.line)("A", "B", add: (2, 2), stroke: black)
    (ctz.line)("P1", "P2", add: (2, 2), stroke: green)

    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C",
      A: "below", B: "below", C: "above")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (5, 1), C: (1, 2.5))
    (ctz.para)("P1", "P2", ("A", "B"), "C")
    (ctz.set-clip)(-0.5, -0.5, 5.5, 3.5)
    (ctz.line)("A", "B", add: (2, 2), stroke: black)
    (ctz.line)("P1", "P2", add: (2, 2), stroke: green)
    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C", A: "below", B: "below", C: "above")
  },
  length: 0.75cm,
)

== Angle Bisector — `bisect`

Construct the bisector of an angle:

#example(
  [```typst
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (4, 0), C: (1, 3))
    (ctz.bisect)("D1", "D2", "C", "A", "B")

    (ctz.set-clip)(-0.5, -0.5, 4.5, 3.5)
    line("A", "B", "C", "A", stroke: black)
    (ctz.seg)("D1", "D2", stroke: red)

    (ctz.angle)("A", "C", "B", radius: 0.5, stroke: gray)
    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C",
      A: "below", B: "below", C: "above")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (4, 0), C: (1, 3))
    (ctz.bisect)("D1", "D2", "C", "A", "B")
    (ctz.set-clip)(-0.5, -0.5, 4.5, 3.5)
    line("A", "B", "C", "A", stroke: black)
    (ctz.seg)("D1", "D2", stroke: red)
    (ctz.angle)("A", "C", "B", radius: 0.5, stroke: gray)
    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C", A: "below", B: "below", C: "above")
  },
)

== Perpendicular Bisector — `mediator`

Construct the perpendicular bisector of a segment:

#example(
  [```typst
  #cetz.canvas(length: 0.75cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (1, 1), B: (5, 3))
    (ctz.mediator)("M1", "M2", "A", "B")
    (ctz.midpoint)("M", "A", "B")

    line("A", "B", stroke: black)
    line("M1", "M2", stroke: purple)
    (ctz.mark-right-angle)("M1", "M", "A", size: 0.25)

    (ctz.points)("A", "B", "M")
    (ctz.labels)("A", "B", "M",
      A: "left", B: "right", M: "below")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (1, 1), B: (5, 3))
    (ctz.mediator)("M1", "M2", "A", "B")
    (ctz.midpoint)("M", "A", "B")
    line("A", "B", stroke: black)
    line("M1", "M2", stroke: purple)
    (ctz.mark-right-angle)("M1", "M", "A", size: 0.25)
    (ctz.points)("A", "B", "M")
    (ctz.labels)("A", "B", "M", A: "left", B: "right", M: "below")
  },
  length: 0.75cm,
)

#pagebreak()

// ==============================================================================
// INTERSECTIONS
// ==============================================================================

= Intersections

== Line–Line — `ll`

Find the intersection of two lines:

#example(
  [```typst
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (4, 3),
              C: (4, 0), D: (0, 2.5))
    (ctz.ll)("I", ("A", "B"), ("C", "D"))

    line("A", "B", stroke: blue)
    line("C", "D", stroke: red)

    (ctz.points)("A", "B", "C", "D", "I")
    (ctz.labels)("I", I: "above left")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (4, 3), C: (4, 0), D: (0, 2.5))
    (ctz.ll)("I", ("A", "B"), ("C", "D"))
    line("A", "B", stroke: blue)
    line("C", "D", stroke: red)
    (ctz.points)("A", "B", "C", "D", "I")
    (ctz.labels)("I", I: "above left")
  },
)

== Line–Circle — `lc`

Find intersections of a line with a circle:

#example(
  [```typst
  #cetz.canvas(length: 0.7cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(O: (0, 0), R: (3, 0),
              A: (-2, 2), B: (4, 1))
    (ctz.lc)(("I1", "I2"), ("A", "B"),
      (center: "O", through: "R"))

    circle("O", "R", stroke: blue)
    (ctz.set-clip)(-4, -4, 5, 4)
    (ctz.line)("A", "B", add: (2, 2), stroke: red)

    (ctz.points)("O", "I1", "I2")
    (ctz.labels)("O", "I1", "I2",
      O: "below", I1: "above left", I2: "below right")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(O: (0, 0), R: (3, 0), A: (-2, 2), B: (4, 1))
    (ctz.lc)(("I1", "I2"), ("A", "B"), (center: "O", through: "R"))
    circle("O", "R", stroke: blue)
    (ctz.set-clip)(-4, -4, 5, 4)
    (ctz.line)("A", "B", add: (2, 2), stroke: red)
    (ctz.points)("O", "I1", "I2")
    (ctz.labels)(
      "O",
      "I1",
      "I2",
      O: "below",
      I1: "above left",
      I2: "below right",
    )
  },
  length: 0.7cm,
)

== Circle–Circle — `cc`

Find intersections of two circles:

#example(
  [```typst
  #cetz.canvas(length: 0.65cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(O1: (0, 0), O2: (3, 0),
              R1: (2.5, 0), R2: (5.5, 0))
    (ctz.cc)(("I1", "I2"),
      (center: "O1", through: "R1"),
      (center: "O2", through: "R2"))

    circle("O1", "R1", stroke: blue)
    circle("O2", "R2", stroke: red)

    (ctz.points)("O1", "O2", "I1", "I2")
    (ctz.labels)("I1", "I2",
      I1: "above", I2: "below")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(O1: (0, 0), O2: (3, 0), R1: (2.5, 0), R2: (5.5, 0))
    (ctz.cc)(
      ("I1", "I2"),
      (center: "O1", through: "R1"),
      (center: "O2", through: "R2"),
    )
    circle("O1", "R1", stroke: blue)
    circle("O2", "R2", stroke: red)
    (ctz.points)("O1", "O2", "I1", "I2")
    (ctz.labels)("I1", "I2", I1: "above", I2: "below")
  },
  length: 0.65cm,
)

#pagebreak()

// ==============================================================================
// TRIANGLE CENTERS
// ==============================================================================

= Triangle Centers

== Basic Centers

=== Centroid — `centroid`

The intersection of medians (center of mass):

#example(
  [```typst
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (5, 0), C: (2, 3.5))
    (ctz.centroid)("G", "A", "B", "C")

    // Draw medians
    (ctz.midpoint)("Ma", "B", "C")
    (ctz.midpoint)("Mb", "A", "C")
    (ctz.midpoint)("Mc", "A", "B")

    line("A", "B", "C", "A", stroke: black)
    line("A", "Ma", stroke: blue + 0.5pt)
    line("B", "Mb", stroke: blue + 0.5pt)
    line("C", "Mc", stroke: blue + 0.5pt)

    (ctz.points)("A", "B", "C", "G")
    (ctz.labels)("A", "B", "C", "G",
      A: "below left", B: "below right",
      C: "above", G: "right")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (5, 0), C: (2, 3.5))
    (ctz.centroid)("G", "A", "B", "C")
    (ctz.midpoint)("Ma", "B", "C")
    (ctz.midpoint)("Mb", "A", "C")
    (ctz.midpoint)("Mc", "A", "B")
    line("A", "B", "C", "A", stroke: black)
    line("A", "Ma", stroke: blue + 0.5pt)
    line("B", "Mb", stroke: blue + 0.5pt)
    line("C", "Mc", stroke: blue + 0.5pt)
    (ctz.points)("A", "B", "C", "G")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "G",
      A: "below left",
      B: "below right",
      C: "above",
      G: "right",
    )
  },
)

=== Circumcenter — `circumcenter`

Center of the circumscribed circle:

#example(
  [```typst
  #cetz.canvas(length: 0.75cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (5, 0), C: (2, 3.5))
    (ctz.circumcenter)("O", "A", "B", "C")

    line("A", "B", "C", "A", stroke: black)
    circle("O", "A", stroke: blue + 0.7pt)

    line("O", "A", stroke: gray + 0.5pt)
    line("O", "B", stroke: gray + 0.5pt)
    line("O", "C", stroke: gray + 0.5pt)

    (ctz.points)("A", "B", "C", "O")
    (ctz.labels)("A", "B", "C", "O",
      A: "below left", B: "below right",
      C: "above", O: "below")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (5, 0), C: (2, 3.5))
    (ctz.circumcenter)("O", "A", "B", "C")
    line("A", "B", "C", "A", stroke: black)
    circle("O", "A", stroke: blue + 0.7pt)
    line("O", "A", stroke: gray + 0.5pt)
    line("O", "B", stroke: gray + 0.5pt)
    line("O", "C", stroke: gray + 0.5pt)
    (ctz.points)("A", "B", "C", "O")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "O",
      A: "below left",
      B: "below right",
      C: "above",
      O: "below",
    )
  },
  length: 0.75cm,
)

=== Incenter — `incenter`

Center of the inscribed circle:

#example(
  [```typst
  #cetz.canvas(length: 0.75cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (5, 0), C: (2, 3.5))
    (ctz.incenter)("I", "A", "B", "C")

    line("A", "B", "C", "A", stroke: black)
    (ctz.incircle)("A", "B", "C", stroke: green + 0.7pt)

    // Angle bisectors
    (ctz.bisect)("Ba1", "Ba2", "I", "B", "C")
    (ctz.bisect)("Bb1", "Bb2", "I", "A", "C")
    (ctz.bisect)("Bc1", "Bc2", "I", "A", "B")

    (ctz.points)("A", "B", "C", "I")
    (ctz.labels)("A", "B", "C", "I",
      A: "below left", B: "below right",
      C: "above", I: "below right")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (5, 0), C: (2, 3.5))
    (ctz.incenter)("I", "A", "B", "C")
    line("A", "B", "C", "A", stroke: black)
    (ctz.incircle)("A", "B", "C", stroke: green + 0.7pt)
    (ctz.points)("A", "B", "C", "I")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "I",
      A: "below left",
      B: "below right",
      C: "above",
      I: "below right",
    )
  },
  length: 0.75cm,
)

=== Orthocenter — `orthocenter`

Intersection of altitudes:

#example(
  [```typst
  #cetz.canvas(length: 0.75cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (5, 0), C: (2, 3.5))
    (ctz.orthocenter)("H", "A", "B", "C")

    // Altitudes (extended as lines)
    (ctz.perp)("Ha1", "Ha2", ("B", "C"), "A")
    (ctz.perp)("Hb1", "Hb2", ("A", "C"), "B")
    (ctz.perp)("Hc1", "Hc2", ("A", "B"), "C")

    (ctz.set-clip)(-0.5, -0.5, 5.5, 4)
    line("A", "B", "C", "A", stroke: black)
    (ctz.line)("A", "Ha1", add: (2, 2), stroke: red + 0.5pt)
    (ctz.line)("B", "Hb1", add: (2, 2), stroke: red + 0.5pt)
    (ctz.line)("C", "Hc1", add: (2, 2), stroke: red + 0.5pt)

    (ctz.points)("A", "B", "C", "H")
    (ctz.labels)("A", "B", "C", "H",
      A: "below left", B: "below right",
      C: "above", H: "below right")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (5, 0), C: (2, 3.5))
    (ctz.orthocenter)("H", "A", "B", "C")
    (ctz.perp)("Ha1", "Ha2", ("B", "C"), "A")
    (ctz.perp)("Hb1", "Hb2", ("A", "C"), "B")
    (ctz.perp)("Hc1", "Hc2", ("A", "B"), "C")
    (ctz.set-clip)(-0.5, -0.5, 5.5, 4)
    line("A", "B", "C", "A", stroke: black)
    (ctz.line)("A", "Ha1", add: (2, 2), stroke: red + 0.5pt)
    (ctz.line)("B", "Hb1", add: (2, 2), stroke: red + 0.5pt)
    (ctz.line)("C", "Hc1", add: (2, 2), stroke: red + 0.5pt)
    (ctz.points)("A", "B", "C", "H")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "H",
      A: "below left",
      B: "below right",
      C: "above",
      H: "below right",
    )
  },
  length: 0.75cm,
)

== The Euler Line

In any non-equilateral triangle, the orthocenter $H$, centroid $G$, and circumcenter $O$ are collinear. This line is called the *Euler line*, and remarkably, $G$ divides $H O$ in the ratio $2:1$.

#example(
  [```typst
  #cetz.canvas(length: 0.75cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (5, 0), C: (1.5, 3.5))

    (ctz.orthocenter)("H", "A", "B", "C")
    (ctz.centroid)("G", "A", "B", "C")
    (ctz.circumcenter)("O", "A", "B", "C")

    (ctz.set-clip)(-0.5, -0.5, 5.5, 4)
    line("A", "B", "C", "A", stroke: black)
    (ctz.line-add)("H", "O", add: 0.5, stroke: (paint: red, dash: "dashed"))
    circle("O", "A", stroke: blue + 0.6pt)

    (ctz.points)("A", "B", "C", "H", "G", "O")
    (ctz.labels)("A", "B", "C", "H", "G", "O",
      A: "below left", B: "below right", C: "above",
      H: "left", G: "below", O: "right")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (5, 0), C: (1.5, 3.5))
    (ctz.orthocenter)("H", "A", "B", "C")
    (ctz.centroid)("G", "A", "B", "C")
    (ctz.circumcenter)("O", "A", "B", "C")
    (ctz.set-clip)(-0.5, -0.5, 5.5, 4)
    line("A", "B", "C", "A", stroke: black)
    (ctz.line-add)("H", "O", add: 0.5, stroke: (paint: red, dash: "dashed"))
    circle("O", "A", stroke: blue + 0.6pt)
    (ctz.points)("A", "B", "C", "H", "G", "O")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "H",
      "G",
      "O",
      A: "below left",
      B: "below right",
      C: "above",
      H: "left",
      G: "below",
      O: "right",
    )
  },
  length: 0.75cm,
)

#pagebreak()

== Advanced Centers

`ctz-euclide` supports 10+ specialized triangle centers:

- `lemoine` — Symmedian point (Lemoine point)
- `nagel` — Nagel point
- `gergonne` — Gergonne point
- `spieker` — Spieker center (incenter of medial triangle)
- `euler` — Nine-point circle center
- `feuerbach` — Feuerbach point
- `mittenpunkt` — Mittenpunkt
- `excenter` — Excenter (specify vertex: `"a"`, `"b"`, or `"c"`)

Example with Euler (nine-point) circle:

#example(
  [```typst
  #cetz.canvas(length: 0.7cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (5, 0), C: (1.5, 3.5))
    (ctz.euler)("N", "A", "B", "C")

    line("A", "B", "C", "A", stroke: black)

    // Nine-point circle passes through
    // midpoints of sides
    (ctz.midpoint)("Ma", "B", "C")
    (ctz.midpoint)("Mb", "A", "C")
    (ctz.midpoint)("Mc", "A", "B")

    circle("N", "Ma", stroke: purple + 0.7pt)

    (ctz.points)("A", "B", "C", "N", "Ma", "Mb", "Mc")
    (ctz.labels)("N", N: "below")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (5, 0), C: (1.5, 3.5))
    (ctz.euler)("N", "A", "B", "C")
    line("A", "B", "C", "A", stroke: black)
    (ctz.midpoint)("Ma", "B", "C")
    (ctz.midpoint)("Mb", "A", "C")
    (ctz.midpoint)("Mc", "A", "B")
    circle("N", "Ma", stroke: purple + 0.7pt)
    (ctz.points)("A", "B", "C", "N", "Ma", "Mb", "Mc")
    (ctz.labels)("N", N: "below")
  },
  length: 0.7cm,
)

#pagebreak()

// ==============================================================================
// TRANSFORMATIONS
// ==============================================================================

= Transformations

== Rotation — `rotate`

Rotate a point around a center:

#example(
  [```typst
  #cetz.canvas(length: 0.75cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(O: (2, 2), A: (5, 2))
    (ctz.rotate)("B", "A", "O", 60)
    (ctz.rotate)("C", "A", "O", 120)

    circle("O", radius: 3, stroke: gray.lighten(50%))
    line("O", "A", stroke: blue)
    line("O", "B", stroke: blue)
    line("O", "C", stroke: blue)
    line("A", "B", "C", "A", stroke: black)

    (ctz.points)("O", "A", "B", "C")
    (ctz.labels)("O", "A", "B", "C",
      O: "below left", A: "right",
      B: "above right", C: "left")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(O: (2, 2), A: (5, 2))
    (ctz.rotate)("B", "A", "O", 60)
    (ctz.rotate)("C", "A", "O", 120)
    circle("O", radius: 3, stroke: gray.lighten(50%))
    line("O", "A", stroke: blue)
    line("O", "B", stroke: blue)
    line("O", "C", stroke: blue)
    line("A", "B", "C", "A", stroke: black)
    (ctz.points)("O", "A", "B", "C")
    (ctz.labels)(
      "O",
      "A",
      "B",
      "C",
      O: "below left",
      A: "right",
      B: "above right",
      C: "left",
    )
  },
  length: 0.75cm,
)

== Reflection — `reflect`

Reflect a point across a line:

#example(
  [```typst
  #cetz.canvas(length: 0.75cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (1, 1), B: (4, 3),
              L1: (0, 0), L2: (5, 0))
    (ctz.reflect)("Ap", "A", "L1", "L2")
    (ctz.reflect)("Bp", "B", "L1", "L2")

    line("L1", "L2", stroke: gray.lighten(30%))
    line("A", "Ap", stroke: (paint: blue, dash: "dashed"))
    line("B", "Bp", stroke: (paint: blue, dash: "dashed"))
    line("A", "B", stroke: red)
    line("Ap", "Bp", stroke: green)

    (ctz.points)("A", "B", "Ap", "Bp")
    (ctz.labels)("A", "B",
      A: "above", B: "above")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (1, 1), B: (4, 3), L1: (0, 0), L2: (5, 0))
    (ctz.reflect)("Ap", "A", "L1", "L2")
    (ctz.reflect)("Bp", "B", "L1", "L2")
    line("L1", "L2", stroke: gray.lighten(30%))
    line("A", "Ap", stroke: (paint: blue, dash: "dashed"))
    line("B", "Bp", stroke: (paint: blue, dash: "dashed"))
    line("A", "B", stroke: red)
    line("Ap", "Bp", stroke: green)
    (ctz.points)("A", "B", "Ap", "Bp")
    (ctz.labels)("A", "B", A: "above", B: "above")
  },
  length: 0.75cm,
)

== Homothety (Scaling) — `scale`

Scale a point from a center:

#example(
  [```typst
  #cetz.canvas(length: 0.7cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(O: (2, 2),
              A: (1, 3), B: (3, 3.5), C: (2, 1))
    (ctz.scale)("Ap", "A", "O", 1.8)
    (ctz.scale)("Bp", "B", "O", 1.8)
    (ctz.scale)("Cp", "C", "O", 1.8)

    line("A", "B", "C", "A", stroke: blue)
    line("Ap", "Bp", "Cp", "Ap", stroke: red)

    line("O", "A", stroke: gray + 0.5pt)
    line("O", "Ap", stroke: gray + 0.5pt)

    (ctz.points)("O", "A", "B", "C", "Ap", "Bp", "Cp")
    (ctz.labels)("O", O: "below")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(O: (2, 2), A: (1, 3), B: (3, 3.5), C: (2, 1))
    (ctz.scale)("A'", "A", "O", 1.8)
    (ctz.scale)("B'", "B", "O", 1.8)
    (ctz.scale)("C'", "C", "O", 1.8)
    line("A", "B", "C", "A", stroke: blue)
    line("A'", "B'", "C'", "A'", stroke: red)
    line("O", "A", stroke: gray + 0.5pt)
    line("O", "A'", stroke: gray + 0.5pt)
    (ctz.points)("O", "A", "B", "C", "A'", "B'", "C'")
    (ctz.labels)("O", O: "below")
  },
  length: 0.7cm,
)

== Projection — `project`

Project a point onto a line:

#example(
  [```typst
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (1, 1), B: (5, 2),
              P: (3, 4))
    (ctz.project)("Pp", "P", "A", "B")

    line("A", "B", stroke: black)
    line("P", "Pp", stroke: (paint: blue, dash: "dashed"))
    (ctz.mark-right-angle)("P", "Pp", "A", size: 0.3)

    (ctz.points)("A", "B", "P", "Pp")
    (ctz.labels)("A", "B", "P",
      A: "left", B: "right", P: "above")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (1, 1), B: (5, 2), P: (3, 4))
    (ctz.project)("Pp", "P", "A", "B")
    line("A", "B", stroke: black)
    line("P", "Pp", stroke: (paint: blue, dash: "dashed"))
    (ctz.mark-right-angle)("P", "Pp", "A", size: 0.3)
    (ctz.points)("A", "B", "P", "Pp")
    (ctz.labels)("A", "B", "P", A: "left", B: "right", P: "above")
  },
)

#pagebreak()

// ==============================================================================
// DRAWING & STYLING
// ==============================================================================

= Drawing & Styling

== Points — `points`

Draw point markers:

```typst
(ctz.points)("A", "B", "C")
```

== Labels — `labels`

Add labels with automatic positioning:

```typst
(ctz.labels)("A", "B", "C",
  A: "below left",
  B: "below right",
  C: "above")
```

Position keywords: `"above"`, `"below"`, `"left"`, `"right"`, and combinations like `"above left"`.

For fine control, use offset tuples:

```typst
(ctz.labels)("A",
  A: (pos: "below", offset: (0.1, -0.2)))
```

== Global Styling — `style`

Set default appearance for all elements:

#example(
  [```typst
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    (ctz.init)()

    // Set global point style
    (ctz.style)(point: (
      shape: "circle",
      size: 0.08,
      fill: blue,
      stroke: none
    ))

    (ctz.pts)(A: (0, 0), B: (4, 0),
              C: (2, 3), D: (2, 1.5))
    (ctz.polygon)("A", "B", "C", stroke: black)

    (ctz.points)("A", "B", "C", "D")
    (ctz.labels)("A", "B", "C", "D",
      A: "below", B: "below",
      C: "above", D: "left")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.style)(point: (
      shape: "circle",
      size: 0.08,
      fill: blue,
      stroke: none,
    ))
    (ctz.pts)(A: (0, 0), B: (4, 0), C: (2, 3), D: (2, 1.5))
    (ctz.polygon)("A", "B", "C", stroke: black)
    (ctz.points)("A", "B", "C", "D")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "D",
      A: "below",
      B: "below",
      C: "above",
      D: "left",
    )
  },
)

Point shapes: `"cross"`, `"dot"`, `"circle"`, `"plus"`, `"square"`, `"diamond"`, `"triangle"`.

== Angle Marking — `angle`

Mark and label angles:

#example(
  [```typst
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (4, 0), C: (1, 3))
    line("A", "B", "C", "A", stroke: black)

    (ctz.angle)("A", "B", "C",
      label: $alpha$,
      radius: 0.6,
      fill: blue.lighten(70%),
      stroke: blue)

    (ctz.angle)("B", "C", "A",
      label: $beta$,
      radius: 0.5,
      fill: red.lighten(70%),
      stroke: red)

    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C",
      A: "below left", B: "below right", C: "above")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (4, 0), C: (1, 3))
    line("A", "B", "C", "A", stroke: black)
    (ctz.angle)(
      "A",
      "B",
      "C",
      label: $alpha$,
      radius: 0.6,
      fill: blue.lighten(70%),
      stroke: blue,
    )
    (ctz.angle)(
      "B",
      "C",
      "A",
      label: $beta$,
      radius: 0.5,
      fill: red.lighten(70%),
      stroke: red,
    )
    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C", A: "below left", B: "below right", C: "above")
  },
)

=== Angle Label Positioning

The angle label is automatically placed along the *angle bisector* (the line that divides the angle in half). You can fine-tune the label position using:

- `radius`: Distance from vertex to the arc
- `label-radius`: Distance from vertex to the label (default: `radius + 0.2`)
- `label-offset`: A tuple `(along, perp)` for fine positioning:
  - `along`: Moves label along the bisector (positive = farther from vertex, negative = closer)
  - `perp`: Moves label perpendicular to bisector (positive = counterclockwise, negative = clockwise)

The offset is relative to the bisector's coordinate system, not the canvas axes.

*Example with offset:*

```typst
(ctz.angle)("A", "B", "C",
  label: $alpha$,
  radius: 0.6,
  label-radius: 0.9,      // Label at distance 0.9 from vertex
  label-offset: (0.1, 0.15),  // Shift slightly outward and counterclockwise
  fill: blue.lighten(70%))
```

== Segment Marks — `mark-segment`

Mark equal segments with tick marks:

#example(
  [```typst
  #cetz.canvas(length: 0.75cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (5, 0),
              C: (2.5, 4), D: (2.5, 2))
    line("A", "B", "C", "A", stroke: black)
    line("C", "D", stroke: blue)
    line("D", "A", stroke: blue)
    line("D", "B", stroke: blue)

    (ctz.mark-segment)("C", "D", mark: 1)
    (ctz.mark-segment)("D", "A", mark: 2)
    (ctz.mark-segment)("D", "B", mark: 2)

    (ctz.points)("A", "B", "C", "D")
    (ctz.labels)("A", "B", "C", "D",
      A: "below left", B: "below right",
      C: "above", D: "left")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (5, 0), C: (2.5, 4), D: (2.5, 2))
    line("A", "B", "C", "A", stroke: black)
    line("C", "D", stroke: blue)
    line("D", "A", stroke: blue)
    line("D", "B", stroke: blue)
    (ctz.mark-segment)("C", "D", mark: 1)
    (ctz.mark-segment)("D", "A", mark: 2)
    (ctz.mark-segment)("D", "B", mark: 2)
    (ctz.points)("A", "B", "C", "D")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "D",
      A: "below left",
      B: "below right",
      C: "above",
      D: "left",
    )
  },
  length: 0.75cm,
)

== Right Angle Marks — `mark-right-angle`

Mark 90° angles:

#example(
  [```typst
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 0), B: (4, 0), C: (4, 3))
    line("A", "B", "C", "A", stroke: black)

    (ctz.mark-right-angle)("A", "B", "C",
      size: 0.35,
      color: blue,
      fill: blue.lighten(80%))

    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C",
      A: "below left", B: "below right", C: "above right")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 0), B: (4, 0), C: (4, 3))
    line("A", "B", "C", "A", stroke: black)
    (ctz.mark-right-angle)(
      "A",
      "B",
      "C",
      size: 0.35,
      color: blue,
      fill: blue.lighten(80%),
    )
    (ctz.points)("A", "B", "C")
    (ctz.labels)(
      "A",
      "B",
      "C",
      A: "below left",
      B: "below right",
      C: "above right",
    )
  },
)

#pagebreak()

// ==============================================================================
// GRID & AXES
// ==============================================================================

= Grid & Axes

== Basic Grid — `grid`

Draw a coordinate grid:

#example(
  [```typst
  #cetz.canvas(length: 0.6cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.grid)(xmin: -2, xmax: 5,
               ymin: -1, ymax: 4,
               stroke: gray.lighten(50%))

    (ctz.pts)(A: (1, 2), B: (4, 3))
    line("A", "B", stroke: blue + 1pt)

    (ctz.points)("A", "B")
    (ctz.labels)("A", "B",
      A: "below", B: "above")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.grid)(xmin: -2, xmax: 5, ymin: -1, ymax: 4, stroke: gray.lighten(50%))
    (ctz.pts)(A: (1, 2), B: (4, 3))
    line("A", "B", stroke: blue + 1pt)
    (ctz.points)("A", "B")
    (ctz.labels)("A", "B", A: "below", B: "above")
  },
  length: 0.6cm,
)

== Axes — `axes`

Draw X and Y axes with labels:

#example(
  [```typst
  #cetz.canvas(length: 0.6cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.axes)(xmin: -3, xmax: 4,
               ymin: -2, ymax: 3,
               x-label: $x$,
               y-label: $y$,
               origin-label: $O$)

    (ctz.pts)(P: (2, 2))
    (ctz.points)("P")
    (ctz.labels)("P", P: "above right")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.axes)(
      xmin: -3,
      xmax: 4,
      ymin: -2,
      ymax: 3,
      x-label: $x$,
      y-label: $y$,
      origin-label: $O$,
    )
    (ctz.pts)(P: (2, 2))
    (ctz.points)("P")
    (ctz.labels)("P", P: "above right")
  },
  length: 0.6cm,
)

== Grid with Subdivisions

Add finer sub-grid lines:

#example(
  [```typst
  #cetz.canvas(length: 0.55cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.grid)(xmin: -2, xmax: 3,
               ymin: -1, ymax: 3,
               sub: true,
               sub-xstep: 0.5,
               sub-ystep: 0.5,
               sub-stroke: luma(200) + 0.25pt,
               stroke: gray + 0.5pt)

    (ctz.axes)(xmin: -2, xmax: 3,
               ymin: -1, ymax: 3,
               labels: true,
               ticks: true)
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.grid)(
      xmin: -2,
      xmax: 3,
      ymin: -1,
      ymax: 3,
      sub: true,
      sub-xstep: 0.5,
      sub-ystep: 0.5,
      sub-stroke: luma(200) + 0.25pt,
      stroke: gray + 0.5pt,
    )
    (ctz.axes)(xmin: -2, xmax: 3, ymin: -1, ymax: 3, labels: true, ticks: true)
  },
  length: 0.55cm,
)

#pagebreak()

// ==============================================================================
// CLIPPING
// ==============================================================================

= Clipping

When drawing extended lines (like altitudes or angle bisectors that go beyond triangle sides), you may want to clip them to a viewing region. `ctz-euclide` provides mathematical line clipping using the Cohen-Sutherland algorithm.

== Global Clipping (Recommended)

Set a clip region once, then all `line` commands automatically clip:

#example(
  [```typst
  #cetz.canvas(length: 0.6cm, {
    import cetz.draw: *
    (ctz.init)()

    (ctz.pts)(A: (0, 1), B: (4, 2), C: (2, 4))

    // Set global clip region
    (ctz.set-clip)(-1, 0, 5, 5)
    (ctz.show-clip)(stroke: gray)

    // These lines auto-clip to bounds
    (ctz.line)("A", "B", add: (5, 5), stroke: blue)
    (ctz.line)("B", "C", add: (5, 5), stroke: red)
    (ctz.line)("C", "A", add: (5, 5), stroke: green)

    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C",
      A: "left", B: "right", C: "above")
  })
  ```],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.pts)(A: (0, 1), B: (4, 2), C: (2, 4))
    (ctz.set-clip)(-1, 0, 5, 5)
    (ctz.show-clip)(stroke: gray)
    (ctz.line)("A", "B", add: (5, 5), stroke: blue)
    (ctz.line)("B", "C", add: (5, 5), stroke: red)
    (ctz.line)("C", "A", add: (5, 5), stroke: green)
    (ctz.points)("A", "B", "C")
    (ctz.labels)("A", "B", "C", A: "left", B: "right", C: "above")
  },
  length: 0.6cm,
)

API:
- `(ctz.set-clip)(xmin, ymin, xmax, ymax)` — Set global clip region
- `(ctz.show-clip)(stroke: ...)` — Draw the clip boundary
- `(ctz.line)(a, b, add: (n, m), stroke: ...)` — Extended line (auto-clips)
- `(ctz.seg)(a, b, stroke: ...)` — Simple segment (auto-clips)
- `(ctz.clear-clip)()` — Remove clipping

== Manual Clipping

For per-line control, specify bounds directly:

```typst
(ctz.clipped-line-add)("A", "B", xmin, ymin, xmax, ymax,
  add: (10, 10), stroke: blue)
```

#pagebreak()

// ==============================================================================
// API REFERENCE
// ==============================================================================

= API Reference

== Initialization

/ `(ctz.init)()`: Initialize the point registry and coordinate resolver. *Required* at the start of every figure.

== Point Definitions

/ `(ctz.pts)(...)`: Define points with named arguments: `(ctz.pts)(A: (0, 0), B: (3, 4))`

/ `(ctz.midpoint)(name, a, b)`: Midpoint of segment AB

/ `(ctz.linear)(name, a, b, k)`: Point P = A + k(B - A)

/ `(ctz.barycentric)(name, a, b, c, wa, wb, wc)`: Barycentric combination

/ `(ctz.regular-polygon)(names, center, first)`: Regular polygon vertices

/ `(ctz.point-on-circle)(name, center, radius, angle)`: Point on circle at angle (degrees)

/ `(ctz.equilateral)(name, a, b)`: Third vertex of equilateral triangle

/ `(ctz.square)(c, d, a, b)`: Complete a square given two vertices

/ `(ctz.golden)(name, a, b)`: Golden ratio point on AB

== Line Constructions

/ `(ctz.perp)(p1, p2, (a, b), through)`: Perpendicular to line AB through point

/ `(ctz.para)(p1, p2, (a, b), through)`: Parallel to line AB through point

/ `(ctz.bisect)(p1, p2, a, vertex, c)`: Angle bisector at vertex

/ `(ctz.mediator)(p1, p2, a, b)`: Perpendicular bisector of AB

== Intersections

/ `(ctz.ll)(name, (a, b), (c, d))`: Line-line intersection

/ `(ctz.lc)(names, (a, b), circle)`: Line-circle intersections. Circle: `(center: "O", through: "A")` or `(center: "O", radius: r)`

/ `(ctz.cc)(names, circle1, circle2)`: Circle-circle intersections

== Triangle Centers

/ `(ctz.centroid)(name, a, b, c)`: Center of mass (medians intersection)

/ `(ctz.circumcenter)(name, a, b, c)`: Circumscribed circle center

/ `(ctz.incenter)(name, a, b, c)`: Inscribed circle center

/ `(ctz.orthocenter)(name, a, b, c)`: Altitudes intersection

/ `(ctz.euler)(name, a, b, c)`: Nine-point circle center

/ `(ctz.lemoine)(name, a, b, c)`: Lemoine point (symmedian point)

/ `(ctz.nagel)(name, a, b, c)`: Nagel point

/ `(ctz.gergonne)(name, a, b, c)`: Gergonne point

/ `(ctz.spieker)(name, a, b, c)`: Spieker center

/ `(ctz.feuerbach)(name, a, b, c)`: Feuerbach point

/ `(ctz.mittenpunkt)(name, a, b, c)`: Mittenpunkt

/ `(ctz.excenter)(name, a, b, c, vertex: "a")`: Excenter opposite to vertex

== Special Triangles

/ `(ctz.medial)(ma, mb, mc, a, b, c)`: Medial triangle (midpoints)

/ `(ctz.orthic)(ha, hb, hc, a, b, c)`: Orthic triangle (feet of altitudes)

/ `(ctz.intouch)(ta, tb, tc, a, b, c)`: Intouch triangle (incircle tangency points)

== Transformations

/ `(ctz.rotate)(name, source, center, angle)`: Rotate point around center (degrees)

/ `(ctz.reflect)(name, source, a, b)`: Reflect point across line AB

/ `(ctz.translate)(name, source, vector)`: Translate by vector `(dx, dy)` or `(a, b)`

/ `(ctz.scale)(name, source, center, factor)`: Homothety (scale from center)

/ `(ctz.project)(name, source, a, b)`: Orthogonal projection onto line AB

/ `(ctz.symmetry)(name, source, center)`: Central symmetry

/ `(ctz.inversion)(name, source, center, radius)`: Circle inversion

== Drawing

/ `(ctz.points)(...)`: Draw point markers: `(ctz.points)("A", "B", "C")`

/ `(ctz.labels)(...)`: Label points with positioning: `(ctz.labels)("A", "B", A: "left", B: "right")`

/ `(ctz.polygon)(...)`: Draw polygon: `(ctz.polygon)("A", "B", "C", close: true, stroke: black)`

/ `(ctz.segment)(a, b, ...)`: Draw segment with optional arrows: `arrows: "<->"`, `dim: $5$`

/ `(ctz.line-add)(a, b, add: (n, m), ...)`: Extended line beyond AB

/ `(ctz.circle-r)(center, radius, ...)`: Circle with explicit radius

/ `(ctz.circle-through)(center, through, ...)`: Circle through point

/ `(ctz.circle-diameter)(a, b, ...)`: Circle with AB as diameter

/ `(ctz.circumcircle)(a, b, c, ...)`: Circumscribed circle of triangle

/ `(ctz.incircle)(a, b, c, ...)`: Inscribed circle of triangle

/ `(ctz.semicircle)(a, b, above: true, ...)`: Semicircle with AB as diameter

/ `(ctz.sector)(center, start, end, ...)`: Circular sector

/ `(ctz.arc)(center, start, end, ...)`: Arc through two points

/ `(ctz.arc-r)(center, radius, start-angle, end-angle, ...)`: Arc with explicit angles

== Marking & Annotation

/ `(ctz.angle)(vertex, a, b, ...)`: Mark angle at vertex. Options: `label`, `radius`, `fill`, `stroke`

/ `(ctz.mark-segment)(a, b, mark: n, ...)`: Tick marks for equal segments (n = 1, 2, 3, ...)

/ `(ctz.mark-right-angle)(a, vertex, c, ...)`: Mark 90° angle

/ `(ctz.fill-angle)(vertex, a, c, ...)`: Fill angle without border

/ `(ctz.label-segment)(a, b, label: $5$, ...)`: Label a segment

== Styling

/ `(ctz.style)(...)`: Set global defaults. Example: `(ctz.style)(point: (shape: "dot", size: 0.08))`

== Grid & Axes

/ `(ctz.grid)(...)`: Draw grid. Options: `xmin`, `xmax`, `ymin`, `ymax`, `xstep`, `ystep`, `sub`, `stroke`

/ `(ctz.axes)(...)`: Draw axes with labels and ticks

/ `(ctz.hline)(y, xmin: ..., xmax: ..., stroke: ...)`: Horizontal line

/ `(ctz.vline)(x, ymin: ..., ymax: ..., stroke: ...)`: Vertical line

/ `(ctz.text)(x, y, content, ...)`: Place text at coordinates

== Clipping

/ `(ctz.set-clip)(xmin, ymin, xmax, ymax)`: Set global clip region

/ `(ctz.show-clip)(stroke: ...)`: Draw clip boundary

/ `(ctz.line)(a, b, add: (n, m), stroke: ...)`: Auto-clipped extended line

/ `(ctz.seg)(a, b, stroke: ...)`: Auto-clipped segment

/ `(ctz.clear-clip)()`: Remove global clipping

/ `(ctz.clipped-line-add)(a, b, xmin, ymin, xmax, ymax, ...)`: Manual per-line clipping

#pagebreak()

// ==============================================================================
// FIGURES GALLERY
// ==============================================================================

= Figures Gallery

The following pages showcase various geometric constructions and their capabilities.

// Figure 1: Complete Triangle Centers
#full-figure(
  [Complete Triangle Centers],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.style)(point: (shape: "dot", size: 0.07, fill: black))

    (ctz.pts)(A: (0, 0), B: (7, 0.5), C: (2.5, 5))
    line("A", "B", "C", "A", stroke: black + 1.5pt)

    (ctz.centroid)("G", "A", "B", "C")
    (ctz.circumcenter)("O", "A", "B", "C")
    (ctz.incenter)("I", "A", "B", "C")
    (ctz.orthocenter)("H", "A", "B", "C")

    // Euler line
    line("H", "O", stroke: (
      paint: red.darken(20%),
      dash: "dashed",
      thickness: 1.2pt,
    ))

    // Circumcircle
    circle("O", "A", stroke: blue + 1pt)

    // Incircle
    (ctz.incircle)("A", "B", "C", stroke: green.darken(20%) + 1pt)

    // Medians
    (ctz.midpoint)("Ma", "B", "C")
    (ctz.midpoint)("Mb", "A", "C")
    (ctz.midpoint)("Mc", "A", "B")
    line("A", "Ma", stroke: gray + 0.7pt)
    line("B", "Mb", stroke: gray + 0.7pt)
    line("C", "Mc", stroke: gray + 0.7pt)

    (ctz.points)("A", "B", "C", "G", "O", "I", "H")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "G",
      "O",
      "I",
      "H",
      A: "below left",
      B: "below right",
      C: "above",
      G: (pos: "right", offset: (0.15, 0)),
      O: (pos: "right", offset: (0.15, 0)),
      I: (pos: "above left", offset: (-0.1, 0.1)),
      H: (pos: "left", offset: (-0.15, 0)),
    )
  },
  caption: [
    Euler Line (red dashed): $O - G - H$ \
    Circumcircle (blue), Incircle (green), Medians (gray)
  ],
  code: ```typst
(ctz.pts)(A: (0, 0), B: (7, 0.5), C: (2.5, 5))
(ctz.centroid)("G", "A", "B", "C")
(ctz.circumcenter)("O", "A", "B", "C")
(ctz.incenter)("I", "A", "B", "C")
(ctz.orthocenter)("H", "A", "B", "C")

line("A", "B", "C", "A", stroke: black + 1.5pt)
line("H", "O", stroke: (paint: red, dash: "dashed"))
circle("O", "A", stroke: blue + 1pt)
(ctz.incircle)("A", "B", "C", stroke: green + 1pt)
```,
  length: 0.95cm,
)

// Figure 2: Nine-Point Circle
#full-figure(
  [Nine-Point (Euler) Circle],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.style)(point: (
      shape: "circle",
      size: 0.06,
      stroke: black + 0.8pt,
      fill: white,
    ))

    (ctz.pts)(A: (0, 0), B: (7, 0), C: (2, 5))
    line("A", "B", "C", "A", stroke: black + 1.5pt)

    // Midpoints of sides
    (ctz.midpoint)("Ma", "B", "C")
    (ctz.midpoint)("Mb", "A", "C")
    (ctz.midpoint)("Mc", "A", "B")

    // Feet of altitudes
    (ctz.project)("Ha", "A", "B", "C")
    (ctz.project)("Hb", "B", "A", "C")
    (ctz.project)("Hc", "C", "A", "B")

    // Orthocenter and midpoints to vertices
    (ctz.orthocenter)("H", "A", "B", "C")
    (ctz.midpoint)("MHa", "H", "A")
    (ctz.midpoint)("MHb", "H", "B")
    (ctz.midpoint)("MHc", "H", "C")

    // Nine-point circle
    (ctz.euler)("N", "A", "B", "C")
    circle("N", "Ma", stroke: purple.darken(10%) + 1.2pt)

    // Draw altitudes
    line("A", "Ha", stroke: blue.lighten(30%) + 0.7pt)
    line("B", "Hb", stroke: blue.lighten(30%) + 0.7pt)
    line("C", "Hc", stroke: blue.lighten(30%) + 0.7pt)

    (ctz.points)(
      "A",
      "B",
      "C",
      "N",
      "Ma",
      "Mb",
      "Mc",
      "Ha",
      "Hb",
      "Hc",
      "MHa",
      "MHb",
      "MHc",
      "H",
    )
    (ctz.labels)(
      "A",
      "B",
      "C",
      "N",
      A: "below left",
      B: "below right",
      C: "above",
      N: (pos: "below", offset: (0, -0.15)),
    )

  },
  caption: [
    The nine-point circle passes through: \
    • Midpoints of sides ($M_a, M_b, M_c$) \
    • Feet of altitudes ($H_a, H_b, H_c$) \
    • Midpoints from H to vertices
  ],
  code: ```typst
(ctz.pts)(A: (0, 0), B: (7, 0), C: (2, 5))
(ctz.midpoint)("Ma", "B", "C")
(ctz.midpoint)("Mb", "A", "C")
(ctz.midpoint)("Mc", "A", "B")
(ctz.project)("Ha", "A", "B", "C")
(ctz.project)("Hb", "B", "A", "C")
(ctz.project)("Hc", "C", "A", "B")
(ctz.orthocenter)("H", "A", "B", "C")
(ctz.midpoint)("MHa", "H", "A")
(ctz.midpoint)("MHb", "H", "B")
(ctz.midpoint)("MHc", "H", "C")
(ctz.euler)("N", "A", "B", "C")
circle("N", "Ma", stroke: purple.darken(10%) + 1.2pt)
```,
  length: 0.9cm,
)

// Figure 3: Regular Pentagon Construction
#full-figure(
  [Regular Pentagon with Diagonals],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.style)(point: (shape: "dot", size: 0.08, fill: black))

    (ctz.pts)(O: (0, 0), V1: (4, 0))
    (ctz.regular-polygon)(("A", "B", "C", "D", "E"), "O", "V1")

    // Pentagon
    line("A", "B", "C", "D", "E", "A", stroke: black + 1.5pt)

    // All diagonals
    line("A", "C", stroke: blue + 0.8pt)
    line("A", "D", stroke: blue + 0.8pt)
    line("B", "D", stroke: red + 0.8pt)
    line("B", "E", stroke: red + 0.8pt)
    line("C", "E", stroke: green.darken(20%) + 0.8pt)

    // Center
    circle("O", radius: 4, stroke: gray.lighten(50%) + 0.5pt)

    (ctz.points)("A", "B", "C", "D", "E", "O")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "D",
      "E",
      A: "right",
      B: (pos: "above right", offset: (0.1, 0.1)),
      C: "above left",
      D: "below left",
      E: "below right",
    )
    (ctz.labels)("O", O: (pos: "below", offset: (0, -0.15)))
  },
  caption: [
    Regular pentagon with all diagonals forming a pentagram
  ],
  code: ```typst
(ctz.pts)(O: (0, 0), V1: (4, 0))
(ctz.regular-polygon)(("A", "B", "C", "D", "E"), "O", "V1")
line("A", "B", "C", "D", "E", "A", stroke: black + 1.5pt)
line("A", "C", stroke: blue + 0.8pt)
line("A", "D", stroke: blue + 0.8pt)
line("B", "D", stroke: red + 0.8pt)
line("B", "E", stroke: red + 0.8pt)
line("C", "E", stroke: green.darken(20%) + 0.8pt)
circle("O", radius: 4, stroke: gray.lighten(50%) + 0.5pt)
```,
  length: 1cm,
)

// Figure 4: Inscribed Angle Theorem
#full-figure(
  [Inscribed Angle Theorem],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.style)(point: (shape: "cross", size: 0.11, stroke: black + 1.2pt))

    (ctz.pts)(O: (0, 0), R: (4, 0))
    circle("O", radius: 4, stroke: black + 1.2pt)

    // Place points on circle: A left, C right, B at bottom
    (ctz.rotate)("A", "R", "O", 150)
    (ctz.rotate)("C", "R", "O", 30)
    (ctz.rotate)("B", "R", "O", 250)

    // Inscribed angle at B (looking up at chord AC)
    line("A", "B", stroke: blue + 1.2pt)
    line("B", "C", stroke: blue + 1.2pt)
    (ctz.angle)(
      "B",
      "A",
      "C",
      label: $alpha$,
      radius: 0.8,
      fill: blue.lighten(70%),
      stroke: blue,
    )

    // Central angle at O (same chord AC)
    line("O", "A", stroke: red + 1.2pt)
    line("O", "C", stroke: red + 1.2pt)
    (ctz.angle)(
      "O",
      "A",
      "C",
      label: $2alpha$,
      radius: 1.2,
      fill: red.lighten(70%),
      stroke: red,
    )

    // Arc
    line("A", "C", stroke: gray.lighten(40%) + 0.8pt)

    (ctz.points)("O", "A", "B", "C")
    (ctz.labels)(
      "O",
      "A",
      "B",
      "C",
      O: (pos: "below", offset: (0, -0.15)),
      A: "left",
      B: "below left",
      C: "right",
    )

  },
  caption: [
    Inscribed angle theorem: $angle A B C = 1/2 angle A O C$
  ],
  code: ```typst
(ctz.pts)(O: (0, 0), R: (4, 0))
circle("O", radius: 4, stroke: black + 1.2pt)
(ctz.rotate)("A", "R", "O", 150)
(ctz.rotate)("C", "R", "O", 30)
(ctz.rotate)("B", "R", "O", 250)
line("A", "B", stroke: blue + 1.2pt)
line("B", "C", stroke: blue + 1.2pt)
(ctz.angle)("B", "A", "C", label: $alpha$, radius: 0.8,
  fill: blue.lighten(70%), stroke: blue)
line("O", "A", stroke: red + 1.2pt)
line("O", "C", stroke: red + 1.2pt)
(ctz.angle)("O", "A", "C", label: $2alpha$, radius: 1.2,
  fill: red.lighten(70%), stroke: red)
```,
  length: 1cm,
)

// Figure 5: Apollonius Circle Construction
#full-figure(
  [Geometric Locus: Apollonius Circle],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.style)(point: (shape: "dot", size: 0.08, fill: black))

    (ctz.pts)(A: (-3, 0), B: (3, 0))

    // For k = 2, construct Apollonius circle
    // Locus of points P such that PA/PB = 2

    // External division point
    let k = 2
    (ctz.pts)(E: (-5, 0))

    // Internal division point
    (ctz.pts)(I: (-1, 0))

    // Center is midpoint of E and I
    (ctz.midpoint)("O", "E", "I")

    // Circle through E and I
    circle("O", "E", stroke: purple.darken(10%) + 1.3pt)

    // Show some points on the circle
    (ctz.rotate)("P1", "E", "O", 60)
    (ctz.rotate)("P2", "E", "O", 120)
    (ctz.rotate)("P3", "E", "O", -60)
    (ctz.rotate)("P4", "E", "O", -120)

    // Draw radii from P1 to A and B
    line("P1", "A", stroke: blue + 0.8pt)
    line("P1", "B", stroke: red + 0.8pt)

    // Base points
    line("A", "B", stroke: black + 1pt)

    (ctz.points)("A", "B", "O", "E", "I", "P1", "P2", "P3", "P4")
    (ctz.labels)(
      "A",
      "B",
      "E",
      "I",
      "P1",
      A: "below",
      B: "below",
      E: "below left",
      I: "below",
      P1: (pos: "above", offset: (0, 0.15)),
    )
    (ctz.labels)("O", O: (pos: "below", offset: (0, -0.15)))
  },
  caption: [
    Apollonius circle: locus of points $P$ where $P A / P B = 2$ \
    Points $E$ (external) and $I$ (internal) divide $A B$ in ratio $2:1$
  ],
  code: ```typst
(ctz.pts)(A: (-3, 0), B: (3, 0))
let k = 2
(ctz.pts)(E: (-5, 0))
(ctz.pts)(I: (-1, 0))
(ctz.midpoint)("O", "E", "I")
circle("O", "E", stroke: purple.darken(10%) + 1.3pt)
(ctz.rotate)("P1", "E", "O", 60)
line("P1", "A", stroke: blue + 0.8pt)
line("P1", "B", stroke: red + 0.8pt)
line("A", "B", stroke: black + 1pt)
```,
  length: 0.95cm,
)

// Figure 6: Orthocenter and Altitudes with Clipping
#full-figure(
  [Orthocenter with Extended Altitudes],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.style)(point: (shape: "cross", size: 0.1, stroke: black + 1.2pt))

    (ctz.pts)(A: (0, 0), B: (8, 0), C: (2.5, 5.5))

    // Set clip region
    (ctz.set-clip)(-1.5, -1.5, 9.5, 7)

    // Triangle
    line("A", "B", "C", "A", stroke: black + 1.5pt)

    // Extended altitudes (clipped)
    (ctz.perp)("Ha1", "Ha2", ("B", "C"), "A")
    (ctz.perp)("Hb1", "Hb2", ("A", "C"), "B")
    (ctz.perp)("Hc1", "Hc2", ("A", "B"), "C")

    (ctz.line)("A", "Ha1", add: (1, 1.5), stroke: blue + 1pt)
    (ctz.line)("B", "Hb1", add: (1, 1.5), stroke: red + 1pt)
    (ctz.line)("C", "Hc1", add: (1, 2.5), stroke: green.darken(20%) + 1pt)

    // Orthocenter
    (ctz.orthocenter)("H", "A", "B", "C")

    // Feet of altitudes
    (ctz.project)("Ha", "A", "B", "C")
    (ctz.project)("Hb", "B", "A", "C")
    (ctz.project)("Hc", "C", "A", "B")

    // Right angle marks
    (ctz.mark-right-angle)("A", "Ha", "B", size: 0.3)
    (ctz.mark-right-angle)("B", "Hb", "C", size: 0.3)
    (ctz.mark-right-angle)("C", "Hc", "A", size: 0.3)

    (ctz.points)("A", "B", "C", "H", "Ha", "Hb", "Hc")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "H",
      A: "below left",
      B: "below right",
      C: "above",
      H: (pos: "below right", offset: (0.1, -0.05)),
    )

  },
  caption: [
    Altitudes extended beyond the triangle, clipped to viewing region
  ],
  code: ```typst
(ctz.pts)(A: (0, 0), B: (8, 0), C: (2.5, 5.5))
(ctz.set-clip)(-1.5, -1.5, 9.5, 7)
line("A", "B", "C", "A", stroke: black + 1.5pt)
(ctz.perp)("Ha1", "Ha2", ("B", "C"), "A")
(ctz.perp)("Hb1", "Hb2", ("A", "C"), "B")
(ctz.perp)("Hc1", "Hc2", ("A", "B"), "C")
(ctz.line)("A", "Ha1", add: (1, 1.5), stroke: blue + 1pt)
(ctz.line)("B", "Hb1", add: (1, 1.5), stroke: red + 1pt)
(ctz.line)("C", "Hc1", add: (1, 2.5), stroke: green.darken(20%) + 1pt)
(ctz.orthocenter)("H", "A", "B", "C")
(ctz.mark-right-angle)("A", "Ha", "B", size: 0.3)
```,
  length: 0.85cm,
)

// Figure 7: Gergonne Point
#full-figure(
  [Gergonne Point and Contact Triangle],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.style)(point: (shape: "dot", size: 0.08, fill: black))

    // Triangle vertices
    (ctz.pts)(A: (0, 0), B: (9, 0), C: (3.6, 6))

    // Set clip region for extended lines
    (ctz.set-clip)(-1.5, -1.5, 10.5, 8)

    // Gergonne point
    (ctz.gergonne)("Ge", "A", "B", "C")

    // Contact points with incircle (intouch triangle)
    (ctz.intouch)("C1", "C2", "C3", "A", "B", "C")

    // Extended lines from vertices through contact points (clipped)
    (ctz.line)("A", "C1", add: (0.25, 0.25), stroke: teal + 1pt)
    (ctz.line)("B", "C2", add: (0.25, 0.25), stroke: teal + 1pt)
    (ctz.line)("C", "C3", add: (0.25, 0.25), stroke: teal + 1pt)

    // Triangle outline
    line("A", "B", "C", "A", stroke: black + 1.5pt)

    // Incircle
    (ctz.incircle)("A", "B", "C", stroke: orange + 1.2pt)

    // Draw segments to show contact triangle
    line("C1", "C2", stroke: orange.darken(20%) + 0.8pt)
    line("C2", "C3", stroke: orange.darken(20%) + 0.8pt)
    line("C3", "C1", stroke: orange.darken(20%) + 0.8pt)

    (ctz.points)("A", "B", "C", "C1", "C2", "C3", "Ge")
    (ctz.labels)("B", "C", "Ge", B: "below", C: "above", Ge: (
      pos: "below right",
      offset: (0.15, -0.1),
    ))
    (ctz.labels)("C1", "C2", "C3", C1: "above", C2: "below right", C3: "left")
  },
  caption: [
    Gergonne point $G_e$: concurrence of lines from vertices \
    to contact points of incircle with opposite sides
  ],
  code: ```typst
(ctz.pts)(A: (0, 0), B: (9, 0), C: (3.6, 6))
(ctz.set-clip)(-1.5, -1.5, 10.5, 8)
(ctz.gergonne)("Ge", "A", "B", "C")
(ctz.intouch)("C1", "C2", "C3", "A", "B", "C")
(ctz.line)("A", "C1", add: (0.25, 0.25), stroke: teal + 1pt)
(ctz.line)("B", "C2", add: (0.25, 0.25), stroke: teal + 1pt)
(ctz.line)("C", "C3", add: (0.25, 0.25), stroke: teal + 1pt)
line("A", "B", "C", "A", stroke: black + 1.5pt)
(ctz.incircle)("A", "B", "C", stroke: orange + 1.2pt)
line("C1", "C2", "C3", "C1", stroke: orange.darken(20%) + 0.8pt)
```,
  length: 0.75cm,
)

// Figure 8: Homothety and Symmetry
#full-figure(
  [Homothety and Symmetry Transformations],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.style)(point: (shape: "dot", size: 0.08, fill: black))

    // Original triangle
    (ctz.pts)(A: (0, 0), B: (3, 0), C: (1.5, 2.5))

    // Center of homothety
    (ctz.pts)(O: (5, 1))

    // Homothety with ratio 0.6
    (ctz.scale)("Ah", "A", "O", 0.6)
    (ctz.scale)("Bh", "B", "O", 0.6)
    (ctz.scale)("Ch", "C", "O", 0.6)

    // Symmetry with respect to a line
    (ctz.pts)(L1: (-1, -1), L2: (7, 3))
    (ctz.reflect)("As", "A", "L1", "L2")
    (ctz.reflect)("Bs", "B", "L1", "L2")
    (ctz.reflect)("Cs", "C", "L1", "L2")

    // Draw original triangle
    line("A", "B", "C", "A", stroke: blue + 1.5pt)

    // Draw homothety triangle
    line("Ah", "Bh", "Ch", "Ah", stroke: red + 1.5pt)

    // Draw symmetric triangle
    line("As", "Bs", "Cs", "As", stroke: green.darken(20%) + 1.5pt)

    // Symmetry axis
    line("L1", "L2", stroke: gray + 0.8pt)

    // Lines from center O through corresponding points
    line("O", "A", stroke: blue.lighten(50%) + 0.6pt, stroke-dasharray: (3, 3))
    line("O", "B", stroke: blue.lighten(50%) + 0.6pt, stroke-dasharray: (3, 3))
    line("O", "C", stroke: blue.lighten(50%) + 0.6pt, stroke-dasharray: (3, 3))

    (ctz.points)("A", "B", "C", "O", "Ah", "Bh", "Ch", "As", "Bs", "Cs")
    (ctz.labels)(
      "A",
      "B",
      "C",
      "O",
      A: "below left",
      B: "below right",
      C: "above",
      O: (pos: "right", offset: (0.15, 0)),
    )

  },
  caption: [
    Blue: original $triangle.stroked A B C$ #h(1em) Red: homothety (center $O$, ratio $0.6$) \
    Green: reflection across gray line
  ],
  code: ```typst
(ctz.pts)(A: (0, 0), B: (3, 0), C: (1.5, 2.5))
(ctz.pts)(O: (5, 1))
(ctz.scale)("Ah", "A", "O", 0.6)
(ctz.scale)("Bh", "B", "O", 0.6)
(ctz.scale)("Ch", "C", "O", 0.6)
(ctz.pts)(L1: (-1, -1), L2: (7, 3))
(ctz.reflect)("As", "A", "L1", "L2")
(ctz.reflect)("Bs", "B", "L1", "L2")
(ctz.reflect)("Cs", "C", "L1", "L2")
line("A", "B", "C", "A", stroke: blue + 1.5pt)
line("Ah", "Bh", "Ch", "Ah", stroke: red + 1.5pt)
line("As", "Bs", "Cs", "As", stroke: green.darken(20%) + 1.5pt)
```,
  length: 0.75cm,
)

// Figure 9: Circle Inversion
#full-figure(
  [Circle Inversion Transformation],
  {
    import cetz.draw: *
    (ctz.init)()
    (ctz.style)(point: (shape: "dot", size: 0.08, fill: black))

    // Inversion center and circle
    (ctz.pts)(O: (0, 0), A: (4, 0), P: (6, 0))

    // Inversion circle (radius = 4)
    circle("O", "A", stroke: blue + 1.3pt)

    // Points to invert
    (ctz.pts)(P1: (2, 0), P2: (8, 0), P3: (6, 3))

    // Invert the points (radius = 4, so r² = 16)
    (ctz.inversion)("P1inv", "P1", "O", 4)
    (ctz.inversion)("P2inv", "P2", "O", 4)
    (ctz.inversion)("P3inv", "P3", "O", 4)

    // Draw diameter
    line("O", "P", stroke: gray + 0.8pt)

    // Draw lines from O to original points
    line("O", "P1", stroke: red.lighten(40%) + 0.7pt, stroke-dasharray: (3, 3))
    line("O", "P2", stroke: green.lighten(40%) + 0.7pt, stroke-dasharray: (
      3,
      3,
    ))

    // Show relationship
    line("P1", "P1inv", stroke: red.lighten(60%) + 0.5pt)
    line("P2", "P2inv", stroke: green.lighten(60%) + 0.5pt)

    // Points outside circle invert to inside
    (ctz.points)("O", "A", "P", "P1", "P2", "P3", "P1inv", "P2inv", "P3inv")
    (ctz.labels)(
      "O",
      "A",
      "P1",
      "P2",
      "P3",
      O: "below left",
      A: "below",
      P1: "above",
      P2: "below",
      P3: "above right",
    )
    (ctz.labels)(
      "P1inv",
      "P2inv",
      "P3inv",
      P1inv: (pos: "below", offset: (0, -0.15)),
      P2inv: "above",
      P3inv: (pos: "left", offset: (-0.15, 0)),
    )

  },
  caption: [
    Circle inversion: $O P dot.op O P' = r^2$ where $r$ is the inversion radius \
    Points outside the circle map to inside, and vice versa
  ],
  code: ```typst
(ctz.pts)(O: (0, 0), A: (4, 0), P: (6, 0))
circle("O", "A", stroke: blue + 1.3pt)
(ctz.pts)(P1: (2, 0), P2: (8, 0), P3: (6, 3))
(ctz.inversion)("P1inv", "P1", "O", 4)
(ctz.inversion)("P2inv", "P2", "O", 4)
(ctz.inversion)("P3inv", "P3", "O", 4)
line("O", "P", stroke: gray + 0.8pt)
line("O", "P1", stroke: red.lighten(40%) + 0.7pt, stroke-dasharray: (3, 3))
line("O", "P2", stroke: green.lighten(40%) + 0.7pt, stroke-dasharray: (3, 3))
line("P1", "P1inv", stroke: red.lighten(60%) + 0.5pt)
line("P2", "P2inv", stroke: green.lighten(60%) + 0.5pt)
```,
  length: 0.75cm,
)
