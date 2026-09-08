///! Shape scale.
///!
///! Maps discrete levels onto marker-shape keywords consumed by \@geom-point
///! (`"circle"`, `"square"`, `"triangle"`, `"diamond"`, `"cross"`, `"x"`,
///! `"star"`, `"triangle-down"`).

#import "../utils/palette.typ": default-shapes

/// Discrete shape scale: maps levels to marker-shape keywords.
///
/// Pass a custom array of keywords via `palette` to override the default shape set.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - palette: Array of shape keywords, or `auto` for the library default.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-shape-manual`, `geom-point`.
///
/// Default shape palette mapping three categories to distinct markers.
///
/// ```typst
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
/// Pair `shape` and `fill` mappings with the same column to reinforce the categorical encoding.
///
/// ```typst
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
/// Keywords cycle through `values` in the order levels appear, unless `limits` fixes the level order.
///
/// - values: Array of shape keywords, one per level.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-shape`, `geom-point`.
///
/// Custom three-shape cycle assigned in input order.
///
/// ```typst
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
/// `limits` pins the level order so the shape mapping stays stable across datasets.
///
/// ```typst
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
/// The mapped column must contain shape keywords accepted by `geom-point` (`"circle"`, `"square"`, `"triangle"`, `"diamond"`, `"cross"`, `"x"`, `"star"`, `"triangle-down"`).
///
/// - name: Legend title. Identity scales draw no legend.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-shape`, `scale-shape-manual`, `geom-point`.
///
/// Per-row shape keyword carried straight through to the marker.
///
/// ```typst
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
#let scale-shape-identity(name: none) = (
  kind: "scale",
  aesthetic: "shape",
  type: "identity",
  name: name,
)

/// Binned shape scale: cuts a continuous variable into `n-breaks` bins, each bin gets one shape from `palette`.
///
/// The scale stays continuous: the trained domain is numeric and the resolver snaps each row to the bin its value falls into. The legend renders one glyph per bin at the midpoint.
///
/// - n-breaks: Number of bins to partition the continuous domain into.
/// - palette: Array of shape keywords, one per bin, or `auto` for the library default.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Continuous `(lo, hi)` pair pinning the domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with bin midpoints, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-shape`, `scale-shape-manual`, `geom-point`.
///
/// Bin a continuous score column into four shape buckets.
///
/// ```typst
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
