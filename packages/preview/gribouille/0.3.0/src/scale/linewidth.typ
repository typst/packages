///! Linewidth scale.
///!
///! Maps a numeric column onto a pair of Typst lengths describing the output
///! range of stroke thicknesses for line-style geoms.

/// Continuous linewidth scale mapping a numeric column to stroke thickness.
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
/// See also: `scale-linewidth-identity`, `scale-size-continuous`.
///
/// Linewidth grows with `w`, one line per group.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, w: 1, g: "a"), (x: 2, y: 2, w: 1, g: "a"),
///   (x: 3, y: 3, w: 1, g: "a"), (x: 4, y: 4, w: 1, g: "a"),
///   (x: 1, y: 2, w: 4, g: "b"), (x: 2, y: 3, w: 4, g: "b"),
///   (x: 3, y: 4, w: 4, g: "b"), (x: 4, y: 5, w: 4, g: "b"),
///   (x: 1, y: 3, w: 7, g: "c"), (x: 2, y: 4, w: 7, g: "c"),
///   (x: 3, y: 5, w: 7, g: "c"), (x: 4, y: 6, w: 7, g: "c"),
///   (x: 1, y: 4, w: 10, g: "d"), (x: 2, y: 5, w: 10, g: "d"),
///   (x: 3, y: 6, w: 10, g: "d"), (x: 4, y: 7, w: 10, g: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linewidth: "w", group: "g"),
///   layers: (geom-line(),),
///   scales: (scale-linewidth-continuous(range: (0.4pt, 2pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pair `colour` and `linewidth` with the same column to encode magnitude through both channels.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, w: 1, g: "a"), (x: 2, y: 2, w: 1, g: "a"),
///   (x: 3, y: 3, w: 1, g: "a"), (x: 4, y: 4, w: 1, g: "a"),
///   (x: 1, y: 2, w: 4, g: "b"), (x: 2, y: 3, w: 4, g: "b"),
///   (x: 3, y: 4, w: 4, g: "b"), (x: 4, y: 5, w: 4, g: "b"),
///   (x: 1, y: 3, w: 7, g: "c"), (x: 2, y: 4, w: 7, g: "c"),
///   (x: 3, y: 5, w: 7, g: "c"), (x: 4, y: 6, w: 7, g: "c"),
///   (x: 1, y: 4, w: 10, g: "d"), (x: 2, y: 5, w: 10, g: "d"),
///   (x: 3, y: 6, w: 10, g: "d"), (x: 4, y: 7, w: 10, g: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "w", linewidth: "w", group: "g"),
///   layers: (geom-line(),),
///   scales: (scale-linewidth-continuous(range: (0.4pt, 3pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-linewidth-continuous(
  name: none,
  range: (0.4pt, 1.4pt),
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

/// Manual discrete linewidth scale: supply a per-level array of Typst lengths.
///
/// Use when each level should map to a chosen thickness rather than the evenly-spaced range that the discrete inference would assign.
///
/// - values: Array of Typst lengths, one per level (in `limits` order when set, otherwise in first-seen order).
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-linewidth-continuous`, `scale-linewidth-identity`.
///
/// Three groups assigned thin/medium/thick strokes.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "a"),
///   (x: 1, y: 2, g: "b"), (x: 2, y: 3, g: "b"),
///   (x: 1, y: 3, g: "c"), (x: 2, y: 4, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linewidth: "g", group: "g"),
///   layers: (geom-line(),),
///   scales: (scale-linewidth-manual(values: (0.4pt, 1pt, 2pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-linewidth-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)

/// Binned continuous linewidth scale.
///
/// Maps a numeric column onto a stroke-thickness range, but groups values into `n-breaks` bins for the legend. The mapping stays continuous so drawn strokes vary smoothly within each bin; only the legend swatches snap to bin centres.
///
/// - n-breaks: Number of legend bins.
/// - range: Pair of Typst lengths `(min, max)` bounding the output thickness.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-linewidth-continuous`, `scale-size-binned`.
///
/// Linewidth grows with `w`, with the legend grouped into four bins.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, w: 1, g: "a"), (x: 2, y: 2, w: 1, g: "a"),
///   (x: 3, y: 3, w: 1, g: "a"), (x: 4, y: 4, w: 1, g: "a"),
///   (x: 1, y: 2, w: 4, g: "b"), (x: 2, y: 3, w: 4, g: "b"),
///   (x: 3, y: 4, w: 4, g: "b"), (x: 4, y: 5, w: 4, g: "b"),
///   (x: 1, y: 3, w: 7, g: "c"), (x: 2, y: 4, w: 7, g: "c"),
///   (x: 3, y: 5, w: 7, g: "c"), (x: 4, y: 6, w: 7, g: "c"),
///   (x: 1, y: 4, w: 10, g: "d"), (x: 2, y: 5, w: 10, g: "d"),
///   (x: 3, y: 6, w: 10, g: "d"), (x: 4, y: 7, w: 10, g: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linewidth: "w", group: "g"),
///   layers: (geom-line(),),
///   scales: (scale-linewidth-binned(n-breaks: 4, range: (0.4pt, 2pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-linewidth-binned(
  n-breaks: 4,
  range: (0.4pt, 1.4pt),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linewidth",
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

/// Linewidth scale that uses each row's value as the stroke thickness.
///
/// Values must be Typst lengths. No legend is drawn because the column carries the visual outcome verbatim.
///
/// - name: Legend title. Identity scales draw no legend.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-linewidth-continuous`.
///
/// Per-row Typst lengths carried straight through to the line strokes; no legend is drawn.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, g: "a", lw: 0.4pt),
///   (x: 2, y: 3, g: "a", lw: 0.4pt),
///   (x: 1, y: 1, g: "b", lw: 1.2pt),
///   (x: 2, y: 2, g: "b", lw: 1.2pt),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", group: "g", linewidth: "lw"),
///   layers: (geom-line(),),
///   scales: (scale-linewidth-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-linewidth-identity(name: none) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "identity",
  name: name,
)
