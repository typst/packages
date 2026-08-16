///! Cartesian coordinate system.
///!
///! The default coordinate system used when no `coord` is passed to \@plot.
///! `xlim` and `ylim` clip the rendered panel without dropping rows, unlike
///! scale limits which remove rows outside the domain.

/// Cartesian coordinate system with optional panel clipping.
///
/// Clipping via `xlim`/`ylim` preserves the trained scales; rows outside are still used for training but drawn off-panel.
///
/// - xlim: Pair `(lo, hi)` clipping the drawn x range, or `none`.
/// - ylim: Pair `(lo, hi)` clipping the drawn y range, or `none`.
/// - expand: Whether to add a small margin around the data range.
/// - clip: Set to `"off"` to let geoms (typically annotations) draw past the panel rectangle. Defaults to `"on"`.
///
/// Returns: Coordinate dictionary consumed by `plot`.
///
/// See also: `plot`, `scale-x-continuous`.
///
/// Clip the drawn panel without dropping rows from training.
///
/// ```typst
/// #let d = range(0, 20).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   coord: coord-cartesian(xlim: (2, 15), ylim: (0, 8)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Disabling `expand` removes the default margin so axis lines hug the data range.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(stroke: 1pt), geom-point(size: 2pt)),
///   coord: coord-cartesian(expand: false),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Set `clip: "off"` so an annotation placed at the data edge can extend past the panel rectangle.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     annotate("typst", x: 9, y: 4.5, label: [Long label]),
///   ),
///   coord: coord-cartesian(clip: "off"),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let coord-cartesian(xlim: none, ylim: none, expand: true, clip: "on") = (
  kind: "coord",
  coord: "cartesian",
  xlim: xlim,
  ylim: ylim,
  expand: expand,
  clip: clip,
)
