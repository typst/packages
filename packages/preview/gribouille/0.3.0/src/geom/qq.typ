///! Q-Q plot points against a reference distribution.
///!
///! Thin wrapper around \@geom-point that computes its data via \@stat-qq.

#import "../layer.typ": make-layer

/// Q-Q point layer: sorted sample versus theoretical quantile.
///
/// The `sample` aesthetic selects the column to compare against the chosen reference distribution. When `sample` is absent the layer falls back to `y` so simple `aes(y: ...)` plots also work. Colour, fill, shape, and alpha can be set or mapped through `aes`.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - size: Marker size (a Typst length).
/// - stroke: Marker outline thickness (a Typst length) or stroke dictionary; `none` disables the outline and the `colour` aesthetic.
/// - fill: Marker fill colour. `auto` resolves via the colour scale or a neutral default.
/// - colour: Fixed marker outline colour. `auto` resolves via the colour scale, falling back to the theme `ink`. Only takes effect when `stroke` is non-zero.
/// - alpha: Marker opacity in `[0, 1]`.
/// - shape: Marker shape keyword. `auto` honours the shape scale.
/// - distribution: Reference distribution name; one of `"normal"` (default), `"uniform"`, `"exponential"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-qq-line`, `stat-qq`, `geom-point`.
///
/// Simple Q-Q against a normal reference, mapping `y` only.
///
/// ```typst
/// #let d = (1, 2, 3, 4, 5).map(v => (v: v))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (geom-qq(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Switch `distribution` to `"uniform"` to compare against a different reference.
///
/// ```typst
/// #let d = range(1, 21).map(i => (v: i))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (geom-qq(distribution: "uniform"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-qq(
  mapping: none,
  data: none,
  size: auto,
  stroke: auto,
  fill: auto,
  colour: auto,
  alpha: auto,
  shape: auto,
  distribution: "normal",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "point",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    stroke: stroke,
    fill: fill,
    colour: colour,
    alpha: alpha,
    shape: shape,
    distribution: distribution,
  ),
  stat: "qq",
  position: position,
  inherit-aes: inherit-aes,
)
