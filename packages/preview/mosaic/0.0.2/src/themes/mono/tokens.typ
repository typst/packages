// Mono design tokens.
// `colors` is this theme's stable palette export: one flat dictionary holding
// the six deck colors and the two status colors. The named constants above it
// are private mixing values: a derived theme should extend `colors`, never
// reach for them by name.
//
// Mono is the terminal voice: a deep slate canvas, off-white type, and a
// phosphor-green accent. It is the one bundled theme that is dark by default,
// which also keeps the canvas-luminance code path exercised without any
// palette override.
#let slate = rgb("#0b0f14")
#let panel = rgb("#121821")
#let fog = rgb("#d2dce5")
#let dim = rgb("#7b8a99")
#let grid-line = rgb("#22303d")
#let phosphor = rgb("#4cc38a")
#let colors = (
  canvas: slate,
  surface: panel,
  text: fog,
  muted: dim,
  line: grid-line,
  accent: phosphor,
  warning: rgb("#d29922"),
  error: rgb("#ff7b72"),
)
