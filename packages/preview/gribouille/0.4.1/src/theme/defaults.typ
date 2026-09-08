// Default theme values consumed by the renderer.
// Each surface is stored as an element record (element-text / element-line /
// element-rect / element-blank). The renderer queries records via
// `resolve-element` in `theme.typ`; user themes override individual records or
// pass spot-overrides via the master `text` / `line` / `rect` keys.

#import "../utils/colour.typ": colour-mix
#import "elements.typ": (
  element-blank, element-geom, element-line, element-rect, element-text,
)
#import "theme.typ": default-stroke-thickness

// Read document colours injected by the typst-render Quarto extension via
// --input flags. Falls back to black/white when rendering standalone.
#let _tr-ink = {
  let v = sys.inputs.at("typst-render-foreground", default: "")
  if v == "" { black } else { rgb(v) }
}
#let _tr-paper = {
  let v = sys.inputs.at("typst-render-background", default: "")
  if v == "" { white } else { rgb(v) }
}

#let default-theme = (
  kind: "theme",
  name: "minimal",

  // Base colours
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),

  // Inherited base records (cascade parents for descendant surfaces)
  text: element-text(size: 9pt, weight: "regular"),
  line: element-line(stroke: default-stroke-thickness),
  rect: element-rect(),

  // Per-surface text records. Sizes are ratios of the parent surface (base
  // `text`), so setting `theme(text: element-text(size: ...))` rescales every
  // surface proportionally. At the default 9pt base these resolve to the
  // historical absolute sizes (axis-text 8pt, plot-title 12pt, ...).
  axis-text: element-text(size: (8 / 9) * 100%),
  axis-title: element-text(size: 100%),
  legend-text: element-text(size: (8 / 9) * 100%),
  legend-title: element-text(size: (8 / 9) * 100%),
  strip-text: element-text(size: (8 / 9) * 100%),
  plot-title: element-text(size: (12 / 9) * 100%, weight: "bold"),
  plot-subtitle: element-text(size: 100%),
  plot-caption: element-text(size: (8 / 9) * 100%),
  plot-tag: element-text(size: (11 / 9) * 100%, weight: "bold"),

  // Per-surface line records. Strokes are ratios of the parent surface (base
  // `line`), so setting `theme(line: element-line(stroke: ...))` rescales every
  // surface proportionally. At the default 0.5pt base these resolve to the
  // historical absolute thicknesses (legend-ticks 0.3pt, ...).
  panel-grid: element-line(stroke: 100%),
  // Minor gridlines halve the resolved `panel-grid` weight.
  // A bare stroke record carries no `kind`, so it inherits the parent's kind and
  // colour: a blank `panel-grid` (e.g., theme-classic / theme-void) stays blank
  // for minors too, while a coloured grid yields a half-weight minor in the
  // same colour. The per-weight cascade lets users override major/minor or
  // per-axis independently.
  panel-grid-minor: (stroke: 50%),
  axis-line: element-line(stroke: 100%),
  axis-ticks: element-line(stroke: 100%),
  // Thinner than the base to keep colour-bar ticks subtle.
  legend-ticks: element-line(stroke: (0.3 / 0.5) * 100%),

  // Per-surface rect records
  panel-background: element-rect(),
  plot-background: element-rect(),
  strip-background: element-rect(),
  legend-background: element-rect(),
  // Hairline frame around the colour-bar gradient. Ratio of the default
  // thickness so a base `rect` stroke override rescales it too.
  legend-bar: element-rect(stroke: (0.2 / 0.5) * 100%),

  // Layer-default aesthetics shared across supporting geoms. All-`none`
  // entries leave the per-geom hardcoded fallback in place; users override
  // selectively via `theme(geom: element-geom(fill: ..., linewidth: ...))`.
  geom: element-geom(),

  tick-length: 0.1cm,
  tick-labels: true,

  // Global legend placement; `auto` defers to the natural default (`"right"`).
  // Accepts the same values as `guide-legend(position:)` and is overridden by
  // any explicit `guides()` placement.
  legend-position: auto,

  // Base diameter of a swatch legend key glyph. Overridden per legend via
  // `guide-legend(key-size:)`; ignored by colourbar / size-ladder legends.
  legend-key: 0.24cm,
)

// Surface overrides for theme-minimal, the library default.
#let minimal-surfaces(ink, paper) = (
  panel-background: element-blank(),
  plot-background: element-rect(),
  panel-grid: element-line(
    colour: colour-mix(ink, paper, 0.7),
    stroke: (0.4 / 0.5) * 100%,
  ),
  axis-line: element-blank(),
  tick-length: 0cm,
)

#let merge-theme(user) = {
  let src = if user == none { minimal-surfaces(_tr-ink, _tr-paper) } else {
    user
  }
  let merged = default-theme
  for (k, v) in src.pairs() {
    merged.insert(k, v)
  }
  merged
}

// Resolve a theme colour key, falling back to black when unset.
#let resolve-colour(theme, key) = {
  let v = theme.at(key, default: none)
  if v == none { black } else { v }
}
