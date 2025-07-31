#import "@preview/cetz:0.3.2": draw
#import "gate.typ"

#let draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  let (x, y) = bl
  let (width, height) = (tr.at(0) - x, tr.at(1) - y)

  let r = (x + width, y + height / 2)

  let f = draw.group(name: id, {
    draw.merge-path(
      inset: 0.5em,
      fill: fill,
      stroke: stroke,
      name: id + "-path",
      close: true, {
        draw.line(bl, tl, r)
      }
    )
    
    draw.anchor("north", (tl, 50%, r))
    draw.anchor("south", (bl, 50%, r))
  })
  return (f, tl, tr, br, bl)
}

/// Draws a buffer gate. This function is also available as `element.gate-buf()`
/// 
/// For parameters, see #doc-ref("gates.gate")
/// #examples.gate-buf
#let gate-buf(
  x: none,
  y: none,
  w: none,
  h: none,
  inputs: 1,
  fill: none,
  stroke: black + 1pt,
  id: "",
  inverted: (),
  debug: (
    ports: false
  )
) = {
  gate.gate(
    draw-shape: draw-shape,
    x: x,
    y: y,
    w: w,
    h: h,
    inputs: inputs,
    fill: fill,
    stroke: stroke,
    id: id,
    inverted: inverted,
    debug: debug
  )
}

/// Draws a NOT gate. This function is also available as `element.gate-not()`
/// 
/// For parameters, see #doc-ref("gates.gate")
/// #examples.gate-not
#let gate-not(x: none,
  y: none,
  w: none,
  h: none,
  inputs: 1,
  fill: none,
  stroke: black + 1pt,
  id: "",
  inverted: (),
  debug: (
    ports: false
  )
) = {
  gate-buf(
    x: x,
    y: y,
    w: w,
    h: h,
    inputs: inputs,
    fill: fill,
    stroke: stroke,
    id: id,
    inverted: if inverted != "all" {inverted + ("out",)} else {inverted},
    debug: debug
  )
}