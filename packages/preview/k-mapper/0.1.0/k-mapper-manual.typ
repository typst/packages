// Copyright 2024 Derek Chai.
// Use of this code is governed by a MIT license in the LICENSE.txt file.

#import "k-mapper.typ": *

#let version = "0.1.0"

#let conf(title, doc) = {
  set page(
    paper: "us-letter",
    header: align(
      right + horizon,
      title
    ),
    numbering: "1"
  )
  set par(justify: true)
  set text(
    font: "Linux Libertine",
    size: 11pt,
  )

  // Heading show rules.

  columns(1, doc)
}

#show: doc => conf(
  [`k-mapper` manual\ version #version],
  doc,
)

= `k-mapper` manual

#v(1em)

== Introduction

The `k-mapper` package allows for implementing Karnaugh maps, also known as K-maps, within Typst. The package allows the creation of 2-variable (2 by 2), 3-variable (2 by 4), and 4-variable (4 by 4) Karnaugh maps.

== Usage

To add a Karnaugh map, use the `karnaugh()` function. 

=== Function Parameters

#table(
  columns: (auto, 2fr, auto),
  inset: 10pt,
  stroke: none,

  table.header([*Parameter*], [*Description*], [*Example*]),

  [*`variables`*\ `array`], 
  [The array of variables for the Karnaugh map. 
  
  Between two and four variables may be provided, with the size of the Karnaugh map being automatically determined by the number of variables.],
  [```typst
  ("$A$", "$B$")
  ```],

  [*`manual-terms`*\ `array`],
  [The array of terms for the Karnaugh map, such as `"0"` or `"1"`. 

  *Terms are displayed in the Karnaugh map in order of the array, top-to-bottom, left-to-right.* Note that this is dissimilar to some LaTeX Karnaugh map packages.
  
  There must be exactly enough terms for the corresponding Karnaugh map size; i.e. a 2-variable map must have 4 terms; a 3-variable map must have 8 terms; a 4-variable map must have 16 terms.],
  [```typst
  ("0", "1", "1", "X")
  ```],

  [*`implicants`*\ `array`],
  [The array of implicants for the Karnaugh map.
  
  Each element is itself an array of all cells within the implicant.],
  [```typst
  ((1, 3), (2, 3))
  ```],

  [*`cell-size`*\ `length`],
  [The size of each cell within the Karnaugh map.
  
  Default: `20pt`],
  [```typst
  25pt
  ```],

  [*`stroke`*\ `length`],
  [The width of the Karnaugh map's strokes.
  
  Default: `0.5pt`],
  [```typst
  1pt
  ```],

  [*`colors`*\ `array`],
  [The array of colors to be used for implicants in the Karnaugh map.
  
  Each element in the array is an array of three RGB integers. The first implicant will use the first color in the array, the second implicant the second color, and so on.
  
  There must be at least as many colors as there are implicants.
  
  Default: red, green, blue, yellow, cyan, magenta (cycled twice)],
  [```typst
  // Sets colors to cycle 
  // between red, green,
  // and blue ten times.
  ((255, 0, 0, 
  0, 255, 0, 
  0, 0, 255) * 10).chunks(3)
  ```],

  [*`alpha`*\ `int`],
  [The alpha value of the colors in the Karnaugh map.
  
  Default: `120`],
  [```typst
  80
  ```],

  
)

=== Cell Numbers

Cells in `k-mapper` are numbered top-to-bottom, left-to-right, starting at cell 0 (top-left). Note that the cell numbers do _not_ correspond to the decimal values of the Gray code state the cell represents.

#grid(
  columns: (1fr, 1fr, 1fr),
  align: horizon,
  karnaugh(
    variables: ("", ""),
    manual-terms: ("0", "1", "2", "3")
  ),

  karnaugh(
    variables: ("", "", ""),
    manual-terms: ("0", "1", "2", "3", "4", "5", "6", "7")
  ),

  karnaugh(
    variables: ("", "", "", ""),
    manual-terms: ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11",
    "12", "13", "14", "15")
  )
)

== Examples

#grid(
  columns: (0.5fr, 1fr),
  inset: 10pt, 

  karnaugh(
    variables: ($R$, $S$, $Q_(t-)$),
    manual-terms: ("0", "1", "1", "1", "0", "0", "X", "X"),
    implicants: ((0, 6), (4, 5, 6, 7))
  ),

  [```typst
  #karnaugh(
    variables: ($R$, $S$, $Q_(t-)$),
    manual-terms: (
      "0", "1", 
      "1", "1", 
      "0", "0", 
      "X", "X"
    ),
    implicants: ((0, 6), (4, 5, 6, 7))
  )
  ```],

  karnaugh(
    variables: ($A$, $B$, $C$, $D$),
    manual-terms: ("0", "0", "0", "0", "1", "1", "1", "1", "0", "1", "1", "1",
    "0", "1", "0", "0"),
    implicants: ((4, 5, 6, 7), (9, 13), (6, 7, 10, 11))
  ),

  [```typst
  #karnaugh(
    variables: ($A$, $B$, $C$, $D$),
    manual-terms: (
      "0", "0", "0", "0", 
      "1", "1", "1", "1", 
      "0", "1", "1", "1",
      "0", "1", "0", "0"
    ),
    implicants: ((4, 5, 6, 7), (9, 13), (6, 7, 10, 11))
  )
  ```]
)