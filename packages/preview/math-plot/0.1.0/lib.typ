// math-plot — A plotting library for mathematics instruction.
// Forked from simple-plot 1.1.0 (MIT, Nathan Scheinmann).
// License: MIT

// ── Styles and defaults ────────────────────────────────────────────────────
#import "src/styles.typ": (
  default-style,
  merge-styles,
  marker-types,
  set-plot-defaults,
  reset-plot-defaults,
  _plot-defaults,
  _plot-default-keys,
)

// ── Transform utilities ────────────────────────────────────────────────────
#import "src/transform.typ": (
  to-cm,
  clip-segment,
  clip-segment-ellipse,
  merge-segment-runs,
  format-number,
  side-to-anchor,
)

// ── Axis helpers ───────────────────────────────────────────────────────────
#import "src/axes.typ": (
  nice-step,
  generate-ticks,
  draw-marker,
)

// ── Internal helpers ───────────────────────────────────────────────────────
#import "src/helpers.typ": (
  _resolve-fn,
  riemann-heights,
  riemann-clip-rect,
)

// ── Main plot function and convenience wrappers ────────────────────────────
#import "src/plot.typ": (
  plot,
  plot-fn,
  plot-rational,
  limit-schema,
  schema-lim,
  volume-of-revolution,
  solid-of-revolution,
)

// ── Series constructors ────────────────────────────────────────────────────
#import "src/series/func.typ": func-plot
#import "src/series/scatter.typ": scatter, data, line-plot
#import "src/series/parametric.typ": parametric
#import "src/series/fill.typ": fill-area, area-between, fill-closed
#import "src/series/reference.typ": note, vline, hline
#import "src/series/riemann.typ": riemann-sum
#import "src/series/zoom.typ": zoom
#import "src/series/quiver.typ": quiver
#import "src/series/contour.typ": contour

// ── 3D series constructors ────────────────────────────────────────────────
#import "src/3d/surface.typ": surface
#import "src/3d/parametric-surface.typ": parametric-surface
#import "src/3d/parametric-curve.typ": parametric-curve
#import "src/3d/quiver3d.typ": quiver3d
