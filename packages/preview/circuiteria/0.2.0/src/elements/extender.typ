#import "@preview/cetz:0.3.2": draw
#import "element.typ"
#import "ports.typ": add-port

#let draw-shape(id, tl, tr, br, bl, fill, stroke, h-ratio: 75%, align-out: true) = {
  let (x, y) = bl
  let (width, height) = (tr.at(0) - x, tr.at(1) - y)

  let ratio = h-ratio / 100%

  tl = (x, y + height * ratio)
  let tr2 = (x + width, y + height * ratio)
  let br = (x + width, y)
  
  if align-out {
    (tr, tr2) = (tr2, tr)
  } else {
    (tr, tr2) = (tr, tr)
  }

  let f = draw.group(name: id, {
    draw.merge-path(
      inset: 0.5em,
      fill: fill,
      stroke: stroke,
      close: true,
      draw.line(tl, tr2, br, bl)
    )
    draw.anchor("north", (tl, 50%, tr2))
    draw.anchor("south", (bl, 50%, br))
    draw.anchor("west", (tl, 50%, bl))
    draw.anchor("east", (tr2, 50%, br))
    draw.anchor("north-west", tl)
    draw.anchor("north-east", tr2)
    draw.anchor("south-east", br)
    draw.anchor("south-west", bl)
  })
  return (f, tl, tr, br, bl)
}

/// Draws a bit extender
///
/// #examples.extender
/// For other parameters description, see #doc-ref("element.elmt")
/// - h-ratio (ratio): The height ratio of the left side relative to the full height
/// - align-out (bool): If true, the output and input ports are aligned, otherwise, the output port is centered on the right side
#let extender(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  fill: none,
  stroke: black + 1pt,
  id: "",
  h-ratio: 75%,
  align-out: true,
  debug: (
    ports: false
  )
) = {
  let ports = (
    west: (
      (id: "in"),
    ),
    east: (
      (id: "out"),
    )
  )
  let out-pct = if align-out {h-ratio / 2} else {50%}
  let ports-y = (
    "in": (h) => {h - h * (h-ratio / 200%)},
    "out": (h) => {h - h * (out-pct / 100%)}
  )
  
  element.elmt(
    draw-shape: draw-shape.with(h-ratio: h-ratio, align-out: align-out),
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

  let in-pos = (rel: (0, h * (h-ratio / 200%)), to: id+".south-west")
  let out-pos = (id+".south-east", out-pct, id+".north-east")
  add-port(id, "west", ports.west.first(), in-pos)
  add-port(id, "east", ports.east.first(), out-pos)
}