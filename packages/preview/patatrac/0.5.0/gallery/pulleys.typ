#import "@preview/patatrac:0.5.0"

#set page(width: 10cm, height: 12cm)
#set text(size: 15pt)

#place(center + horizon, patatrac.cetz.canvas(length: 0.5mm, {
  import patatrac: *
  let draw = patatrac.cetz.standard()

  let ceiling = move(rect(130, 20), 30, 5)
  let radius = 15

  let C1 = move(circle(radius), 50, -30)
  let A = move(place(rect(15, 15), C1("r")), 0, -60)
  let L1 = rope(C1, anchors.y-inter-x(C1, ceiling("bl")))

  let C2 = circle(radius)
  C2 = stick(C2("r"), C1("l"))
  C2 = move(C2, 0, -50)

  let C3 = circle(radius)
  C3 = place(C3("r"), C2("c"))
  C3 = move(C3, 0, -50)

  let rope23 = rope(C2("c"), C3, (C3("l")().x, 0))
  let rope12 = rope(A("c"), C1("r"), C2("r"), (C2("l")().x, 0))

  let B = rect(20, 20)
  B = place(B, C3("c"))
  B = move(B, 0, -40)
  let ropeB = rope(B, C3("c"))

  draw(C1, C2, C3, stroke: 2pt)
  draw(rope12, stroke: 2pt + red.darken(30%))
  draw(rope23, stroke: 2pt + blue.darken(30%))
  draw(L1, ropeB, stroke: 2pt)
  draw(A, fill: red, stroke: 2pt + red.darken(30%))
  draw(B, fill: blue, stroke: 2pt + blue.darken(30%))

  let tensionA1 = arrow(A("t"), 20)
  let tensionA2 = arrow(C1("r"), 20, angle: -90deg)
  draw(stroke: 2pt + red.darken(30%),
    tensionA1, tensionA2,
    place(tensionA1, C2("r")),
    place(tensionA1, C2("l")),
    place(tensionA2, rope12("end")),
    place(tensionA2, C1("l")),
  )

  let tensionB1 = arrow(rope23("start"), 40, angle: -90deg)
  let tensionB2 = arrow(C3("r"), 40, angle: +90deg)
  draw(stroke: 2pt + blue.darken(30%),
    tensionB1,
    place(tensionB1, rope23("end")),
    tensionB2,
    place(tensionB2, C3("l"))
  )

  draw(point(rope23("end"), rot: false), label: math.arrow($T_1$), align: top + right, lx: -3, ly: -10)
  draw(point(tensionA1("end"), rot: false), label: math.arrow($T_2$), align: left, lx: 5, ly: -5)
  draw(point(C1("c")), point(C2("c")), point(C3("c")), radius: 2)
  draw(point(A("c")), label: text(fill: white, $m$), ly: 1)
  draw(point(B("c")), label: text(fill: white, $M$))

  import "@preview/fancy-tiling:1.0.0": diagonal-stripes
  draw(ceiling, 
    fill: diagonal-stripes(stripe-color: black, size: 10pt, thickness-ratio: 25%, angle: 60deg), 
    stroke: (bottom: 2pt + black)
  )
}))