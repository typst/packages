#import "util.typ": *

/// Circular node shape
///
/// ```example
/// #cetz.canvas({
///   node((0,0), shape: "circle")
///   node((2,0), shape: "circle", flat: false)
/// })
/// ```
/// -> function
#let node-shape-circle = (sx, sy, radius, stroke, fill, flat) => {
  if not flat {
    cetz.draw.circle(
      (0, 0, 1),
      radius: (sx, sy),
      stroke: stroke,
      fill: fill,
    )
    cetz.draw.line(
      (sx, sy * 1 / 8, 1),
      (sx, 0, 0),
      (-sx, 0, 0),
      (-sx, sy * 1 / 8, 1),
      fill: fill,
      stroke: stroke,
    )
  }
  cetz.draw.circle(
    (0, 0),
    radius: (sx, sy),
    stroke: stroke,
    fill: fill,
  )
}

/// Hexagonal node shape
///
/// ```example
/// #cetz.canvas({
///   node((0,0), shape: "hex")
///   node((2,0), shape: "hex", flat: false)
/// })
/// ```
/// -> function
#let node-shape-hex = (sx, sy, radius, stroke, fill, flat) => {
  if not flat {
    cetz.draw.line(
      (-sx, 0, 0),
      (-sx, 0, 1),
      (-sx, sy * 1 / 8, 1),
      (-sx / 2, -sy, 1),
      (sx / 2, -sy, 1),
      (sx, sy * 1 / 8, 1),
      (sx, 0, 0),
      fill: fill,
      stroke: stroke,
    )
    cetz.draw.line(
      (-sx / 2, sy),
      (sx / 2, sy),
      (sx, 0),
      (sx / 2, -sy),
      (-sx / 2, -sy),
      (-sx, 0),
      (-sx / 2, sy),
      fill: fill,
      stroke: stroke,
    )
  } else {
    cetz.draw.polygon(
      (0, 0),
      6,
      stroke: stroke,
      fill: fill,
    )
  }
}

/// Square node shape
///
/// ```example
/// #cetz.canvas({
///   node((0,0), shape: "square")
///   node((2,0), shape: "square", flat: false)
/// })
/// ```
/// -> function
#let node-shape-square = (sx, sy, radius, stroke, fill, flat) => {
  if not flat {
    cetz.draw.line(
      (sx, sy, 0),
      (sx, sy, 1),
      (sx, -sy, 1),
      (-sx, -sy, 1),
      (-sx, -sy, 0),
      (-sx, 0, 0),
      fill: fill,
      stroke: stroke,
    )
    cetz.draw.line(
      stroke: stroke,
      (sx, -sy, 1),
      (sx, -sy, 0),
    )
  }

  cetz.draw.rect(
    (-sx, -sy),
    (sx, sy),
    stroke: stroke,
    fill: fill,
    radius: radius,
  )
}

/// Rectangular node shape
///
/// ```example
/// #cetz.canvas({
///   node((0,0), shape: "rect")
///   node((2,0), shape: "rect", flat: false)
/// })
/// ```
/// -> function
#let node-shape-rect = (sx, sy, radius, stroke, fill, flat) => {
  if not flat {
    cetz.draw.line(
      (sx, sy * 2 / 3, 0),
      (sx, sy * 2 / 3, 1),
      (sx, -sy * 2 / 3, 1),
      (-sx, -sy * 2 / 3, 1),
      (-sx, -sy * 2 / 3, 0),
      (-sx, 0, 0),
      fill: fill,
      stroke: stroke,
    )
    cetz.draw.line(
      stroke: stroke,
      (sx, -sy * 2 / 3, 1),
      (sx, -sy * 2 / 3, 0),
    )
  }

  cetz.draw.rect(
    (-sx, -sy * 2 / 3),
    (sx, sy * 2 / 3),
    stroke: stroke,
    fill: fill,
    radius: radius,
  )
}

/// Bridge node shape
///
/// ```example
/// #cetz.canvas({
///   node((0,0), shape: "bridge")
///   node((2,0), shape: "bridge", flat: false)
/// })
/// ```
/// -> function
#let node-shape-bridge = (sx, sy, radius, stroke, fill, flat) => {
  let s = override-stroke(stroke, miter-limit: 1)
  if not flat {
    cetz.draw.merge-path(
      stroke: s,
      fill: fill,
      close: true,
      {
        cetz.draw.line(
          (sx, sy * .9, 1),
          (sx, -sy, 1),
          (-sx, -sy, 1),
          (-sx, sy * .9, 0),
        )
        cetz.draw.arc(
          (-sx, sy * .9, 1),
          start: -145deg,

          delta: 112.5deg,
          radius: sx * 6 / 5,
        )
      },
    )
    cetz.draw.line(
      stroke: s,
      fill: fill,
      (sx, -sy, 0),
      (sx, -sy, 1),
      (sx, sy * .9, 1),
      (sx, sy * .9, 0),
      (sx, -sy, 0),
    )
  }
  cetz.draw.merge-path(
    stroke: override-stroke(stroke, miter-limit: 1),
    fill: fill,
    close: true,
    {
      cetz.draw.line((sx, sy * .9), (sx, -sy), (-sx, -sy), (-sx, sy * .9))
      cetz.draw.arc(
        (-sx, sy * .9),
        start: -145deg,

        delta: 112.5deg,
        radius: sx * 6 / 5,
      )
    },
  )
}

/// Firewall node shape
///
/// ```example
/// #cetz.canvas({
///   node((0,0), shape: "firewall")
///   node((2,0), shape: "firewall", flat: false)
/// })
/// ```
/// -> function
#let node-shape-firewall = (sx, sy, radius, stroke, fill, flat) => {
  let s = override-stroke(stroke, miter-limit: 1)
  if not flat {
    cetz.draw.rect(
      (-sx, -sy, 1),
      (sx, sy, 1),
      stroke: stroke,
      fill: fill,
    )
    cetz.draw.line(
      (-sx, sy, 0),
      (-sx, sy, 1),
      (sx, sy, 1),
      (sx, sy, 0),
      stroke: s,
      fill: fill,
    )
    for v in range(3) {
      let x = sx * 2 * v / 3 - sx + sx / 3
      cetz.draw.line(
        stroke: stroke,
        (x, sy, 0),
        (x, sy, 1),
      )
    }
    cetz.draw.line(
      (sx, sy, 0),
      (sx, sy, 1),
      (sx, -sy, 1),
      (sx, -sy, 0),
      stroke: s,
      fill: fill,
    )
    for h in range(5) {
      let y = sy * (h + 1) / 3 - sy
      cetz.draw.line(
        stroke: stroke,
        (sx, y, 0),
        (sx, y, 1),
      )
    }
  }
  cetz.draw.rect(
    (-sx, -sy),
    (sx, sy),
    stroke: stroke,
    fill: fill,
  )
  for h in range(6) {
    let y = sy * (h) / 3 - sy
    cetz.draw.line(
      stroke: stroke,
      (-sx, y),
      (sx, y),
    )
    for v in range(3) {
      let x = sx * 2 * v / 3 - sx + (sx * calc.rem(h, 2) / 3)
      cetz.draw.line(
        stroke: stroke,
        (x, y + sy / 3),
        (x, y),
      )
    }
  }
}

/// Dict containing all of the node shape presets
/// -> dict
#let node-shapes = (
  "circle": node-shape-circle,
  "hex": node-shape-hex,
  "square": node-shape-square,
  "rect": node-shape-rect,
  "bridge": node-shape-bridge,
  "firewall": node-shape-firewall,
)
