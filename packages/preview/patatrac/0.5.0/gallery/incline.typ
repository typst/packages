#import "@preview/patatrac:0.5.0"

#set page(width: 10cm, height: 6cm)
#set text(size: 15pt)

#place(center + horizon, patatrac.cetz.canvas(length: 0.5mm, {
  import patatrac: *
  let draw = cetz.standard(
    rect: (stroke: 0.75pt, fill: white),
    circle: (stroke: 0.75pt),
    arrow: (stroke: 0.75pt, mark: (end: "stealth", fill: black)),
    incline: (stroke: 0.75pt),
    rope: (stroke: 0.75pt),
  )

  let sideA = 20
  let sideB = 15
  let radiusC = 5
  let hang = 15

  let I = incline(150, 25deg)

  let A = rect(sideA,sideA)
  A = stick(A("bl"), I("tl"))
  A = slide(A, -40, 0)

  let centerC = anchors.slide(I("tr")(), hang, sideA/2 - radiusC)
  let C = place(circle(radiusC), centerC)
  let L = rope(C(), I("tr"))
  
  let B = move(place(rect(sideB, sideB), C("r")), 0, -40)
  let R = rope(A("r"), C("t"), B("t"))
  
  let tension1 = arrow(A("r"), 20)
  let tension2 = arrow(B("t"), 20)

  let dotted = tiling(
    size: (2pt, 2pt), 
    pad(std.circle(radius: 0.1pt, fill: black, stroke: none), 1pt)
  )

  draw(I, fill: dotted)
  draw(L, C, R, tension1, tension2)
  draw(point(tension1("end"), rot: false), lx: -8, ly: 2, label: $std.math.arrow(T)_1$, align: bottom)
  draw(point(tension2("c"), rot: false), lx: 10, label: $std.math.arrow(T)_2$, align: bottom)
  draw(point(C("c")), radius: 1pt)
  
  draw(axes(A("c"), 0, 40), stroke: (paint: black, thickness: 0.5pt, dash: "dashed")) 
  draw(A, B)
  draw(point(A("c")), label: $M$)
  draw(point(B("c")), label: $m$, ly: 1)
  
  let coord(a) = { let a = anchors.to-anchor(a); return (a.x, a.y) }
  cetz.angle.angle(label: $alpha$, radius: 30, label-radius: 38, stroke: 0.5pt, 
    coord(I("bl")), 
    coord(I("br")), 
    coord(I("tr")), 
  )
}))