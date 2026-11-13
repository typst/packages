///! Fixed aspect-ratio coordinate system.
///!
///! Locks the panel so that one data unit on x maps to `ratio` data units on y.
///! Scale training is unchanged; only the inner panel pixel size is adjusted.

#import "../utils/errors.typ": fail-type
#import "../utils/types.typ": check-number
#import "contract.typ": coord-base

// Shrink the inner panel along the longer axis so that one x data unit
// projects to `ratio` y data units. Returns the adjusted (width, height).
// Falls back to the input box if either trained scale is missing or has a
// zero-length domain.
#let _fixed-inner-size(ratio, trained, box-w, box-h) = {
  let x-trained = trained.at("x", default: none)
  let y-trained = trained.at("y", default: none)
  if x-trained == none or y-trained == none { return (box-w, box-h) }
  if x-trained.type != "continuous" or y-trained.type != "continuous" {
    return (box-w, box-h)
  }
  let (x-lo, x-hi) = x-trained.domain
  let (y-lo, y-hi) = y-trained.domain
  let dx = x-hi - x-lo
  let dy = y-hi - y-lo
  // A degenerate domain has no ratio to hold, and a box the chrome squeezed to
  // nothing has none either: hand the box back rather than divide by it.
  if dx <= 0 or dy <= 0 or box-w <= 0 or box-h <= 0 { return (box-w, box-h) }
  // Pixels-per-x-unit must equal ratio * pixels-per-y-unit.
  let want = (dy * ratio) / dx
  let have = box-h / box-w
  if want >= have {
    (box-h / want, box-h)
  } else {
    (box-w, box-w * want)
  }
}

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
#let coord-fixed(ratio: 1) = {
  check-number("coord-fixed", "ratio", ratio)
  if ratio <= 0 { fail-type("coord-fixed", "ratio", ratio, "a positive number") }
  (
    coord-base("fixed")
      + (
        ratio: ratio,
        panel-size: (trained, w, h) => _fixed-inner-size(ratio, trained, w, h),
      )
  )
}
