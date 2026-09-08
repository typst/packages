///! Quantile regression lines.
///!
///! Wraps \@stat-quantile with line rendering: one polyline per fitted
///! quantile τ. Use the `colour` aesthetic on the layer to differentiate
///! lines; otherwise all lines share the layer's `colour` parameter.

#import "../layer.typ": make-layer
#import "../stat/quantile.typ": stat-quantile

/// Quantile-regression layer: a fitted line per requested τ.
///
/// Default `quantiles` are `(0.25, 0.5, 0.75)`. The lines are drawn through `geom-line` on top of the stat's grouped output. Set `colour` per layer to colour all lines uniformly; for per-quantile colour, map an aesthetic to the `_quantile` column emitted by the stat.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - quantiles: Array of τ values in `(0, 1)` to fit.
/// - n-samples: Number of evenly-spaced x positions sampled per fitted line.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` resolves via the colour scale or a neutral default.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword. `auto` honours the linetype scale.
/// - linewidth: Multiplier on line thickness, mapped via the linewidth scale.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `stat-quantile`, `geom-smooth`.
///
/// Median plus quartile bands over a noisy linear trend.
///
/// ```typst
/// #let d = range(0, 50).map(i => (
///   x: i,
///   y: i * 0.5 + calc.sin(i * 0.4) * 4,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt, alpha: 0.4),
///     geom-quantile(),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-quantile(
  mapping: none,
  data: none,
  quantiles: (0.25, 0.5, 0.75),
  n-samples: 64,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  linewidth: auto,
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "line",
  mapping: mapping,
  data: data,
  params: (
    stroke: stroke,
    stroke-fallback: 0.6pt,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
    linewidth: linewidth,
  ),
  stat: stat-quantile(quantiles: quantiles, n-samples: n-samples),
  position: position,
  inherit-aes: inherit-aes,
)
