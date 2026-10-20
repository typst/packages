/// Bind column names to visual channels to form an aesthetic mapping.
///
/// Aesthetic mappings tell `plot` how to turn data columns into visual properties: which column drives the x axis, which becomes a colour, etc. Pass the result as the `mapping` argument of `plot` or any geom layer.
///
/// Channel values can also be late-binding markers that defer resolution past the point where a column was first bound:
///
/// - Use `from-theme` to pull a scalar from the active theme.
/// - Use `after-stat` to substitute a column or closure result published by the layer's stat.
/// - Use `after-scale` to post-transform a channel's scale-resolved value just before draw.
/// - Use `stage` to compose all three lanes for a single channel.
///
/// - x: Column name for the x position.
/// - y: Column name for the y position.
/// - colour: Column name driving the stroke colour.
/// - fill: Column name driving the fill colour.
/// - size: Column name driving marker or line size.
/// - alpha: Column name driving opacity.
/// - linewidth: Column name driving line stroke thickness.
/// - group: Column name used to partition layers that connect observations.
/// - shape: Column name driving marker shape.
/// - linetype: Column name driving line dash pattern.
/// - label: Column name used by `geom-text` and `geom-label`.
/// - xmin: Column name for the lower x bound (ribbons, error bars).
/// - xmax: Column name for the upper x bound.
/// - ymin: Column name for the lower y bound.
/// - ymax: Column name for the upper y bound.
/// - xend: Column name for the x end point of a segment.
/// - yend: Column name for the y end point of a segment.
/// - xintercept: Column name or scalar for vertical reference lines.
/// - yintercept: Column name or scalar for horizontal reference lines.
/// - slope: Slope for oblique reference lines (`geom-abline`).
/// - intercept: Intercept for oblique reference lines.
/// - weight: Column name carrying per-row statistical weights.
/// - stroke: Column name driving marker outline thickness (`geom-point`).
/// - x0: Column name for the x centre of an ellipse (`geom-ellipse`).
/// - y0: Column name for the y centre of an ellipse.
/// - a: Column name for the ellipse semi-major radius in data units.
/// - b: Column name for the ellipse semi-minor radius in data units.
/// - angle: Column name for the ellipse rotation in radians (`geom-ellipse`) or the spoke direction in radians (`geom-spoke`).
/// - radius: Column name for the spoke length in data units (`geom-spoke`).
/// - z: Column name for the value summarised over a 2D grid (`stat-summary-2d`, `stat-summary-hex`).
/// - nudge-x: Column name or scalar for per-row x offsets applied to text/label/typst geoms, in data units. Combines with layer-level `dx`.
/// - nudge-y: Column name or scalar for per-row y offsets applied to text/label/typst geoms, in data units. Combines with layer-level `dy`.
///
/// Returns: Dictionary tagged `kind: "aes"`, consumed by `plot` and geom layers.
///
/// See also: `plot`, `geom-point`, `as-factor`, `from-theme`, `after-stat`, `after-scale`, `stage`.
///
/// Bind three columns: `x`, `y`, and a categorical `colour`.
///
/// ```typst
/// #let iris = (
///   (x: 5.1, y: 3.5, sp: "setosa"),
///   (x: 7.0, y: 3.2, sp: "versicolor"),
///   (x: 6.3, y: 3.3, sp: "virginica"),
/// )
/// #plot(
///   data: iris,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Bind ribbon endpoints (`ymin`, `ymax`) alongside a centre line, sharing the same `x` between the two layers.
///
/// ```typst
/// #let d = range(0, 10).map(i => (
///   x: i, y: i * 0.5, lo: i * 0.5 - 0.6, hi: i * 0.5 + 0.6,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi"),
///   layers: (
///     geom-ribbon(alpha: 0.3),
///     geom-line(stroke: 1pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Bind y to the count column the stat publishes via `after-stat`.
///
/// ```typst
/// #let d = ((grp: "a"), (grp: "b"), (grp: "a"), (grp: "c"))
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: after-stat("_count"), fill: "grp"),
///   layers: (geom-bar(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Darken the marker outline from the trained fill palette via `after-scale`.
///
/// ```typst
/// #let d = ((x: 1, sp: "a"), (x: 2, sp: "b"), (x: 3, sp: "a"))
/// #plot(
///   data: d,
///   mapping: aes(
///     x: "x",
///     y: "x",
///     fill: "sp",
///     colour: stage(
///       start: "sp",
///       after-scale: (c, _) => c.darken(40%),
///     ),
///   ),
///   layers: (geom-point(size: 4pt, stroke: 0.6pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let aes(
  x: none,
  y: none,
  colour: none,
  fill: none,
  size: none,
  alpha: none,
  linewidth: none,
  group: none,
  shape: none,
  linetype: none,
  label: none,
  xmin: none,
  xmax: none,
  ymin: none,
  ymax: none,
  xend: none,
  yend: none,
  xintercept: none,
  yintercept: none,
  slope: none,
  intercept: none,
  weight: none,
  stroke: none,
  x0: none,
  y0: none,
  a: none,
  b: none,
  angle: none,
  radius: none,
  z: none,
  nudge-x: none,
  nudge-y: none,
) = (
  kind: "aes",
  x: x,
  y: y,
  z: z,
  colour: colour,
  fill: fill,
  size: size,
  alpha: alpha,
  linewidth: linewidth,
  group: group,
  shape: shape,
  linetype: linetype,
  label: label,
  xmin: xmin,
  xmax: xmax,
  ymin: ymin,
  ymax: ymax,
  xend: xend,
  yend: yend,
  xintercept: xintercept,
  yintercept: yintercept,
  slope: slope,
  intercept: intercept,
  weight: weight,
  stroke: stroke,
  x0: x0,
  y0: y0,
  a: a,
  b: b,
  angle: angle,
  radius: radius,
  nudge-x: nudge-x,
  nudge-y: nudge-y,
)
