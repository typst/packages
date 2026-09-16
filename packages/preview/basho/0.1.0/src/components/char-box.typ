// src/char-box.typ
// Base character box rendering

/// Wraps a single character in a 1em × 1em box with vertical OpenType features.
/// Alignment within the box depends on bracket type:
/// - Opening brackets (「 etc.) → left-aligned (or right-aligned depending on convention)
/// - Closing brackets (」 etc.) → right-aligned (or left-aligned depending on convention)
/// - All other characters → center-aligned
///
/// For U+2015 (Horizontal Bar / vertical dash), the text is rendered at
/// `rendering.dash-scale` size so consecutive dashes concatenate seamlessly.
///
/// - body (content): The character content to render.
/// - font (str): Font family name.
/// - config (dictionary): The layout configuration.
/// - h-align (alignment): Horizontal alignment override.
/// -> content: A box containing the vertically-oriented character.
#let char-box(
  body,
  font,
  config,
  h-align: center,
  v-align: horizon,
  height: none,
) = {
  let render-module = config.rendering.first()
  let f-opt = if font != none { (font: font) } else { (:) }

  // Half-width spaces render as a narrow vertical gap (default 0.25em)
  if body == "\u{0020}" {
    let space-width = config.at("space-width", default: 0.25em)
    return box(width: config.sizing.char-box, height: space-width)
  }

  let inner = if type(body) == str {
    if body == "―" {
      text(
        ..f-opt,
        size: render-module.dash-scale,
        features: config.features,
        body,
      )
    } else {
      text(
        ..f-opt,
        features: config.features,
        body,
      )
    }
  } else {
    body
  }

  let box-height = if height != none { height } else { config.sizing.char-box }
  box(
    width: config.sizing.char-box,
    height: box-height,
    clip: false,
    align(h-align + v-align, inner),
  )
}
