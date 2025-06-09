#import "@preview/preprintx:0.1.0": preprintx

#show: preprintx.with(
  title: "My Beautiful Manuscript",
  authors: (
    ("Einstein, Albert", "1,\u{2709}"),
    ("Feynman, Richard", "1,2"),
    ("Planck, Max", "3"),
  ),
  affils: (
    "1": "Institute for Advanced Study",
    "2": "California Institute of Technology",
    "3": "University of Berlin",
  ),
  abstract: lorem(100),
  keywords: ([astrophysics], [relativity], [black holes]),
  correspondence: "einstein@relativity.com",
)

= Section
#lorem(30)

== Subsection
#lorem(80)

=== SubSubsection
#lorem(80)

#figure(
  image("example.jpeg", width: 50%),
  caption: [My figure],
) <fig1>

#lorem(100)

A reference to @fig1

#figure(
  table(
    columns: 2,
    [*Text*], [*Number*],
    [x], [100],
    [y], [$pi$],
  ),
  caption: [My table],
) <table1>

A reference to @table1

Some citations @maxwell1865dynamical@planck1901law@einstein1905relativity

Some math: $E=m c^2$

#lorem(400)

= References
#v(-3em)
#bibliography("example.bib", style: "nature", title: "")




