#set document(date: none)


#import "/src/lib.typ": *


#set page(margin: 1cm)


= n = 1
#align(center)[
  #hilbert-curve(1, step-size: 50)
]


= n = 2
#align(center)[
  #hilbert-curve(2, step-size: 30, stroke-style: blue)
]


= n = 3
#align(center)[
  #hilbert-curve(3, step-size: 30, stroke-style: red + 4pt)
]


= n = 4
#align(center)[
  #hilbert-curve(4, step-size: 15, stroke-style: stroke(paint: gray, thickness: 5pt, cap: "round", join: "round"))
]
#pagebreak(weak: true)


= n = 5
#align(center)[
  #hilbert-curve(5, step-size: 8, stroke-style: stroke(paint: purple, thickness: 2pt, cap: "square"))
]


= n = 6
#align(center)[
  #hilbert-curve(6, step-size: 6, stroke-style: stroke(paint: gradient.linear(..color.map.crest, angle: 45deg), thickness: 4pt, cap: "square"))
]
#pagebreak(weak: true)
