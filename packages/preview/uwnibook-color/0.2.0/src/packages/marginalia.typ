#import "@preview/marginalia:0.2.0" // import marginalia package, use universe version as it contains the necessary functions

#let note_text_style(config) = (size: 0.8 * 11pt, style: "normal", weight: "regular", font: config._caption_font)
#let note_par_style = (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt)
#let block-style(config) = side => if side == "left" {
  (
    stroke: (left: config._color_palette.accent + config._page_margin),
    outset: (left: config._page_margin, rest: 1pt),
    width: 100%,
  )
} else {
  (
    stroke: (right: config._color_palette.accent + config._page_margin),
    outset: (right: config._page_margin, rest: 1pt),
    width: 100%,
  )
}

/// Format note marker
/// -> content
#let note-numbering(
  config,
  repeat: true,
  ..,
  /// -> int
  number,
) = {
  let markers = marginalia.note-markers
  let index = if repeat { calc.rem(number - 1, markers.len()) } else { number - 1 }
  let symbol = if index < markers.len() {
    markers.at(index)
  } else {
    str(index + 1 - markers.len())
    h(1.5pt)
  }
  return text(
    size: 5pt,
    style: "normal",
    font: config._symbol_font,
    fill: config._color_palette.accent,
    baseline: -.1em,
    symbol,
  )
}

#let _note(config, ..args) = marginalia.note(
  text-style: note_text_style(config),
  par-style: note_par_style,
  block-style: block-style(config),
  numbering: note-numbering.with(config),
  ..args,
)


#let _notefigure(config) = marginalia.notefigure.with(text-style: note_text_style(config), par-style: note_par_style)
#let _wideblock = marginalia.wideblock

