///! Cartesian coordinate system.
///!
///! The default coordinate system used when no `coord` is passed to \@plot.
///! `xlim` and `ylim` clip the rendered panel without dropping rows, unlike
///! scale limits which remove rows outside the domain.

/// Cartesian coordinate system with optional panel clipping.
///
/// Clipping via `xlim`/`ylim` preserves the trained scales; rows outside
/// are still used for training but drawn off-panel.
///
/// \@category Coord
/// \@stability stable
/// \@since 0.0.1
///
/// \@param xlim Pair `(lo, hi)` clipping the drawn x range, or `none`.
///
/// \@param ylim Pair `(lo, hi)` clipping the drawn y range, or `none`.
///
/// \@param expand Whether to add a small margin around the data range.
///
/// \@param clip Set to `"off"` to let geoms (typically annotations) draw past the panel rectangle. Defaults to `"on"`.
///
/// \@returns Coordinate dictionary consumed by \@plot.
///
/// \@examples Clip the drawn panel without dropping rows from training.
/// ```
/// //| alt: "Scatter chart of a linear y = x/2 series with x from 0 to 19; the panel is clipped to x between 2 and 15 and y between 0 and 8 so only the central segment is drawn."
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
/// \@examples Disabling `expand` removes the default margin so axis lines
/// hug the data range.
/// ```
/// //| alt: "Line with points along the y = x diagonal from 0 to 10; axis lines hug the data range with no expansion margin."
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
/// \@examples Set `clip: "off"` so an annotation placed at the data edge can
/// extend past the panel rectangle.
/// ```
/// //| alt: "Scatter chart of y = x/2 from x = 0 to 9 with a text annotation 'Long label' at (9, 4.5) that extends past the right panel edge because clipping is disabled."
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
///
/// \@see \@plot, \@scale-x-continuous
#let coord-cartesian(xlim: none, ylim: none, expand: true, clip: "on") = (
  kind: "coord",
  coord: "cartesian",
  xlim: xlim,
  ylim: ylim,
  expand: expand,
  clip: clip,
)
