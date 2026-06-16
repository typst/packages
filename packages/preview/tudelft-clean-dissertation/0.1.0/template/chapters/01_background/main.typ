#import  "/template.typ": chapter-cover

#chapter-cover(
  title: [Background],
  chapter-label: "ch-background",
  chapter-sidebar-label: "background ",
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