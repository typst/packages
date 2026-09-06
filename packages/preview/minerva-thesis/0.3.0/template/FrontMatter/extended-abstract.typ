#import "@preview/minerva-thesis:0.3.0": *

#import "../defs.typ": *

#show: extended-abstract.with(
  flyleaf: false,
  font-size: 10pt,
  caption-align: center,
  subfigure-numbering: default-subfigure-numbering, //restore the default value (instead of the value set by "thesis.with(...)" in thesis.typ
  subfigure-caption-sep: default-caption-separator, //restore the default value  
  subfigure-caption-prefix-text: (weight: "semibold"), // set the number of subfigures in semibold
  )



//in an extended abstract (in English) the abstract should follow directly "#abstract-keywords["  (without spaces or a newline) in order to continue the text directly after "Abstract-"
#abstract-keywords[In this thesis ...

#lorem(30)

#lorem(40)
]



= Introduction



