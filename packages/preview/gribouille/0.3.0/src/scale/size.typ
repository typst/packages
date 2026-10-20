///! Continuous size scale.
///!
///! Maps a numeric column onto a pair of Typst lengths describing the output
///! range of marker or line sizes.

/// Continuous size scale mapping a numeric column to a size range.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - range: Pair of Typst lengths `(min, max)` bounding the output size.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-shape`, `scale-colour-continuous`.
///
/// Linear size mapping with the default 1pt-to-6pt range.
///
/// ```typst
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
/// Widen the `range` for stronger visual contrast on small numeric differences.
///
/// ```typst
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
/// Quantises the trained domain into equal-width bins so that all rows in a bin take the same visual size, drawn from the midpoint position of the `range` interval.
///
/// - n-breaks: Number of bins to partition the domain into.
/// - range: Pair of Typst lengths `(min, max)` bounding the output size.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-size-continuous`, `scale-size-binned-area`.
///
/// Four-bin discretisation across the default size range.
///
/// ```typst
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
/// More bins (`n-breaks: 8`) on a wider `range` give finer steps while keeping the visual binning.
///
/// ```typst
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
/// Maps each value through the square root of its normalised position so the drawn marker area, rather than its diameter, scales linearly with the data. This is the perceptually neutral default when the visual quantity of interest is a count or magnitude.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - range: Pair of Typst lengths `(min, max)` bounding the output size.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-size-continuous`, `scale-size-binned-area`.
///
/// Area-proportional sizing on a quadratic series; markers grow with the square root of `w` so visual area tracks the value.
///
/// ```typst
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
/// Use `scale-size-area` with `geom-count` so the count of duplicate `(x, y)` rows reads as proportional area.
///
/// ```typst
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
/// Combines binning with area scaling: the domain is partitioned into `n-breaks` bins, and the size of each bin grows with the square root of its normalised midpoint position.
///
/// - n-breaks: Number of bins to partition the domain into.
/// - range: Pair of Typst lengths `(min, max)` bounding the output size.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-size-binned`, `scale-size-area`.
///
/// Four-bin area-proportional discretisation on a quadratic series.
///
/// ```typst
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
/// Combine more bins with a wider `range` for a finer banded area scale on dense data.
///
/// ```typst
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
/// Values may be Typst lengths (passed through verbatim) or numbers (interpreted as point sizes). No legend is drawn because the column carries the visual outcome verbatim.
///
/// - name: Legend title. Identity scales draw no legend.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-size-continuous`, `scale-alpha-identity`, `scale-linewidth-identity`.
///
/// Per-row Typst lengths carried straight through to the marker radii; no legend is drawn.
///
/// ```typst
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
#let scale-size-identity(name: none) = (
  kind: "scale",
  aesthetic: "size",
  type: "identity",
  name: name,
)

/// Manual discrete size scale: supply a per-level array of Typst lengths.
///
/// Use when each level should map to a chosen marker radius rather than the evenly-spaced range that the discrete inference would assign.
///
/// - values: Array of Typst lengths, one per level (in `limits` order when set, otherwise in first-seen order).
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-size-continuous`, `scale-radius`.
///
/// Three groups assigned small/medium/large markers.
///
/// ```typst
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
/// Alias of `scale-size-continuous` with the more explicit name. Provides the linear value-to-radius mapping that gribouille already uses by default; `scale-size-area` is the area-proportional variant.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - range: Pair of Typst lengths `(min, max)` bounding the output radius.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-size-continuous`, `scale-size-area`.
///
/// Marker radius grows linearly with `w`.
///
/// ```typst
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
