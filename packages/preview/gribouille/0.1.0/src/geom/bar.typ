///! Bars of observation counts.
///!
///! Thin wrapper around \@geom-col that swaps in `stat: "count"` and defaults
///! `position` to `"stack"`. Use this when you want counts; use \@geom-col for
///! pre-aggregated heights.

#import "col.typ": geom-col

/// Bar layer that counts rows per x level (stat-count).
///
/// Maps the `x` aesthetic to a discrete variable; the layer then counts
/// rows per x level and draws one bar per count. Use \@geom-col instead
/// when y is already computed.
///
/// \@category Geoms
/// \@subcategory Bars and histograms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Falls back to the plot mapping when `none`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param width Bar width as a fraction of the category width (0 to 1).
///
/// \@param colour Bar outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
///
/// \@param fill Bar fill colour. `auto` resolves via the fill scale or a neutral default.
///
/// \@param stroke Bar outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
///
/// \@param alpha Bar opacity in `[0, 1]`.
///
/// \@param position Position adjustment: `"stack"` (default), `"dodge"`, `"fill"`, or `"identity"`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Plain count of rows per category.
/// ```
/// //| alt: "Bar chart of row counts per category (a, b, c) on the x axis with count on the y axis."
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
/// \@examples Map `fill` to a second column and switch `position` to
/// `"dodge"` to compare counts side by side.
/// ```
/// //| alt: "Dodged bar chart of counts per group (a, b, c) split into two fill categories (x, y) shown side by side."
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
/// \@examples Penguin counts per island, broken down by species with
/// dodged bars.
/// ```
/// //| alt: "Dodged bar chart of penguin counts per island on the x axis with species coloured by fill aesthetic."
/// #plot(
///   data: penguins,
///   mapping: aes(x: "island", fill: "species"),
///   layers: (geom-bar(position: "dodge"),),
///   labs: labs(x: "Island", y: "Count", fill: "Species"),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-col, \@stat-count
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
