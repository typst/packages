#import "@preview/patatrac:0.5.0"

#set page(width: 10cm, height: 7cm)
#set text(size: 11pt)

#place(center + horizon, patatrac.cetz.canvas(length: 0.75mm, {
  import patatrac: *
  let draw = patatrac.cetz.standard(
    polygon: (stroke: 0.5pt, fill: white),
    circle: (stroke: 0.5pt),
    trajectory: (stroke: (thickness: 0.5pt, dash: "dashed")),
    arrow: (mark: (end: "stealth", fill: black, scale: 0.75))
  )
  let debug = patatrac.cetz.debug()
  
  let cliff = rect(30, 60)
  let floor = place(rect(70, 10)("bl"), cliff("br"))
  let ball = move(place(circle(4)("b"), cliff("t")), 10, 0)
  let motion = trajectory(A: 50%,
    t => (ball("c")().x + 10*t, ball("c")().y - 2*t*t),
    (0,5.5)
  )
  let ball2 = place(ball("c"), motion("A"))

  let shape = polygon(
    cliff("bl"),
    cliff("tl"),
    cliff("tr"),
    floor("tl"),
    floor("tr"),
    floor("br"),
  )

  let velocity = rotate(arrow(ball("c"), 15), -90deg)

  draw(motion)
  draw(shape, fill: white)
  draw(shape, fill: tiling(
    size: (2pt, 2pt), 
    pad(std.circle(radius: 0.1pt, fill: black, stroke: none), 1pt)
  ))
  draw(ball, fill: white)
  draw(ball2)
  draw(point(ball("c")), radius: 1pt, label: $t=0"s"$, ly: 7)
  draw(point(ball2("c")), radius: 1pt, align: left, label: $t=0.5"s"$, lx: 6)
  draw(velocity)
  draw(point(velocity("end"), rot: false), align: left, label: $std.math.arrow(v)_0$, lx: 1)
}))