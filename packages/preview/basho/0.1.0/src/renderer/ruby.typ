// src/ruby.typ
// Ruby (furigana) rendering

#import "../core/char-box.typ": char-box

/// Renders a character with ruby (furigana) on the right side.
/// The overall box is strictly 1em × 1em, with the ruby text overflowing
/// into the gutter to the right. This ensures column pitch remains consistent.
///
/// - token (dictionary): Token with type "ruby", `text` (base), and `ruby` (reading).
/// - config (dictionary): The layout configuration.
/// -> content: Rendered ruby box.
#let render-ruby(token, config) = {
  let base-chars = token.text.clusters()
  let base-len = base-chars.len()
  let base-height = base-len * config.sizing.char-box

  let base-stack = stack(
    dir: ttb,
    spacing: 0pt,
    ..base-chars.map(ch => char-box(ch, config.font, config)),
  )

  if token.ruby == "" or token.ruby == none {
    return base-stack
  }

  let ruby-chars = token.ruby.clusters()
  let ruby-len = ruby-chars.len()
  let ruby-height = ruby-len * config.sizing.ruby-size

  // Ruby text stack: characters are stacked top-to-bottom
  let ruby-stack = stack(
    dir: ttb,
    spacing: 0pt,
    ..ruby-chars.map(ch => {
      box(
        width: config.sizing.ruby-size,
        height: config.sizing.ruby-size,
        align(center + horizon, text(
          size: config.sizing.ruby-size,
          ..(if config.font != none { (font: config.font) } else { (:) }),
          features: config.features,
          ch,
        )),
      )
    }),
  )

  // Calculate the required height to fit whichever is taller (base or ruby)
  let total-height = calc.max(base-height, ruby-height)

  // Wrap in a box. The height expands to prevent overlap with adjacent tokens.
  // Both base and ruby are vertically centered within this height.
  // Ruby flows to the right.
  box(
    width: config.sizing.char-box,
    height: total-height,
    clip: false,
    {
      place(left + horizon, base-stack)
      place(left + horizon, dx: config.sizing.ruby-offset, ruby-stack)
    },
  )
}
