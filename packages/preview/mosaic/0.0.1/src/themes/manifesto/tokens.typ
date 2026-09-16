// Manifesto design tokens.
// `colors` is this theme's stable palette export: one flat dictionary holding
// the six deck colors and the two status colors. The named constants above it
// are private mixing values: a derived theme should extend `colors`, never
// reach for them by name.
//
// Manifesto stays monochrome red on warm white, but the monochrome is a
// ramp rather than one value: full red for text and accent, a faded red for
// subordinate type, and a pale wash for drawn rules, so hierarchy survives
// the single hue.
#let cream = rgb("#fffcf9")
#let red = rgb("#c83224")
#let faded = rgb("#cc7f70")
#let wash = rgb("#eed3ca")
// The status pair steers clear of the accent red: a golden yellow for
// warnings and a deep maroon for errors, so an accent, warning, and error
// component sitting side by side read as three different signals rather than
// three reds.
#let gold = rgb("#b58900")
#let maroon = rgb("#6e1b12")
#let colors = (
  canvas: cream,
  surface: cream,
  text: red,
  muted: faded,
  line: wash,
  accent: red,
  warning: gold,
  error: maroon,
)
