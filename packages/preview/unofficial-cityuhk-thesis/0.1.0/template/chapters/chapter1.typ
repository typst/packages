#import "@preview/unofficial-cityuhk-thesis:0.1.0": chapter

#chapter[Chapter 1]

#lorem(40) @schaub_hierarchical_2023

= Section 1

#lorem(40)

== Subsection 1

#lorem(40)

#lorem(40)

= Section 2

#lorem(40)

#figure(
  image("../figures/sample-figure.png", width: 50%),
  caption: [Example figure Minion],
)

== Subsection 1

#lorem(40)

#figure(
  image("../figures/sample-figure.png", width: 50%),
  caption: [Example figure Minion],
)

#figure(
  table(
    columns: (auto, auto),
    inset: 10pt,
    align: horizon,
    table.header(
      [*Volume*],
      [*Parameters*],
    ),

    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    $ sqrt(2) / 12 a^3 $, [$a$: edge length],
  ),
  caption: [Example table],
)

#lorem(40)


=== Subsubsection 1

#lorem(40)
