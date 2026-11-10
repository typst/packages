// src/renderer.typ
// Character box rendering with OpenType vertical glyph features

#import "../kinsoku/kinsoku.typ": is-forbidden-end, is-forbidden-start

#import "../components/char-box.typ": char-box

/// Renders a TCY (tate-chu-yoko / 縦中横) run: short horizontal text displayed
/// with normal horizontal glyphs, centered within a 1em × 1em slot in the
/// vertical column flow. No rotation, no vertical OpenType features.
/// Typically used for 2-digit numbers ("42") or short abbreviations ("IT").
/// Font size adapts to string length so text fits within the 1em column width.
///
/// - token (dictionary): A token with type "tcy" and text field.
/// - config (dictionary): The layout configuration.
/// -> content: Horizontal text in a 1em × 1em box.
#let render-tcy(token, config) = {
  let f-opt = if config.font != none { (font: config.font) } else { (:) }
  let tcy-module = config.tcy.first()
  let sizes = tcy-module.sizes

  let inner = if type(token.text) == str {
    let len = token.text.clusters().len()
    let sz = if len <= 2 { sizes.at(0) } else if len <= 3 { sizes.at(1) } else {
      calc.min(sizes.at(2) / 1em, 1.0 / len) * config.sizing.char-box
    }
    text(..f-opt, size: sz, token.text)
  } else {
    token.text
  }

  box(
    width: config.sizing.char-box,
    height: config.sizing.char-box,
    align(center + horizon, inner),
  )
}

/// Renders hanging punctuation (kinsoku shori): the character is drawn
/// in a zero-height box so it visually overflows into the gutter below
/// the column without affecting the column height.
///
/// - token (dictionary): A token with type "hanging" and text field.
/// - config (dictionary): The layout configuration.
/// -> content: Zero-height box with the character.
#let render-hanging(token, config) = {
  let f-opt = if config.font != none { (font: config.font) } else { (:) }
  box(
    width: config.sizing.char-box,
    height: 0pt,
    clip: false,
    align(center + top, text(
      ..f-opt,
      features: config.features,
      token.text,
    )),
  )
}

#import "ruby.typ": render-ruby

/// Renders a single token based on its type.
/// Dispatches "char" → char-box, "tcy" → render-tcy, "hanging" → render-hanging, "ruby" → render-ruby.
///
/// - token (dictionary): A token dictionary with at least a `type` and `text` field.
/// - config (dictionary): The layout configuration.
/// -> content: Rendered content for the token.
#let render-char-token(token, config) = {
  let f-opt = if config.font != none { (font: config.font) } else { (:) }

  let rendered = none
  for render-module in config.rendering {
    if (
      "node-renderers" in render-module
        and token.type in render-module.node-renderers
    ) {
      rendered = (render-module.node-renderers.at(token.type))(token, config)
      break
    }
  }

  if rendered == none {
    let heading-level = token.at("heading", default: none)
    let scales = config.sizing.heading-scales
    let font-scale = if heading-level == 1 { scales.at(0) } else if (
      heading-level == 2
    ) { scales.at(1) } else if (
      heading-level == 3
    ) { scales.at(2) } else { 1.0 }

    // Determine kinsoku-aware alignment from config.kinsoku character sets
    let check-opening(token) = is-forbidden-end(
      token,
      config.kinsoku.forbidden-end,
    )
    let check-closing(token) = is-forbidden-start(
      token,
      config.kinsoku.forbidden-start,
    )

    rendered = if token.type == "char" {
      // Determine horizontal alignment based on bracket type
      let h-align = if check-opening(token) { right } else if check-closing(
        token,
      ) { left } else { center }
      // Determine vertical alignment based on bracket type to fix spacing when compressed
      let v-align = horizon

      let cb = config.at("char-box-abs", default: config.sizing.char-box)
      let base = token.at("base-width", default: 1.0)
      let applied = token.at("compression-applied", default: 0pt)
      let box-height = base * cb - applied

      if heading-level != none {
        // Heading characters: scaled box
        let sz = config.sizing.char-box * font-scale
        box(
          width: sz,
          height: sz,
          align(h-align + v-align, text(
            ..f-opt,
            size: config.sizing.char-box * font-scale,
            features: config.features,
            weight: "bold",
            token.text,
          )),
        )
      } else {
        char-box(
          token.text,
          config.font,
          config,
          h-align: h-align,
          v-align: v-align,
          height: box-height,
        )
      }
    } else if token.type == "tcy" {
      render-tcy(token, config)
    } else if token.type == "hanging" {
      render-hanging(token, config)
    } else if token.type == "ruby" {
      render-ruby(token, config)
    } else if token.type == "heading-anchor" {
      box(
        width: 0pt,
        height: 0pt,
        clip: true,
        heading(
          level: token.level,
          outlined: true,
          bookmarked: true,
          token.body,
        ),
      )
    } else {
      none
    }
  }

  if rendered != none and token.type != "turn" {
    if token.at("bold", default: false) { rendered = strong(rendered) }
    if token.at("italic", default: false) { rendered = emph(rendered) }
    if "dest" in token { rendered = link(token.dest, rendered) }
  }

  let space-after = token.at("space-after", default: 0pt)
  if space-after != 0pt and rendered != none {
    rendered = stack(dir: ttb, spacing: 0pt, rendered, box(
      width: config.sizing.char-box,
      height: space-after,
    ))
  }

  rendered
}
