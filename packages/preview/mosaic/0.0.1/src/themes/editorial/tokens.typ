// Editorial design tokens.
// `colors` is this theme's stable palette export: one flat dictionary holding
// the six deck colors and the two status colors. The named constants above it
// are private mixing values: a derived theme should extend `colors`, never
// reach for them by name.
//
// Editorial is the magazine duotone: a cream canvas carrying ink type, with sage
// as the raised surface. The line color is a darker cream, which is what the
// numeral section's enormous ghost number is painted with.
#let cream = rgb("#f2eee5")
#let sage = rgb("#aebdb3")
#let ink = rgb("#1d201b")
#let moss = rgb("#6f7a6e")
#let parchment = rgb("#cbc4b2")
#let evergreen = rgb("#48604f")
#let colors = (
  canvas: cream,
  surface: sage,
  text: ink,
  muted: moss,
  line: parchment,
  accent: evergreen,
  warning: rgb("#E69F00"),
  error: rgb("#D55E00"),
)
