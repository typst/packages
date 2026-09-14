#import "@preview/clean-uoft-thesis:0.1.0": *

#show: uoft.with(
  title: "Title of Thesis",
  author: "Firstname Lastname",
  department: "Physiology",
  degree: "Doctor of Philosophy",
  graduation-year: "2025",
  abstract: include "abstract.typ",
  acknowledgements: include "acknowledgements.typ",
  font-size: 12pt
)

#include "introduction.typ"

#pagebreak()
#include "ch1.typ"

#pagebreak()
#include "ch2.typ"

#pagebreak()
#include "ch3.typ"

#pagebreak()
#include "ch4.typ"

#pagebreak()
#include "references.typ"

#counter(heading).update(0)

#pagebreak()
#include "appendix.typ"
