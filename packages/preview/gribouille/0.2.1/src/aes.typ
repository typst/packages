/// Bind column names to visual channels to form an aesthetic mapping.
///
/// Aesthetic mappings tell \@plot how to turn data columns into visual
/// properties: which column drives the x axis, which becomes a colour, etc.
/// Pass the result as the `mapping` argument of \@plot or any geom layer.
///
/// Channel values can also be late-binding markers that defer
/// resolution past the point where a column was first bound:
///
/// - Use \@from-theme to pull a scalar from the active theme.
/// - Use \@after-stat to substitute a column or closure result
///   published by the layer's stat.
/// - Use \@after-scale to post-transform a channel's scale-resolved
///   value just before draw.
/// - Use \@stage to compose all three lanes for a single channel.
///
/// \@category Core
/// \@stability stable
/// \@since 0.0.1
///
/// \@param x Column name for the x position.
///
/// \@param y Column name for the y position.
///
/// \@param colour Column name driving the stroke colour.
///
/// \@param fill Column name driving the fill colour.
///
/// \@param size Column name driving marker or line size.
///
/// \@param alpha Column name driving opacity.
///
/// \@param linewidth Column name driving line stroke thickness.
///
/// \@param group Column name used to partition layers that connect observations.
///
/// \@param shape Column name driving marker shape.
///
/// \@param linetype Column name driving line dash pattern.
///
/// \@param label Column name used by \@geom-text and \@geom-label.
///
/// \@param xmin Column name for the lower x bound (ribbons, error bars).
///
/// \@param xmax Column name for the upper x bound.
///
/// \@param ymin Column name for the lower y bound.
///
/// \@param ymax Column name for the upper y bound.
///
/// \@param xend Column name for the x end point of a segment.
///
/// \@param yend Column name for the y end point of a segment.
///
/// \@param xintercept Column name or scalar for vertical reference lines.
///
/// \@param yintercept Column name or scalar for horizontal reference lines.
///
/// \@param slope Slope for oblique reference lines (\@geom-abline).
///
/// \@param intercept Intercept for oblique reference lines.
///
/// \@param weight Column name carrying per-row statistical weights.
///
/// \@param stroke Column name driving marker outline thickness (\@geom-point).
///
/// \@param x0 Column name for the x centre of an ellipse (\@geom-ellipse).
///
/// \@param y0 Column name for the y centre of an ellipse.
///
/// \@param a Column name for the ellipse semi-major radius in data units.
///
/// \@param b Column name for the ellipse semi-minor radius in data units.
///
/// \@param angle Column name for the ellipse rotation in radians (\@geom-ellipse) or the spoke direction in radians (\@geom-spoke).
///
/// \@param radius Column name for the spoke length in data units (\@geom-spoke).
///
/// \@param z Column name for the value summarised over a 2D grid (\@stat-summary-2d, \@stat-summary-hex).
///
/// \@param nudge-x Column name or scalar for per-row x offsets applied to text/label/typst geoms, in data units. Combines with layer-level `dx`.
///
/// \@param nudge-y Column name or scalar for per-row y offsets applied to text/label/typst geoms, in data units. Combines with layer-level `dy`.
///
/// \@returns Dictionary tagged `kind: "aes"`, consumed by \@plot and geom layers.
///
/// \@examples Bind three columns: `x`, `y`, and a categorical `colour`.
/// ```
/// //| alt: "Scatter chart of sepal width against sepal length for three iris species, with marker colour encoding the species categorical."
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
/// \@examples Bind ribbon endpoints (`ymin`, `ymax`) alongside a centre
/// line, sharing the same `x` between the two layers.
/// ```
/// //| alt: "Line chart of y against x with a translucent ribbon spanning ymin to ymax around the line."
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
/// \@examples Bind y to the count column the stat publishes via \@after-stat.
/// ```
/// //| alt: "Bar chart of per-group counts with bar fill encoding the group, y bound to the stat's _count column via after-stat."
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
/// \@examples Darken the marker outline from the trained fill palette
/// via \@after-scale.
/// ```
/// //| alt: "Scatter chart with filled markers whose outlines are darkened versions of the fill palette via after-scale."
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
///
/// \@see \@plot, \@geom-point, \@as-factor, \@from-theme, \@after-stat,
///   \@after-scale, \@stage
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
