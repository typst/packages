#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)

// Only the removed column enters the mode-dependent delta --- the
// added column is part of the fixed base count, present in both
// compiles, same as the added row above.
#passage[
  #figure(
    table(
      columns: 3 + int(mode() != "clean"),
      [Group], [N], add[p-value], ..if mode() == "clean" { () } else { (del[Old score],) },
      [Control], [42], add[0.03], ..if mode() == "clean" { () } else { (del[--],) },
    ),
    caption: [Sample sizes --- p-value column added, Old score column dropped.],
  )
]
