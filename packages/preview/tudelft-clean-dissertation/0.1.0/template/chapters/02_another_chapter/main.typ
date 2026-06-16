#import  "/template.typ": chapter-cover

#chapter-cover(
  title: [Another],
  chapter-label: "ch-another",
  chapter-sidebar-label: "another",
  quote: "This is a chapter-quote. Your opportunity to add some levity to this work.",
  quote-credit: "Quote Machine" 
)[
  // chapter abstract/summary
  #lorem(200)
]

#include "introduction.typ"

== Main section

#lorem(800)

#include "supplementary.typ"

