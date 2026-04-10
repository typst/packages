#import "@preview/illc-mol-thesis:0.2.0": *

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
#include "1-introduction.typ"
#include "2-my-logic.typ"
#include "3-examples.typ"
#pagebreak()

#load-bib(read("references.bib"), main: true)
