// src/turn.typ
// Turn module for rotating generic content (like math equations) 90 degrees

/// Renders arbitrary content rotated 90 degrees clockwise.
/// The bounding box automatically reflows to reserve the correct vertical space.
/// ideal for equations, figures, or complex nested content.
///
/// - token (dictionary): A token with type "turn" and text field (content).
/// - config (dictionary): The layout configuration.
/// -> content: Rotated content inside a container bounded horizontally by the column width.
#let render-turn(token, config) = {
  let heading-level = token.at("heading", default: none)
  let scales = config.sizing.heading-scales
  let font-scale = if heading-level == 1 { scales.at(0) } else if (
    heading-level == 2
  ) { scales.at(1) } else if (
    heading-level == 3
  ) { scales.at(2) } else { 1.0 }

  let is-str = type(token.text) == str
  let heading-str = heading-level != none and is-str
  let f-opt = if config.font != none { (font: config.font) } else { (:) }
  let size-opt = if heading-level != none {
    (size: config.sizing.char-box * font-scale)
  } else { (:) }
  let weight-opt = if (
    heading-level != none or token.at("bold", default: false)
  ) { (weight: "bold") } else { (:) }
  let style-opt = if token.at("italic", default: false) {
    (style: "italic")
  } else { (:) }

  let base = if is-str {
    text(
      ..f-opt,
      ..size-opt,
      ..weight-opt,
      ..style-opt,
      token.text,
    )
  } else {
    token.text
  }

  let styled = if is-str { base } else {
    let s = base
    if token.at("bold", default: false) { s = strong(s) }
    if token.at("italic", default: false) { s = emph(s) }
    s
  }

  let inner = rotate(90deg, reflow: true, styled)
  if font-scale != 1.0 and not heading-str {
    inner = scale(x: font-scale, y: font-scale, inner)
  }

  // We use a box with a fixed horizontal width (char-box) to keep it centered
  // in the vertical column, but let the height auto-calculate based on the rotated content.
  box(
    width: config.sizing.char-box * font-scale,
    align(center + horizon, inner),
  )
}

/// Default turn rendering module.
/// Bundles the renderer for "turn" tokens.
#let default-turn = (
  node-renderers: (
    "turn": render-turn,
  ),
)
