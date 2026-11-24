// Argument checking shared by every annotation constructor.
//
// An annotation belongs to a view rather than to the physical situation, so it
// is validated where it is written: a misspelled side or an unknown arrow tip
// is reported against the annotation that declared it, not against the figure.

#import "../validation/lib.typ" as validation

#let accepted-arrow-tips = (
  "triangle", "stealth", "curved-stealth", "bar", "ellipse", "circle",
  "bracket", "diamond", "rect", "hook", "straight", "barbed", "plus",
  "star", "parenthesis", "x", ">", "<", "<>", "[]", "]", "[", "|",
  "o", "+", "*", ")>", ">>", ")",
)

#let accepted-text-keys = (
  "fill", "size", "font", "fallback", "style", "weight", "stretch",
  "tracking", "spacing", "baseline", "overhang", "top-edge",
  "bottom-edge", "lang", "region", "script", "dir", "hyphenate",
  "features", "costs",
)

#let validate-endpoint(endpoint, source-description, argument) = {
  assert(
    endpoint != none,
    message: (
      "typed-physics: "
        + source-description
        + " needs `"
        + argument
        + ":` as an attachment point such as \"A.top\" or an (x, y) point"
    ),
  )
  validation.validate-attachment(
    endpoint,
    source-description,
    argument,
    allow-coordinate: true,
  )
}

#let validate-arrows(arrows, source-description) = {
  assert(
    arrows in ("both", "start", "end", "none"),
    message: (
      "typed-physics: "
        + source-description
        + " arrows: must be \"both\", \"start\", \"end\", or \"none\""
    ),
  )
}

#let validate-arrow-tip(arrow-tip, source-description) = {
  assert(
    type(arrow-tip) == str and arrow-tip in accepted-arrow-tips,
    message: (
      "typed-physics: "
        + source-description
        + " has unknown `arrow-tip:` "
        + repr(arrow-tip)
        + "; use a built-in CeTZ mark such as \"stealth\", \"triangle\", or \"straight\""
    ),
  )
}

#let validate-arrow-scale(arrow-scale, source-description) = {
  assert(
    type(arrow-scale) in (int, float) and arrow-scale > 0,
    message: (
      "typed-physics: "
        + source-description
        + " needs a positive numeric `arrow-scale:`"
    ),
  )
}

#let validate-text-style(text-style, source-description) = {
  assert(
    type(text-style) == dictionary,
    message: (
      "typed-physics: " + source-description + " needs `text:` as a dictionary"
    ),
  )
  for key in text-style.keys() {
    assert(
      key in accepted-text-keys,
      message: (
        "typed-physics: "
          + source-description
          + " `text:` has unknown key \""
          + key
          + "\"; use a supported Typst text property"
      ),
    )
  }
}

#let validate-distance(distance, source-description, argument) = {
  assert(
    type(distance) in (int, float) and distance >= 0,
    message: (
      "typed-physics: "
        + source-description
        + " needs a non-negative numeric `"
        + argument
        + ":`"
    ),
  )
}

#let validate-length(distance, source-description, argument) = {
  assert(
    type(distance) in (int, float) and distance > 0,
    message: (
      "typed-physics: "
        + source-description
        + " needs a positive numeric `"
        + argument
        + ":`"
    ),
  )
}

#let validate-rotation(rotation, source-description, argument) = {
  assert(
    type(rotation) == std.angle,
    message: (
      "typed-physics: "
        + source-description
        + " needs `"
        + argument
        + ":` as an angle"
    ),
  )
}

#let validate-side(side, source-description) = {
  assert(
    side in ("above", "below", "left", "right"),
    message: (
      "typed-physics: "
        + source-description
        + " side: must be \"above\", \"below\", \"left\", or \"right\""
    ),
  )
}

#let validate-color(color, source-description) = {
  if color != auto { validation.validate-paint(color, source-description, "color") }
}

#let validate-annotation-stroke(annotation-stroke, source-description) = {
  if annotation-stroke != auto {
    validation.validate-stroke(annotation-stroke, source-description, "stroke")
  }
}

// The two directions an annotation can be told to point in: a compass name for
// the eight common ones, or an angle measured from the positive x axis.
#let compass-directions = (
  east: 0deg,
  "north-east": 45deg,
  north: 90deg,
  "north-west": 135deg,
  west: 180deg,
  "south-west": 225deg,
  south: 270deg,
  "south-east": 315deg,
)

#let direction-angle-of(direction, source-description, argument) = {
  if type(direction) == std.angle { return direction }
  assert(
    type(direction) == str and direction in compass-directions,
    message: (
      "typed-physics: "
        + source-description
        + " needs `"
        + argument
        + ":` as an angle or one of "
        + compass-directions.keys().join(", ")
        + ", got "
        + repr(direction)
    ),
  )
  compass-directions.at(direction)
}
