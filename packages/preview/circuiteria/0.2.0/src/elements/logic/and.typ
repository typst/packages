#import "@preview/cetz:0.3.2": draw
#import "gate.typ"

#let draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  let (x, y) = bl
  let (width, height) = (tr.at(0) - x, tr.at(1) - y)

  let t = (x + width / 2, y + height)
  let b = (x + width / 2, y)

  let f = draw.group(name: id, {
    draw.merge-path(
      inset: 0.5em,
      fill: fill,
      stroke: stroke,
      name: id + "-path",
      close: true, {
        draw.line(bl, tl, t)
        draw.arc-through((), (tr , 50%, br), b)
        draw.line((), b)
      }
    )
    
    draw.anchor("north", t)
    draw.anchor("south", b)
  })
  return (f, tl, tr, br, bl)
}

/// Draws an AND gate. This function is also available as `element.gate-and()`
/// 
/// For parameters, see #doc-ref("gates.gate")
/// #examples.gate-and
#let gate-and(
  x: none,
  y: none,
  w: none,
  h: none,
  inputs: 2,
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

/// Draws an NAND gate. This function is also available as `element.gate-nand()`
/// 
/// For parameters, see #doc-ref("gates.gate")
/// #examples.gate-nand
#let gate-nand(
  x: none,
  y: none,
  w: none,
  h: none,
  inputs: 2,
  fill: none,
  stroke: black + 1pt,
  id: "",
  inverted: (),
  debug: (
    ports: false
  )
) = {
  gate-and(
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