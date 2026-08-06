// Metropolis design tokens.
// `colors` is this theme's stable palette export: one flat dictionary holding
// the six deck colors and the two status colors. The named constants above it
// are private mixing values: a derived theme should extend `colors`, never
// reach for them by name.
//
// The accent is Metropolis's signature orange, so the status pair steers well
// clear of it: a golden yellow for warnings and a brick red for errors, each
// far enough from the accent and from one another to tell apart at a glance
// even as the pale panel tints components mix from them. The surface is a
// shade of warm gray below the paper canvas, so neutral cards and badges read
// as raised panels rather than disappearing into the page.
#let ink = rgb("#23373b")
#let orange = rgb("#f28e2b")
#let paper = rgb("#fafafa")
#let panel = rgb("#efede8")
#let dot = rgb("#667477")
#let track = rgb("#b8b1a8")
#let gold = rgb("#b58900")
#let brick = rgb("#b0413e")
#let colors = (
  canvas: paper,
  surface: panel,
  text: ink,
  muted: dot,
  line: track,
  accent: orange,
  warning: gold,
  error: brick,
)
