///! Grid faceting.
///!
///! Panels arranged on a `row x column` grid, driven by two discrete variables.
///! Scales may be shared (`"fixed"`) or freed per column (`x`) / row (`y`).

#import "labellers.typ": label-value
#import "../utils/errors.typ": fail, fail-enum

/// Grid facets: panels on a row x column grid from two discrete variables.
///
/// Either `rows` or `columns` may be `none`, but not both. Free scales follow the grid structure: `"free_x"` frees x per column, `"free_y"` frees y per row, and `"free"` frees both; non-positional scales stay shared.
///
/// - rows: Name of the discrete column driving panel rows, or `none`.
/// - columns: Name of the discrete column driving panel columns, or `none`.
/// - scales: Scale policy: `"fixed"` (default, shared), `"free_x"` (x free per column), `"free_y"` (y free per row), or `"free"` (both).
/// - labeller: Labeller controlling strip text. Defaults to `label-value()` which shows the level as-is.
///
/// Returns: Facet dictionary consumed by `plot`.
///
/// See also: `facet-wrap`, `plot`.
///
/// Two discrete variables driving the row and column structure.
///
/// ```typst
/// #let d = ()
/// #for sp in ("a", "b") {
///   for sex in ("F", "M") {
///     for i in range(0, 5) {
///       d.push((sp: sp, sex: sex, x: i, y: i + 1))
///     }
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-grid(rows: "sex", columns: "sp"),
///   width: 12cm,
///   height: 7cm,
/// )
/// ```
///
/// Pass only `rows:` (or only `columns:`) for a one-dimensional grid layout.
///
/// ```typst
/// #let d = ()
/// #for sex in ("F", "M") {
///   for i in range(0, 6) {
///     d.push((sex: sex, x: i, y: i * 1.5))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-grid(rows: "sex"),
///   width: 12cm,
///   height: 7cm,
/// )
/// ```
#let facet-grid(
  rows: none,
  columns: none,
  scales: "fixed",
  labeller: label-value(),
) = {
  if not ("fixed", "free", "free_x", "free_y").contains(scales) {
    fail-enum(
      "facet-grid",
      "scales",
      scales,
      ("fixed", "free", "free_x", "free_y"),
    )
  }
  if rows == none and columns == none {
    fail("facet-grid", "needs at least one of rows: or columns:")
  }
  (
    kind: "facet",
    facet: "grid",
    rows: rows,
    columns: columns,
    scales: scales,
    labeller: labeller,
  )
}
