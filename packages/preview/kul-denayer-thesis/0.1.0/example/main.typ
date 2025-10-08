#import "@preview/kul-denayer-thesis:0.1.0" : template


#template(
  auteurs: ("First name LAST NAME",),
  promotor:  "Promotor",
  Co-promotor : "Co-promotor",
  evaluatoren : ("evaluator1","evaluator2"),
  begeleider : "accompanist",
  startDatum : "2025",
  eindeDatum : "2026",
  title : "Title of master thesis",
  subtitle : "subtitle",
  cover : "cover_fiiw_denayer_eng.png",
  dutchTitlePage: false,
  dutchTitle: "Titel van masterproef",
  dutchSubtitle: "ondertitel",
  contents: [
    
= Introduction

#lorem(1000)
#pagebreak()

Effective grammer-aware fuzzer @Gramatron. A random equation @equation.
\
  $ sum_(i=0)^(n=10) (x^2 + lambda * e^(-sin(alpha)))/e^(-sin(alpha)) $ <equation>
\
#figure(caption: [Volumes])[
#table(
  columns: (auto, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Object*], [*Volume*], [*Parameters*],
  ),
  text("Cylinder"),
  $ pi h (D^2 - d^2) / 4 $,
  [
    $h$: height \
    $D$: outer radius \
    $d$: inner radius
  ],
  text("tetrahedron"),
  $ sqrt(2) / 12 a^3 $,
  [$a$: edge length]
)
]
#figure(caption: "Rustacean")[
 #image("media/rustacean.png") 
]
  
#bibliography("bib.bib")
    
  ]
)

