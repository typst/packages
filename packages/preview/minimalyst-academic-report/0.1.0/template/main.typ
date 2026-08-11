#import "@preview/minimalyst-academic-report:0.1.0": report
// #import "@local/minimalyst-academic-report:0.1.0": report

#show: doc => report(
  title: "Academic Template",
  subtitle: "A clean template for reports",
  // if a single author, leave a comma ate the ending to ensure it is an array
  authors: (
    (name: "John Doe", number: "424242"),
    (name: "Jane Doe", number: "424242")
  ),
  table-of-contents: true,
  table-of-figures: true,
  cover-image: (rect(
    fill: blue,
    width: 30%,
    height: 5em,
    stroke: (dash: "dashed"))[
      #set align(center + horizon)
      REPLACE THIS WITH YOUR IMAGE
    ]
  ),
  date: "02 April 2026",
  doc,
)

= Soft
== Close
=== Closest
@hard: #lorem(80)

== Softest

#lorem(80)

== Softest

#lorem(80)

= Hard <hard>

#lorem(80)

== Hardest

#lorem(80)
