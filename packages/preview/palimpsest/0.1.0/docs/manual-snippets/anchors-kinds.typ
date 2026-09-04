#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set-revisions(
  require-exchange: false,
  authors: (
    bob: (name: "Bobby Fischer", color: rgb("#c026d3")),
    alice: "Alice Smith",
  ),
)

#added(<r1-1>)[A reviewer's comment, `<r1-1>` --- one color per reviewer number.]

#added(<e1>)[An editor's comment, `<e1>` --- its own fixed color, distinct from every reviewer.]

#added(<bob-1>)[Bob's own change, `<bob-1>` --- name and color both registered explicitly.]

#added(<alice-1>)[Alice's own change, `<alice-1>` --- name registered, color assigned automatically.]

#added(<carol-1>)[Carol's own change, `<carol-1>` --- nothing registered at all, still a distinct color, displayed under her raw id.]
