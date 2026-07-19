#import "@preview/illc-mol-thesis:0.2.0": *

#mol-chapter("Examples")

== Figures

We illustrate the protagonist of this thesis. in @protagonist.

#figure(caption: "The protagonist.", numbering: "1.1")[
  #emoji.person
]<protagonist>

== Tables

In @cities we compare some cities.

#figure(caption: "An overview of cities.")[
  #table(
    columns: 3,
    stroke: (x, y) => if x == 0 { (right: black) },
    table.hline(),
    table.header([City],[Population],[area ($"km"^2$)]),
    table.hline(),
    [Amsterdam],[851573],[219],
    [Groningen],[200952],[ 83],
    [Utrecht  ],[321989],[100],
    table.hline()
  )
]<cities>

#mol-chapter("Conclusions")

As we discussed in @background, Logic is great.

#lorem(400)

#load-bib(read("references.bib"))
