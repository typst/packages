#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set-revisions(require-exchange: false)

*color: auto (default) — one color per reviewer*
#passage(<r1-1>)[Reviewer 1's #add[addition].]
#passage(<r2-1>)[Reviewer 2's #add[addition] — a different color, automatically.]

#v(0.8em)
#set-revisions(color: rgb("#7a7a7a"))
*color: a fixed value — overrides per-reviewer colors*
#passage(<r1-1>)[Reviewer 1's #add[addition], now in the fixed color.]
#passage(<r2-1>)[Reviewer 2's #add[addition], the same fixed color, not a different one.]
