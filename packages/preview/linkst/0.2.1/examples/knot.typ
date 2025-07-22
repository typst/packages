#import "../src/user-lib.typ": *

#set page(width: auto, height: auto, margin: 1cm)

#set heading(numbering: "(I)")
#show heading: it => [
  #set align(center)
  \~ #emph(it.body) \~
]


= Example Knot

#let trefoil = knot(
  node(0, 0, connect: ((0, 1), (2, 3, true))),
  node(2, 0, connect: ((0, 1, true), (2, 3))),
  node(1, calc.sqrt(3), connect: ((0, 3, true), (1, 2))),
  
  edge(0, 1, bezier-rel: (0, 0.2), stroke: red),
  edge(2, 0, bezier-rel: ((-0.7, 1), (0.7, 1),), stroke: red),
  edge(2, 0, bezier-rel: (0, 0.2), stroke: blue),
  edge(1, 2, bezier-rel: ((-0.7, 1), (0.7, 1),), stroke: blue),
  edge(1, 2, bezier-rel: (0, 0.2), stroke: green),
  edge(0, 1, bezier-rel: ((-0.7, 1), (0.7, 1),), stroke: green),

  style: (
    stroke: 3pt,
    scale: 0.8,
    bridge-space: 0.6,
    transform: ((-1, -calc.sqrt(3) / 3),),
  )
)

#draw(trefoil)




#pagebreak()

= Trefoil

#let trefoil-bend = knot(
  node(0, 0, connect: ((0, 3), (1, 2, true))),
  node(2, 0, connect: ((0, 3, true), (1, 2))),
  node(1, calc.sqrt(3), connect: ((0, 3, true), (1, 2))),
  
  edge(0, 1, bend: -30deg),
  edge(1, 2, bend: -30deg),
  edge(2, 0, bend: -30deg),
  edge(0, 1, bend: -100deg),
  edge(1, 2, bend: -100deg),
  edge(2, 0, bend: -100deg),
)

#let trefoil-bezier = knot(
  node(0, 0, connect: ((0, 3), (1, 2))),
  node(2, 0, connect: ((0, 3), (1, 2))),
  node(1, calc.sqrt(3), connect: ((0, 3), (1, 2))),
  
  edge(0, 1, bezier-rel: ((0, 0.2),)),
  edge(1, 2, bezier-rel: ((0, 0.2),)),
  edge(2, 0, bezier-rel: ((0, 0.2),)),
  edge(0, 1, bezier-rel: ((-0.8, 1), (0.8, 1))),
  edge(1, 2, bezier-rel: ((-0.8, 1), (0.8, 1))),
  edge(2, 0, bezier-rel: ((-0.8, 1), (0.8, 1))),

  style: (
    transform: ((0, -calc.sqrt(3)/3*2), 60deg),
  ),
)

#let rot-scale(knot) = { knot.style.transform = (0.485, 60deg) + knot.style.transform; knot }

#table(
  columns: 3,
  align: horizon,
  stroke: none,
  [
    #draw(
      trefoil-bend,
      style: (debug: true)
    )
  ],
  [
    #draw(
      trefoil-bend,
      style: (debug: "lines")
    )
  ],
  [
    #draw(
      trefoil-bend,
    )
  ],
  [
    #draw(
      trefoil-bezier,
      rot-scale(trefoil-bezier),
      rot-scale(rot-scale(trefoil-bezier)),
      style: (debug: "all")
    )
  ],
  [
    #draw(
      trefoil-bezier,
      rot-scale(trefoil-bezier),
      rot-scale(rot-scale(trefoil-bezier)),
      style: (debug: "lines")
    )
  ],
  [
    #draw(
      trefoil-bezier,
      rot-scale(trefoil-bezier),
      rot-scale(rot-scale(trefoil-bezier)),
      style: (transform: (30deg,)),
    )
  ],
)



#pagebreak()

= Typical Knots

#let (black, red, green, blue) = (luma(30%), red, green, blue).map(c => rgb(c).desaturate(20%))

#let unknot = knot(
  node(0, 0),
  edge(0, 0, bend: 96deg, stroke: black, orientation: -90deg),

  style: (connection-size: 0.1),
)

#let hopf = knot(
  node((0, 0), connect: ((0, 1, true), (2, 3))),
  node((0, 1), connect: ((0, 1), (2, 3, true))),
  edge(0, 1, bend: 140deg, stroke: black),
  edge(1, 0, bend: 40deg, stroke: black),
  edge(1, 0, bend: 140deg, stroke: blue),
  edge(0, 1, bend: 40deg, stroke: blue),
)

#let trefoil = knot(
  node(0, 0, connect: ((0, 1), (2, 3, true))),
  node(2, 0, connect: ((0, 1, true), (2, 3))),
  node(1, calc.sqrt(3), connect: ((0, 3, true), (1, 2))),
  
  edge(0, 1, bezier-rel: (0, 0.2), stroke: red),
  edge(2, 0, bezier-rel: ((-0.7, 1), (0.7, 1),), stroke: red),
  edge(2, 0, bezier-rel: (0, 0.2), stroke: blue),
  edge(1, 2, bezier-rel: ((-0.7, 1), (0.7, 1),), stroke: blue),
  edge(1, 2, bezier-rel: (0, 0.2), stroke: green),
  edge(0, 1, bezier-rel: ((-0.7, 1), (0.7, 1),), stroke: green),

  style: (
    scale: 0.8,
    bridge-space: 0.6,
    transform: ((-1, -calc.sqrt(3) / 3),),
  )
)

#let figure-eight = knot(
  node(-1, 0),
  node(0, 0, connect: ((2, 3, true), (0, 1))),
  node(1, 0, connect: ((0, 2, true), (1, 3))),
  node(1.2, 0.7, connect: ((1, 3, true), (0, 2))),
  node(2.2, 0.7, connect: ((1, 3, true), (0, 2))),
  node(3.2, 0.7),

  edge(0, 1),
  edge(1, 2, bend: 0deg),
  edge(1, 2, bend: -70deg),
  edge(1, 3, bezier-rel: ((-0.5, -0.5), (0.1, -0.4))),
  edge(4, 2, bezier-rel: ((-0.5, -0.5), (0.1, -0.4))),
  edge(2, 3),
  edge(4, 3, bend: 0deg),
  edge(4, 3, bend: -70deg),
  edge(4, 5),

  style: (
    scale: 1,
    bridge-space: 0.5,
    bridge-type: "fade",
    bridge-color: luma(10%),
    connection-size: 0.3,
    transform: ((-1, 0),),
    stroke: 10pt + black,
  )
)

#draw(
  unknot,
  transform-knot(hopf, ((0, -1.6),)),
  transform-knot(trefoil, ((0, -3.8),)),
  transform-knot(figure-eight, ((0, -7.5), 1.3)),
  style: (
    stroke: 3pt,
  ),
)
