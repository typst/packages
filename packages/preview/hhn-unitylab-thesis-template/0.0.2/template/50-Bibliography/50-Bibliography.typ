#import "../Template-Import.typ": *
#import "52-Glossary.typ": *

#pagebreak()
#bibliography(
  //title: "Literatur",
  style: "ieee",
  "51-Sources.bib",
)<bib>

#pagebreak()
= Glossary<glossary>
#print-glossary(entry-list)


#text(fill: white,)[invisible spacer]
<lastpage>