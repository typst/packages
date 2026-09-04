#import "@preview/palimpsest:0.1.0": *

#document("manuscript.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #passage(<r1-1>)[The sample size #rep[was not justified][was determined by a power calculation].]
]

#document("response.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #reviewer(1)[
    #exchange(<r1-1>)[The sample size is not justified.][
      Compare the wording: #pinpoint(<r1-1>, excerpt: true, mode: "tracked")
    ]
  ]
]
