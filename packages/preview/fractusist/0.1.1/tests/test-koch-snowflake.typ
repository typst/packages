#set document(date: none)


#import "/src/lib.typ": *


#set page(margin: 1cm)


= n = 1
#align(center)[
  #koch-snowflake(1, step-size: 40)
]


= n = 2
#align(center)[
  #koch-snowflake(2, step-size: 20, fill-style: gray, stroke-style: none)
]


= n = 3
#align(center)[
  #koch-snowflake(3, step-size: 8, fill-style: silver, stroke-style: orange + 3pt)
]
#pagebreak(weak: true)


= n = 4
#align(center)[
  #koch-snowflake(4, step-size: 5, fill-style: gradient.radial((orange, 0%), (silver, 100%), focal-center: (30%, 30%)), stroke-style: stroke(paint: gradient.linear(..color.map.crest, angle: 45deg), thickness: 2pt))
]
#pagebreak(weak: true)
