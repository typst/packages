#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let yearlen = 6cm
#let lineheight = -1.25cm
#let blockheight = .8

#let project(y: none, name, x, color, ..args) = ({
  let stroke-color = color.darken(50%)
  let fill-color = color.lighten(50%)
  let (y, dy) = y 
  let (x, dx) = x 
  node(
    ((x + dx / 2) * yearlen, y * lineheight),
    box(block(
      width: calc.abs(dx) * yearlen,
      height: dy * lineheight,
      stroke: stroke-color,
      fill: color.lighten(50%),
      ..args,
      name
    )),
  )
})

#let vline(y, label, x, ..args) = {
 edge(
    (x * yearlen, y.at(0) * lineheight), (rel: (0pt, y.at(1) * lineheight)), 
    label: label,
    label-pos: 0, // middle of the edge
    label-side: left, // type, not string
    ..args
  )
}
