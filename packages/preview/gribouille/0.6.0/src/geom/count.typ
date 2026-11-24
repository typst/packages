///! Scatter markers sized by the count of overplotted `(x, y)` pairs.
///!
///! Thin wrapper over \@geom-point that defaults `stat: "sum"`. The backing
///! \@stat-sum aggregates duplicate `(x, y)` rows into one row per unique pair
///! and exposes the count via the `size` aesthetic.

#import "../layer.typ": make-layer, split-aes-params

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
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
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
/// Pair with `scale-area` to give markers an area-proportional scaling (instead of a radius-proportional one).
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
///   scales: scales(size: scale-area(range: (1pt, 12pt))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-count(
  mapping: none,
  data: none,
  size: auto,
  colour: auto,
  fill: auto,
  stroke: auto,
  alpha: auto,
  shape: auto,
  stat: "sum",
  position: "identity",
  key: auto,
  inherit-aes: true,
  ..args,
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
  )
    + split-aes-params("geom-count", args),
  stat: stat,
  position: position,
  key: key,
  inherit-aes: inherit-aes,
)
