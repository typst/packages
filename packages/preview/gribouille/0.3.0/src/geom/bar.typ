///! Bars of observation counts.
///!
///! Thin wrapper around \@geom-col that swaps in `stat: "count"` and defaults
///! `position` to `"stack"`. Use this when you want counts; use \@geom-col for
///! pre-aggregated heights.

#import "col.typ": geom-col

/// Bar layer that counts rows per x level (stat-count).
///
/// Maps the `x` aesthetic to a discrete variable; the layer then counts rows per x level and draws one bar per count. Use `geom-col` instead when y is already computed.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - width: Bar width as a fraction of the category width (0 to 1).
/// - colour: Bar outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// - fill: Bar fill colour. `auto` resolves via the fill scale or a neutral default.
/// - stroke: Bar outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// - alpha: Bar opacity in `[0, 1]`.
/// - position: Position adjustment: `"stack"` (default), `"dodge"`, `"fill"`, or `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-col`, `stat-count`.
///
/// Plain count of rows per category.
///
/// ```typst
/// #let d = (
///   (grp: "a"),
///   (grp: "b"),
///   (grp: "a"),
///   (grp: "c"),
///   (grp: "b"),
///   (grp: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp"),
///   layers: (geom-bar(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Map `fill` to a second column and switch `position` to `"dodge"` to compare counts side by side.
///
/// ```typst
/// #let d = (
///   (grp: "a", k: "x"),
///   (grp: "b", k: "x"),
///   (grp: "a", k: "y"),
///   (grp: "c", k: "x"),
///   (grp: "b", k: "y"),
///   (grp: "a", k: "y"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", fill: "k"),
///   layers: (geom-bar(position: "dodge"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Penguin counts per island, broken down by species with dodged bars.
///
/// ```typst
/// #plot(
///   data: penguins,
///   mapping: aes(x: "island", fill: "species"),
///   layers: (geom-bar(position: "dodge"),),
///   labs: labs(x: "Island", y: "Count", fill: "Species"),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
#let geom-bar(
  mapping: none,
  data: none,
  width: 0.9,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  position: "stack",
  inherit-aes: true,
) = geom-col(
  mapping: mapping,
  data: data,
  width: width,
  colour: colour,
  fill: fill,
  stroke: stroke,
  alpha: alpha,
  stat: "count",
  position: position,
  inherit-aes: inherit-aes,
)
