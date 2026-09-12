// Shared utilities: colour palette and item-accessor helpers.
// Import with:  #import "common.typ": palette, _lab, _col
#let palette = (
  rgb("#aab4f7"),   // lavender
  rgb("#a7dd9b"),   // green
  rgb("#f9c74f"),   // amber
  rgb("#e64553"),   // red
  rgb("#74c7ec"),   // sky
)
#let _lab(it) = if type(it) == array { it.at(0) } else { it }
#let _col(it, i) = if type(it) == array and it.len() > 1 { it.at(1) } else { palette.at(calc.rem(i, palette.len())) }
