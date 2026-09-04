#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)

#passage[
  #figure(
    table(
      columns: 2,
      [Group], [N],
      [Control], [42],
      ..if mode() == "clean" { () } else { (del[Treatment], del[45]) },
      [Placebo], [40],
    ),
    caption: [Sample sizes by group.],
  )
]
