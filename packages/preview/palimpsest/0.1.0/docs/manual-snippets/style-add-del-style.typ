#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)

*add-style: underline, del-style: default (strikes plain text like this)*
#passage[Some text with #add[an addition] and #del[a deletion].]

#v(0.8em)
#let boxed-mark(body) = box(stroke: 0.6pt, inset: (x: 2pt), radius: 1.5pt, body)
#set-revisions(add-style: boxed-mark, del-style: boxed-mark)
*add-style/del-style: a custom `body -> content` function*
#passage[Some text with #add[an addition] and #del[a deletion], both boxed instead of underlined/struck. The reviewer color still applies on top --- it's added separately by the passage, not by this function.]
