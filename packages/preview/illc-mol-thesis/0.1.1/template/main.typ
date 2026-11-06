#import "@preview/illc-mol-thesis:0.1.1": *

#show: mol-thesis

#mol-titlepage(
  title: "Title of the Thesis",
  author: "John Q. Public",
  birth-date: "April 1st, 1980",
  birth-place: "Alice Springs, Australia",
  defence-date: "August 28, 2005",
  /* Only one supervisor? The singleton array ("Dr Jack Smith",) needs the
     trailing comma. */
  supervisors: ("Dr Jack Smith", "Prof Dr Jane Williams"),
  committee: (
    "Dr Jack Smith",
    "Prof Dr Jane Williams",
    "Dr Jill Jones",
    "Dr Albert Heijn"),
  degree: "MSc in Logic"
)

#mol-abstract[
  ABSTRACT OF THE THESIS
  
  #lorem(150)
]

#outline()

#mol-chapter("Introduction")

#lorem(100)

== Background <background>

#lorem(75)

== Literature

We use standard results from @BRV2001:Modal. Also relevant for our work is
@BB1999:IPGames, where it was proven that Logic is great.

#lorem(1200)

== Criticism

#lorem(150)

#mol-chapter("My Logic")

#lorem(100)

== Syntax

#definition[
  We defined the language $cal(L)$ as follows:

  $ phi.alt ::= top | p | phi.alt and phi.alt $
]

#lorem(50)

== Semantics

== Axioms

== Soundness

== Completeness

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

#lorem(500)

#pagebreak()
#bibliography("references.bib")
