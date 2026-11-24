///! Pass-through statistic.
///!
///! Use `stat-identity` whenever you want a layer to draw the dataset as-is,
///! without any pre-aggregation or transformation.

/// Identity statistic: returns data and mapping unchanged.
///
/// Useful as an explicit marker; most geoms default to this statistic.
///
/// Returns: Statistic object with `name: "identity"`, consumed by geom layers.
///
/// See also: `stat-count`, `stat-bin`, `stat-smooth`.
///
/// Explicit `stat: "identity"` on a scatter, equivalent to the default behaviour.
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
///   layers: (geom-point(size: 3pt, stat: "identity"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pre-aggregated heights drawn directly with `geom-col`, using `stat-identity` to skip any binning.
///
/// ```typst
/// #let d = (
///   (q: "Q1", revenue: 10),
///   (q: "Q2", revenue: 18),
///   (q: "Q3", revenue: 25),
///   (q: "Q4", revenue: 22),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "revenue"),
///   layers: (geom-col(stat: stat-identity()),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-identity() = (kind: "stat", name: "identity", params: (:))

#let apply(data, mapping, params: (:)) = (data: data, mapping: mapping)
