///! Fixed aspect-ratio coordinate system.
///!
///! Locks the panel so that one data unit on x maps to `ratio` data units on y.
///! Scale training is unchanged; only the inner panel pixel size is adjusted.

/// Cartesian coordinate system with a fixed data-unit aspect ratio.
///
/// The user's `width` and `height` act as upper bounds: the renderer keeps the smaller of the two derived panel dimensions and shrinks the longer axis so that one x data unit projects to `ratio` y data units.
///
/// - ratio: Number of y data units per x data unit (default `1`).
///
/// Returns: Coordinate dictionary consumed by `plot`.
///
/// See also: `plot`, `coord-cartesian`.
///
/// One x unit equals one y unit, useful for spatial data where the axes share units.
///
/// ```typst
/// #let d = range(0, 20).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   coord: coord-fixed(ratio: 1),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// `ratio: 0.5` makes y units half the size of x units, useful for stretching tall data into a wide panel.
///
/// ```typst
/// #let d = range(0, 20).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(stroke: 1pt), geom-point(size: 2pt)),
///   coord: coord-fixed(ratio: 0.5),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let coord-fixed(ratio: 1) = (
  kind: "coord",
  coord: "fixed",
  ratio: ratio,
)
