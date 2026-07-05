#set document(date: none)


#import "/src/lib.typ": *


#set page(margin: 1cm)


= n = 1
#align(center)[
  #sierpinski-arrowhead-curve(1, step-size: 40)
]


= n = 2
#align(center)[
  #sierpinski-arrowhead-curve(2, step-size: 20, stroke-style: red + 2pt)
]


= n = 3
#align(center)[
  #sierpinski-arrowhead-curve(3, step-size: 20, stroke-style: stroke(paint: gradient.linear(..color.map.crest, angle: 45deg), thickness: 4pt))
]


= n = 4
#align(center)[
  #sierpinski-arrowhead-curve(4, step-size: 20, stroke-style: stroke(paint: gradient.linear(..color.map.rainbow, angle: 45deg), thickness: 10pt, cap: "round", join: "round"))
]
#pagebreak(weak: true)


= n = 5
#align(center)[
  #sierpinski-arrowhead-curve(5, step-size: 10, stroke-style: stroke(paint: purple, thickness: 2pt, cap: "square"))
]
#pagebreak(weak: true)
