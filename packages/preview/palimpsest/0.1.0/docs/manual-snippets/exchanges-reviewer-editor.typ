#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)

// Manuscript-side passages, matched by the exchanges below.
#added(<r1-1>)[A justification for the sample size.]
#added(<r1-2>)[A sensitivity analysis, added alongside it.]
#added(<e1>)[A clarified abstract word count.]

// Response-side exchanges -- a reviewer's block holds as many
// successive exchanges as needed, one heading for the whole group.
#reviewer(1)[
  #exchange(<r1-1>)[The sample size is not justified.][
    We agree and have added a justification.
  ]

  #exchange(<r1-2>)[A sensitivity analysis would strengthen this.][
    Added, using the same assumptions.
  ]
]

#editor[
  #exchange(<e1>)[Please double-check the abstract word count.][
    Confirmed within the journal's limit.
  ]
]
