///! Linewidth scale.
///!
///! Maps a numeric column onto a pair of Typst lengths describing the output
///! range of stroke thicknesses for line-style geoms.

/// Continuous linewidth scale mapping a numeric column to stroke thickness.
///
/// \@category Scales
/// \@subcategory Linewidth scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param range Pair of Typst lengths `(min, max)` bounding the output thickness.
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
/// \@examples Linewidth grows with `w`, one line per group.
/// ```
/// //| alt: "Line chart of four diagonal lines whose stroke thickness scales continuously with w from thin to thick."
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
/// \@examples Pair `colour` and `linewidth` with the same column to encode
/// magnitude through both channels.
/// ```
/// //| alt: "Line chart of four diagonal lines where w encodes both stroke thickness and colour so magnitude grows redundantly through both channels."
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
///
/// \@see \@scale-linewidth-identity, \@scale-size-continuous
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
/// Use when each level should map to a chosen thickness rather than the
/// evenly-spaced range that the discrete inference would assign.
///
/// \@category Scales
/// \@subcategory Linewidth scales
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
/// \@examples Three groups assigned thin/medium/thick strokes.
/// ```
/// //| alt: "Line chart of three groups along x against y where manual values pin group a to a thin stroke, b to medium, and c to a thick stroke."
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
///
/// \@see \@scale-linewidth-continuous, \@scale-linewidth-identity
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
/// Maps a numeric column onto a stroke-thickness range, but groups values
/// into `n-breaks` bins for the legend. The mapping stays continuous so
/// drawn strokes vary smoothly within each bin; only the legend swatches
/// snap to bin centres.
///
/// \@category Scales
/// \@subcategory Linewidth scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param n-breaks Number of legend bins.
///
/// \@param range Pair of Typst lengths `(min, max)` bounding the output thickness.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Linewidth grows with `w`, with the legend grouped into four bins.
/// ```
/// //| alt: "Line chart of four diagonal lines whose strokes thicken with w while the legend collapses into four stepped thickness bins."
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
///
/// \@see \@scale-linewidth-continuous, \@scale-size-binned
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
/// Values must be Typst lengths. No legend is drawn because the column
/// carries the visual outcome verbatim.
///
/// \@category Scales
/// \@subcategory Linewidth scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row Typst lengths carried straight through to the line
/// strokes; no legend is drawn.
/// ```
/// //| alt: "Line chart of two segments along x against y where the lw column passes through as the stroke thickness, one thin and one thick, with no legend."
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
///
/// \@see \@scale-linewidth-continuous
#let scale-linewidth-identity(name: none) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "identity",
  name: name,
)
