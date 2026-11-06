// src/ruby.typ
// Ruby (furigana) rendering

#import "../components/char-box.typ": char-box

/// Renders a character with ruby (furigana) on the right side.
/// The overall box is strictly 1em × 1em, with the ruby text overflowing
/// into the gutter to the right. This ensures column pitch remains consistent.
///
/// - token (dictionary): Token with type "ruby", `text` (base), and `ruby` (reading).
/// - config (dictionary): The layout configuration.
/// -> content: Rendered ruby box.
#let render-ruby(token, config) = {
  let base-is-str = type(token.text) == str
  let base-chars = if base-is-str { token.text.clusters() } else {
    (token.text,)
  }
  let base-len = if base-is-str { base-chars.len() } else { 1 }
  let base-height = base-len * config.sizing.char-box

  let base-stack = stack(
    dir: ttb,
    spacing: 0pt,
    ..base-chars.map(ch => char-box(ch, config.font, config)),
  )

  let ruby-is-str = type(token.ruby) == str
  if (ruby-is-str and token.ruby == "") or token.ruby == none {
    return base-stack
  }

  let ruby-chars = if ruby-is-str { token.ruby.clusters() } else {
    (token.ruby,)
  }
  let ruby-len = ruby-chars.len()
  let ruby-height = ruby-len * config.sizing.ruby-size

  // Ruby text stack: characters are stacked top-to-bottom
  let ruby-stack = stack(
    dir: ttb,
    spacing: 0pt,
    ..ruby-chars.map(ch => {
      let ruby-char = if type(ch) == str {
        text(
          size: config.sizing.ruby-size,
          ..(if config.font != none { (font: config.font) } else { (:) }),
          features: config.features,
          ch,
        )
      } else { ch }
      box(
        width: config.sizing.ruby-size,
        height: config.sizing.ruby-size,
        align(center + horizon, ruby-char),
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
