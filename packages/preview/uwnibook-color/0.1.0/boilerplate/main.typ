#import "uwnibook.typ": *

/// make the title page
#titlepage

#show: template

#preamble[
  #include "chapters/preamble.typ"
  // #include "chapters/more.typ"
]

/// make the abstract
#outline()

// this is necessary before starting your main text
#mainbody[
  #include "chapters/1_intro.typ"
  // Use the following line to include more chapters
  // #include "chapters/more.typ"
]

#appendix[
  #include "chapters/appendix.typ"
  // #include "chapters/more.typ"
]

/// make the bibliography
#bibliography("citation.bib")

/// make the index
#make-index()