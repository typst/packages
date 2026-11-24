// Annotations that comment on a figure rather than measure it: a callout that
// names a point, a brace that groups a span, and an arrow that traces a path.

#import "../validation/lib.typ" as validation
#import "common.typ"

#let callout(
  at: none,
  label: none,
  direction: "north-east",
  distance: 1.2,
  dot: true,
  frame: true,
  fill: white,
  arrow-tip: none,
  arrow-scale: 0.5,
  stroke: auto,
  color: auto,
  text: (:),
) = {
  let described-as = "callout()"
  common.validate-endpoint(at, described-as, "at")
  assert(
    label != none,
    message: (
      "typed-physics: callout() needs `label:` content such as [frictionless pulley]"
    ),
  )
  common.validate-distance(distance, described-as, "distance")
  validation.validate-boolean(dot, described-as, "dot")
  validation.validate-boolean(frame, described-as, "frame")
  validation.validate-paint(fill, described-as, "fill", allow-none: true)
  if arrow-tip != none { common.validate-arrow-tip(arrow-tip, described-as) }
  common.validate-arrow-scale(arrow-scale, described-as)
  common.validate-text-style(text, described-as)
  common.validate-color(color, described-as)
  common.validate-annotation-stroke(stroke, described-as)
  (
    kind: "callout",
    at: at,
    label: label,
    direction: common.direction-angle-of(direction, described-as, "direction"),
    distance: distance,
    dot: dot,
    frame: frame,
    fill: fill,
    "arrow-tip": arrow-tip,
    "arrow-scale": arrow-scale,
    stroke: stroke,
    color: color,
    text: text,
  )
}

// `side:` follows the same convention as an aligned dimension: "above" and
// "left" put the brace on the left of the direction from `from` to `to`.
#let brace(
  from: none,
  to: none,
  label: none,
  side: "above",
  offset: 0.25,
  amplitude: 0.3,
  pointiness: 60%,
  label-offset: 0.18,
  label-rotation: 0deg,
  stroke: auto,
  color: auto,
  text: (:),
) = {
  let described-as = "brace()"
  assert(
    from != none and to != none,
    message: "typed-physics: brace() needs `from:` and `to:` attachment points",
  )
  common.validate-endpoint(from, described-as, "from")
  common.validate-endpoint(to, described-as, "to")
  common.validate-side(side, described-as)
  common.validate-distance(offset, described-as, "offset")
  common.validate-length(amplitude, described-as, "amplitude")
  assert(
    type(pointiness) == ratio and pointiness >= 0% and pointiness <= 100%,
    message: (
      "typed-physics: brace() needs `pointiness:` as a ratio between 0% and 100%"
    ),
  )
  common.validate-distance(label-offset, described-as, "label-offset")
  common.validate-rotation(label-rotation, described-as, "label-rotation")
  common.validate-text-style(text, described-as)
  common.validate-color(color, described-as)
  common.validate-annotation-stroke(stroke, described-as)
  (
    kind: "brace",
    from: from,
    to: to,
    label: label,
    side: side,
    offset: offset,
    amplitude: amplitude,
    pointiness: pointiness,
    "label-offset": label-offset,
    "label-rotation": label-rotation,
    stroke: stroke,
    color: color,
    text: text,
  )
}

// One annotation covers a vector drawn between two points and a path drawn
// through several, because a path is the same line with waypoints and without
// an arrowhead.
#let arrow(
  from: none,
  to: none,
  via: (),
  label: none,
  label-position: "end",
  label-offset: 0.24,
  label-rotation: 0deg,
  arrows: "end",
  arrow-tip: "stealth",
  arrow-scale: 0.5,
  stroke: auto,
  color: auto,
  text: (:),
) = {
  let described-as = "arrow()"
  assert(
    from != none and to != none,
    message: "typed-physics: arrow() needs `from:` and `to:` attachment points",
  )
  common.validate-endpoint(from, described-as, "from")
  common.validate-endpoint(to, described-as, "to")
  assert(
    type(via) == array,
    message: (
      "typed-physics: arrow() needs `via:` as an array of attachment points"
    ),
  )
  for (waypoint-index, waypoint) in via.enumerate() {
    common.validate-endpoint(
      waypoint,
      described-as,
      "via." + str(waypoint-index),
    )
  }
  assert(
    label-position in ("start", "center", "end"),
    message: (
      "typed-physics: arrow() label-position: must be \"start\", \"center\", or \"end\""
    ),
  )
  common.validate-distance(label-offset, described-as, "label-offset")
  common.validate-rotation(label-rotation, described-as, "label-rotation")
  common.validate-arrows(arrows, described-as)
  common.validate-arrow-tip(arrow-tip, described-as)
  common.validate-arrow-scale(arrow-scale, described-as)
  common.validate-text-style(text, described-as)
  common.validate-color(color, described-as)
  common.validate-annotation-stroke(stroke, described-as)
  (
    kind: "arrow",
    from: from,
    to: to,
    via: via,
    label: label,
    "label-position": label-position,
    "label-offset": label-offset,
    "label-rotation": label-rotation,
    arrows: arrows,
    "arrow-tip": arrow-tip,
    "arrow-scale": arrow-scale,
    stroke: stroke,
    color: color,
    text: text,
  )
}
