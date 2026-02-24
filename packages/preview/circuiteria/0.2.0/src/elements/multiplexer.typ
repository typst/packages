#import "@preview/cetz:0.3.2": draw
#import "../util.typ"
#import "element.typ"
#import "ports.typ": add-port

#let draw-shape(id, tl, tr, br, bl, fill, stroke, h-ratio: 60%) = {
  let margin = (100% - h-ratio) / 2
  let tr2 = (tr, margin, br)
  let br2 = (br, margin, tr)
  let f = draw.group(name: id, {
    draw.merge-path(
      inset: 0.5em,
      fill: fill,
      stroke: stroke,
      close: true,
      draw.line(tl, tr2, br2, bl)
    )
    draw.anchor("north", (tl, 50%, tr2))
    draw.anchor("south", (bl, 50%, br2))
    draw.anchor("west", (tl, 50%, bl))
    draw.anchor("east", (tr2, 50%, br2))
    draw.anchor("north-west", tl)
    draw.anchor("north-east", tr2)
    draw.anchor("south-east", br2)
    draw.anchor("south-west", bl)
  })

  return (f, tl, tr, br, bl)
}

/// Draws a multiplexer
///
/// #examples.multiplexer
/// For other parameters description, see #doc-ref("element.elmt")
/// - entries (int, array): If it is an integer, it defines the number of input ports (automatically named with their binary index). If it is an array of strings, it defines the name of each input.
/// - h-ratio (ratio): The height ratio of the right side relative to the full height
#let multiplexer(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  entries: 2,
  h-ratio: 60%,
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    ports: false
  )
) = {
  let ports = ()
  let ports-y = (
    out: (h) => {h * 0.5}
  )

  if (type(entries) == int) {
    let nbits = calc.ceil(calc.log(entries, base: 2))
    for i in range(entries) {
      let bits = util.lpad(str(i, base: 2), nbits)
      ports.push((id: "in" + str(i), name: bits))
    }
  } else {
    for (i, port) in entries.enumerate() {
      ports.push((id: "in" + str(i), name: port))
    }
  }

  let space = 100% / ports.len()
  let l = ports.len()
  for (i, port) in ports.enumerate() {
    ports-y.insert(port.id, (h) => {h * (i + 0.5) / l})
  }
  
  element.elmt(
    draw-shape: draw-shape.with(h-ratio: h-ratio),
    x: x,
    y: y,
    w: w,
    h: h,
    name: name,
    name-anchor: name-anchor,
    ports: (west: ports, east: ((id: "out"),)),
    fill: fill,
    stroke: stroke,
    id: id,
    ports-y: ports-y,
    auto-ports: false,
    debug: debug
  )

  for (i, port) in ports.enumerate() {
    let pct = (i + 0.5) * space
    add-port(id, "west", port, (id+".north-west", pct, id+".south-west"))
  }
  add-port(id, "east", (id: "out"), (id+".north-east", 50%, id+".south-east"))
}