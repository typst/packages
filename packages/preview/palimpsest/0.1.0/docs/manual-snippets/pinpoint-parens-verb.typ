#import "@preview/palimpsest:0.1.0": *

#document("manuscript.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #passage(<r1-1>)[The sample size #rep[was not justified][was determined by a power calculation].]
  #touched(<r1-2>)[We kept the eligibility criteria exactly as submitted.]
]

#document("response.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #reviewer(1)[
    #exchange(<r1-1>)[The sample size is not justified.][
      See #pinpoint(<r1-1>, parens: false, verb: none) for the updated wording.
    ]

    #exchange(<r1-2>)[Please confirm the eligibility criteria are unchanged.][
      Confirmed --- #pinpoint(<r1-2>).
    ]
  ]
]
