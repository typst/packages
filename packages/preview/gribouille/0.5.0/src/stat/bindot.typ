///! Dot-density binning.
///!
///! Backing statistic for \@geom-dotplot. Bins observations along x into
///! uniform-width buckets, emits one row per observation with the bin
///! midpoint as `x`, the within-bin stack index as `y`, and the bin width
///! plus per-bin count for reference.

#import "../utils/types.typ": parse-number
#import "../utils/bin.typ": (
  bin-midpoint, bin-of, panel-bin-grid, resolve-bin-grid,
)
#import "../utils/aes-resolve.typ": stat-output-mapping

/// Dot-density bin statistic: emit one stacked row per observation.
///
/// Either `bins` or `binwidth` fixes the partition; `binwidth` wins when both are supplied. The `y` column carries each observation's stack index within its bin, so geom-dotplot can place dots at increasing heights.
///
/// - bins: Target number of bins when `binwidth` is `none`.
/// - binwidth: Fixed bin width. Overrides `bins` when set.
/// - stackratio: Vertical spacing between stacked dots, in dot units. 1 means touching.
///
/// Returns: Statistic object with `name: "bindot"`, consumed by `geom-dotplot`.
///
/// See also: `geom-dotplot`, `stat-bin`.
///
/// `stat-bindot` powers `geom-dotplot`; forward `binwidth` (or `bins`) through the wrapper to stack each observation within a half-unit bucket.
///
/// ```typst
/// #let d = range(0, 40).map(i => (
///   x: calc.sin(i * 0.4) * 3 + calc.cos(i * 0.7) * 2,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-dotplot(binwidth: 0.5),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-bindot(bins: 30, binwidth: none, stackratio: 1.0) = (
  kind: "stat",
  name: "bindot",
  params: (bins: bins, binwidth: binwidth, stackratio: stackratio),
)

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  if x-col == none { return (data: data, mapping: mapping) }
  let new-mapping = stat-output-mapping(mapping, (x: "x", y: "y"))
  let xs = data
    .map(r => parse-number(r.at(x-col, default: none)))
    .filter(v => v != none)
  if xs.len() == 0 { return (data: (), mapping: new-mapping) }
  let grid = resolve-bin-grid(xs, params)
  let counts = range(grid.n-bins).map(_ => 0)
  let assignments = ()
  for x in xs {
    let idx = bin-of(x, grid.lo, grid.width, grid.n-bins)
    assignments.push((bin: idx, stack: counts.at(idx)))
    counts.at(idx) = counts.at(idx) + 1
  }
  let stackratio = params.at("stackratio", default: 1.0)
  let rows = assignments.map(a => (
    x: bin-midpoint(grid.lo, grid.width, a.bin),
    y: (a.stack + 0.5) * stackratio,
    _bin-count: counts.at(a.bin),
    width: grid.width,
  ))
  (data: rows, mapping: new-mapping)
}
