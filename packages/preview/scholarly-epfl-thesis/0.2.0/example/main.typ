#import "@preview/scholarly-epfl-thesis:0.2.0": template, front-matter, main-matter, back-matter

#show: template.with(author: "Your name")

// #set pagebreak(weak: true)
#set page(numbering: none)

#include "head/cover-page.typ"
#pagebreak()
#pagebreak()
#include "head/dedication.typ"

#show: front-matter

#include "head/acknowledgements.typ"
#include "head/preface.typ"
#include "head/abstracts.typ"

#outline(title: "Contents")
#outline(title: "List of Figures", target: figure.where(kind: image))
#outline(title: "List of Tables", target: figure.where(kind: table))
// #outline(title: "List of Listings", target: figure.where(kind: raw))

#show: main-matter

#include "main/ch1_introduction.typ"
#include "main/ch2_figures_tables.typ"
#include "main/ch3_math.typ"
#include "main/ch4_more_text.typ"
#include "main/ch5_the_others.typ"

#show: back-matter

#include "tail/appendix.typ"
#include "tail/biblio.typ"
// #include "tail/cv/cv"
