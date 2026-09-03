#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set-revisions(authors: (bob: "Bobby Fischer"))

#added(<r1-1>)[Default word: "comment".]
#added(<bob-1>)[Default word: "change".]
#added(<r2-1>)[Global override applies here.]
#added(<bob-2>)[Per-call override applies here.]

#reviewer(1)[
  #exchange(<r1-1>)[A remark.][The default reviewer word.]
]
#author("bob")[
  #note(<bob-1>)[The default author word.]
]

#set-revisions(comment-word: "remark", change-word: "revision")

#reviewer(2)[
  #exchange(<r2-1>)[Another remark.][Now under the global override --- "remark", not "comment".]
]

#author("bob")[
  #note(<bob-2>, term: "aside")[This one overrides the word for just this call.]
]

Cross-references: #xcomment(<r1-1>), #xcomment(<r2-1>), and #xcomment(<bob-2>).
