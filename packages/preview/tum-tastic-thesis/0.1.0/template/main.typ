#import "packages.typ": package

#import package("abbr") as abbr
#import package("tum-tastic-thesis"): dissertation, thesis


#show: abbr.show-rule
#abbr.load("abbreviations.csv")

// Import each chapter here
#import "theory.typ" as theory
#import "introduction.typ" as introduction

// We configure the template
#show: dissertation.with()

// If you are doing a bachelor/master thesis, use instead:
// #show: thesis.with()

// Your chapters go here
#introduction.content

#pagebreak()
#theory.content

// After your chapters:

#set heading(numbering: none)

// Print bibliography
#set page(header: [
  #set text(style: "italic")
  #align(right)[Bibliography]
])

#pagebreak()
#bibliography("bibliography.bib")

// Print abbreviations
#set page(header: [
  #set text(style: "italic")
  #align(right)[Abbreviations]
])

#pagebreak()
#abbr.list()
