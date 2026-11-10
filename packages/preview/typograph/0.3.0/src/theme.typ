// Atomic diagram themes.
//
// A theme contains only semantic node presets and edge appearance. Shape
// builders live directly in node styles, so themes need no separate shape
// lookup table. The generic renderer never imports a concrete theme.

#import "style.typ": validate-node-style, validate-edge-style

#let _keys = ("palette", "node-presets", "edge-defaults", "edge-presets")

/// Creates a complete theme value. All fields are dictionaries:
///
/// - `palette`: named colours or paints exposed to document code
/// - `node-presets`: semantic node kind -> partial node style
/// - `edge-defaults`: partial style applied to every edge
/// - `edge-presets`: named edge preset -> partial edge style
#let theme(palette: (:), node-presets: (:), edge-defaults: (:), edge-presets: (:)) = {
  assert(type(palette) == dictionary, message: "theme palette must be a dictionary")
  assert(type(node-presets) == dictionary, message: "theme node-presets must be a dictionary")
  assert(type(edge-defaults) == dictionary, message: "theme edge-defaults must be a dictionary")
  assert(type(edge-presets) == dictionary, message: "theme edge-presets must be a dictionary")
  for (name, preset) in node-presets {
    let _ = validate-node-style(preset, source: "node preset " + repr(name))
  }
  let _ = validate-edge-style(edge-defaults, source: "theme edge-defaults")
  for (name, preset) in edge-presets {
    let _ = validate-edge-style(preset, source: "edge preset " + repr(name))
  }
  (palette: palette, node-presets: node-presets, edge-defaults: edge-defaults, edge-presets: edge-presets)
}

/// A theme with no semantic presets or appearance overrides.
#let neutral-theme = theme()

/// Validates a theme dictionary and supplies omitted fields. Using `theme()`
/// is preferred, but accepting plain dictionaries keeps user theme files terse.
#let resolve-theme(value) = {
  assert(type(value) == dictionary, message: "diagram theme must be a dictionary")
  let unknown = value.keys().filter(key => key not in _keys)
  assert(
    unknown.len() == 0,
    message: "diagram theme has unknown field(s): " + unknown.join(", ") + " — available: " + _keys.join(", "),
  )
  theme(
    palette: value.at("palette", default: (:)),
    node-presets: value.at("node-presets", default: (:)),
    edge-defaults: value.at("edge-defaults", default: (:)),
    edge-presets: value.at("edge-presets", default: (:)),
  )
}
