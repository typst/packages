///! Scatter markers sized by the count of overplotted `(x, y)` pairs.
///!
///! Thin wrapper over \@geom-point that defaults `stat: "sum"`. The backing
///! \@stat-sum aggregates duplicate `(x, y)` rows into one row per unique pair
///! and exposes the count via the `size` aesthetic.

#import "../layer.typ": make-layer

/// Count layer drawing one marker per unique `(x, y)`, sized by frequency.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - size: Marker size (a Typst length). `auto` honours the size scale, which `stat-sum` wires to the per-cell count.
/// - stroke: Marker outline thickness (a Typst length) or stroke dictionary; `none` disables the outline and the `colour` aesthetic.
/// - fill: Marker body fill. `auto` resolves via the fill scale or a neutral default.
/// - colour: Fixed marker outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// - alpha: Marker opacity in `[0, 1]`.
/// - shape: Marker shape keyword. `auto` honours the shape scale.
/// - stat: Statistical transform name. Defaults to `"sum"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-point`, `stat-sum`.
///
/// Marker size grows with the number of duplicate `(x, y)` rows.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1),
///   (x: 1, y: 1),
///   (x: 2, y: 2),
///   (x: 3, y: 3),
///   (x: 3, y: 3),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-count(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pair with `scale-size-area` to give markers an area-proportional scaling (instead of a radius-proportional one).
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1),
///   (x: 1, y: 1),
///   (x: 2, y: 2),
///   (x: 3, y: 3),
///   (x: 3, y: 3),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-count(),),
///   scales: (scale-size-area(range: (1pt, 12pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-count(
  mapping: none,
  data: none,
  size: auto,
  stroke: auto,
  fill: auto,
  colour: auto,
  alpha: auto,
  shape: auto,
  stat: "sum",
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
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)
