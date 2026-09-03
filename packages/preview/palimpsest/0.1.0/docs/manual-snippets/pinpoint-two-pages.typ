#import "@preview/palimpsest:0.1.0": *

#document("manuscript.pdf")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #passage(<r1-1>)[This revision responds to a single comment that required changes in two separate sections.]
  #pagebreak()
  #passage(<r1-1>)[The same comment, addressed a second time here.]
]

#document("response.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #reviewer(1)[
    #exchange(<r1-1>)[A single comment requiring changes in two places.][
      Addressed in both places. #pinpoint(<r1-1>)
    ]
  ]
]
