#import "../src/lib.typ": *


= Linkst
\



#let trefoil = knot(
  node((0, 0), connect: ((1, 2), (0, 3, true))),
  node((2, 0), connect: ((1, 2, true), (0, 3))),
  node((1, calc.sqrt(3)*1), connect: ((1, 2, true), (0, 3))),
  edge(0, 1, bezier: ((0.2, 0),)),
  edge(1, 2, bezier: ((0.2, 0),)),
  edge(2, 0, bezier: ((0.2, 0),)),
  edge(0, 1, bezier: ((1, -0.8), (1, 0.8))),
  edge(1, 2, bezier: ((1, -0.8), (1, 0.8))),
  edge(2, 0, bezier: ((1, -0.8), (1, 0.8))),
)

#draw-knot(
  trefoil,
  style: (
    debug: true,
    scale: 1.5,
  )
)

#draw-knot(
  trefoil,
  style: (
    debug: "nodes",
    stroke: (dash: "dashed")
  )
)

#draw-knot(
  trefoil,
)


#pagebreak()

#let loop = knot(
  node((0, 0), name: "main", label: [#text([Hallo], size: 0.8em)], label-offset: (0, -0.1)),
  node((1, 0), label: [#text([$pi$], size: 1.5em)], label-offset: (0, -0.05)),
  edge(1, "main", arr: true, arc: (center: (0.5, 1), switch: true)),
  edge("main", 1, bezier: ((-0.5, 0),), arr: true),

  node((0.5, 1), label: [$A approx pi r^2$]),
)

#draw-knot(
  loop,
  style: (debug: true, scale: 2)
)

\

#draw-knot(
  loop,
  style: (scale: 1.5)
)

\

#let circle = knot(
    node((0, 0), label: [$2pi r$], label-offset: (-0.5, -0.1)),
    edge(0, 0, double: true, arc: (center: (1, 0), switch: true)),

    node((1, 0), label: [$A=pi r^2$])
)

#draw-knot(
  circle,
  style: (debug: true, connection-size: 0)
)

\

#draw-knot(
  circle,
  style: (connection-size: 0)
)

#draw-knot(
    node((0, 0), label: [$2pi r$], label-offset: (-1, -0.1)),
    node((1, 0)),
    node((1, -1)),
    edge(1, 0, double: true, arc: (center: (0.5, 0.01), switch: true)),
    edge(1, 2, double: true),

    style: (connection-size: 0)
)

\

#let spike = knot(
  node((0,0), connect: ((0, 1, "spike"),)),
  node((1,0)),
  node((0.5,-1)),

  edge(2, 0, double: true, arr: true),
  edge(0, 1, arr: true)
)

#draw-knot(
  spike,
  style: (debug: "nodes", scale: 3)
)

#pagebreak()

= Linkst Grids
\


#tangle(
  ("ltwist", "rtwist",),
  ("xscoupon", [$pi$], "xscoupon", [$pi$]),
  ("rtwist", "ltwist",),
  ("space", "rtwist",),
  ("scoupon", [$pi$]),
  ("space", "ltwist",),
  ("ltwist", "rtwist",),
  ("mcoupon", [$pi$]),
  ("rtwist", "ltwist",),
  ("ltwist", "space", "rtwist",),
  ("lcoupon", [$pi$]),
  ("rtwist", "space", "ltwist",),
  style: (thick: true),
)

#tangle(
  (">id", "<id"),
  (">ev", "<ev"),
  (">coev", "<coev"),
  (">lswitch", ">rswitch"),
  ("<lswitch", "<rswitch"),
)

test?

#tangle(
  (">id", (0, 0.3, [$V$], 0, -1.3, [$V$]), "<id", (0, 0.3, [$V^*$], 0, -1.3, [$V^*$]), ">ltwist", ">rtwist"),
  (),
  (">ev", "<ev"),
  (">coev", "<coev"),
  (">lswitch", ">rswitch"),
  style: (thick: true),
)





#pagebreak()

= Esters Spielplatz

#let reidemeister1 = knot(
  node((0, 0)),
  node((1, 2), connect: ((0, 1), (2, 3, true))),
  node((0, 4)),
  edge(0, 1, bezier:((0, 1, true),)),
  edge(1, 1, bezier: ((2, 2, true), (2, -2, true))),
  edge(1, 2, bezier:((-1, 1, true),)),
)

#let straightline = knot(
  node((0, 0)),
  node((0, 4)),
  edge(0,1)
)

#let reidemeister-scale = 0.7

#table(
  columns: 3,
  align: horizon,
  stroke: none,
  gutter: 5pt,
  [
    #draw-knot(
      reidemeister1,
      style: (
        scale: reidemeister-scale,
      )
    )
  ],
  $arrow.l.r$,
  [
    #draw-knot(
      straightline,
      style: (
        scale: reidemeister-scale,
      )
    )
  ]
)

#let straightlines = knot(
  node((0, 0)),
  node((0, 4)),
  node((2, 0)),
  node((2, 4)),
  edge(0, 1),
  edge(2, 3),
)

#let reidemeister2 = knot(
  node((0, 0)),
  node((2, 0)),
  node((1, 1), connect:((0, 2), (1, 3, true))),
  node((1, 3), connect:((0, 2), (1, 3, true))),
  node((0, 4)),
  node((2, 4)),
  
  edge(0, 2),
  edge(1, 2),
  edge(2, 3, bezier:((1, 1, true),)),
  edge(2, 3, bezier:((-1, 1, true),)),
  edge(3, 4),
  edge(3, 5),
)



#table(
  columns: 3,
  align: horizon,
  stroke: none,
  gutter: 5pt,
  [
    #draw-knot(
      reidemeister2,
      style: (
        scale: reidemeister-scale,
      )
    )
  ],
  $arrow.l.r$,
  [
    #draw-knot(
      straightlines,
      style: (
        scale: reidemeister-scale,
      )
    )
  ]
)



#let lemniscate = knot(
  node((0, 0), connect: ((1, 3, true), (2, 0,),)),
  edge(0, 0, bezier: ((-1, -1, true), (-1, 1, true))),
  edge(0, 0, bezier: ((1, 1, true), (1, -1, true))),
)

#draw-knot(lemniscate)

$angle.l #draw-knot(lemniscate, style:(scale: 0.2, bridge-space:1.3em, stroke: (thickness:0.06em))) angle.r$

#let draw-inline(knot, scale) = draw-knot(knot, style:(scale: .2 * scale, bridge-space:1.4em, stroke: (thickness:0.08em*scale))) 

#draw-inline(trefoil, .5)

#draw-inline(reidemeister1, .4)


#let circle = knot(
  node((0, 0)),
  node((1, 0)),
  edge(0, 1, arc:(center:(0.5, 0), switch:false),),
  edge(0, 1, arc:(center:(0.5, 0), switch:true),)
)

#draw-knot(circle)

#let hopf_link = knot(
  node((0, 0)),
  node((0, 1)),
  edge(0, 1, arc:(center:(0.5, .5), switch:false),),
  edge(1, 0, arc:(center:(0.5, 0.5), switch:true),),
  edge(0, 1, arc:(center:(-0.5, .5), switch:false),),
  edge(0, 1, arc:(center:(-0.5, 0.5), switch:true),)
)

#draw-knot(hopf_link)

#let hopf_link = knot(
  node((0, 0), connect: ((0, 1), (2, 3, true))),
  node((0, 1), connect: ((0, 1, true), (2, 3))),
  edge(1, 0, arc:(center:(0.5, .5), switch:true),),
  edge(1, 0, arc:(center:(0.5, 0.5), switch:false),),
  edge(1, 0, arc:(center:(-0.5, .5), switch:true),),
  edge(1, 0, arc:(center:(-0.5, 0.5), switch:false),)
)

#draw-knot(hopf_link, style: (debug: false, bridge-space: 0.25, connection-size: 0.25))

