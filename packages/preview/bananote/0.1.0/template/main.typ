
#import "@preview/bananote:0.1.0": *
#import "@preview/pergamon:0.5.0": *


#show: note.with(
  title: [My Research Note],
  authors: (([My Name], [My Affiliation]),)
)

#abstract[
  #lorem(50)
]



= Introduction

#lorem(50)

== Subsection

#lorem(50)


= Another Section

#lorem(50)


/*
// Uncomment this to typeset the bibliography:

#add-bib-resource(read("bibliography.bib"))
#print-bananote-bibliography()
*/

