#set document(date: none)


#import "/src/lib.typ": *


#set page(margin: 1cm)


= n = 1
#align(center)[
  #dragon-curve(1, step-size: 40)
]


= n = 2
#align(center)[
  #dragon-curve(2, step-size: 20, stroke-style: stroke(paint: red, thickness: 2pt, cap: "square"))
]


= n = 3
#align(center)[
  #dragon-curve(3, step-size: 20, stroke-style: stroke(paint: orange, thickness: 4pt, cap: "square"))
]


= n = 4
#align(center)[
  #dragon-curve(4, step-size: 20, stroke-style: stroke(paint: green, thickness: 6pt, cap: "square"))
]


= n = 5
#align(center)[
  #dragon-curve(5, step-size: 16, stroke-style: stroke(paint: blue, thickness: 8pt, cap: "round", join: "round"))
]


= n = 6
#align(center)[
  #dragon-curve(6, step-size: 16, stroke-style: stroke(paint: purple, thickness: 8pt, cap: "square"))
]
#pagebreak(weak: true)


= n = 7
#align(center)[
  #dragon-curve(7, step-size: 10, stroke-style: stroke(paint: gradient.linear(..color.map.crest, angle: 45deg), thickness: 2pt, cap: "square"))
]


= n = 8
#align(center)[
  #dragon-curve(8, step-size: 10, stroke-style: stroke(paint: gradient.linear(..color.map.crest, angle: 45deg), thickness: 3pt, cap: "square"))
]


= n = 9
#align(center)[
  #dragon-curve(9, step-size: 10, stroke-style: stroke(paint: gradient.linear(..color.map.crest, angle: 45deg), thickness: 4pt, cap: "square"))
]
#pagebreak(weak: true)
