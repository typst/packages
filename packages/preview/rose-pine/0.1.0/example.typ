#import "lib.typ" : apply
#show: apply()
#set align(center)

= Example Typst Document
#set heading(numbering: "1.")
= Text and headings
#lorem(30)

== H2
#lorem(20)

=== H3
#lorem(15)

= Links and other references <links>
== Links
#link("https://www.google.com")[
    Google
]
#link("https://www.google.com")

== References
@links

== Footnotes
Some text#footnote[footnote test]

= Tables
#table(
  columns: (1fr, auto, auto),
  inset: 10pt,
  align: horizon,
  [*Equation*], [*Area*], [*Parameters*],
  $ pi h (D^2 - d^2) / 4 $,
  [
    $h$: height \
    $D$: outer radius \
    $d$: inner radius
  ],
  $ sqrt(2) / 12 a^3 $,
)

= Visuals
== Circles
#circle(radius: 25pt)

#circle[
  #set align(center + horizon)
  Automatically \
  sized to fit.
]

== Ellipses
// Without content.
#ellipse(width: 35%, height: 30pt)

// With content.
#ellipse[
  #set align(center)
  Automatically sized \
  to fit the content.
]

== Lines

#line(length: 100%)
#line(end: (50%, 10%))
#line(
  length: 4cm,
)
== Paths
#path(
  closed: true,
  (0pt, 50pt),
  (100%, 50pt),
  ((50%, 0pt), (40pt, 0pt)),
)

== Polygons

#polygon(
  (20%, 0pt),
  (60%, 0pt),
  (80%, 2cm),
  (0%,  2cm),
)

== Rectangles
#rect(width: 35%, height: 30pt)

#rect[
  Automatically sized \
  to fit the content.
]

== Squares

#square(size: 40pt)

#square[
  Automatically \
  sized to fit.
]
