#import "packages.typ": *

/// make the title page
#titlepage

#show: template
#show math.pi: math.upright
#show "。": "．"
#show "，": "、"

#preamble[
  #include "chapters/0_abs.typ"
]

/// make the abstract
#outline()

// this is necessary before starting your main text
#mainbody[
  #include "chapters/usage.typ"
  #include "chapters/1_intro.typ"
]

#appendix[
  #include "appendices/data.typ"
  #include "appendices/proof.typ"
]

#include "misc/ref.typ"

#make-index()

