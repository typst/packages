///! Deterministic offset by a fixed `(x, y)`.
///!
///! Useful for separating two layers that would otherwise overlap, e.g.,
///! shifting text labels off their points.

#import "../utils/types.typ": parse-number

/// Shift every row's x and y by a fixed amount in data units.
///
/// - x: Offset added to the x value of each row.
/// - y: Offset added to the y value of each row.
///
/// Returns: Position dictionary with `name: "nudge"`, consumed by `plot`.
///
/// See also: `position-jitter`, `geom-text`.
///
/// Offset text labels above their points using a default `position-nudge()`.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, lab: "alpha"),
///   (x: 2, y: 4, lab: "beta"),
///   (x: 3, y: 3, lab: "gamma"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "lab"),
///   layers: (
///     geom-point(size: 3pt),
///     geom-text(position: "nudge"),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pass explicit `x` and `y` offsets to flow labels diagonally off the points.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, lab: "alpha"),
///   (x: 2, y: 4, lab: "beta"),
///   (x: 3, y: 3, lab: "gamma"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "lab"),
///   layers: (
///     geom-point(size: 3pt),
///     geom-text(position: position-nudge(x: 0.2, y: 0.3)),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let position-nudge(x: 0, y: 0) = (
  kind: "position",
  name: "nudge",
  params: (x: x, y: y),
)

#let apply(data, mapping, params: (:), coord: none) = {
  let dx = params.at("x", default: 0)
  let dy = params.at("y", default: 0)
  if dx == 0 and dy == 0 { return (data: data, mapping: mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let new-data = data.map(row => {
    let r = row
    if x-col != none and dx != 0 {
      let v = parse-number(row.at(x-col, default: none))
      if v != none { r.insert(x-col, v + dx) }
    }
    if y-col != none and dy != 0 {
      let v = parse-number(row.at(y-col, default: none))
      if v != none { r.insert(y-col, v + dy) }
    }
    r
  })
  (data: new-data, mapping: mapping)
}
