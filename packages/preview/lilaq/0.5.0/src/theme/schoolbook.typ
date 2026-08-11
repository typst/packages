#import "@preview/tiptoe:0.3.1"
#import "../typing.typ": *

#let schoolbook = it => {
  let filter(value, distance) = value != 0 and distance >= 5pt
  let axis-args = (position: 0, filter: filter)
  

  show: set-tick(inset: 1.5pt, outset: 1.5pt, pad: 0.4em)
  show: set-spine(tip: tiptoe.stealth)
  show: set-grid(stroke: none)

  show: set-diagram(xaxis: axis-args, yaxis: axis-args)

  show: set-label(pad: none, angle: 0deg)
  show: show_(
    label.with(kind: "y"),
    it => place(bottom + right, dy: -100% - .0em, dx: -.5em, it)
  )
  show: show_(
    label.with(kind: "x"),
    it => place(left + top, dx: 100% + .0em, dy: .4em, it)
  )
  
  it
}
