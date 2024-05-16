#set document(date: none)


#import "/src/lib.typ": *


#set page(margin: 1cm)


= n = 1
#align(center)[
  #koch-curve(1, step-size: 40)
]


= n = 2
#align(center)[
  #koch-curve(2, step-size: 20, stroke-style: red + 2pt)
]


= n = 3
#align(center)[
  #koch-curve(3, step-size: 10, stroke-style: stroke(paint: gradient.linear(..color.map.crest, angle: 45deg), thickness: 4pt))
]


= n = 4
#align(center)[
  #koch-curve(4, step-size: 5, stroke-style: stroke(paint: gradient.linear(..color.map.rainbow, angle: 45deg), thickness: 2pt))
]


= n = 5
#align(center)[
  #koch-curve(5, step-size: 2, stroke-style: blue)
]
#pagebreak(weak: true)
