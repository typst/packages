///! User-supplied closure stat.

#let _identity = data => data

/// Manual statistic: run a closure on the data array inside the layer.
///
/// `fun` is invoked with `data` (an array of row dictionaries). The result
/// replaces the layer's data; mapping is unchanged. Use it for ad-hoc
/// transforms with no dedicated stat counterpart (e.g., centroids, hulls,
/// running totals).
///
/// \@category Stats
/// \@subcategory Functions and helpers
/// \@stability stable
/// \@since 0.6.0
///
/// \@param fun Closure `data => data` taking the row array and returning the
///   transformed array. Defaults to identity.
///
/// \@returns Statistic object with `name: "manual"`, consumed by geom layers.
///
/// \@examples Compute a per-row index column inside the layer pipeline and
/// label it via \@geom-text.
/// ```
/// //| alt: "Scatter chart with x and y axes plotting three points, each annotated by a per-row index label 1, 2, 3 derived inside the layer via stat-manual."
/// #let d = (
///   (x: 1, y: 2),
///   (x: 2, y: 4),
///   (x: 3, y: 3),
/// )
/// #let with-index = data => data.enumerate().map(((i, r)) => r + (label: str(i + 1)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "label"),
///   layers: (
///     geom-point(size: 3pt),
///     geom-text(stat: stat-manual(fun: with-index), dy: 0.3),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@stat-identity, \@stat-summary
#let stat-manual(fun: _identity) = (
  kind: "stat",
  name: "manual",
  params: (fun: fun),
)

#let apply(data, mapping, params: (:)) = {
  let fun = params.at("fun", default: _identity)
  (data: fun(data), mapping: mapping)
}
