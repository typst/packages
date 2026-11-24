// Molecular color palettes, journal presets, and canvas sizing.

#import "validation.typ": _color-type, _invalid-input

// CPK hues bright enough to read on either background keep one value; the
// dark theme lifts the lightness of the hues that vanish on dark slides
// (N, Br, I; O slightly) without changing their identity.
#let _atom-color(symbol, theme: "light", fg: black) = {
  let dark = theme == "dark"
  if symbol == "N" or symbol == "n"      { if dark { rgb("#7A8CFF") } else { rgb("#3050F8") } }
  else if symbol == "O" or symbol == "o" { if dark { rgb("#FF5252") } else { rgb("#FF0D0D") } }
  else if symbol == "S" or symbol == "s" { rgb("#E6C800") }
  else if symbol == "P"                  { rgb("#FF8000") }
  else if symbol == "F"                  { rgb("#90E050") }
  else if symbol == "Cl"                 { rgb("#1FF01F") }
  else if symbol == "Br"                 { if dark { rgb("#D07C7C") } else { rgb("#A62929") } }
  else if symbol == "I"                  { if dark { rgb("#DC7CDC") } else { rgb("#940094") } }
  else { fg }
}

#let _label-color(style, theme: "light", fg: black) = {
  let dark = theme == "dark"
  if style == ""                             { fg }
  else if style.starts-with("#")            { rgb(style) }
  else if style == "red"                    { if dark { rgb("#FF5252") } else { rgb("#FF0D0D") } }
  else if style == "blue"                   { if dark { rgb("#7A8CFF") } else { rgb("#3050F8") } }
  else if style == "green"                  { if dark { rgb("#55C455") } else { rgb("#1FA51F") } }
  else if style == "black"                  { fg }
  else if style == "gray" or style == "grey"{ if dark { rgb("#A6A6A6") } else { rgb("#777777") } }
  else if style == "silver"                 { rgb("#C0C0C0") }
  else if style == "white"                  { white }
  else if style == "orange"                 { rgb("#FF8000") }
  else if style == "yellow"                 { rgb("#E6C800") }
  else if style == "brown"                  { if dark { rgb("#C98F5A") } else { rgb("#8B4513") } }
  else if style == "pink"                   { rgb("#FF69B4") }
  else if style == "purple"                 { if dark { rgb("#DC7CDC") } else { rgb("#940094") } }
  else if style == "cyan"                   { rgb("#00B4D8") }
  else if style == "lime"                   { rgb("#32CD32") }
  else if style == "teal"                   { if dark { rgb("#35BDBD") } else { rgb("#008080") } }
  else if style == "maroon"                 { if dark { rgb("#D06A6A") } else { rgb("#800000") } }
  else if style == "navy"                   { if dark { rgb("#8F9BFF") } else { rgb("#000080") } }
  else { _atom-color(style, theme: theme, fg: fg) }
}

// Resolves the fg/theme pair: an `auto` foreground inherits the surrounding
// text color (so molecules recolor with the slide theme), and an `auto`
// theme picks the dark palette when the foreground is light.
#let _resolve-foreground-theme(fg, theme) = {
  if fg != auto and type(fg) != _color-type {
    _invalid-input(
      "foreground",
      "expected auto or a color, got " + repr(fg),
      "Use fg: auto or pass a Typst color.",
    )
  }
  let resolved-fg = if fg == auto {
    if type(text.fill) == _color-type { text.fill } else { black }
  } else { fg }
  let resolved-theme = if theme == auto {
    if type(resolved-fg) == _color-type and oklab(resolved-fg).components().at(0) > 60% {
      "dark"
    } else {
      "light"
    }
  } else if theme == "light" or theme == "dark" {
    theme
  } else {
    panic("theme must be auto, \"light\", or \"dark\"")
  }
  (resolved-fg, resolved-theme)
}

// CeTZ canvas unit: one bond length is 30 pt at scale 1.
#let _canvas-scale(scale, bond-length) = (
  if bond-length == none { scale } else { bond-length }
) * 30pt

// Journal style presets, approximating the corresponding ChemDraw document
// stylesheets with the journals' published drawing settings: bond length
// (in 30 pt units), atom-label size, line width, and a Helvetica/Arial font
// stack. Journal presets default to monochrome line art; "default" applies
// nothing, so typed-smiles' own look is untouched. Presets only fill in
// arguments the caller left unset.
//
// Sources — ACS 1996: 14.4 pt bonds, 0.6 pt lines, 10 pt labels.
// RSC: 12.2 pt bonds, 0.5 pt lines, 7 pt labels.
// Nature Portfolio: 0.381 cm (10.8 pt) bonds, 0.021 cm (0.6 pt) lines,
// 6 pt labels. Wiley/Angewandte: 6 mm (17 pt) bonds, 3 mm element symbols
// (≈12 pt font); its line width and label size are scaled from the bond
// length, as the guideline only fixes a minimum.
#let _sans-stack = ("Helvetica", "Arial")
#let _style-preset(style) = {
  if style == "default" { none }
  else if style == "acs" {
    (bond-length: 14.4 / 30, font-size: 10pt, bond-stroke: 0.6pt, font: _sans-stack, color: false)
  } else if style == "rsc" {
    (bond-length: 12.2 / 30, font-size: 7pt, bond-stroke: 0.5pt, font: _sans-stack, color: false)
  } else if style == "nature" {
    (bond-length: 10.8 / 30, font-size: 6pt, bond-stroke: 0.6pt, font: _sans-stack, color: false)
  } else if style == "wiley" {
    (bond-length: 17.0 / 30, font-size: 12pt, bond-stroke: 0.7pt, font: _sans-stack, color: false)
  } else {
    panic("style must be \"default\", \"acs\", \"rsc\", \"nature\", or \"wiley\"")
  }
}
