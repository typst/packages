///! Continuous size scale.
///!
///! Maps a numeric column onto a pair of Typst lengths describing the output
///! range of marker or line sizes.

/// Continuous size scale mapping a numeric column to a size range.
///
/// \@category Scales
/// \@subcategory Size scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param range Pair of Typst lengths `(min, max)` bounding the output size.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Linear size mapping with the default 1pt-to-6pt range.
/// ```
/// //| alt: "Scatter chart of ten diagonal points where marker radius scales linearly with w from a small to a moderate dot."
/// #let d = range(0, 10).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-continuous(range: (1pt, 6pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Widen the `range` for stronger visual contrast on small
/// numeric differences.
/// ```
/// //| alt: "Scatter chart of ten diagonal points where the widened 2pt to 14pt range exaggerates marker-radius contrast across w."
/// #let d = range(0, 10).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-continuous(range: (2pt, 14pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-shape, \@scale-colour-continuous
#let scale-size-continuous(
  name: none,
  range: (1pt, 6pt),
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

/// Binned continuous size scale mapping a numeric column to `n-breaks` sizes.
///
/// Quantises the trained domain into equal-width bins so that all rows in a
/// bin take the same visual size, drawn from the midpoint position of the
/// `range` interval.
///
/// \@category Scales
/// \@subcategory Size scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param range Pair of Typst lengths `(min, max)` bounding the output size.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Four-bin discretisation across the default size range.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where w is cut into four bins so markers snap to four distinct radii rather than vary smoothly."
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-binned(n-breaks: 4, range: (1pt, 6pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples More bins (`n-breaks: 8`) on a wider `range` give finer steps
/// while keeping the visual binning.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where w is cut into eight bins across a wider 1pt to 12pt radius range for finer stepped marker sizes."
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-binned(n-breaks: 8, range: (1pt, 12pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-size-continuous, \@scale-size-binned-area
#let scale-size-binned(
  n-breaks: 4,
  range: (1pt, 6pt),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: auto,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Area-proportional continuous size scale.
///
/// Maps each value through the square root of its normalised position so the
/// drawn marker area, rather than its diameter, scales linearly with the
/// data. This is the perceptually neutral default when the visual quantity
/// of interest is a count or magnitude.
///
/// \@category Scales
/// \@subcategory Size scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param range Pair of Typst lengths `(min, max)` bounding the output size.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Area-proportional sizing on a quadratic series; markers grow
/// with the square root of `w` so visual area tracks the value.
/// ```
/// //| alt: "Scatter chart of seven diagonal points where marker radii grow with the square root of a quadratic w so visual area tracks the value linearly."
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-area(range: (1pt, 12pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Use `scale-size-area` with \@geom-count so the count of
/// duplicate `(x, y)` rows reads as proportional area.
/// ```
/// //| alt: "Scatter chart of three counted points where geom-count tallies duplicates and area-proportional sizing makes marker area read as the row count."
/// #let d = (
///   (x: 1, y: 1), (x: 1, y: 1),
///   (x: 2, y: 2),
///   (x: 3, y: 3), (x: 3, y: 3), (x: 3, y: 3), (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-count(),),
///   scales: (scale-size-area(range: (2pt, 14pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-size-continuous, \@scale-size-binned-area
#let scale-size-area(
  name: none,
  range: (1pt, 6pt),
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  size-trans: "area",
)

/// Binned area-proportional size scale.
///
/// Combines binning with area scaling: the domain is partitioned into
/// `n-breaks` bins, and the size of each bin grows with the square root of
/// its normalised midpoint position.
///
/// \@category Scales
/// \@subcategory Size scales
/// \@stability stable
/// \@since 0.3.0
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param range Pair of Typst lengths `(min, max)` bounding the output size.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Four-bin area-proportional discretisation on a quadratic
/// series.
/// ```
/// //| alt: "Scatter chart of seven diagonal points where a quadratic w is cut into four bins and each bin sets marker area through the square-root mapping."
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-binned-area(n-breaks: 4, range: (1pt, 12pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Combine more bins with a wider `range` for a finer banded
/// area scale on dense data.
/// ```
/// //| alt: "Scatter chart of fifteen diagonal points where a quadratic w is cut into eight area-proportional bins across a wider 1pt to 16pt radius range."
/// #let d = range(1, 16).map(i => (x: i, y: i, w: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: (scale-size-binned-area(n-breaks: 8, range: (1pt, 16pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-size-binned, \@scale-size-area
#let scale-size-binned-area(
  n-breaks: 4,
  range: (1pt, 6pt),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: auto,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
  size-trans: "area",
)

/// Size scale that uses each row's value as the marker or line size.
///
/// Values may be Typst lengths (passed through verbatim) or numbers
/// (interpreted as point sizes). No legend is drawn because the column
/// carries the visual outcome verbatim.
///
/// \@category Scales
/// \@subcategory Size scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row Typst lengths carried straight through to the marker
/// radii; no legend is drawn.
/// ```
/// //| alt: "Scatter chart of three points where the s column passes through as the marker radius, rendering a small, medium, and large dot with no legend."
/// #let d = (
///   (x: 1, y: 1, s: 2pt),
///   (x: 2, y: 2, s: 5pt),
///   (x: 3, y: 3, s: 9pt),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "s"),
///   layers: (geom-point(),),
///   scales: (scale-size-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-size-continuous, \@scale-alpha-identity, \@scale-linewidth-identity
#let scale-size-identity(name: none) = (
  kind: "scale",
  aesthetic: "size",
  type: "identity",
  name: name,
)

/// Manual discrete size scale: supply a per-level array of Typst lengths.
///
/// Use when each level should map to a chosen marker radius rather than
/// the evenly-spaced range that the discrete inference would assign.
///
/// \@category Scales
/// \@subcategory Size scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param values Array of Typst lengths, one per level (in `limits` order when set, otherwise in first-seen order).
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
/// \@examples Three groups assigned small/medium/large markers.
/// ```
/// //| alt: "Scatter chart of three groups where manual values pin group a to a small marker, b to medium, and c to large in a fixed discrete cycle."
/// #let d = (
///   (x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "a"),
///   (x: 1, y: 2, g: "b"), (x: 2, y: 3, g: "b"),
///   (x: 1, y: 3, g: "c"), (x: 2, y: 4, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "g", group: "g"),
///   layers: (geom-point(fill: rgb("#1f77b4")),),
///   scales: (scale-size-manual(values: (2pt, 4pt, 7pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-size-continuous, \@scale-radius
#let scale-size-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)

/// Linear-radius continuous size scale.
///
/// Alias of \@scale-size-continuous with the more explicit name. Provides
/// the linear value-to-radius mapping that gribouille already uses by
/// default; \@scale-size-area is the area-proportional variant.
///
/// \@category Scales
/// \@subcategory Size scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param range Pair of Typst lengths `(min, max)` bounding the output radius.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Marker radius grows linearly with `w`.
/// ```
/// //| alt: "Scatter chart of seven diagonal points where marker radius scales linearly with w via the radius alias of the continuous size scale."
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(fill: rgb("#1f77b4")),),
///   scales: (scale-radius(range: (1pt, 8pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-size-continuous, \@scale-size-area
#let scale-radius(
  name: none,
  range: (1pt, 6pt),
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)
