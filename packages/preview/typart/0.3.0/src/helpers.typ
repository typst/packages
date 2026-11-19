// Small content helpers for figures.  Import with:  #import "helpers.typ": icon, hstack
//
//   #icon("\u{f023}", fill: green)                     // a Font Awesome glyph
//   #hstack(icon("\u{f023}"), [OR], icon("\u{f084}"))  // items in a row, centred vertically

#let icon(glyph, fill: auto, size: 2em, font: "Font Awesome 7 Free") = text(font: font, size: size,
  ..if fill != auto { (fill: fill) }, glyph)

#let hstack(..items, gap: 1em) = box(items.pos().map(item => box(baseline: 50%, item)).join(h(gap)))
