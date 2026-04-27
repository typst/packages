#import "@preview/patatrac:0.5.0"

#set page(width: 11cm, height: 6cm)
#set text(size: 10pt)

#place(center + horizon, patatrac.cetz.canvas(length: 0.75mm, {
  import patatrac: *
  let draw = cetz.standard(
    circle: (stroke: 0.5pt),
    terrain: (stroke: 0.5pt),
    arrow: (stroke: 0.5pt, mark: (end: "stealth", fill: black, scale: 0.5)),
  )
  let debug = cetz.debug()
  
  let width = 2
  let floor = terrain(scale: 30, A: -0.2, B: 43%, C: 80%,
    // My personal favorite smooth-step function exp(-4tan(x^3 pi/2))
    x => 0.25 + if x < 0 { 1.0 } 
    else if x > width { 0.0 } 
    else { calc.exp(-4*calc.tan(calc.pow(x/width, 3)*calc.pi/2)) }, (0 - 1, width + 1)
  )
  let ball1 = stick(circle(5)("b"), floor("A"))
  let ball2 = stick(ball1, floor("B"))
  let ball3 = stick(ball1, floor("C"))
  let velocity1 = rotate(arrow(ball1("c"), 10), -90deg)
  let velocity2 = rotate(arrow(ball2("c"), 12), -90deg)
  let velocity3 = rotate(arrow(ball3("c"), 20), -90deg)

  draw(floor, fill: tiling(
    size: (2pt, 2pt), 
    pad(std.circle(radius: 0.1pt, fill: black, stroke: none), 1pt)
  ))
  draw(ball1)
  draw(ball2, ball3, stroke: (dash: "densely-dotted", thickness: 0.5pt))
  draw(velocity1, velocity2, velocity3)
  draw(point(velocity1("end"), rot: false), label: $std.math.arrow(v)_1$, align: left, lx: 1)
  draw(point(velocity2("end"), rot: false), label: $std.math.arrow(v)_2$, align: bottom + left)
  draw(point(velocity3("c"), rot: false), label: $std.math.arrow(v)_3$, align: bottom, ly: 1)
  draw(point(floor("A"), rot: false), radius: 1pt, label: pad($A$, 3pt), align: top)
  draw(point(floor("B"), rot: false), radius: 1pt, label: pad($B$, 1pt), align: top + right)
  draw(point(floor("C"), rot: false), radius: 1pt, label: pad($C$, 3pt), align: top)
}))