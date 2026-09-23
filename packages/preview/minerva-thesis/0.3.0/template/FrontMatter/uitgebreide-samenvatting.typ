#import "@preview/minerva-thesis:0.3.0": *
#import "../defs.typ": *

#show: extended-abstract.with(
  language: "nl",
//   title: [Een mooie masterproeftitel -- #lorem(10) ],
  flyleaf: false,
  font-size: 10pt,
  subfigure-numbering: default-subfigure-numbering, //restore the default value 
  subfigure-caption-sep: default-caption-separator, //restore the default value 
  subfigure-caption-prefix-text: (weight: "semibold"), 
  )


// No blank line after "#abstract-keywords[" such that the text directly follows "Samenvatting - "
#abstract-keywords[
#lorem(30)

#lorem(40)
]


= Inleiding



