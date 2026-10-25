// Small content helpers for figures.  Import with:  #import "helpers.typ": icon, hstack
//
//   #icon("\u{f023}", fill: rgb("#8bc34a"))          // a Font Awesome glyph
//   #hstack(icon("\u{f023}"), [OR], icon("\u{f084}"))  // items in a row, centred vertically

// A glyph from an icon font (Font Awesome 7 Free by default).
#let icon(glyph, fill: auto, size: 34pt, font: "Font Awesome 7 Free") = text(font: font, size: size,
  ..if fill != auto { (fill: fill) }, glyph)

// Items side by side, centred on a common middle line.
#let hstack(..items, gap: 1em) = grid(columns: items.pos().len(), column-gutter: gap, align: horizon,
  ..items.pos())
