///! Stroke scale.
///!
///! Maps a numeric column onto a pair of Typst lengths describing the output
///! range of marker outline thicknesses for `geom-point`.

/// Continuous stroke scale mapping a numeric column to outline thickness.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - range: Pair of Typst lengths `(min, max)` bounding the output thickness.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-stroke-identity`, `scale-linewidth-continuous`.
///
/// Marker outline grows with `w`.
///
/// ```typst
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", stroke: "w"),
///   layers: (geom-point(size: 5pt, fill: rgb("#1f77b4")),),
///   scales: (scale-stroke-continuous(range: (0.2pt, 1.6pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-stroke-continuous(
  name: none,
  range: (0.2pt, 1.4pt),
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "stroke",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

/// Manual discrete stroke scale: supply a per-level array of Typst lengths.
///
/// - values: Array of Typst lengths, one per level.
/// - name: Legend title.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-stroke-continuous`, `scale-linewidth-manual`.
///
/// Three explicit thickness lengths pinned to three named levels via `values` and `limits`.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "thin"),
///   (x: 2, y: 2, g: "thin"),
///   (x: 1, y: 2, g: "medium"),
///   (x: 2, y: 3, g: "medium"),
///   (x: 1, y: 3, g: "thick"),
///   (x: 2, y: 4, g: "thick"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", stroke: "g"),
///   layers: (geom-point(size: 6pt, fill: rgb("#1f77b4")),),
///   scales: (
///     scale-stroke-manual(
///       values: (0.2pt, 0.8pt, 2pt),
///       limits: ("thin", "medium", "thick"),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-stroke-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "stroke",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)

/// Binned continuous stroke scale.
///
/// Maps a numeric column onto an outline-thickness range, but groups values into `n-breaks` bins for the legend.
///
/// - n-breaks: Number of legend bins.
/// - range: Pair of Typst lengths `(min, max)` bounding the output thickness.
/// - name: Legend title.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-stroke-continuous`, `scale-linewidth-binned`.
///
/// Bucket a continuous `w` column into three thickness bands while still feeding a numeric range to the scale.
///
/// ```typst
/// #let d = range(1, 13).map(i => (x: i, y: i, w: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", stroke: "w"),
///   layers: (geom-point(size: 5pt, fill: rgb("#1f77b4")),),
///   scales: (scale-stroke-binned(n-breaks: 3, range: (0.2pt, 1.6pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-stroke-binned(
  n-breaks: 4,
  range: (0.2pt, 1.4pt),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "stroke",
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

/// Stroke scale that uses each row's value as the outline thickness.
///
/// Values must be Typst lengths. No legend is drawn because the column carries the visual outcome verbatim.
///
/// - name: Legend title. Identity scales draw no legend.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-stroke-continuous`.
///
/// Pass per-row Typst lengths from a `t` column straight through to the marker outline.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, t: 0.2pt),
///   (x: 2, y: 2, t: 0.8pt),
///   (x: 3, y: 3, t: 2pt),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", stroke: "t"),
///   layers: (geom-point(size: 6pt, fill: rgb("#1f77b4")),),
///   scales: (scale-stroke-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-stroke-identity(name: none) = (
  kind: "scale",
  aesthetic: "stroke",
  type: "identity",
  name: name,
)
