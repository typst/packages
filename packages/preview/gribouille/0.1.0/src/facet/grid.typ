///! Grid faceting.
///!
///! Panels arranged on a `row x column` grid, driven by two discrete variables.
///! v1 supports shared scales only.

#import "labellers.typ": label-value

/// Grid facets: panels on a row x column grid from two discrete variables.
///
/// Either `rows` or `columns` may be `none`, but not both. Only shared
/// scales are supported in v1.
///
/// \@category Facets
/// \@stability stable
/// \@since 0.0.1
///
/// \@param rows Name of the discrete column driving panel rows, or `none`.
///
/// \@param columns Name of the discrete column driving panel columns, or `none`.
///
/// \@param scales Scale policy. Only `"fixed"` is supported in v1.
///
/// \@param labeller Labeller controlling strip text. Defaults to
///   `label-value()` which shows the level as-is.
///
/// \@returns Facet dictionary consumed by \@plot.
///
/// \@examples Two discrete variables driving the row and column structure.
/// ```
/// //| alt: "2-by-2 grid of scatter panels with sex (F, M) on the rows and species (a, b) on the columns; each panel shows the same y = x + 1 line."
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
/// \@examples Pass only `rows:` (or only `columns:`) for a one-dimensional
/// grid layout.
/// ```
/// //| alt: "Two scatter panels stacked vertically, one row per sex (F, M), both showing the same y = 1.5x line over x = 0 to 5."
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
///
/// \@see \@facet-wrap, \@plot
#let facet-grid(
  rows: none,
  columns: none,
  scales: "fixed",
  labeller: label-value(),
) = {
  if scales != "fixed" {
    panic("facet-grid currently supports scales: \"fixed\" only")
  }
  if rows == none and columns == none {
    panic("facet-grid needs at least one of rows: or columns:")
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
