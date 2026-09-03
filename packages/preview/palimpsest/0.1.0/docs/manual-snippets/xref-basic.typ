#import "@preview/palimpsest:0.1.0": *

#document("manuscript.pdf")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #set heading(numbering: "1.")
  = Results
  #pagebreak()
  #figure(rect(width: 3cm, height: 1.5cm, fill: luma(230)), caption: [Propensity score distribution.]) <fig-a>
]

#document("response.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)

  A bare reference resolves the real manuscript number, for free: @fig-a.

  `xref` adds the page number on top: #xref(<fig-a>).

  A label that doesn't exist: #xref(<fig-nonexistent>).
]
