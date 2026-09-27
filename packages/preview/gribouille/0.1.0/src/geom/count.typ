///! Scatter markers sized by the count of overplotted `(x, y)` pairs.
///!
///! Thin wrapper over \@geom-point that defaults `stat: "sum"`. The backing
///! \@stat-sum aggregates duplicate `(x, y)` rows into one row per unique pair
///! and exposes the count via the `size` aesthetic.

#import "../layer.typ": make-layer

/// Count layer drawing one marker per unique `(x, y)`, sized by frequency.
///
/// \@category Geoms
/// \@subcategory Points
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Falls back to the plot mapping when `none`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param size Marker size (a Typst length). `auto` honours the size scale, which \@stat-sum wires to the per-cell count.
///
/// \@param stroke Marker outline thickness (a Typst length) or stroke dictionary; `none` disables the outline and the `colour` aesthetic.
///
/// \@param fill Marker body fill. `auto` resolves via the fill scale or a neutral default.
///
/// \@param colour Fixed marker outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
///
/// \@param alpha Marker opacity in `[0, 1]`.
///
/// \@param shape Marker shape keyword. `auto` honours the shape scale.
///
/// \@param stat Statistical transform name. Defaults to `"sum"`.
///
/// \@param position Position adjustment name. Usually `"identity"`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Marker size grows with the number of duplicate `(x, y)` rows.
/// ```
/// //| alt: "Scatter of x against y where each marker size encodes the number of duplicate (x, y) rows at that location."
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
/// \@examples Pair with \@scale-size-area to give markers an area-proportional
/// scaling (instead of a radius-proportional one).
/// ```
/// //| alt: "Scatter of x against y with marker size proportional to area encoding count of duplicate (x, y) rows."
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
///
/// \@see \@geom-point, \@stat-sum
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
