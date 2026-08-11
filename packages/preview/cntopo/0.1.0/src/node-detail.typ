#import "util.typ": *
#import "misc.typ": *

/// Secure node detail
///
/// ```example
/// #cetz.canvas({
///   node((0,2), detail: "secure")
///   node((2,2), detail: "secure", flat: false)
///   node((0,0), class: "secure")
///   node((2,0), class: "secure", flat: false)
/// })
/// ```
/// -> function
#let node-detail-secure = (sx, sy, stroke, fill) => {
  lock(
    (0, 0),
    (sx, sy),
    stroke: stroke,
    fill: fill,
    stroke-inner: stroke,
    fill-inner: stroke-to-paint(stroke),
  )
}

/// Cloud node detail
///
/// ```example
/// #cetz.canvas({
///   node((0,2), detail: "cloud")
///   node((2,2), detail: "cloud", flat: false)
///   node((0,0), class: "cloud")
///   node((2,0), class: "cloud", flat: false)
/// })
/// ```
/// -> function
#let node-detail-cloud = (sx, sy, stroke, fill) => {
  cloud(
    (0, 0),
    (sx, sy),
    stroke: stroke,
    fill: fill,
    stroke-inner: stroke,
    fill-inner: stroke-to-paint(stroke),
  )
}

/// Dict containing all of the node detail presets
/// -> dict
#let node-details = (
  "secure": node-detail-secure,
  "cloud": node-detail-cloud,
)
