///! Shape scale.
///!
///! Maps discrete levels onto marker-shape keywords consumed by \@geom-point
///! (`"circle"`, `"square"`, `"triangle"`, `"diamond"`, `"cross"`, `"x"`,
///! `"star"`, `"triangle-down"`).

#import "../utils/palette.typ": default-shapes

/// Discrete shape scale: maps levels to marker-shape keywords.
///
/// Pass a custom array of keywords via `palette` to override the default
/// shape set.
///
/// \@category Scales
/// \@subcategory Shape scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param palette Array of shape keywords, or `auto` for the library default.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default shape palette mapping three categories to distinct
/// markers.
/// ```
/// //| alt: "Scatter chart of three points along x against y where the sp column drives the marker glyph through the default discrete shape palette."
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-shape(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Pair `shape` and `fill` mappings with the same column to
/// reinforce the categorical encoding.
/// ```
/// //| alt: "Scatter chart of three points where sp drives both marker glyph and fill colour, reinforcing the categorical encoding through redundant channels."
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "sp", fill: "sp"),
///   layers: (geom-point(size: 4pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-shape-manual, \@geom-point
#let scale-shape(
  name: none,
  palette: auto,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "shape",
  type: "discrete",
  name: name,
  palette: if palette == auto { default-shapes } else { palette },
  limits: limits,
  oob: oob,
  labels: labels,
)

/// Manual discrete shape scale: supply the shape-keyword array directly.
///
/// Keywords cycle through `values` in the order levels appear, unless
/// `limits` fixes the level order.
///
/// \@category Scales
/// \@subcategory Shape scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of shape keywords, one per level.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Custom three-shape cycle assigned in input order.
/// ```
/// //| alt: "Scatter chart of three points where the manual values pin sp to a circle, triangle, and diamond glyph in the order levels first appear."
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-shape-manual(
///     values: ("circle", "triangle", "diamond"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples `limits` pins the level order so the shape mapping stays
/// stable across datasets.
/// ```
/// //| alt: "Scatter chart of three points where limits forces a, b, c order so the circle, triangle, diamond mapping stays stable regardless of input order."
/// #let d = (
///   (x: 1, y: 3, sp: "c"),
///   (x: 2, y: 4, sp: "a"),
///   (x: 3, y: 2, sp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "sp"),
///   layers: (geom-point(size: 4pt),),
///   scales: (scale-shape-manual(
///     values: ("circle", "triangle", "diamond"),
///     limits: ("a", "b", "c"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-shape, \@geom-point
#let scale-shape-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "shape",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)

/// Shape scale that uses each row's value as the marker keyword directly.
///
/// The mapped column must contain shape keywords accepted by \@geom-point
/// (`"circle"`, `"square"`, `"triangle"`, `"diamond"`, `"cross"`, `"x"`,
/// `"star"`, `"triangle-down"`).
///
/// \@category Scales
/// \@subcategory Shape scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row shape keyword carried straight through to the marker.
/// ```
/// //| alt: "Scatter chart of three points where the sh column passes through as the marker glyph, rendering a circle, triangle, and diamond with no legend."
/// #let d = (
///   (x: 1, y: 2, sh: "circle"),
///   (x: 2, y: 4, sh: "triangle"),
///   (x: 3, y: 3, sh: "diamond"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "sh"),
///   layers: (geom-point(size: 4pt),),
///   scales: (scale-shape-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-shape, \@scale-shape-manual, \@geom-point
#let scale-shape-identity(name: none) = (
  kind: "scale",
  aesthetic: "shape",
  type: "identity",
  name: name,
)

/// Binned shape scale: cuts a continuous variable into `n-breaks` bins, each
/// bin gets one shape from `palette`.
///
/// The scale stays continuous: the trained domain is numeric and the
/// resolver snaps each row to the bin its value falls into. The legend
/// renders one glyph per bin at the midpoint.
///
/// \@category Scales
/// \@subcategory Shape scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param n-breaks Number of bins to partition the continuous domain into.
///
/// \@param palette Array of shape keywords, one per bin, or `auto` for the library default.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Continuous `(lo, hi)` pair pinning the domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with bin midpoints, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Bin a continuous score column into four shape buckets.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where the continuous w column is cut into four bins, each mapped to a distinct marker glyph."
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", shape: "w"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-shape-binned(n-breaks: 4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-shape, \@scale-shape-manual, \@geom-point
#let scale-shape-binned(
  n-breaks: 4,
  palette: auto,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "shape",
  type: "continuous",
  name: name,
  palette: if palette == auto { default-shapes } else { palette },
  limits: limits,
  oob: oob,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)
