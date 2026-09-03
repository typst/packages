#import "@preview/palimpsest:0.1.0": *

#change-list()

= Introduction

#lorem(20)

#passage(<r1-1>)[
  Propensity scores were estimated by logistic regression
  #add[and their overlap was assessed graphically, following the
  approach of @hernan2016].
]

= Methods

#passage(<r1-2>)[
  The positivity assumption #rep[was not discussed][is now assessed
  graphically, see @fig-positivity].
]
#added(<r1-2>)[
#figure(
  rect(width: 4cm, height: 2cm, fill: luma(230)),
  caption: [Distribution of propensity scores.],
) <fig-positivity>
]

#passage(<r2-1>)[
  A truncation-based sensitivity analysis #add[has also been performed (data not shown)].
]

= Discussion

#touched(<r1-3>)[
  We have kept this wording, which we believe remains appropriate.
]

#bibliography("manuscript.bib", title: [References])
