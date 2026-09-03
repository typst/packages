#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)

*style: "inline" (default)*
#passage[This whole sentence is marked #add[with an inline addition] in the flow of text.]

#v(0.8em)
#set-revisions(style: "bar")
*style: "bar"*
#passage[This whole sentence is marked #add[with an addition] under the bar style instead.]

#v(0.8em)
#set-revisions(style: "none")
*style: "none"*
#passage[This whole sentence is marked #add[with an addition] but renders exactly like the clean version — a layout sanity check.]
