#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set-revisions(require-exchange: false)

*show-anchor: true (default)*
#passage(<r1-2>)[The #add[anchor tag] appears in superscript at the end of the passage.]

#v(0.8em)
#set-revisions(show-anchor: false)
*show-anchor: false*
#passage(<r1-2>)[No tag at the end of #add[the passage] anymore --- still colored by reviewer, just no visible label.]
