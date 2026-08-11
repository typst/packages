/*
  File: professional.typ
  Author: neuralpain
  Date Modified: 2025-12-10

  Description: Edgeframe example for professional papers and technical reports.
  Includes: Cover, TOC, Figures, Tables, Bibliography.
*/

#import "@preview/edgeframe:0.3.0": *

// ------------------------------------------------------------------ COVER PAGE
// Cover pages will be properly handled in a future version of Edgeframe.

#place(center + horizon)[
  #text(fill: black, size: 3em, weight: "black")[PROJECT APOLLO] \
  #v(1em)
  #text(fill: black.transparentize(20%), size: 1.5em)[Final Technical Report]
]
#place(bottom + center, dy: -3em)[
  #text(fill: black, "Prepared by John Doe")
]

#pagebreak()

// ------------------------------------------------------------ EDGEFRAME CONFIG
#show: ef-document.with(
  ..ef-defaults,
  paper: "us-letter",
  margin: margin.normal,
  header: (
    content: ([*Project Apollo*], [], [2025]),
  ),
  footer: (
    content: ([Confidential], [], [v2.4]),
  ),
  page-count: true,
)

// ---------------------------------------------------------------- FRONT MATTER
#counter(page).update(1) // Reset counter for page 1

= Executive Summary
As discussed in @smith2023, the project viability is high. However, recent developments by Jones et al. @jones2024 suggest caution regarding the timeline.

#lorem(100)

== Key Findings
As shown in @growth_chart, revenue has increased by 15%.

#figure(
  rect(width: 80%, height: 150pt, fill: luma(90%), radius: 5pt)[
    #align(center + horizon)[*CeTZ Chart Here*]
  ],
  caption: [Projected Revenue Growth Q1-Q4],
) <growth_chart>

= Technical Data
The specific parameters for the experiment are detailed below.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    inset: 10pt,
    align: center,
    table.header([*Parameter*], [*Value*], [*Unit*]),
    [Voltage], [240], [V],
    [Current], [15], [A],
    [Resistance], [16], [$Omega$],
  ),
  caption: [System Specifications],
) <specs_table>

Refer to @specs_table for electrical constraints.

= Technical Analysis
#lorem(50)

#lorem(100)

// ---------------------------------------------------------------- BIBLIOGRAPHY
#pagebreak()

#bibliography(title: "References", "works.bib")
