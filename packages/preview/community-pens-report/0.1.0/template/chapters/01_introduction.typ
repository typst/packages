#import "@preview/community-pens-report:0.1.0": *

= Introduction <ch:introduction>

== Background <sec:background>

Write the introduction background here. This sample chapter demonstrates
headings, figures, tables, equations, and citations @smith2020example.

== Sample Figure

#figure(
  rect(width: 8cm, height: 4cm, fill: rgb("#eef2f7"))[
    #align(center + horizon, text(gray)[Placeholder figure])
  ],
  caption: [Example figure with a caption.],
) <fig:sample>

== Sample Table

#figure(
  caption: [Example table with a caption.],
  table(
    columns: 2,
    [*A*], [*B*],
    [1], [2],
    [3], [4],
  ),
) <tab:sample>

== Sample Equation

#figure(
  $ E = m c^2 $,
  caption: [Example equation with a caption.],
  kind: "equation",
  supplement: [Equation],
) <eq:sample>

== Cross References

As shown in @fig:sample and @tab:sample, you can reference figures and tables
across chapters, and cite sources like @doe2018book.
