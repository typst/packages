#import "@preview/ribon:0.1.0": *

#set page(width: 140mm, height: 70mm, margin: 0pt, fill: white)
#set text(font: "Libertinus Serif", size: 7pt)

#let sequence = "GGGAAACCCGGGAAACCC"
#let structure = "(((...)))(((...)))"
#let scene = data(layout(sequence, structure, method: "naview"))
#let revised = scene.points.enumerate().map(((index, point)) => {
  if index == 3 { (x: point.x - 0.15, y: point.y - 0.12) }
  else { point }
})
#scene.insert("points", revised)

#align(center + horizon, render-scene(
  scene,
  width: 136mm,
  height: 66mm,
  theme: varna-theme,
  numbering: none,
  show-ends: false,
))
