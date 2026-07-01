///! Polyline connecting observations in x order.
///!
///! Rows are sorted by x within each group, then joined with a stroked line.
///! Groups default to the combination of discrete aesthetics (colour, fill,
///! linetype) when `group` is not set explicitly.

#import "../layer.typ": make-layer
#import "grouped-path.typ": draw-grouped-paths, rows-to-points, sort-rows-by-x

/// Line layer connecting observations in x order, one path per group.
///
/// Grouping is implicit: rows sharing the same discrete colour, fill, or
/// `group` mapping form one path. Set `group` in \@aes to override when
/// you need separate lines without mapping colour.
///
/// \@category Geoms
/// \@subcategory Lines and paths
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Falls back to the plot mapping when `none`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param stroke Line thickness (a Typst length).
///
/// \@param colour Fixed line colour. `auto` resolves via the colour scale or a neutral default.
///
/// \@param alpha Line opacity in `[0, 1]`.
///
/// \@param linetype Dash keyword (e.g., `"solid"`, `"dashed"`). `auto` honours the linetype scale.
///
/// \@param key Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
///
/// \@param stat Statistical transform name. Usually `"identity"`.
///
/// \@param position Position adjustment name. Usually `"identity"`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples One line per group, derived implicitly from the `colour` mapping.
/// ```
/// //| alt: "Two polylines of y against x = 1 to 3 for groups a and b coloured by the colour aesthetic with implicit grouping."
/// #let d = (
///   (x: 1, y: 2, grp: "a"),
///   (x: 2, y: 4, grp: "a"),
///   (x: 3, y: 3, grp: "a"),
///   (x: 1, y: 1, grp: "b"),
///   (x: 2, y: 2, grp: "b"),
///   (x: 3, y: 4, grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Map `linetype` to the same column to give each group a distinct
/// dash pattern in addition to colour.
/// ```
/// //| alt: "Two polylines of y against x = 1 to 3 for groups a and b with distinct colour and dash patterns per group."
/// #let d = (
///   (x: 1, y: 2, grp: "a"),
///   (x: 2, y: 4, grp: "a"),
///   (x: 3, y: 3, grp: "a"),
///   (x: 1, y: 1, grp: "b"),
///   (x: 2, y: 2, grp: "b"),
///   (x: 3, y: 4, grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "grp", linetype: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-point, \@geom-smooth, \@scale-linetype, \@aes
#let geom-line(
  mapping: none,
  data: none,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  key: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "line",
  mapping: mapping,
  data: data,
  params: (stroke: stroke, colour: colour, alpha: alpha, linetype: linetype),
  key: key,
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let _build-pts(rows, layer, mapping, x-trained, ctx) = (
  rows-to-points(sort-rows-by-x(rows, mapping, x-trained), mapping, ctx)
)

#let draw(layer, ctx) = draw-grouped-paths(layer, ctx, _build-pts)
