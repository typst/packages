///! Fixed aspect-ratio coordinate system.
///!
///! Locks the panel so that one data unit on x maps to `ratio` data units on y.
///! Scale training is unchanged; only the inner panel pixel size is adjusted.

/// Cartesian coordinate system with a fixed data-unit aspect ratio.
///
/// The user's `width` and `height` act as upper bounds: the renderer keeps
/// the smaller of the two derived panel dimensions and shrinks the longer
/// axis so that one x data unit projects to `ratio` y data units.
///
/// \@category Coord
/// \@stability stable
/// \@since 0.0.1
///
/// \@param ratio Number of y data units per x data unit (default `1`).
///
/// \@returns Coordinate dictionary consumed by \@plot.
///
/// \@examples One x unit equals one y unit, useful for spatial data where
/// the axes share units.
/// ```
/// //| alt: "Scatter chart of x = 0 to 19 against y = x/2 with a 1:1 aspect ratio so the panel shrinks to keep one x unit equal to one y unit."
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
/// \@examples `ratio: 0.5` makes y units half the size of x units, useful
/// for stretching tall data into a wide panel.
/// ```
/// //| alt: "Line with points along y = x/2 from x = 0 to 19 drawn with y units half the size of x units, stretching the trend horizontally."
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
///
/// \@see \@plot, \@coord-cartesian
#let coord-fixed(ratio: 1) = (
  kind: "coord",
  coord: "fixed",
  ratio: ratio,
)
