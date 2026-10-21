// Visual annotations belong to a view rather than to the physical situation.

#import "validation.typ"

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
  assert(
    from != none and to != none,
    message: "typed-physics: dimension() needs `from:` and `to:` attachment points",
  )
  validation.validate-attachment(
    from,
    "dimension()",
    "from",
    allow-coordinate: true,
  )
  validation.validate-attachment(
    to,
    "dimension()",
    "to",
    allow-coordinate: true,
  )
  assert(
    orientation in ("aligned", "horizontal", "vertical"),
    message: "typed-physics: dimension() orientation: must be \"aligned\", \"horizontal\", or \"vertical\"",
  )
  assert(
    type(offset) in (int, float) and offset >= 0,
    message: "typed-physics: dimension() needs a non-negative numeric `offset:`",
  )
  let resolved-side = if side == auto {
    if orientation == "vertical" { "right" } else { "above" }
  } else {
    side
  }
  assert(
    resolved-side in ("above", "below", "left", "right"),
    message: "typed-physics: dimension() side: must be \"above\", \"below\", \"left\", or \"right\"",
  )
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
  assert(
    type(label-offset) in (int, float) and label-offset >= 0,
    message: "typed-physics: dimension() needs a non-negative numeric `label-offset:`",
  )
  assert(
    type(label-rotation) == std.angle,
    message: "typed-physics: dimension() needs `label-rotation:` as an angle",
  )
  assert(
    arrows in ("both", "start", "end", "none"),
    message: "typed-physics: dimension() arrows: must be \"both\", \"start\", \"end\", or \"none\"",
  )
  assert(
    type(arrow-tip) == str,
    message: "typed-physics: dimension() needs `arrow-tip:` as a CeTZ mark name",
  )
  let accepted-arrow-tips = (
    "triangle", "stealth", "curved-stealth", "bar", "ellipse", "circle",
    "bracket", "diamond", "rect", "hook", "straight", "barbed", "plus",
    "star", "parenthesis", "x", ">", "<", "<>", "[]", "]", "[", "|",
    "o", "+", "*", ")>", ">>", ")",
  )
  assert(
    arrow-tip in accepted-arrow-tips,
    message: (
      "typed-physics: dimension() has unknown `arrow-tip:` "
        + repr(arrow-tip)
        + "; use a built-in CeTZ mark such as \"stealth\", \"triangle\", or \"straight\""
    ),
  )
  assert(
    type(arrow-scale) in (int, float) and arrow-scale > 0,
    message: "typed-physics: dimension() needs a positive numeric `arrow-scale:`",
  )
  assert(
    type(extensions) == bool,
    message: "typed-physics: dimension() needs `extensions:` as true or false",
  )
  assert(
    type(extension-gap) in (int, float) and extension-gap >= 0,
    message: "typed-physics: dimension() needs a non-negative numeric `extension-gap:`",
  )
  assert(
    type(text) == dictionary,
    message: "typed-physics: dimension() needs `text:` as a dictionary",
  )
  validation.validate-paint(
    label-fill,
    "dimension()",
    "label-fill",
    allow-none: true,
  )
  if color != auto {
    validation.validate-paint(color, "dimension()", "color")
  }
  if stroke != auto {
    validation.validate-stroke(stroke, "dimension()", "stroke")
  }
  if extension-stroke != auto {
    validation.validate-stroke(
      extension-stroke,
      "dimension()",
      "extension-stroke",
    )
  }
  let allowed-text-keys = (
    "fill", "size", "font", "fallback", "style", "weight", "stretch",
    "tracking", "spacing", "baseline", "overhang", "top-edge",
    "bottom-edge", "lang", "region", "script", "dir", "hyphenate",
    "features", "costs",
  )
  for key in text.keys() {
    assert(
      key in allowed-text-keys,
      message: (
        "typed-physics: dimension() `text:` has unknown key \""
          + key
          + "\"; use a supported Typst text property"
      ),
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
