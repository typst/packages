///! Secondary axes for continuous x and y scales.
///!
///! A secondary axis draws an extra set of ticks on the opposite side of the
///! panel, optionally derived from the primary axis through a transformation
///! function. Pass the result of `dup-axis` or `sec-axis` to the `secondary:`
///! parameter of `scale-x-continuous` or `scale-y-continuous`.

/// Duplicate the primary axis on the opposite side of the panel.
///
/// Draws the same ticks as the primary axis but on the top edge for x or the right edge for y, optionally with a different title.
///
/// - name: Title shown above or beside the secondary axis, or `none`.
/// - breaks: Array of break values, or `auto` to mirror the primary axis.
/// - labels: Array of labels aligned with `breaks`, or `auto`.
///
/// Returns: Secondary axis dictionary consumed by `scale-x-continuous` and `scale-y-continuous`.
///
/// See also: `sec-axis`, `scale-x-continuous`, `scale-y-continuous`.
///
/// Mirror the x axis on top with a different title.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i, y: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (
///     scale-x-continuous(name: "x", secondary: dup-axis(name: "x'")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Mirror the y axis on the right with custom break positions.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i, y: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: (
///     scale-y-continuous(
///       name: "y",
///       secondary: dup-axis(breaks: (0, 25, 50, 75, 100)),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let dup-axis(name: none, breaks: auto, labels: auto) = (
  kind: "secondary-axis",
  transform: "identity",
  name: name,
  breaks: breaks,
  labels: labels,
)

/// Secondary axis derived from the primary through a transformation.
///
/// `transform` is a function mapping a primary-axis value to its secondary-axis value. Use `"identity"` to mirror the primary axis exactly, or pass any callable, e.g., `x => x * 9 / 5 + 32` for Celsius to Fahrenheit.
///
/// - transform: Function or `"identity"` mapping primary values to secondary values.
/// - name: Title shown above or beside the secondary axis, or `none`.
/// - breaks: Array of break values in primary units, or `auto`.
/// - labels: Array of labels aligned with `breaks`, or `auto`.
///
/// Returns: Secondary axis dictionary consumed by `scale-x-continuous` and `scale-y-continuous`.
///
/// See also: `dup-axis`, `scale-x-continuous`, `scale-y-continuous`.
///
/// Celsius primary axis with a Fahrenheit secondary derived through a callable.
///
/// ```typst
/// #let d = range(0, 11).map(i => (c: i * 5, mpg: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "c", y: "mpg"),
///   layers: (geom-point(size: 2pt),),
///   scales: (
///     scale-x-continuous(
///       name: "Celsius",
///       secondary: sec-axis(transform: x => x * 9 / 5 + 32, name: "Fahrenheit"),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// A y secondary axis converting metres to feet, useful for dual-unit displays.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i, m: i * 3))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "m"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (
///     scale-y-continuous(
///       name: "Metres",
///       secondary: sec-axis(transform: m => m * 3.281, name: "Feet"),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let sec-axis(
  transform: "identity",
  name: none,
  breaks: auto,
  labels: auto,
) = (
  kind: "secondary-axis",
  transform: transform,
  name: name,
  breaks: breaks,
  labels: labels,
)

// Map a primary value through the secondary's transformation.
#let apply-transform(sec, value) = {
  let t = sec.transform
  if t == "identity" or t == none { return value }
  t(value)
}
