/*
  File: business.typ
  Author: neuralpain
  Date Modified: 2025-12-10

  Description: Edgeframe example for internal memos, quarterly reports, and whitepapers.
  Includes: Cover, TOC.
*/

#import "@preview/edgeframe:0.3.0": *

#show: ef-document.with(
  draft: true,
  paper: "a4",
  margin: margin.a4,
  header: (
    content: ([*Acme Corp*], [], [Internal Report]),
    first-page: [*ACME CORPORATION*],
    // Double-sided printing
    odd-page: ([*Acme Corp*], [], [2025 Strategy]),
    even-page: ([2025 Strategy], [], [*Acme Corp*]),
  ),
  footer: (
    content: ([Confidential], [Page 0], [v1.0]),
  ),
  page-count: true,
  page-count-position: center, // default, but explicit
  paragraph: (
    spacing: 1.2em,
  ),
)

#v(3em)
#align(center + horizon)[
  #rect(inset: 2em, stroke: 2pt)[
    #text(20pt, weight: "black")[Q1 STRATEGIC OVERVIEW]
  ]
]

#pagebreak()

// --- Outlines will be included in a future version of Edgeframe

#show outline.entry.where(level: 1): it => {
  v(1.5em, weak: true)
  text(weight: "bold", size: 1.1em, fill: rgb("#003366"))[
    #it.element.body #h(1fr) #it
  ]
}

#show outline.entry.where(level: 2): it => {
  h(1.5em)
  it.element.body
  box(width: 1fr, repeat[.])
  it.page
}

#outline(title: [Report Structure])

#pagebreak()

= Executive Summary
#lorem(40)

- Key Performance Indicator A
- Key Performance Indicator B
- Key Performance Indicator C

= Financial Analysis
#lorem(80)