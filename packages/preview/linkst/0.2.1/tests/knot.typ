#import "../src/user-lib.typ": *

#set page(width: auto, height: auto, margin: 1cm)



== example knot

#let trefoil = knot(
  node(0, 0, connect: ((0, 3), (1, 2, true))),
  node(2, 0, connect: ((0, 3, true), (1, 2))),
  node(1, calc.sqrt(3), connect: ((0, 3, true), (1, 2))),
  
  edge(0, 1, bend: -40deg, stroke: red),
  edge(1, 2, bend: -40deg, stroke: green),
  edge(2, 0, bend: -40deg, stroke: blue),
  edge(0, 1, bend: -100deg, stroke: green),
  edge(1, 2, bend: -100deg, stroke: blue),
  edge(2, 0, bend: -100deg, stroke: red),
)

#draw(
  trefoil,
)

#draw(
  trefoil,
  style: (debug: true)
)




#pagebreak()

== trefoil

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
    )
  ],
)


