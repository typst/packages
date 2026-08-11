///! Axis guide customisation.
///!
///! Build a guide spec the axis renderer respects when bound to the `x` or
///! `y` aesthetic via \@guides. Rotate tick labels with `angle` or stagger
///! them across multiple rows (x) or columns (y) with `n-dodge` to prevent
///! overlap.

/// Customise the x- or y-axis tick labels.
///
/// The returned spec carries customisation only; it is bound to an aesthetic when passed through `guides` as `x: guide-axis(...)` or `y: guide-axis(...)`, and applied by the axis renderer when drawing tick labels. On the x-axis `n-dodge` staggers labels across rows; on the y-axis it staggers them across columns receding from the axis.
///
/// - angle: Tick-label rotation in degrees: 0 horizontal, 45 readable diagonal, 90 vertical.
/// - n-dodge: Number of rows (x-axis) or columns (y-axis) across which to stagger tick labels; 1 keeps them on a single row/column.
///
/// Returns: Guide dictionary tagged `kind: "guide"`, consumed by `guides`.
///
/// See also: `guides`, `guide-legend`, `plot`.
///
/// Rotate long x tick labels so they don't overlap.
///
/// ```typst
/// #let d = (
///   (x: "January", y: 1),
///   (x: "February", y: 2),
///   (x: "March", y: 3),
///   (x: "April", y: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(x: guide-axis(angle: 30)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Stagger labels across two rows when many short ticks would pile up.
///
/// ```typst
/// #let months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug")
/// #let d = months.enumerate().map(((i, m)) => (x: m, y: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-col(),),
///   guides: guides(x: guide-axis(n-dodge: 2)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Rotate long y tick labels.
///
/// ```typst
/// #let cities = ("Anvers", "Bruxelles", "Charleroi", "Liège")
/// #let d = cities.enumerate().map(((i, c)) => (x: i + 1, y: c))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(y: guide-axis(angle: 30)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let guide-axis(angle: 0, n-dodge: 1) = (
  kind: "guide",
  aesthetic: none,
  angle: angle,
  n-dodge: n-dodge,
)

/// Add minor tick marks at log-scale subdivisions on a `transform: "log10"` axis.
///
/// Inherits the `angle` / `n-dodge` controls from `guide-axis` and additionally emits short, unlabelled tick marks at the sub-decade positions (2, 3, ..., 9 within each decade). Has no effect when the axis is not log10-transformed.
///
/// - angle: Tick-label rotation in degrees.
/// - n-dodge: Number of rows/columns across which to stagger labels.
///
/// Returns: Guide dictionary tagged `kind: "guide"`, consumed by `guides`.
///
/// See also: `guide-axis`, `guides`.
///
/// Major ticks at decade boundaries plus minor ticks at 2, 3, ..., 9.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1),
///   (x: 10, y: 100),
///   (x: 100, y: 10000),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   scales: (
///     scale-x-continuous(transform: "log10"),
///     scale-y-continuous(transform: "log10"),
///   ),
///   guides: guides(
///     x: guide-axis-logticks(),
///     y: guide-axis-logticks(),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let guide-axis-logticks(angle: 0, n-dodge: 1) = (
  kind: "guide",
  aesthetic: none,
  angle: angle,
  n-dodge: n-dodge,
  logticks: true,
)
