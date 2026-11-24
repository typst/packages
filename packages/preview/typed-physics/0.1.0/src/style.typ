// Visual defaults, and the two levels at which they can be overridden.
//
// A diagram style sets how a whole figure looks: the stroke weights, the force
// colors, the text sizes. A situation carries one, and every view may override
// it for that view alone.
//
// An element style sets how one declared thing looks. A block, a surface, or a
// force can carry its own, and it wins over the diagram style for that element
// and nothing else. Element styles use short names — `fill`, `stroke` — because
// they are already scoped to the thing they describe.

#import "validation.typ"

// ── Diagram defaults ─────────────────────────────────────────────────────────

#let theme = (
  // World geometry. CeTZ canvas units are centimetres, so a ramp declared with
  // `length: 6` is six centimetres along its incline.
  block-size: 1.0,

  // Surfaces and bodies
  surface-stroke: 0.8pt + rgb("#333333"),
  surface-fill: rgb("#F1F3F5"),
  hatch-stroke: 0.6pt + rgb("#868E96"),
  hatch-spacing: 0.28,
  hatch-length: 0.26,
  body-stroke: 0.9pt + rgb("#212529"),
  body-fill: rgb("#DDE6F5"),
  point-mass-fill: rgb("#212529"),

  // Angle marks and construction lines
  angle-stroke: 0.6pt + rgb("#495057"),
  angle-radius: 0.9,
  construction-stroke: (paint: rgb("#868E96"), thickness: 0.5pt, dash: "dashed"),
  right-angle-size: 0.18,

  // How far off a surface its length is written, on the side away from the
  // bodies resting on it.
  length-label-offset: 0.8,

  // Drafting-style dimensions added by a scene view.
  dimension-color: rgb("#868E96"),
  dimension-stroke: 0.7pt,
  dimension-extension-stroke: (thickness: 0.7pt, dash: "dashed"),
  dimension-text: (size: 9pt),

  // Force arrows. Lengths are in world units: the largest force on a body is
  // drawn at `force-length` and the rest in proportion, down to `force-floor`,
  // so a free-body diagram reads as a comparison and not just as a list.
  force-stroke: 1.1pt,
  force-length: 1.5,
  force-floor: 0.45,
  force-colors: (
    weight: rgb("#1971C2"),
    normal: rgb("#2F9E44"),
    friction: rgb("#E8590C"),
    applied: rgb("#6741D9"),
    tension: rgb("#5F3DC4"),
    component: rgb("#1971C2"),
  ),

  // Connectors. A rope is drawn as a thin line and a spring as a coil of
  // `spring-width` about the line between its ends.
  rope-stroke: 0.9pt + rgb("#495057"),
  spring-stroke: 0.9pt + rgb("#495057"),
  pulley-fill: rgb("#E9ECEF"),
  pulley-stroke: 0.9pt + rgb("#212529"),

  // Motion arrows, drawn in their own colour so a velocity is never mistaken
  // for a force.
  velocity-color: rgb("#0B7285"),
  velocity-stroke: 1.1pt,
  velocity-length: 1.2,

  // Text
  label-text: (size: 9pt),
  force-text: (size: 9pt),
  angle-text: (size: 9pt),
  scale: 1.0,
)

#let resolve-style(overrides) = {
  validation.validate-style-dictionary(overrides, "diagram")
  for key in overrides.keys() {
    assert(
      key in theme,
      message: "typed-physics: unknown style key \"" + key + "\"",
    )
  }
  if "force-colors" in overrides {
    assert(
      type(overrides.force-colors) == dictionary,
      message: "typed-physics: diagram style `force-colors:` must be a dictionary of force roles to colors",
    )
    for role in overrides.force-colors.keys() {
      assert(
        role in theme.force-colors,
        message: (
          "typed-physics: diagram style `force-colors:` has unknown role \""
            + role
            + "\"; accepted roles are "
            + theme.force-colors.keys().join(", ")
        ),
      )
      validation.validate-paint(
        overrides.force-colors.at(role),
        "diagram style `force-colors:` role \"" + role + "\"",
        "color",
      )
    }
  }
  for numeric-key in (
    "block-size",
    "hatch-spacing",
    "hatch-length",
    "angle-radius",
    "right-angle-size",
    "length-label-offset",
    "force-length",
    "force-floor",
    "velocity-length",
    "scale",
  ) {
    if numeric-key in overrides {
      validation.validate-positive-number(
        overrides.at(numeric-key),
        "diagram style",
        numeric-key,
      )
    }
  }
  for text-key in ("label-text", "force-text", "angle-text", "dimension-text") {
    if text-key in overrides {
      assert(
        type(overrides.at(text-key)) == dictionary,
        message: "typed-physics: diagram style `" + text-key + ":` must be a text-style dictionary",
      )
    }
  }
  for paint-key in (
    "surface-fill", "body-fill", "point-mass-fill", "pulley-fill",
    "dimension-color", "velocity-color",
  ) {
    if paint-key in overrides {
      validation.validate-paint(
        overrides.at(paint-key),
        "diagram style",
        paint-key,
        allow-none: true,
      )
    }
  }
  for stroke-key in (
    "surface-stroke", "hatch-stroke", "body-stroke", "angle-stroke",
    "construction-stroke", "dimension-stroke",
    "dimension-extension-stroke", "force-stroke", "rope-stroke",
    "spring-stroke", "pulley-stroke", "velocity-stroke",
  ) {
    if stroke-key in overrides {
      validation.validate-stroke(
        overrides.at(stroke-key),
        "diagram style",
        stroke-key,
      )
    }
  }
  let resolved-style = theme + overrides
  if "force-colors" in overrides {
    resolved-style.force-colors = theme.force-colors + overrides.force-colors
  }
  assert(
    resolved-style.force-floor <= resolved-style.force-length,
    message: "typed-physics: diagram style `force-floor:` must not exceed `force-length:`; lower the floor or increase the full arrow length",
  )
  resolved-style
}

#let scaled-diagram(
  diagram-style,
  diagram-content,
) = if diagram-style.scale == 1.0 {
    diagram-content
  } else {
    scale(diagram-style.scale * 100%, reflow: true, diagram-content)
  }

// ── Element styles ───────────────────────────────────────────────────────────

// Named-argument builders give editor completion while returning the same
// sparse dictionaries that a `style:` argument accepts directly.
#let _sparse-style(..entries) = {
  let declared-entries = (:)
  for (key, value) in entries.named() {
    if value != auto { declared-entries.insert(key, value) }
  }
  declared-entries
}

#let block-style(fill: auto, stroke: auto, label-text: auto) = _sparse-style(
  fill: fill,
  stroke: stroke,
  label-text: label-text,
)

#let surface-style(
  fill: auto,
  stroke: auto,
  hatch-stroke: auto,
  hatch-spacing: auto,
  hatch-length: auto,
) = _sparse-style(
  fill: fill,
  stroke: stroke,
  hatch-stroke: hatch-stroke,
  hatch-spacing: hatch-spacing,
  hatch-length: hatch-length,
)

#let force-style(color: auto, stroke: auto, length: auto, text: auto) = (
  _sparse-style(color: color, stroke: stroke, length: length, text: text)
)

#let connector-style(stroke: auto, fill: auto) = _sparse-style(
  stroke: stroke,
  fill: fill,
)

#let _validate-element-style(element-style, allowed-keys, element-description) = {
  validation.validate-element-style(
    element-style,
    allowed-keys,
    element-description,
  )
  for numeric-key in ("hatch-spacing", "hatch-length", "length") {
    if numeric-key in element-style {
      validation.validate-positive-number(
        element-style.at(numeric-key),
        element-description + " style",
        numeric-key,
      )
    }
  }
  for text-key in ("label-text", "text") {
    if text-key in element-style {
      assert(
        type(element-style.at(text-key)) == dictionary,
        message: "typed-physics: " + element-description + " style `" + text-key + ":` must be a text-style dictionary",
      )
    }
  }
  for paint-key in ("fill", "color") {
    if paint-key in element-style {
      validation.validate-paint(
        element-style.at(paint-key),
        element-description + " style",
        paint-key,
        allow-none: paint-key == "fill",
      )
    }
  }
  for stroke-key in ("stroke", "hatch-stroke") {
    if stroke-key in element-style {
      validation.validate-stroke(
        element-style.at(stroke-key),
        element-description + " style",
        stroke-key,
      )
    }
  }
  element-style
}

#let validate-block-style(element-style, name) = _validate-element-style(
  element-style,
  ("fill", "stroke", "label-text"),
  "block \"" + name + "\"",
)

#let validate-surface-style(element-style, name) = _validate-element-style(
  element-style,
  ("fill", "stroke", "hatch-stroke", "hatch-spacing", "hatch-length"),
  "surface \"" + name + "\"",
)

#let validate-force-style(element-style, on) = _validate-element-style(
  element-style,
  ("color", "stroke", "length", "text"),
  "force() on \"" + on + "\"",
)

#let validate-connector-style(element-style, name) = _validate-element-style(
  element-style,
  ("stroke", "fill"),
  "connector \"" + name + "\"",
)

// The three resolvers below turn a diagram style plus one element's overrides
// into the handful of values that drawing the element actually needs.

#let resolve-body-style(diagram-style, body-style) = (
  fill: body-style.at("fill", default: diagram-style.body-fill),
  stroke: body-style.at("stroke", default: diagram-style.body-stroke),
  point-mass-fill: body-style.at(
    "fill",
    default: diagram-style.point-mass-fill,
  ),
  label-text: diagram-style.label-text
    + body-style.at("label-text", default: (:)),
)

#let resolve-surface-style(diagram-style, surface-style) = (
  fill: surface-style.at("fill", default: diagram-style.surface-fill),
  stroke: surface-style.at("stroke", default: diagram-style.surface-stroke),
  hatch-stroke: surface-style.at(
    "hatch-stroke",
    default: diagram-style.hatch-stroke,
  ),
  hatch-spacing: surface-style.at(
    "hatch-spacing",
    default: diagram-style.hatch-spacing,
  ),
  hatch-length: surface-style.at(
    "hatch-length",
    default: diagram-style.hatch-length,
  ),
)

#let resolve-connector-style(diagram-style, connector-style, kind) = (
  stroke: connector-style.at(
    "stroke",
    default: if kind == "spring" {
      diagram-style.spring-stroke
    } else { diagram-style.rope-stroke },
  ),
  fill: connector-style.at("fill", default: diagram-style.pulley-fill),
)

// `role` is which force this is — weight, normal, friction, applied — and picks
// the color a force that declared none inherits.
#let resolve-force-style(diagram-style, force-style, role) = (
  color: force-style.at("color", default: diagram-style.force-colors.at(role)),
  stroke: force-style.at("stroke", default: diagram-style.force-stroke),
  length: force-style.at("length", default: diagram-style.force-length),
  text: diagram-style.force-text + force-style.at("text", default: (:)),
)

#let resolve-velocity-style(diagram-style, velocity-style) = (
  color: velocity-style.at("color", default: diagram-style.velocity-color),
  stroke: velocity-style.at("stroke", default: diagram-style.velocity-stroke),
  length: velocity-style.at("length", default: diagram-style.velocity-length),
  text: diagram-style.force-text + velocity-style.at("text", default: (:)),
)
