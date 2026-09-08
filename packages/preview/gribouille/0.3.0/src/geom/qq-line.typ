///! Reference line for a Q-Q plot.
///!
///! Thin wrapper around \@geom-line that computes its data via \@stat-qq-line.

#import "../layer.typ": make-layer

/// Q-Q reference line layer fitted through the IQR of the sample.
///
/// The `sample` aesthetic selects the column whose 25th and 75th quantiles anchor the line; when `sample` is absent the layer falls back to `y`. The reference distribution is selected via `distribution` and must match the matching `geom-qq` layer.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` resolves via the colour scale or a neutral default.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword. `auto` honours the linetype scale.
/// - distribution: Reference distribution name; one of `"normal"` (default), `"uniform"`, `"exponential"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-qq`, `stat-qq-line`, `geom-line`.
///
/// Reference line under `geom-qq` for a normal Q-Q plot.
///
/// ```typst
/// #let d = (1, 2, 3, 4, 5).map(v => (v: v))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (geom-qq(), geom-qq-line()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Distinguish the line by colour and dash to keep it visible over the points.
///
/// ```typst
/// #let d = range(1, 21).map(i => (v: i + calc.sin(i)))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (
///     geom-qq(size: 2pt),
///     geom-qq-line(colour: rgb("#cc0000"), stroke: 1pt, linetype: "dashed"),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-qq-line(
  mapping: none,
  data: none,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  distribution: "normal",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "line",
  mapping: mapping,
  data: data,
  params: (
    stroke: stroke,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
    distribution: distribution,
  ),
  stat: "qq-line",
  position: position,
  inherit-aes: inherit-aes,
)
