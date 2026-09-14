///! Stack position adjustment.

#import "_cumulate.typ": cumulate-by-x
#import "../utils/radial.typ": is-radial

/// Stack position adjustment: cumulate y per x bucket.
///
/// Stacking is per x bucket across all groups. Rows are sorted by the grouping aesthetic so the first alphabetic level sits at the top of the bar in cartesian coords (legend top entry = top band). Under any `coord-radial` the cumulation flips so the first alphabetic level becomes the first slice clockwise from 12 o'clock.
///
/// Typically set on a layer as `position: "stack"` rather than constructed directly; the constructor exists for symmetry with the other positions.
///
/// Returns: Position dictionary with `name: "stack"`, consumed by `plot`.
///
/// See also: `position-dodge`, `position-fill`, `position-identity`.
///
/// Two groups stacked per quarter to show component contribution to a total.
///
/// ```typst
/// #let d = (
///   (q: "Q1", grp: "a", y: 3),
///   (q: "Q1", grp: "b", y: 5),
///   (q: "Q2", grp: "a", y: 4),
///   (q: "Q2", grp: "b", y: 2),
///   (q: "Q3", grp: "a", y: 6),
///   (q: "Q3", grp: "b", y: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp"),
///   layers: (geom-col(position: "stack"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Stacked area chart over time, useful when the running total itself is informative.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for i in range(0, 10) {
///     d.push((x: i, y: i * 0.3 + (if grp == "b" { 1 } else if grp == "c" { 2 } else { 0 }), grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "grp"),
///   layers: (geom-area(position: "stack", alpha: 0.6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let position-stack() = (kind: "position", name: "stack")

#let apply(data, mapping, params: (:), coord: none) = {
  let slice = if is-radial(coord) {
    (cum, yv, tot) => (cum, cum + yv)
  } else {
    (cum, yv, tot) => (tot - cum - yv, tot - cum)
  }
  cumulate-by-x(data, mapping, slice)
}
