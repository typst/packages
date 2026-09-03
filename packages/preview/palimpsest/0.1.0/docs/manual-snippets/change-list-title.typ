#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set-revisions(require-exchange: false)

*Without `title: none` --- your own heading, then the package's own "Summary of changes" on top of it:*

#text(weight: "bold", size: 1.2em)[Summary of Revisions]
#change-list()

*With `title: none` --- no second, redundant heading:*

#text(weight: "bold", size: 1.2em)[Summary of Revisions]
#change-list(title: none)

#added(<r1-1>)[A reviewer's addition.]
