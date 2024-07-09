#set document(date: none)


#import "/src/lib.typ": *


#set page(margin: 1cm)


= n = 1
#align(center)[
  #sierpinski-square-curve(1, step-size: 40)
]


= n = 2
#align(center)[
  #sierpinski-square-curve(2, step-size: 15, fill-style: gray, stroke-style: none)
]


= n = 3
#align(center)[
  #sierpinski-square-curve(3, step-size: 8, fill-style: silver, stroke-style: stroke(paint: orange, thickness: 3pt, cap: "round", join: "round"))
]
#pagebreak(weak: true)


= n = 4
#align(center)[
  #sierpinski-square-curve(4, step-size: 4, fill-style: gradient.radial((orange, 0%), (silver, 100%), focal-center: (30%, 30%)), stroke-style: stroke(paint: gradient.linear(..color.map.crest, angle: 45deg), thickness: 2pt))
]


= n = 5
#align(center)[
  #sierpinski-square-curve(5, step-size: 3, fill-style: gradient.linear(..color.map.crest, angle: 45deg), stroke-style: none)
]
#pagebreak(weak: true)
