#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set-revisions(require-exchange: false)

*Comment with no matching passage anywhere:*
#reviewer(1)[
  #exchange(<r9-1>)[A comment with nothing in the manuscript to answer.][A response anyway.]
]

*Exchange with a blank response:*
#passage(<r9-2>)[#add[A real addition, matched below.]]
#reviewer(1)[
  #exchange(<r9-2>)[A real comment.][]
]

*A mark outside any passage:*
#add[Added text with no enclosing `passage`.]

*A passage with no mark and no `summary:`:*
#passage(<r9-3>)[Plain text, nothing added, removed, or replaced.]
