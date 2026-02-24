#import "@preview/cetz:0.3.2": draw
#import "element.typ"

#let draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  let f = draw.rect(
    radius: 0.5em,
    inset: 0.5em,
    fill: fill,
    stroke: stroke,
    name: id,
    bl, tr
  )
  return (f, tl, tr, br, bl)
}

/// Draws a block element
///
/// #examples.block
/// For parameters description, see #doc-ref("element.elmt")
#let block(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  ports: (),
  ports-margins: (),
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    ports: false
  )
) = element.elmt(
  draw-shape: draw-shape,
  x: x,
  y: y,
  w: w,
  h: h,
  name: name,
  name-anchor: name-anchor,
  ports: ports,
  ports-margins: ports-margins,
  fill: fill,
  stroke: stroke,
  id: id,
  debug: debug
)