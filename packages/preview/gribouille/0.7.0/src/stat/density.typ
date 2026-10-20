///! Gaussian kernel density estimate.
///!
///! Backing statistic for \@geom-density. Smooths the x sample into a dense
///! `(x, y)` density curve: each grid value is the weight-normalised sum of
///! Gaussian kernels centred on the observations, evaluated directly
///! (O(rows × n) per group, workable for plot-sized inputs).

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": read-weight
#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/kde.typ": kde-1d, validate-kde-params

/// Density statistic: Gaussian kernel density estimate of the x sample.
///
/// Emits `n` evenly spaced `(x, y)` rows per group where `y` is the estimated density, plus the after-stat columns `_density` (same as `y`), `_count` (density scaled by the number of observations), `_scaled` (density scaled to a maximum of 1), and `_n` (the number of observations).
///
/// (R's `bw.nrd0`); pass a positive number to fix it.
///
/// `adjust: 0.5` halves the smoothing.
///
/// (default) extends it by three bandwidths on each side so the curve decays to the baseline.
///
/// - bw: Kernel bandwidth. `auto` applies Silverman's rule of thumb
/// - adjust: Bandwidth multiplier: the kernels use `adjust * bw`, so
/// - n: Number of evenly spaced grid points the density is evaluated at.
/// - trim: Whether to restrict the grid to the data range. `false`
///
/// Returns: Statistic object with `name: "density"`, consumed by geom layers.
///
/// See also: `geom-density`, `stat-bin`, `stat-ecdf`.
///
/// Density curve of a skewed sample via `geom-line(stat: "density")`.
///
/// ```typst
/// #let d = range(0, 60).map(i => (
///   x: calc.pow(calc.rem(i * 7, 30) / 10, 2) * 0.7 + 1,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-line(stat: "density", stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Constructor form: customise the smoothing with `adjust` on any geom; here a coarser and a finer estimate of the same sample overlay.
///
/// ```typst
/// #let d = range(0, 60).map(i => (
///   x: calc.sin(i * 0.9) * 2 + calc.rem(i, 3),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (
///     geom-line(stat: stat-density(adjust: 2), stroke: 1pt),
///     geom-line(stat: stat-density(adjust: 0.5), stroke: 1pt, linetype: "dashed"),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-density(bw: auto, adjust: 1, n: 512, trim: false) = (
  kind: "stat",
  name: "density",
  params: (bw: bw, adjust: adjust, n: n, trim: trim),
)

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  let new-mapping = stat-output-mapping(mapping, (x: "x", y: "y"))
  if x-col == none { return (data: (), mapping: new-mapping) }
  validate-kde-params("stat-density", params)
  let weight-col = mapping.at("weight", default: none)
  let pairs = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      if xv == none { return none }
      (x: xv, w: read-weight(r, weight-col))
    })
    .filter(p => p != none and p.w > 0)
  if pairs.len() < 2 { return (data: (), mapping: new-mapping) }

  let n-obs = pairs.len()
  let estimate = kde-1d(
    pairs,
    bw: params.at("bw", default: auto),
    adjust: params.at("adjust", default: 1),
    n: params.at("n", default: 512),
    trim: params.at("trim", default: false),
  )
  let peak = calc.max(..estimate.rows.map(r => r.density))
  let denom = if peak > 0 { peak } else { 1 }
  let rows = estimate.rows.map(r => (
    x: r.x,
    y: r.density,
    _density: r.density,
    _count: r.density * n-obs,
    _scaled: r.density / denom,
    _n: n-obs,
  ))
  (data: rows, mapping: new-mapping)
}
