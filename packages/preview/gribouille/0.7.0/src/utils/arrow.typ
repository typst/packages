///! Arrowhead spec and drawing, shared by the line geoms and the text
///! connectors.
///!
///! Heads are drawn from a polyline already in canvas centimetres, so a
///! sampled bezier gets a head tangent to the curve and a `coord-radial`
///! panel gets one tangent to the projected arc.

#import "../deps.typ": cetz
#import "errors.typ": fail-enum, fail-range, fail-type

#let ARROW-ENDS = ("first", "last", "both")
#let ARROW-TYPES = ("open", "closed")

// Validate the `arrow()` arguments. Kept out of `arrow` itself because that
// function's `length`, `angle` and `type` parameters shadow the Typst builtins
// the checks need.
#let _validate(head-length, half-angle, ends, head-type) = {
  if type(head-length) != length {
    fail-type(
      "arrow",
      "length",
      head-length,
      "a length such as `4pt`",
      hint: "Use `6pt` or `0.2cm`; a bare number is not a length.",
    )
  }
  // Positive is the whole constraint: a head as long as the line it sits on is
  // ugly rather than wrong, so nothing caps it. The message says only that.
  if head-length <= 0pt {
    fail-type(
      "arrow",
      "length",
      head-length,
      "a positive length such as `4pt`",
    )
  }
  if type(half-angle) != angle {
    fail-type(
      "arrow",
      "angle",
      half-angle,
      "an angle such as `25deg`",
      hint: "Use `25deg`; the angle is the half-opening of the head.",
    )
  }
  if half-angle <= 0deg or half-angle >= 90deg {
    fail-range("arrow", "angle", half-angle, 0deg, 90deg)
  }
  if ends not in ARROW-ENDS {
    fail-enum("arrow", "ends", ends, ARROW-ENDS)
  }
  if head-type not in ARROW-TYPES {
    fail-enum("arrow", "type", head-type, ARROW-TYPES)
  }
}

/// Arrowhead spec for the line geoms and the text-geom connectors.
///
/// Pass the result to the `arrow` parameter of a line geom, where it marks the direction the line runs, or of a text geom, where it marks the connector running to its data point. The head takes the colour and thickness of the line it sits on, and stays solid under a dashed `linetype`.
///
/// - length: Head length along each wing (a Typst length).
/// - angle: Half-opening of the head, in `(0deg, 90deg)`. Smaller values give a narrower head.
/// - ends: Which end of the line carries a head: `"last"`, `"first"`, or `"both"`. On a multi-point geom the ends are the ends of the whole group, not of every join.
/// - type: `"open"` strokes a V; `"closed"` fills a triangle.
///
/// Returns: Arrow specification dictionary.
///
/// See also: `geom-segment`, `geom-curve`, `geom-spoke`, `geom-path`, `geom-line`, `geom-step`, `geom-text`, `geom-label`, `geom-typst`.
///
/// Three segments carrying an open head at their far end.
///
/// ```typst
/// #let d = (
///   (x: 0, y: 0, xend: 4, yend: 3),
///   (x: 0, y: 3, xend: 4, yend: 0),
///   (x: 2, y: 0, xend: 2, yend: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend"),
///   layers: (geom-segment(stroke: 1pt, arrow: arrow(length: 8pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// A closed head at both ends, marking a span rather than a direction.
///
/// ```typst
/// #let d = ((x: 1, y: 1, xend: 5, yend: 1),)
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend"),
///   layers: (
///     geom-segment(
///       stroke: 1pt,
///       arrow: arrow(length: 10pt, ends: "both", type: "closed"),
///     ),
///   ),
///   width: 10cm,
///   height: 4cm,
/// )
/// ```
#let arrow(length: 4pt, angle: 25deg, ends: "last", type: "open") = {
  _validate(length, angle, ends, type)
  (
    kind: "arrow",
    length: length,
    angle: angle,
    ends: ends,
    type: type,
  )
}

// Panic unless `spec` is an `arrow()` record or `none`. Called by every geom
// taking an `arrow` parameter so a wrong value fails at the call site rather
// than as a missing field halfway through the draw pass.
#let assert-arrow(scope, spec) = {
  if spec == none { return }
  let ok = (
    type(spec) == dictionary and spec.at("kind", default: none) == "arrow"
  )
  if not ok {
    fail-type(
      scope,
      "arrow",
      spec,
      "an `arrow()` specification, or `none`",
      hint: "Build it with `arrow()`, e.g. `arrow(length: 6pt, ends: \"both\")`.",
    )
  }
}

// The two wing points of a head whose tip sits at `anchor` and which opens
// back toward `towards`, at `half-angle` either side of the chord. `none` when
// the two points coincide, leaving no direction to point along.
#let _arrow-head-points(anchor, towards, head-length-cm, half-angle) = {
  let (ax, ay) = anchor
  let (tx, ty) = towards
  let dx = tx - ax
  let dy = ty - ay
  let chord = calc.sqrt(dx * dx + dy * dy)
  if chord < 1e-6 { return none }
  let ux = dx / chord
  let uy = dy / chord
  let cos-a = calc.cos(half-angle)
  let sin-a = calc.sin(half-angle)
  (
    (
      ax + head-length-cm * (ux * cos-a - uy * sin-a),
      ay + head-length-cm * (uy * cos-a + ux * sin-a),
    ),
    (
      ax + head-length-cm * (ux * cos-a + uy * sin-a),
      ay + head-length-cm * (uy * cos-a - ux * sin-a),
    ),
  )
}

// Draw one head with its tip at `anchor`, opening back toward `towards`.
#let draw-arrow-head(anchor, towards, spec, colour, thickness) = {
  let wings = _arrow-head-points(
    anchor,
    towards,
    spec.length / 1cm,
    spec.angle,
  )
  if wings == none { return }
  let (left, right) = wings
  let stroke = (paint: colour, thickness: thickness)
  if spec.type == "closed" {
    cetz.draw.line(
      left,
      anchor,
      right,
      close: true,
      fill: colour,
      stroke: stroke,
    )
  } else {
    cetz.draw.line(left, anchor, right, stroke: stroke)
  }
}

// The first point walking from `idx` by `step` that is far enough from
// `pts.at(idx)` to give a direction. `none` when every candidate coincides,
// which is how a degenerate line skips its head.
#let _direction-point(pts, idx, step) = {
  let (ax, ay) = pts.at(idx)
  let i = idx + step
  while i >= 0 and i < pts.len() {
    let (px, py) = pts.at(i)
    let dx = px - ax
    let dy = py - ay
    if dx * dx + dy * dy > 1e-12 { return pts.at(i) }
    i += step
  }
  none
}

// Draw the heads `spec` asks for on the canvas-cm polyline `pts`. A `none`
// spec draws nothing, so callers can pass the layer parameter straight
// through.
#let draw-arrow-heads(pts, spec, colour, thickness) = {
  if spec == none or pts.len() < 2 { return }
  if spec.ends == "last" or spec.ends == "both" {
    let towards = _direction-point(pts, pts.len() - 1, -1)
    if towards != none {
      draw-arrow-head(pts.last(), towards, spec, colour, thickness)
    }
  }
  if spec.ends == "first" or spec.ends == "both" {
    let towards = _direction-point(pts, 0, 1)
    if towards != none {
      draw-arrow-head(pts.first(), towards, spec, colour, thickness)
    }
  }
}
