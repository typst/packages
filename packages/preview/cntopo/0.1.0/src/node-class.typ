#import "util.typ": *
#import "shapes.typ": *

/// Router node class
///
/// ```example
/// #cetz.canvas({
///   node((0,2), class: "router")
///   node((2,2), class: "router", flat: false)
///   node((0,0), detail: "router")
///   node((2,0), detail: "router", flat: false)
/// })
/// ```
/// -> function
#let node-class-router = (sx, sy, stroke, fill) => {
  let arrs = (sx * 0.65, sy * 0.4)
  let arr = arrow.with(stroke: stroke, fill: fill)

  cetz.draw.rotate(45deg)
  arr((sx / 2, 0), arrs)
  cetz.draw.rotate(90deg)
  arr((-sx / 2, 0), arrs)
  cetz.draw.rotate(90deg)
  arr((sx / 2, 0), arrs)
  cetz.draw.rotate(90deg)
  arr((-sx / 2, 0), arrs)
}

/// Switch node class
///
/// ```example
/// #cetz.canvas({
///   node((0,2), class: "switch")
///   node((2,2), class: "switch", flat: false)
///   node((0,0), detail: "switch")
///   node((2,0), detail: "switch", flat: false)
/// })
/// ```
/// -> function
#let node-class-switch = (sx, sy, stroke, fill) => {
  let arrs = (sx * 0.75, sy * 0.4)
  let arr = arrow.with(stroke: stroke, fill: fill)

  arr((sx * 0.5, sy * 0.6), arrs)
  arr((sx * 0.25, -sy * 0.2), arrs)
  cetz.draw.rotate(180deg)
  arr((sx * 0.5, sy * 0.6), arrs)
  arr((sx * 0.25, -sy * 0.2), arrs)
  cetz.draw.rotate(135deg)
}

/// Hub node class
///
/// ```example
/// #cetz.canvas({
///   node((0,2), class: "hub")
///   node((2,2), class: "hub", flat: false)
///   node((0,0), detail: "hub")
///   node((2,0), detail: "hub", flat: false)
/// })
/// ```
/// -> function
#let node-class-hub = (sx, sy, stroke, fill) => {
  arrows((0, 0), (sx * 1.6, sy), stroke: stroke, fill: fill, type: "two")
}

/// Fast ethernet hub node class
///
/// ```example
/// #cetz.canvas({
///   node((0,2), class: "fe-hub")
///   node((2,2), class: "fe-hub", flat: false)
///   node((0,0), detail: "fe-hub")
///   node((2,0), detail: "fe-hub", flat: false)
/// })
/// ```
/// -> function
#let node-class-fe-hub = (sx, sy, stroke, fill) => {
  // TODO: standardized licon sizes
  arrow((0, 0), (sx * 1.6, sy), stroke: stroke, fill: fill)
}

/// Layer 3 switch node class
///
/// ```example
/// #cetz.canvas({
///   node((0,2), class: "l3-switch")
///   node((2,2), class: "l3-switch", flat: false)
///   node((0,0), detail: "l3-switch")
///   node((2,0), detail: "l3-switch", flat: false)
/// })
/// ```
/// -> function
#let node-class-l3-switch = (sx, sy, stroke, fill) => {
  let arrs = (sx * 0.5, sy * 0.3)
  let arrp = (sx * 0.6, 0)
  let arr = arrow.with(stroke: stroke, fill: fill)

  cetz.draw.circle(
    (0, 0),
    radius: (sx * 0.35, sy * 0.35),
    stroke: stroke,
    fill: fill,
  )
  arr(arrp, arrs)
  cetz.draw.rotate(45deg)
  arr(arrp, arrs)
  cetz.draw.rotate(45deg)
  arr(arrp, arrs)
  cetz.draw.rotate(45deg)
  arr(arrp, arrs)
  cetz.draw.rotate(45deg)
  arr(arrp, arrs)
  cetz.draw.rotate(45deg)
  arr(arrp, arrs)
  cetz.draw.rotate(45deg)
  arr(arrp, arrs)
  cetz.draw.rotate(45deg)
  arr(arrp, arrs)
}

/// Access point node class
///
/// ```example
/// #cetz.canvas({
///   node((0,2), class: "ap")
///   node((2,2), class: "ap", flat: false)
///   node((0,0), detail: "ap")
///   node((2,0), detail: "ap", flat: false)
/// })
/// ```
/// -> function
#let node-class-ap = (sx, sy, stroke, fill) => {
  wireless-wave((0, -sy * 2 / 7), (sx * 0.8, sy * .1), stroke: stroke)
}

/// Dual access point node class
///
/// ```example
/// #cetz.canvas({
///   node((0,2), class: "dual-ap")
///   node((2,2), class: "dual-ap", flat: false)
///   node((0,0), detail: "dual-ap")
///   node((2,0), detail: "dual-ap", flat: false)
/// })
/// ```
/// -> function
#let node-class-dual-ap = (sx, sy, stroke, fill) => {
  wireless-wave((0, -sy * 2 / 7), (sx * 0.8, sy * .1), stroke: stroke)
  wireless-wave((0, sy * 2 / 7), (sx * 0.8, sy * .1), stroke: stroke)
}

/// Mesh access point node class
///
/// As you can see, the text transformation doesn't work yet in 3d
/// ```example
/// #cetz.canvas({
///   node((0,2), class: "mesh-ap")
///   node((2,2), class: "mesh-ap", flat: false)
///   node((0,0), detail: "mesh-ap")
///   node((2,0), detail: "mesh-ap", flat: false)
/// })
/// ```
/// -> function
#let node-class-mesh-ap = (sx, sy, stroke, fill) => {
  cetz.draw.content((0, sy * 2 / 7), text(
    fill: stroke-to-paint(stroke),
    // TODO: dynamic font size
    // FIXME: skew text
    size: 1.5em * sx,
    weight: "bold",
  )[MESH])
  wireless-wave((0, -sy * 2 / 7), (sx * 0.8, sy * .1), stroke: stroke)
}

/// Dict containing all of the node class presets
/// -> dict
#let node-classes = (
  "router": node-class-router,
  "switch": node-class-switch,
  "hub": node-class-hub,
  "fe-hub": node-class-fe-hub,
  "l3-switch": node-class-l3-switch,
  "ap": node-class-ap,
  "dual-ap": node-class-dual-ap,
  "mesh-ap": node-class-mesh-ap,
)
