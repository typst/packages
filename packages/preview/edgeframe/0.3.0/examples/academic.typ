/*
  File: academic.typ
  Author: neuralpain
  Date Modified: 2025-12-10

  Description: Edgeframe example for research papers, essays, and formal articles.
*/

#import "@preview/edgeframe:0.3.0": *

#show: ef-document.with(
  paper: "us-letter",
  margin: (top: 1in, bottom: 1in, x: 1.25in),
  page-count: true,
  page-count-position: right,
  page-count-first-page: false,
  header: (
    content: ([Running Head: SHORT TITLE], [], [Smith]),
    first-page: none,
  ),
  paragraph: (
    justify: true,
    first-line-indent: 2em,
    spacing: 1.5em,
    leading: 0.8em,
  ),
  number-list: (
    numbering: "1.a.",
    indent: 1em,
  ),
)

#align(center)[
  #text(17pt, weight: "bold")[Full Title of the Paper] \
  \
  Author Name \
  Department Name, University Name \
  Course Code: Course Name \
  Date
]

#v(2em)

= Introduction
#lorem(60)

= Literature Review
#lorem(100)

== Early Studies
#lorem(50)
