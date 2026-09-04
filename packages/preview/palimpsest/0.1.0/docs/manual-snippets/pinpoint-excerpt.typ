#import "@preview/palimpsest:0.1.0": *

#document("manuscript.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #passage(<r1-1>)[The sample size #rep[was not justified][was determined by a power calculation].]
  #deleted(<r1-2>, summary: [an outdated caveat about generalizability])[
    An earlier caveat about generalizability, no longer needed.
  ]
]

#document("response.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #reviewer(1)[
    #exchange(<r1-1>)[The sample size is not justified.][
      Addressed as follows: #pinpoint(<r1-1>, excerpt: true)
    ]

    #exchange(<r1-2>)[This caveat is no longer accurate.][
      Agreed: #pinpoint(<r1-2>, excerpt: true)
    ]
  ]
]
