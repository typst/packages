
#import "@preview/vanilla:0.2.0": body, vanilla

#show: vanilla.with(
  styles: (
    body: (
      font: ("Times New Roman", "Libertinus Serif"),
      spacing: "double",
      first-line-indent: 0.5in,
      justify: true,
    ),
  ),
)

= HEADING 1

== Heading 2: #lorem(20)

=== Heading 3

==== Heading 4

===== Heading 5

====== Heading 6

#lorem(50)

+ #lorem(20)

+ #lorem(20) #footnote[#lorem(20)]

- *Bullet 1*: #lorem(50)

- *Bullet 2*

#lorem(50) #footnote[#lorem(20)]

#pagebreak()

#lorem(50)

#table(
  align: left,
  columns: 2,
  table.header([*Heading 1*], [*Heading 2*]),
  [Column 1], [Column 2],
  [#lorem(10)], [#lorem(20)],
)

#lorem(50)

#figure(caption: [Complaint, D.I. 35, #sym.pilcrow 64.])[
  #set align(left)
  #lorem(50)
]

#lorem(50)

#pagebreak()

#lorem(50)

#quote(attribution: lorem(20))[
  #lorem(100) #footnote(lorem(30))
]

#lorem(50) #footnote[https://google.com]

#body(spacing: "single", first-line-indent: 0in)[
  #lorem(50)
]

#lorem(50)
