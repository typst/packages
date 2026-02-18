#import "@preview/cetz:0.3.2": draw
#import "../element.typ"
#import "../ports.typ": add-port

#let draw-shape(id, tl, tr, br, bl, fill, stroke, zigzags: 7) = {
  let (x, y) = bl
  let (width, height) = (tr.at(0) - x, tr.at(1) - y)
  
  let pts = (
    (x, y + height / 2),
    (x + width * 0.2, y + height / 2),
  )
  
  for i in range(zigzags) {
    let xi = ((i+0.5) / zigzags * 0.6 + 0.2) * width + x
    let yi = y + height * calc.rem(i, 2)
    pts.push((xi, yi))
  }

  pts += (
    (x + width * 0.8, y + height / 2),
    (x + width, y + height / 2),
  )

  let f = draw.line(..pts, name: id, stroke: stroke)
  return (f, tl, tr, br, bl)
}

/// Draws a resistor
///
/// #examples.resistor
/// For other parameters description, see #doc-ref("element.elmt")
#let resistor(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    ports: false
  )
) = {
  let ports = (
    west: (
      (id: "west"),
    ),
    east: (
      (id: "east"),
    )
  )
  
  let ports-y = (
    "in": (h) => {h - h * (h-ratio / 200%)},
    "out": (h) => {h - h * (out-pct / 100%)}
  )
  
  element.elmt(
    draw-shape: draw-shape.with(),
    x: x,
    y: y,
    w: w,
    h: h,
    name: name,
    name-anchor: name-anchor,
    ports: ports,
    auto-ports: false,
    ports-y: ports-y,
    fill: fill,
    stroke: stroke,
    id: id,
    debug: debug
  )

  let in-pos = id+".start"
  let out-pos = id+".end"
  add-port(id, "west", ports.west.first(), in-pos)
  add-port(id, "east", ports.east.first(), out-pos)
}