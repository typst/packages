#set document(date: none)


#import "/src/lib.typ": *


#set page(margin: 1cm)


= n = 1
#align(center)[
  #sierpinski-triangle(1, step-size: 40)
]


= n = 2
#align(center)[
  #sierpinski-triangle(2, step-size: 30, fill-style: gray, stroke-style: none)
]


= n = 3
#align(center)[
  #sierpinski-triangle(3, step-size: 20, fill-style: none, stroke-style: stroke(paint: gradient.linear(..color.map.crest, angle: 45deg), thickness: 4pt, join: "bevel"))
]


= n = 4
#align(center)[
  #sierpinski-triangle(4, step-size: 20, fill-style: gradient.radial((orange, 0%), (silver, 100%), focal-center: (30%, 30%)), stroke-style: stroke(paint: gradient.linear(..color.map.crest, angle: 45deg), thickness: 2pt, join: "bevel"))
]
#pagebreak(weak: true)


= n = 5
#align(center)[
  #sierpinski-triangle(5, step-size: 10, fill-style: none, stroke-style: stroke(paint: purple, thickness: 2pt, join: "bevel"))
]


= n = 6
#align(center)[
  #sierpinski-triangle(6, step-size: 6, fill-style: gradient.linear(..color.map.crest, angle: 45deg), stroke-style: none)
]
#pagebreak(weak: true)
