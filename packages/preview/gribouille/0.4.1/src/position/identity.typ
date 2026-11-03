///! Identity position adjustment.
///!
///! Default for most geoms: draws each row at its mapped position without
///! any offset.

/// Identity position adjustment: no offset applied to any row.
///
/// Typically set on a layer as `position: "identity"` rather than constructed directly; the constructor exists for symmetry with the other positions.
///
/// Returns: Position dictionary with `name: "identity"`, consumed by `plot`.
///
/// See also: `position-stack`, `position-dodge`, `position-fill`.
///
/// Explicit identity position on a scatter, equivalent to the default behaviour of most geoms.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2),
///   (x: 2, y: 4),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt, position: "identity"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Use identity on `geom-col` when you have pre-computed bar heights you want drawn unchanged, even if a `fill` mapping is present.
///
/// ```typst
/// #let d = (
///   (q: "Q1", grp: "a", y: 3),
///   (q: "Q1", grp: "b", y: 5),
///   (q: "Q2", grp: "a", y: 4),
///   (q: "Q2", grp: "b", y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp"),
///   layers: (geom-col(position: "identity", alpha: 0.6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let position-identity() = (kind: "position", name: "identity")

#let apply(data, mapping, params: (:), coord: none) = (
  data: data,
  mapping: mapping,
)
