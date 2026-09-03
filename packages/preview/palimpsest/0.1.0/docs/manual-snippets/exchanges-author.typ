#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set-revisions(authors: (bob: "Bobby Fischer"))

// Manuscript-side passages.
#added(<bob-1>)[Bobby's own addition.]
#added(<bob-2>)[Bobby's second change.]

// Response-side notes -- no reviewer comment to quote, just an author
// explaining their own change.
#author("bob")[
  #note(<bob-1>)[Explaining why I made this change.]

  // exchange() with two arguments renders identically to note() above.
  #exchange(<bob-2>)[Explaining the second change, via exchange() instead.]
]
