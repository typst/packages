// Default theme values consumed by the renderer.
// Each surface is stored as an element record (element-text / element-line /
// element-rect / element-blank). The renderer queries records via
// `resolve-element` in `theme.typ`; user themes override individual records or
// pass spot-overrides via the master `text` / `line` / `rect` keys.

#import "../utils/colour.typ": col-mix
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

  // Per-surface text records
  axis-text: element-text(size: 8pt),
  axis-title: element-text(size: 9pt),
  legend-text: element-text(size: 8pt),
  legend-title: element-text(size: 8pt),
  strip-text: element-text(size: 8pt),
  plot-title: element-text(size: 12pt, weight: "bold"),
  plot-subtitle: element-text(size: 9pt),
  plot-caption: element-text(size: 8pt),
  plot-tag: element-text(size: 11pt, weight: "bold"),

  // Per-surface line records
  panel-grid: element-line(stroke: default-stroke-thickness),
  axis-line: element-line(stroke: default-stroke-thickness),
  axis-ticks: element-line(stroke: default-stroke-thickness),
  // Thinner than `default-stroke-thickness` to keep colour-bar ticks subtle.
  legend-ticks: element-line(stroke: 0.3pt),

  // Per-surface rect records
  panel-background: element-rect(),
  plot-background: element-rect(),
  strip-background: element-rect(),
  legend-background: element-rect(),
  // Hairline frame around the colour-bar gradient.
  legend-bar: element-rect(stroke: 0.2pt),

  // Layer-default aesthetics shared across supporting geoms. All-`none`
  // entries leave the per-geom hardcoded fallback in place; users override
  // selectively via `theme(geom: element-geom(fill: ..., linewidth: ...))`.
  geom: element-geom(),

  tick-length: 0.1cm,
  tick-labels: true,
)

// Surface overrides for theme-minimal, the library default.
#let minimal-surfaces(ink, paper) = (
  panel-background: element-blank(),
  plot-background: element-rect(),
  panel-grid: element-line(colour: col-mix(ink, paper, 0.7), stroke: 0.4pt),
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

