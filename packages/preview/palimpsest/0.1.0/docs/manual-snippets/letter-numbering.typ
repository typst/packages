#import "@preview/palimpsest:0.1.0": *
#import "../../src/letter.typ": with-letter-numbering

#document("manuscript.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #set heading(numbering: "1.1.")

  = Introduction
  = Methods

  #passage(<r1-1>)[
    #add[
      #figure(rect(width: 3cm, height: 2cm, fill: luma(220)), caption: [A subgroup analysis, added per reviewer request.]) <fig-subgroup>
    ]
  ]

  #passage(<r1-2>)[
    #add[
      == Sensitivity analysis <sub-sensitivity>
      Added per reviewer request.
    ]
  ]
]

#document("response.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #with-letter-numbering[
    #reviewer(1)[
      #exchange(<r1-1>)[Please add a subgroup analysis.][
        Done. #pinpoint(<r1-1>, excerpt: true)
      ]
      #exchange(<r1-2>)[Please add a sensitivity analysis subsection.][
        Done. #pinpoint(<r1-2>, excerpt: true)
      ]
    ]

    For the reviewer's convenience only, not in the manuscript:

    #figure(rect(width: 3cm, height: 2cm, fill: luma(150)), caption: [A figure the letter adds on its own.])
  ]
]
