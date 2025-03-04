/*
 * Paper template for JACoW conference proceedings
 *
 * Based on the JACoW guide for preparation of papers.
 * See https://jacow.org/ for more information.
 *
 * This file is part of the accelerated-jacow template.
 * Typst universe: https://typst.app/universe/package/accelerated-jacow
 * GitHub repository: https://github.com/eltos/accelerated-jacow
 */

#import "@preview/accelerated-jacow:0.1.1": jacow

#show: paper => jacow(
  // Paper title
  title: [
    Accelerated JAC#lower[o]W paper template\
    for conference proceedings
  ],
  // Author list
  authors: (
    (name: "C. Author", at: "uni", email: "mail@example.com"),
    (name: "P. Coauthor", at: ("uni", "third")),
    (name: "J. Cockcroft", at: ("INP", "third")),
    (name: "C. D. Anderson", at: "INP"),
    (names: ("N. Bohr", "A. Einstein", "M. Curie", "E. Lawrence"), at: "INP"),
  ),
  affiliations: (
    uni: "Town University, City, Country",
    INP: "Insitute of Nobel Physics, Stockhold, Sweden",
    third: [The Third Institute, City, Country],
  ),
  // Funding note (optional, comment out if not applicable)
  funding: "Work supported by ...",
  // Paper abstract
  abstract: [
    This document shows how to use the accelerated-jacow paper template to compose papers for JACoW conference proceedings.
    #lorem(20)
  ],
  paper,
)

// Other useful packages
//#import "@preview/quick-maths:0.1.0"
//#import "@preview/physica:0.9.3"
#import "@preview/unify:0.6.0": unit,num,qty,numrange,qtyrange



= Introduction

Typst @typst is a great, modern and blazingly fast typesetting system focussed on scientific papers.
This paper template is based on the JACoW paper preparation guide @jacowguide.
It showcases common elements, like an equation:
$ e^("i" pi) + 1 = 0 $
This equation can be referenced
$
  sum_(k=0)^n k
  &= 1 + 2 + ... + n \
  &= (n(n+1)) / 2
$ <eq:thesum>

To reference elements, use @eq:thesum, @fig:writer or @table:xydata.
Make sure to use the long form at the #underline[beginning] of a sentence.
@fig:writer[Figure] for example.
@eq:thesum[Equation] as well.
@table:xydata is a table and therefore anyways always written out.

Scientific quantities can be typeset correctly with the unify package.
Examples are quantities like
#qty(1.2, "um") with a reduced spacing,
$q=#num(0.12345678)$ with digit grouping,
$f_"rev"=qty("325.2+-0.1", "kHz")$ with an uncertainty
or $h=qty("8.3+0.1-0.2  e-2", "mm")$ with an asymmetric tolerance.
Plain units can be written as
#unit("tesla meter") or #unit("T m") (but #unit("Tm") is something different).
More examples: #qty(3, "keV"), #qty(4, "GeV"), $qty("100", "kW")$, #qty(7, "um")

Here is a list with some markup examples for common document elements:
- This is a "list"
- With _emphasize_ and *strong _emphasize_*
- And usage of a `monospace font`
- Last #highlight[but not least] something
  #highlight(fill: white, stroke: orange, extent: 0.1em, [fancy])
  💥



= Headings
Headings, subsection headings and even third-level headings follow the JACoW style guide and are automatically transformed to all-caps case and word-caps case respectively.
Custom upper/lower case can be forced if required.

#let nacl = [#upper[N]#lower[a]#upper[C]#lower[l]]

== Subsection heading: #nacl, #upper[N]#lower[a]Cl, $"NaCl"$
#lorem(30)

=== Third-level headings
#lorem(30)

= Floating figures

#figure(
  image("writer.svg"),
  placement: bottom, // top, bottom or auto
  caption: [Scientific writing (AI artwork).],
) <fig:writer>

#lorem(50)

#figure(
  box(fill: silver, width: 100%, height: 1cm),
  placement: bottom, // top, bottom or auto
  caption: [
    A gray rectangle with a relative width of 100%, an absolute height of 1cm
    and a two line caption.
  ],
) <fig:rect>

#figure(
  table(
    columns: 4,
    [x], [1], [2], [3],
    [y], [0.3], [0.4], [0.8],
  ),
  placement: auto, // top, bottom or auto
  caption: [Values for x and y],
) <table:xydata>

#figure(
  table(
    stroke: none,
    columns: 4,
    align: (x, y) => {if x==0 {left} else {center}},
    table.hline(),
    table.header[][*x*][*y*][*z*],
    table.hline(),
    [First], [1], [0.3], [14],
    [Second], [2], [0.4], table.cell(rowspan: 2, align: horizon, [9¾]),
    [Third], [3], [0.8],
    table.hline(),
  ),
  placement: auto, // top, bottom or auto
  caption: [
    Values for x and y as in @table:xydata
    with additional values for z and a different table style
  ]
)

#lorem(50)

#figure(
  box(fill: silver, width: 100%, height: 3cm),
  scope: "parent", // two column-figure
  placement: top, // top, bottom or auto
  caption: [A column spanning figure.],
) <fig:rect>

#lorem(300)

= Conclusions
#lorem(50)

= Acknowledgements
#lorem(50)


#bibliography("references.bib")


// Workaround until balanced columns are available
// See https://github.com/typst/typst/issues/466
#place(
  bottom,
  scope: "parent",
  float: true,
  clearance: 0pt, // TODO: increase clearance for manual column balancing
  []
)

