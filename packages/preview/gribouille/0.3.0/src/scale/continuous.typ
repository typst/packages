///! Continuous position scales for x and y.
///!
///! Use these to override the default continuous axis: set `limits` to clip,
///! `breaks` and `labels` to control tick marks, or `transform` to apply
///! `"log10"`, `"sqrt"`, or `"reverse"` transformations.

#let _continuous-scale(
  aesthetic,
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  transform: "identity",
  expand: auto,
  secondary: none,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  transform: transform,
  expand: expand,
  secondary: secondary,
)

#let _transform-scale(
  aesthetic,
  transform,
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  transform: transform,
  expand: auto,
)

#let _binned-scale(
  aesthetic,
  name: none,
  limits: none,
  oob: "drop",
  n-breaks: 10,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  limits: limits,
  oob: oob,
  breaks: auto,
  labels: labels,
  transform: "identity",
  expand: auto,
  binned: true,
  n-breaks: n-breaks,
)

/// Continuous x scale: axis title, limits, breaks, labels, and transformation.
///
/// `transform` accepts `"identity"`, `"log10"`, `"sqrt"`, and `"reverse"`.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps them to the nearest endpoint.
/// - breaks: Array of break values, or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
/// - transform: Transformation keyword: `"identity"`, `"log10"`, `"sqrt"`, or `"reverse"`.
/// - expand: Padding around the domain. Accepts a `ratio` (`5%`) for proportional breathing room, a `length` (`5pt`) for canvas-space padding, a `relative` (`5pt + 5%`) for both, or a `(lo, hi)` 2-tuple for asymmetric padding. `auto` keeps the per-scale default; `false` collapses to zero.
/// - secondary: Secondary axis spec from `dup-axis` or `sec-axis`, or `none`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-y-continuous`, `scale-x-discrete`, `coord-cartesian`.
///
/// Override the axis title and pin the domain.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: i, y: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-continuous(name: "Index", limits: (0, 12)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Switch `transform` to `"sqrt"` and supply explicit `breaks` for a custom non-linear axis.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i * i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-continuous(
///     name: "x (sqrt)",
///     transform: "sqrt",
///     breaks: (0, 25, 50, 75, 100),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Apply `format-comma()` to format penguin body-mass tick labels with thousands separators on the x axis.
///
/// ```typst
/// #plot(
///   data: penguins,
///   mapping: aes(x: "body-mass", y: "flipper-len", fill: "species"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-continuous(name: "Body mass (g)", labels: format-comma()),),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
#let scale-x-continuous(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  transform: "identity",
  expand: auto,
  secondary: none,
) = _continuous-scale(
  "x",
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  transform: transform,
  expand: expand,
  secondary: secondary,
)

/// Continuous y scale: axis title, limits, breaks, labels, and transformation.
///
/// `transform` accepts `"identity"`, `"log10"`, `"sqrt"`, and `"reverse"`.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps them to the nearest endpoint.
/// - breaks: Array of break values, or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
/// - transform: Transformation keyword: `"identity"`, `"log10"`, `"sqrt"`, or `"reverse"`.
/// - expand: Padding around the domain. Accepts a `ratio` (`5%`) for proportional breathing room, a `length` (`5pt`) for canvas-space padding, a `relative` (`5pt + 5%`) for both, or a `(lo, hi)` 2-tuple for asymmetric padding. `auto` keeps the per-scale default; `false` collapses to zero.
/// - secondary: Secondary axis spec from `dup-axis` or `sec-axis`, or `none`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-x-continuous`, `scale-y-discrete`.
///
/// Log-10 transform compresses an exponential growth curve into a near-linear axis.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: i, y: calc.pow(2, i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-continuous(name: "Value", transform: "log10"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Reverse the y axis to put the largest values at the bottom, useful for ranks where lower numbers are better.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: i, y: 11 - i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-continuous(name: "Rank", transform: "reverse"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-y-continuous(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  transform: "identity",
  expand: auto,
  secondary: none,
) = _continuous-scale(
  "y",
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  transform: transform,
  expand: expand,
  secondary: secondary,
)

/// Continuous x scale on a base-10 log axis.
///
/// Thin wrapper over `scale-x-continuous` with `transform: "log10"`. All x values must be strictly positive.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps them to the nearest endpoint.
/// - breaks: Array of break values, or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-x-continuous`, `scale-y-log10`.
///
/// Log-10 axis with auto breaks across several decades of x.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: calc.pow(10, i / 2), y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-log10(name: "x"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pin tick positions explicitly for tidier labelling on a known log range.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: calc.pow(10, i / 2), y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-log10(
///     name: "x",
///     breaks: (1, 10, 100, 1000, 10000),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-x-log10(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  _transform-scale(
    "x",
    "log10",
    name: name,
    limits: limits,
    oob: oob,
    breaks: breaks,
    labels: labels,
  )
)

/// Continuous y scale on a base-10 log axis.
///
/// Thin wrapper over `scale-y-continuous` with `transform: "log10"`. All y values must be strictly positive.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps them to the nearest endpoint.
/// - breaks: Array of break values, or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-y-continuous`, `scale-x-log10`.
///
/// Log-10 y axis turns an exponential into a near-linear shape.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: i, y: calc.pow(2, i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-log10(name: "y"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Combine `limits` and `breaks` to clip and label a specific log range.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: i, y: calc.pow(2, i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-log10(
///     name: "y",
///     limits: (2, 1024),
///     breaks: (2, 8, 32, 128, 512),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-y-log10(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  _transform-scale(
    "y",
    "log10",
    name: name,
    limits: limits,
    oob: oob,
    breaks: breaks,
    labels: labels,
  )
)

/// Continuous x scale on a square-root axis.
///
/// Thin wrapper over `scale-x-continuous` with `transform: "sqrt"`. All x values must be non-negative.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps them to the nearest endpoint.
/// - breaks: Array of break values, or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-x-continuous`, `scale-y-sqrt`.
///
/// Square-root x axis spreads small values and compresses large ones.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i * i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-sqrt(name: "x"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pin breaks at perfect squares so the labels match the underlying data structure.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i * i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-sqrt(
///     name: "x",
///     breaks: (0, 4, 16, 36, 64, 100),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-x-sqrt(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  _transform-scale(
    "x",
    "sqrt",
    name: name,
    limits: limits,
    oob: oob,
    breaks: breaks,
    labels: labels,
  )
)

/// Continuous y scale on a square-root axis.
///
/// Thin wrapper over `scale-y-continuous` with `transform: "sqrt"`. All y values must be non-negative.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps them to the nearest endpoint.
/// - breaks: Array of break values, or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-y-continuous`, `scale-x-sqrt`.
///
/// Square-root y axis straightens a quadratic relationship.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i, y: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-sqrt(name: "y"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Combine with `limits` to highlight a specific range without changing the underlying data.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i, y: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-sqrt(name: "y", limits: (0, 64)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-y-sqrt(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  _transform-scale(
    "y",
    "sqrt",
    name: name,
    limits: limits,
    oob: oob,
    breaks: breaks,
    labels: labels,
  )
)

/// Continuous x scale flipped left-to-right.
///
/// Thin wrapper over `scale-x-continuous` with `transform: "reverse"`. Tick labels stay in data units; only the axis direction reverses.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps them to the nearest endpoint.
/// - breaks: Array of break values, or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-x-continuous`, `scale-y-reverse`.
///
/// Reverse the x axis so values decrease left-to-right.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-reverse(name: "x"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pair with `limits` to clip a reversed timeline to a specific window.
///
/// ```typst
/// #let d = range(2000, 2025).map(y => (x: y, y: calc.sin(y / 4)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-x-reverse(name: "Year", limits: (2024, 2010)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-x-reverse(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  _transform-scale(
    "x",
    "reverse",
    name: name,
    limits: limits,
    oob: oob,
    breaks: breaks,
    labels: labels,
  )
)

/// Binned continuous x scale: quantises a numeric axis into `n-breaks` bins.
///
/// Keeps the underlying mapping continuous so geoms still receive their raw numeric position, but places ticks at the midpoint of each equal-width bin to communicate the discretised reading of the axis.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps them to the nearest endpoint.
/// - n-breaks: Number of bins to partition the domain into.
/// - labels: Array of tick labels aligned with the bin midpoints, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-y-binned`, `scale-x-continuous`.
///
/// Five equal-width bins along the x axis.
///
/// ```typst
/// #let d = range(0, 30).map(i => (x: i / 3.0, y: calc.sin(i / 4.0)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-binned(n-breaks: 5),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Bump `n-breaks` for a finer grid; pair with `limits` to focus on a sub-range.
///
/// ```typst
/// #let d = range(0, 30).map(i => (x: i / 3.0, y: calc.sin(i / 4.0)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-x-binned(n-breaks: 10, limits: (2, 8)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-x-binned(
  name: none,
  limits: none,
  oob: "drop",
  n-breaks: 10,
  labels: auto,
) = _binned-scale(
  "x",
  name: name,
  limits: limits,
  oob: oob,
  n-breaks: n-breaks,
  labels: labels,
)

/// Binned continuous y scale: quantises a numeric axis into `n-breaks` bins.
///
/// Counterpart of `scale-x-binned` for the y axis.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps them to the nearest endpoint.
/// - n-breaks: Number of bins to partition the domain into.
/// - labels: Array of tick labels aligned with the bin midpoints, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-x-binned`, `scale-y-continuous`.
///
/// Five equal-width bins along the y axis.
///
/// ```typst
/// #let d = range(0, 30).map(i => (x: i, y: i / 3.0))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-binned(n-breaks: 5),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// A finer ten-bin partition with `limits` clipping the lower tail.
///
/// ```typst
/// #let d = range(0, 30).map(i => (x: i, y: i / 3.0))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-binned(n-breaks: 10, limits: (2, 9)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-y-binned(
  name: none,
  limits: none,
  oob: "drop",
  n-breaks: 10,
  labels: auto,
) = _binned-scale(
  "y",
  name: name,
  limits: limits,
  oob: oob,
  n-breaks: n-breaks,
  labels: labels,
)

/// Continuous y scale flipped bottom-to-top.
///
/// Thin wrapper over `scale-y-continuous` with `transform: "reverse"`. Tick labels stay in data units; only the axis direction reverses.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps them to the nearest endpoint.
/// - breaks: Array of break values, or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-y-continuous`, `scale-x-reverse`.
///
/// Reverse the y axis so larger values sit at the bottom.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (scale-y-reverse(name: "y"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Useful for ranking displays where rank 1 should sit at the top.
///
/// ```typst
/// #let d = (
///   (team: "A", rank: 1),
///   (team: "B", rank: 2),
///   (team: "C", rank: 3),
///   (team: "D", rank: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "team", y: "rank"),
///   layers: (geom-point(size: 4pt),),
///   scales: (scale-y-reverse(name: "Rank", breaks: (1, 2, 3, 4)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-y-reverse(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  _transform-scale(
    "y",
    "reverse",
    name: name,
    limits: limits,
    oob: oob,
    breaks: breaks,
    labels: labels,
  )
)
