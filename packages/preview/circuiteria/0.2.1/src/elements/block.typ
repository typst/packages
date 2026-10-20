#import "/src/cetz.typ": draw
#import "element.typ"

#let draw-shape(id, tl, tr, br, bl, fill, stroke, radius: 0.5em) = {
  let f = draw.rect(
    radius: radius,
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
/// For other parameters description, see #doc-ref("element.elmt")
/// - radius (number, length, ratio, dictionary): The corner radius of the block. See CeTZ documentation for more information
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
  radius: 0.5em,
  stroke: black + 1pt,
  id: "",
  debug: (
    ports: false
  )
) = element.elmt(
  draw-shape: draw-shape.with(radius: radius),
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
