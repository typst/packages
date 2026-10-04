// Annotations that state a measured geometric quantity: a distance between two
// points, the angle between two directions, and the axes a frame is read in.

#import "../validation/lib.typ" as validation
#import "common.typ"

#let dimension(
  from: none,
  to: none,
  orientation: "aligned",
  offset: 0.6,
  side: auto,
  label: auto,
  label-position: "center",
  label-offset: 0.2,
  label-rotation: 0deg,
  label-fill: white,
  arrows: "both",
  arrow-tip: "stealth",
  arrow-scale: 0.5,
  extensions: true,
  extension-gap: 0.08,
  extension-stroke: auto,
  stroke: auto,
  color: auto,
  text: (:),
) = {
  let described-as = "dimension()"
  assert(
    from != none and to != none,
    message: "typed-physics: dimension() needs `from:` and `to:` attachment points",
  )
  common.validate-endpoint(from, described-as, "from")
  common.validate-endpoint(to, described-as, "to")
  assert(
    orientation in ("aligned", "horizontal", "vertical"),
    message: "typed-physics: dimension() orientation: must be \"aligned\", \"horizontal\", or \"vertical\"",
  )
  common.validate-distance(offset, described-as, "offset")
  let resolved-side = if side == auto {
    if orientation == "vertical" { "right" } else { "above" }
  } else {
    side
  }
  common.validate-side(resolved-side, described-as)
  assert(
    orientation != "horizontal" or resolved-side in ("above", "below"),
    message: "typed-physics: a horizontal dimension must use side: \"above\" or \"below\"",
  )
  assert(
    orientation != "vertical" or resolved-side in ("left", "right"),
    message: "typed-physics: a vertical dimension must use side: \"left\" or \"right\"",
  )
  assert(
    label-position in ("above", "below", "center"),
    message: "typed-physics: dimension() label-position: must be \"above\", \"below\", or \"center\"",
  )
  common.validate-distance(label-offset, described-as, "label-offset")
  common.validate-rotation(label-rotation, described-as, "label-rotation")
  common.validate-arrows(arrows, described-as)
  common.validate-arrow-tip(arrow-tip, described-as)
  common.validate-arrow-scale(arrow-scale, described-as)
  assert(
    type(extensions) == bool,
    message: "typed-physics: dimension() needs `extensions:` as true or false",
  )
  common.validate-distance(extension-gap, described-as, "extension-gap")
  common.validate-text-style(text, described-as)
  validation.validate-paint(
    label-fill,
    described-as,
    "label-fill",
    allow-none: true,
  )
  common.validate-color(color, described-as)
  common.validate-annotation-stroke(stroke, described-as)
  if extension-stroke != auto {
    validation.validate-stroke(
      extension-stroke,
      described-as,
      "extension-stroke",
    )
  }
  (
    kind: "dimension",
    from: from,
    to: to,
    orientation: orientation,
    offset: offset,
    side: resolved-side,
    label: label,
    label-position: label-position,
    label-offset: label-offset,
    label-rotation: label-rotation,
    label-fill: label-fill,
    arrows: arrows,
    arrow-tip: arrow-tip,
    arrow-scale: arrow-scale,
    extensions: extensions,
    extension-gap: extension-gap,
    extension-stroke: extension-stroke,
    stroke: stroke,
    color: color,
    text: text,
  )
}

// A direction reference names an element whose own direction is meant, that
// element reversed, or a direction in the world frame.
#let _validate-direction-reference(
  direction-reference,
  source-description,
  argument,
) = {
  if type(direction-reference) == std.angle { return }
  if type(direction-reference) == str {
    validation.validate-simple-reference(
      direction-reference,
      source-description,
      argument,
    )
    return
  }
  assert(
    type(direction-reference) == dictionary,
    message: (
      "typed-physics: "
        + source-description
        + " needs `"
        + argument
        + ":` as an element name, (on: \"name\", reversed: true), or an angle, got "
        + repr(direction-reference)
    ),
  )
  for key in direction-reference.keys() {
    assert(
      key in ("on", "reversed"),
      message: (
        "typed-physics: "
          + source-description
          + " has unknown `"
          + argument
          + ":` field \""
          + key
          + "\"; a direction reference accepts `on:` and `reversed:`"
      ),
    )
  }
  assert(
    "on" in direction-reference,
    message: (
      "typed-physics: "
        + source-description
        + " needs `"
        + argument
        + ":` to include `on:` an element name"
    ),
  )
  validation.validate-simple-reference(
    direction-reference.on,
    source-description,
    argument + ".on",
  )
  validation.validate-boolean(
    direction-reference.at("reversed", default: false),
    source-description,
    argument + ".reversed",
  )
}

// The marked angle sweeps counterclockwise from `from` to `to`, so which of the
// two angles between a pair of lines is meant is a matter of declaration order
// and of `reversed:`, never of the renderer guessing.
#let angle-mark(
  from: none,
  to: none,
  at: auto,
  radius: auto,
  label: auto,
  label-offset: (0, 0),
  label-rotation: 0deg,
  right-angle: auto,
  stroke: auto,
  color: auto,
  text: (:),
) = {
  let described-as = "angle-mark()"
  assert(
    from != none and to != none,
    message: "typed-physics: angle-mark() needs `from:` and `to:` directions",
  )
  _validate-direction-reference(from, described-as, "from")
  _validate-direction-reference(to, described-as, "to")
  if at != auto { common.validate-endpoint(at, described-as, "at") }
  if radius != auto { common.validate-length(radius, described-as, "radius") }
  assert(
    type(label-offset) == array
      and label-offset.len() == 2
      and label-offset.all(component => type(component) in (int, float)),
    message: (
      "typed-physics: angle-mark() needs `label-offset:` as an (x, y) pair of numbers"
    ),
  )
  common.validate-rotation(label-rotation, described-as, "label-rotation")
  validation.validate-boolean(
    right-angle,
    described-as,
    "right-angle",
    allow-auto: true,
  )
  common.validate-text-style(text, described-as)
  common.validate-color(color, described-as)
  common.validate-annotation-stroke(stroke, described-as)
  (
    kind: "angle-mark",
    from: from,
    to: to,
    at: at,
    radius: radius,
    label: label,
    label-offset: label-offset,
    label-rotation: label-rotation,
    right-angle: right-angle,
    stroke: stroke,
    color: color,
    text: text,
  )
}

// Coordinate axes drawn at a point, optionally turned into the frame of the
// element a body is resolved in, which is what an inclined-plane solution
// measures its components against.
#let axis(
  at: none,
  along: auto,
  angle: 0deg,
  length: 1.2,
  x-label: auto,
  y-label: auto,
  quadrants: "positive",
  arrow-tip: "stealth",
  arrow-scale: 0.5,
  label-offset: 0.24,
  stroke: auto,
  color: auto,
  text: (:),
) = {
  let described-as = "axis()"
  common.validate-endpoint(at, described-as, "at")
  if along != auto {
    _validate-direction-reference(along, described-as, "along")
  }
  common.validate-rotation(angle, described-as, "angle")
  common.validate-length(length, described-as, "length")
  assert(
    quadrants in ("positive", "both"),
    message: "typed-physics: axis() quadrants: must be \"positive\" or \"both\"",
  )
  common.validate-arrow-tip(arrow-tip, described-as)
  common.validate-arrow-scale(arrow-scale, described-as)
  common.validate-distance(label-offset, described-as, "label-offset")
  common.validate-text-style(text, described-as)
  common.validate-color(color, described-as)
  common.validate-annotation-stroke(stroke, described-as)
  (
    kind: "axis",
    at: at,
    along: along,
    angle: angle,
    length: length,
    "x-label": x-label,
    "y-label": y-label,
    quadrants: quadrants,
    arrow-tip: arrow-tip,
    arrow-scale: arrow-scale,
    label-offset: label-offset,
    stroke: stroke,
    color: color,
    text: text,
  )
}
