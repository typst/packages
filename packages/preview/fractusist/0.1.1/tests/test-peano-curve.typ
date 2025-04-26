#set document(date: none)


#import "/src/lib.typ": *


#set page(margin: 1cm)


= n = 1
#align(center)[
  #peano-curve(1, step-size: 40)
]


= n = 2
#align(center)[
  #peano-curve(2, step-size: 10, stroke-style: blue + 4pt)
]


= n = 3
#align(center)[
  #peano-curve(4, step-size: 5, stroke-style: stroke(paint: gray, thickness: 2pt, cap: "square"))
]
#pagebreak(weak: true)


= n = 4
#align(center)[
  #peano-curve(4, step-size: 6, stroke-style: stroke(paint: gradient.radial(..color.map.crest), thickness: 4pt, cap: "square"))
]
#pagebreak(weak: true)
