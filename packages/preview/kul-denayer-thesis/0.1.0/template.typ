// Title Page ---------------------------
#let titlepage(
  auteurs: ("First name LAST NAME",),
  promotor:  "Promotor",
  Co-promotor : "Co-promotor",
  evaluatoren : ("evaluator1","evaluator2"),
  begeleider : "accompanist",
  start : "2025",
  einde : "2026",
  title : "Title of master thesis",
  subtitle : "subtitle",
) = {
text(font: "Libertinus Serif")[

#set page(
  paper: "a4",
  margin: (left:60pt, top:350pt, bottom: 110pt, right: 50pt),
  numbering: none,
)
// KULeuven Logo 

#page(
  background: image(
  "cover_fiiw_denayer.png",
  height: 100%, width: 100%,
  fit: "cover"))[


// Title

#place(
  left + top,
  float: true,
  clearance: 30pt,
  )[
  #text(size: 30pt, weight: "regular", fill:rgb("#1D8DB0"))[#title]
]
// Subtitle

#place(
  left + top,
  float: true,
  clearance: 50pt,
  )[
    #text(size: 17pt)[#subtitle]
]
#place(
  right + top,
  float: true,
)[
  #for auteur in auteurs [
    #set text(size:15pt, weight: "bold")
    #auteur\
  ]
]

#place(
  right + bottom,
  float: true,
  clearance: 20pt,
)[
  Master’s Thesis submitted to obtain the\
  degree of Master of Science\
  in industrial sciences:\
  electronics-ICT, software engineering\

  _Promotor_\
  #promotor\

  _Co-promotor_\
  #Co-promotor\
  
]

#place(
  bottom + right,
  float: true
)[
  Academic year #start - #einde
]
]
#pagebreak()

#set page(
  paper: "a4",
  margin: (left:80pt, top:350pt, bottom: 110pt, right: 120pt),
  numbering: none,
)

#place(
  bottom + left,
  float: true
)[
#align(bottom + left,)[
  #set par(
  justify: true,
  leading: 0.52em,
)
© Copyright KU Leuven

Without written permission of the supervisor(s) and the author(s) it is forbidden to reproduce or adapt in any form or by any means any part of this publication. Requests for obtaining the right to reproduce or utilise parts of this publication should be addressed to: KU Leuven Faculty of Engineering Technology, W. de Croylaan 56, B-3000 Heverlee, email info.iiw\@kuleuven.be.

Written permission from the supervisor(s) is also required to use the methods, products, schematics, and programs described in this work for industrial or commercial use, for referring to this work in publications, and for submitting this publication in scientific contests.
 


]]
]
}

// Einde Titel pagina ------------------------
#set page(
  paper: "a4",
  margin: (inside: 80pt, outside: 120pt, y:120pt),
  numbering: none,
)
#let start(
  voorwoord: [Mijn voorwoord],
  naam: [Mijn Naam],
  samenvatting: [Mijn samenvatting],
  afkortingen: [*af* afkorting],
) = [
#pagebreak()
// #counter(page).update(1) // Reset numbering to start at 1
// #set page(
// numbering: "i",
// margin: (inside: 80pt, outside: 120pt, y:120pt),
// )

#counter(page).update(1) // Reset numbering to start at 1
#set page(footer: context {
  if calc.even(counter(page).get().first()) {
    align(left, counter(page).display("i"))
} else {
    align(right, counter(page).display("i"))
  }
})

#show heading.where(level: 1): it => [
  #set align(left)
  #set text(20pt, weight: "bold")
  #block(it.body)\
]
#show heading.where(level: 2): it => [
  #set align(left)
  #set text(14pt, weight: "bold")
  #block(it.body)\
]



= Preface
#text()[
  #voorwoord 
]
#align(right)[
  _ #naam _
]
#pagebreak()
#page(
  margin: (y:200pt),
  align(center)[
  #image("logo.png")
  #block(above: 100pt, text(size: 18pt, style: "italic")[
    #set par(spacing: 12pt)
Copyright Information: 
  
student paper which is part of an academic

education 

and examination.

 No correction was made to the paper 
 
after examination.
])
  


])
#pagebreak()
#outline(title: "TABLE OF CONTENTS")
#pagebreak()

= Summary
#samenvatting
#pagebreak()

= List of Figures and Tables
// Inhoudstafel van de figuren -- comment als er geen tabellen zijn
#outline(
  title: [== List of Figures],
  target: figure.where(kind: image),
)
// Inhoudstafel van de tabellen -- comment als er geen tabellen zijn
#outline(
  title: [== List of Tables],
  target: figure.where(kind: table),
)
#pagebreak()
= List of Abreviations
#afkortingen


#pagebreak()
#set page(numbering:none)

]