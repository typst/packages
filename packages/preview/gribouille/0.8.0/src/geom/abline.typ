///! Oblique reference line from slope and intercept.
///!
///! Requires continuous x and y scales. The line is drawn across the full
///! trained x domain using `y = slope * x + intercept`. Under non-identity
///! axis transformations the line is sampled as a 64-point polyline so it
///! follows the warped axis correctly. Under `coord-radial` the line follows the
///! polar grid as a curve.

#import "../utils/errors.typ": assert-alpha, assert-linetype
#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "../coord/project.typ": axis-mapper, project-path
#import "../scale/train.typ": transform-inv
#import "../utils/flip.typ": user-axes, user-axis-key, user-point
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

#let spec = (
  reads: ("slope", "intercept", "colour", "alpha", "linewidth", "linetype"),
  extents: none,
)

/// Reference line described by slope and intercept.
///
/// The line runs across the full trained x domain. Requires continuous x and y scales; discrete scales are skipped silently. Under `coord-radial` the line follows the polar grid as a curve. To drive several lines from data, bind `slope` and/or `intercept` (and optionally `colour`, `alpha`, `linewidth`, `linetype`) through `aes` and pass `data`; one line is then drawn per row, with aesthetics resolved per row. Unlike `geom-vline` and `geom-hline`, mapped slope/intercept do not extend the trained scales.
///
/// - mapping: Aesthetic mapping built with `aes`. Bind `slope` and/or `intercept` to columns to draw a data-driven line per row.
/// - data: Layer-specific dataset for the mapped `slope`/`intercept` columns, or `none`.
/// - slope: Line slope, used when `slope` is not mapped.
/// - intercept: Line y intercept, used when `intercept` is not mapped. May be numeric or an ISO-8601 date/datetime/time string when a temporal y scale is active.
/// - colour: Line colour. `auto` inherits the theme `ink`.
/// - stroke: Line thickness (a Typst length).
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword (e.g., `"solid"`, `"dashed"`). `auto` honours the linetype scale.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping. Defaults to `false`.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-hline`, `geom-vline`, `geom-smooth`.
///
/// The `y = x` identity reference line over a noisy point cloud.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i + calc.rem(i, 2)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-abline(slope: 1, intercept: 0, colour: rgb("#cc0000")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Adjust `slope` and `intercept` to anchor a custom regression reference.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: 0.7 * i + 1 + calc.sin(i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-abline(slope: 0.7, intercept: 1, colour: rgb("#1b9e77")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Drive several lines from data: bind `slope`, `intercept` and `colour` through `aes` so each fit row draws its own coloured line.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: 0.7 * i + calc.sin(i)))
/// #let fits = (
///   (m: 0.5, b: 1, fit: "lo"),
///   (m: 1, b: 0, fit: "hi"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-abline(mapping: aes(slope: "m", intercept: "b", colour: "fit"), data: fits),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-abline(
  mapping: none,
  data: none,
  slope: 1,
  intercept: 0,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  key: auto,
  inherit-aes: false,
  ..args,
) = {
  assert-alpha("geom-abline", alpha)
  assert-linetype("geom-abline", linetype)
  make-layer(
    "abline",
    mapping: mapping,
    data: data,
    params: (
      slope: slope,
      intercept: intercept,
      colour: colour,
      stroke: stroke,
      alpha: alpha,
      linetype: linetype,
    )
      + split-aes-params("geom-abline", args, spec.reads),
    key: key,
    inherit-aes: inherit-aes,
  )
}

#let draw(layer, ctx) = {
  // Under flip, the renderer has already swapped trained.x and trained.y so
  // the user's original x scale lives on trained.y and vice versa. The
  // slope/intercept are in user-space, so `user-axes` hands back the scales
  // and ranges of the user's own x and y.
  let axes = user-axes(ctx)
  if axes == none { return }
  let (x-trained: user-x-trained, y-trained: user-y-trained) = axes
  if (
    user-x-trained.type != "continuous" or user-y-trained.type != "continuous"
  ) {
    return
  }
  // Sample slope/intercept in data space, regardless of any pre-stat warp.
  let _data-domain(t) = if t.at("pre-transformed", default: false) {
    let n = t.at("transform", default: "identity")
    (transform-inv(n, t.domain.at(0)), transform-inv(n, t.domain.at(1)))
  } else { t.domain }
  let (x-lo, x-hi) = _data-domain(user-x-trained)
  let raw-mapping = (ctx.resolve-mapping)(layer)
  let mapping = if raw-mapping == none { (:) } else { raw-mapping }
  let slope-col = mapping.at("slope", default: none)
  let intercept-col = mapping.at("intercept", default: none)
  let theme-ink = resolve-geom-colour(resolve-geom-defaults(ctx.theme))
  let _stroke-for(row) = (
    paint: resolve-channel(
      "colour",
      layer.params,
      mapping,
      ctx,
      row,
      theme-ink,
    ),
    thickness: resolve-channel(
      "linewidth",
      layer.params,
      mapping,
      ctx,
      row,
      0.6pt,
    ),
    dash: resolve-channel("linetype", layer.params, mapping, ctx, row, "solid"),
  )

  // Each entry pairs a (slope, intercept) with its stroke spec. Mapped: one
  // entry per data row, defaulting any unmapped term to its parameter, with
  // per-row stroke. Unmapped: a single entry from the parameters. `parse-number`
  // resolves ISO date/datetime/time intercepts to the numeric value the active
  // scale trains against; unparseable terms drop the line.
  let lines = if slope-col != none or intercept-col != none {
    let data = (ctx.resolve-data)(layer)
    data
      .map(row => {
        let slope = parse-number(if slope-col == none {
          layer.params.slope
        } else { row.at(slope-col, default: none) })
        let intercept = parse-number(if intercept-col == none {
          layer.params.intercept
        } else { row.at(intercept-col, default: none) })
        if slope == none or intercept == none { none } else {
          (slope: slope, intercept: intercept, stroke: _stroke-for(row))
        }
      })
      .filter(entry => entry != none)
  } else {
    (
      (
        slope: parse-number(layer.params.slope),
        intercept: parse-number(layer.params.intercept),
        stroke: _stroke-for((:)),
      ),
    )
  }
  if lines.len() == 0 { return }

  // `_pos` returns the cetz `(cx, cy)` for a user-space point.
  let map-x = axis-mapper(ctx, user-axis-key("x", ctx), space: "data")
  let map-y = axis-mapper(ctx, user-axis-key("y", ctx), space: "data")
  let _pos(ux, uy) = user-point(ctx, map-x(ux), map-y(uy))
  let radial = ctx.at("radial", default: none)
  let x-transform = user-x-trained.at("transform", default: "identity")
  let y-transform = user-y-trained.at("transform", default: "identity")
  let warped = x-transform != "identity" or y-transform != "identity"
  let _samples(slope, intercept) = if warped {
    range(0, 64).map(i => {
      let x = x-lo + i / 63 * (x-hi - x-lo)
      (x, slope * x + intercept)
    })
  } else {
    ((x-lo, slope * x-lo + intercept), (x-hi, slope * x-hi + intercept))
  }

  for line in lines {
    let slope = line.slope
    let intercept = line.intercept
    let stroke-spec = line.stroke
    let samples = _samples(slope, intercept)
    let pts = if radial != none {
      project-path(ctx, samples, space: "data")
    } else { samples.map(((x, y)) => _pos(x, y)) }
    if pts.len() >= 2 {
      cetz.draw.line(..pts, stroke: stroke-spec)
    }
  }
}
