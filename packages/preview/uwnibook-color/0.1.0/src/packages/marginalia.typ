#import "../../packages/typst-marginalia/lib.typ" as marginalia // import marginalia package, use universe version as it contains the necessary functions

#import "../components.typ": is_even_page // import component

#let note_text_style(config) = (size: 0.8 * 11pt, style: "normal", weight: "regular", font: config._caption_font)
#let note_par_style = (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt)
#let page_margin = 15mm
#let block-style(config, loc) = if calc.even(loc.page()) {
  (
    stroke: (left: config._color_palette.accent + page_margin),
    outset: (left: page_margin, rest: 1pt),
    width: 100%,
  )
} else {
  (
    stroke: (right: config._color_palette.accent + page_margin),
    outset: (right: page_margin, rest: 1pt),
    width: 100%,
  )
}

#let _note(config, ..args) = context {
  marginalia.note(
    text-style: note_text_style(config),
    par-style: note_par_style,
    block-style: block-style.with(config),
    ..args,
  )
}

#let _notefigure(config) = marginalia.notefigure.with(text-style: note_text_style(config), par-style: note_par_style)
#let _wideblock = marginalia.wideblock

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
