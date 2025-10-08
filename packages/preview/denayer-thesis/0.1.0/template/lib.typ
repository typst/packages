#import "@preview/hydra:0.6.2": hydra
// Title Page ---------------------------
#let titlepage(
  auteurs: ("First name LAST NAME",),
  promotor:  "Promotor",
  co-promotor : "Co-promotor",
  evaluatoren : ("evaluator1","evaluator2"),
  begeleider : "accompanist",
  start : "2025",
  einde : "2026",
  title : "Title of master thesis",
  subtitle : "subtitle",
  cover : "cover_fiiw_denayer_eng.png",
  cover-text: ([
    Master’s Thesis submitted to obtain the\
    degree of Master of Science\
    in industrial sciences:\
    electronics-ICT, software engineering\
  ],"Academic year"),
  copyright: [
© Copyright KU Leuven

Without written permission of the supervisor(s) and the author(s) it is forbidden to reproduce or adapt in any form or by any means any part of this publication. Requests for obtaining the right to reproduce or utilise parts of this publication should be addressed to: KU Leuven Faculty of Engineering Technology, W. de Croylaan 56, B-3000 Heverlee, email info.iiw\@kuleuven.be.

Written permission from the supervisor(s) is also required to use the methods, products, schematics, and programs described in this work for industrial or commercial use, for referring to this work in publications, and for submitting this publication in scientific contests.
    
  ]
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
  "assets/" + cover, 
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
  #cover-text.at(0)

  _Promotor_\
  #promotor\

  _Co-promotor_\
  #co-promotor\
  
]

#place(
  bottom + right,
  float: true
)[
   #cover-text.at(1) #start - #einde
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
#copyright

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
  #image("assets/logo.png")
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

#let template(
  contents: [content],
  auteurs: ("First name LAST NAME",),
  promotor:  "Promotor",
  co-promotor : "Co-promotor",
  evaluatoren : ("evaluator1","evaluator2"),
  begeleider : "accompanist",
  start-datum : "2025",
  einde-datum : "2026",
  title : "Title of master thesis",
  subtitle : "Subtitle",
  cover : "cover_fiiw_denayer_eng.png",
  voorwoord: [preface],
  naam: [My name],
  samenvatting: [My Summary],
  afkortingen: [*CFG* Context Free Grammar],
  dutch-titlepage: false,
  dutch-title: "Titel van masterproef",
  dutch-subtitle: "Ondertitel",
  bib-file: "bib.bib"
) = [
  // DUTCH TITLE PAGE 
  #if dutch-titlepage [
  #titlepage(
    auteurs: auteurs,
    promotor: promotor ,
    co-promotor : co-promotor,
    evaluatoren : evaluatoren,
    begeleider : begeleider ,
    start : start-datum , 
    einde : einde-datum ,
    title : dutch-title ,
    subtitle: dutch-subtitle,
    cover: "cover_fiiw_denayer.png",
    coverText: ([
    Thesis voortgedragen tot het behalen\
    van de graad van Master of Science\
    in de industriële wetenschappen:\
    electronica-ICT, software engineering\
    ], "Academiejaar"),
    copyright: [
    ©Copyright KU Leuven\
    
    Deze masterproef is een examendocument dat niet werd gecorrigeerd voor eventuele vastge-
    stelde fouten. \
    
    Zonder voorafgaande schriftelijke toestemming van zowel de promotor(en) als de auteur(s) is
    overnemen, kopiëeren, gebruiken of realiseren van deze uitgave of gedeelten ervan verboden.
    Voor aanvragen i.v.m. het overnemen en/of gebruik en/of realisatie van gedeelten uit deze
    publicatie, kan u zich richten tot KU Leuven Campus De Nayer, Jan De Nayerlaan 5, B-2860
    Sint-Katelijne-Waver, +32 15 31 69 44 of via e-mail iiw.denayer\@kuleuven.be.\
    
    Voorafgaande schriftelijke toestemming van de promotor(en) is eveneens vereist voor het
    aanwenden van de in deze masterproef beschreven (originele) methoden, producten, scha-
    kelingen en programma’s voor industrieel of commercieel nut en voor de inzending van deze
    publicatie ter deelname aan wetenschappelijke prijzen of wedstrijden.
    ]
  )]
  
  
  #titlepage(
    auteurs: auteurs,
    promotor: promotor ,
    co-promotor : co-promotor,
    evaluatoren : evaluatoren,
    begeleider : begeleider ,
    start : start-datum , 
    einde : einde-datum ,
    title : title,
    subtitle: subtitle,
  )
  #start(
    voorwoord:voorwoord ,
    naam:naam ,
    samenvatting:samenvatting,
    afkortingen:afkortingen ,
  )

  // ========== DOCUMENT SETTINGS =================
  
  #set page(paper: "a4", margin: (inside: 120pt, outside: 80pt, y:120pt), numbering: "1", header: context {
    if calc.odd(here().page()) {
      align(right, emph(hydra(1, skip-starting: false)))
    } else {
      align(left, emph(hydra(1, skip-starting: false)))
    }
    line(length: 100%,
    stroke: luma(50%),
  )
  })
  #set heading(numbering: "1.1")
  
  #counter(page).update(1) // Reset numbering to start at 1
  #set page(footer: context {
    if calc.even(counter(page).get().first()) {
      align(left, counter(page).display("1"))
  } else {
      align(right, counter(page).display("1"))
    }
  })
  
  #set par(
    spacing: 0.65em,
    justify: true,
  )
  
  // // Customize Level 1 headings
  #show heading.where(level: 1): it => [
    #pagebreak(weak: true);
    #block(it)\
  ]
  

  #set math.equation(numbering: "(1)")
  
  #show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      link(el.location(),numbering(
        el.numbering,
        ..counter(eq).at(el.location())
      ))
    } else {
      // Other references as usual.
      it
    }
  }

// ============ DOCUMENT CONTENTS ARE INSERTED HERE
  
  #contents

  
    
]
