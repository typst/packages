#import "@preview/linkst:0.2.1": *

#set page(width: auto, height: auto, margin: 1cm)

#set heading(numbering: "(I)")
#show heading: it => [
  #set align(center)
  \~ #emph(it.body) \~
]


= Bridges

#let bridge-types = (none, "gap", "jump-50", "dive-30", "fade-70")
#let bridge-layers = (0, 0, 0, -1, -1)

#let height = (bridge-types.len() - 1) * 0.3
#let args = ()
#for (i, bridge-type) in bridge-types.enumerate() {
  let start-index = 2
  let add-index = start-index + 3 * i
  let pos = -i * height / bridge-types.len()

  args += (
    node(-1, pos),
    node(0, pos, layer: bridge-layers.at(i), style: (connection-size: 0.3, bridge-type: bridge-type)),
    node(1, pos, label: [#repr(bridge-type)], label-offset: (0.5, 0.025)),
    edge(0 + add-index, 1 + add-index, style: (stroke: blue)),
    edge(1 + add-index, 2 + add-index, style: (stroke: (paint: red, dash: "dashed"))),
  )
}

#draw(
  node(0, 0.25),
  node(0, -height),
  edge(0, 1),

  ..args,
  
  style: (
    scale: 2,
    debug: false,
    stroke: 2.5pt,
    connection-size: 0,
  )
)



#pagebreak()

= Edges

#table(
  columns: 2,
  stroke: none,
  [
    == node to node

    \ 
    
    
    #draw(
      node(0, 0),
      node(1, 0),
      edge(0, 1, bend: -60deg),
      
      node(0, -1),
      node(1, -1),
      edge(2, 3, bezier-rel: ((0, 0.3),)),
      
      node(0, -2),
      node(1, -2),
      edge(4, 5, bezier-rel: ((-0.5, 0.5), (0.5, -0.1))),
      
      /* node(0, -1),
      node(1, -1),
      edge(4, 5, arc: ()),
      
      node(0, -1),
      node(1, -1),
      edge(4, 5, arc-rel: ()),
      */

      style: (
        scale: 2,
        debug: "lines",
        stroke: 2.5pt,
        connection-size: 0.1,
      )
    )
  ],
  
  [
    == loops

    \ 
    
    
    #draw(
      node(0, -0.5),
      edge(0, 0, bend: -60deg, orientation: 90deg),
      
      node(0, -1, label: [none]),
      
      node(0, -2.5),
      edge(2, 2, bezier-rel: ((-2, 1), (2, 1)), orientation: 90deg),

      style: (
        scale: 2,
        debug: "lines",
        stroke: 2.5pt,
        connection-size: 0.2,
      )
    )
  ]
)



#pagebreak()

= Layers

#let n = 8
#let r = range(n)
#let step = 0.1
#let h = n * step

#draw(
  ..r.map(i => node(-h, i * step)),
  ..r.map(i => node(h, i * step)),
  ..r.map(i => edge(i, i + n, layer: 2 * i, style: (stroke: color.hsl(i / n * 80deg, 100%, 50%)))),

  ..r.map(i => node((i - n / 2 + 0.5) * step, -h/2 - step)),
  ..r.map(i => node((i - n / 2 + 0.5) * step, h*3/2)),
  ..r.map(i => edge(i + 2 * n, layer: 2 * i + 1, i + 3*n, style: (stroke: color.hsl(i / n * 80deg + 180deg, 100%, 50%)))),

  style: (
    scale: 2,
    debug: false,
    connection-size: 0.1,
    stroke: (thickness: step * 1.02cm * 2),
  )
)




#pagebreak()

= Debug Mode

#let args = arguments(
  node((0, 0), style: (connection-size:0.6,)),
  node((2, 0), style: (bridge-offset: 0.4, bridge-space: 0.6, bridge-type: "jump-30"), connect: ((0, 2), (1, 3, true))),
  node((1, calc.sqrt(3)), style: (connection-size: 0.4, bridge-offset: 0.3, bridge-space: 0.2), connect: ((0, 3), (1, 2, true))),
  node((3, calc.sqrt(3)), style: (bridge-offset: -0.15), connect: ((0, 3), (1, 2, true))),
  node((4, 0), style: (connection-size: 0.6,)),
  node((2, calc.sqrt(3) * 2), label: [$ pi $], label-offset: (0, 0.5), style: (bridge-type: "dive-30", bridge-space: 0.5), connect: ((0, 3, true), (1, 2))),

  edge(0, 1, bend: -20deg),
  edge(0, 2, bend: 38deg),
  edge(1, 2, bend: 70deg, style: (stroke: (paint: green))),
  edge(2, 5, bend: 38deg, style: (stroke: (paint: red))),
  edge(1, 3, bezier-abs: ((2, 1), (3, 0.8)), style: (stroke: (paint: red))),
  edge(2, 3, bezier-rel: ((0, 0.2), (0, -0.2))),
  edge(1, 4, bezier-abs: ((3, 0.5),), style: (stroke: (paint: green))),
  edge(3, 4, bezier-rel: ((-0.5, -0.5),), style: (stroke: (paint: green))),
  edge(3, 5, bezier-rel: ((-0.5, 0.5),)),
  edge(5, 5, bezier-abs: ((1, 4.5), (3, 4.5)), style: (stroke: (dash: "dashed", paint: rgb("#b39a29")))),
)

#draw(
  ..args,
  style: (
    scale: 1,
    stroke: 1pt + rgb("#29b3b3"),
    connection-size: 0.2,
  ),
)

#table(
  stroke: none,
  align: horizon,
  columns: 2,
  [
    #draw(
      ..args,
      style: (
        debug: "true",
        scale: 0.5,
        stroke: 1pt + rgb("#29b3b3"),
        connection-size: 0.2,
      ),
    )
  ],
  [
    #draw(
      ..args,
      style: (
        debug: "all",
        transform: (40deg, 0.8, (-2, -2),),
        scale: 0.5,
        stroke: 1pt + rgb("#29b3b3"),
        connection-size: 0.2,
      ),
    )
  ],
)



#pagebreak()

= Laughing Avocado

#let edge-range = 8
#let connect-range = range(edge-range).map(p => (p, p + edge-range))
#let connect-swap-range = range(edge-range).map(
  p => {
    let args = (p, if p == 0 { edge-range * 2 - 1 } else { p + edge-range - 1 })
    if p == 0 { args.push(true) }
    args
  }
)


#let args = arguments(
  node((0, 0), style: (connection-size: 2), connect: connect-range),
  node((4, -0.5), style: (connection-size: 1.5, bridge-space: 0.4, bridge-offset: -0.5, bridge-type: "fade-60"), connect: connect-swap-range),

  ..range(edge-range).map(p => edge(0, 1, bend: p * 150deg / edge-range - 20deg, style: (stroke: (thickness: 1pt, paint: color.hsl(p / edge-range * 260deg, 100%, 50%))))),
  ..range(edge-range).map(p => edge(0, 1, bezier-rel: ((-0.5 - p * 0.1 - p * p * 0.04, 0.7 + p * 0.15), (0.9 + p * 0.4, 0.8 + p * 0.18 - p * p * 0.01)), style: (stroke: 1pt + color.hsl((p + 1) / edge-range * 260deg, 100%, 50%)))),
)

#draw(
  ..args,
  style: (
    debug: true,
    scale: 0.5,
    stroke: 1pt + rgb("#29b3b3"),
    connection-size: 0.2,
  ),
)

#let eye = rotate(10deg)[#text(size: 30pt)[$sigma$]]

#draw(
  ..args,
  node(0.3, 0.2, label: [ #eye ]),
  node(3.7, -0.1, label: [ #scale(x: -100%)[ #eye ] ]),
  style: (
    scale: 0.5,
    stroke: 1pt + rgb("#29b3b3"),
    connection-size: 0.2,
    transform: (5deg,),
  ),
)