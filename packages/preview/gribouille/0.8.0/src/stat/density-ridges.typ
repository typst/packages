///! Per-group horizontal kernel density estimate. Backing stat for
///! \@geom-density-ridges.
///!
///! Buckets rows by their y value and smooths each bucket's x sample into
///! a density curve along x, with a `height` column normalised across the
///! buckets of one aesthetic group so ridges share a common scale.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": read-weight
#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/group.typ": bucket-by-col
#import "../utils/kde.typ": kde-1d, validate-kde-params

/// Ridgeline statistic: Gaussian kernel density estimate of x per y bucket.
///
/// For every distinct y value, emits `n` evenly spaced rows along x where `height` is the estimated density scaled to a shared maximum of 1 across all buckets, plus the after-stat columns `_density` (estimated density), `_scaled` (density scaled per bucket), and `_n` (the bucket's observation count).
///
/// (R's `bw.nrd0`); pass a positive number to fix it.
///
/// `adjust: 0.5` halves the smoothing.
///
/// per bucket.
///
/// `false` (default) extends the grid by three bandwidths on each side so every ridge decays to its baseline.
///
/// - bw: Kernel bandwidth. `auto` applies Silverman's rule of thumb
/// - adjust: Bandwidth multiplier: the kernels use `adjust * bw`, so
/// - n: Number of evenly spaced grid points the density is evaluated at
/// - trim: Whether to restrict each curve to its bucket's x range.
///
/// Returns: Statistic object with `name: "density-ridges"`, consumed by `geom-density-ridges`.
///
/// See also: `geom-density-ridges`, `stat-density`, `stat-ydensity`.
///
/// Sharper ridges via `adjust` on the backing statistic.
///
/// ```typst
/// #let xs = (1, 2, 2, 3, 5, 6, 6, 7)
/// #let d = ()
/// #for (i, grp) in ("a", "b", "c").enumerate() {
///   for x in xs {
///     d.push((grp: grp, x: x + i))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "grp"),
///   layers: (geom-density-ridges(scale: 1.4, stat: stat-density-ridges(adjust: 0.5)),),
///   scales: scales(y: scale-discrete(expand: (auto, 45%))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-density-ridges(bw: auto, adjust: 1, n: 512, trim: false) = (
  kind: "stat",
  name: "density-ridges",
  params: (bw: bw, adjust: adjust, n: n, trim: trim),
)

#let apply(data, mapping, params: (:)) = {
  let base-mapping = stat-output-mapping(mapping, (x: "x", height: "height"))
  if mapping == none { return (data: (), mapping: base-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: (), mapping: base-mapping)
  }
  validate-kde-params("stat-density-ridges", params)
  let weight-col = mapping.at("weight", default: none)

  // Bucket rows by their raw y value in first-appearance order so the
  // downstream discrete y scale keeps the input's level ordering.
  // One KDE per bucket; height normalisation needs every bucket's peak, so
  // estimate first and scale in a second pass.
  let estimates = ()
  for rows in bucket-by-col(data, y-col) {
    let pairs = rows
      .map(r => {
        let xv = parse-number(r.at(x-col, default: none))
        if xv == none { return none }
        (x: xv, w: read-weight(r, weight-col))
      })
      .filter(p => p != none and p.w > 0)
    if pairs.len() < 2 { continue }
    let raw-y = rows.first().at(y-col, default: none)
    let parsed-y = parse-number(raw-y)
    let estimate = kde-1d(
      pairs,
      bw: params.at("bw", default: auto),
      adjust: params.at("adjust", default: 1),
      n: params.at("n", default: 512),
      trim: params.at("trim", default: false),
    )
    let peak = calc.max(..estimate.rows.map(r => r.density))
    estimates.push((
      y: if parsed-y != none { parsed-y } else { raw-y },
      rows: estimate.rows,
      peak: if peak > 0 { peak } else { 1 },
      n-obs: pairs.len(),
    ))
  }
  if estimates.len() == 0 { return (data: (), mapping: base-mapping) }

  let shared-peak = calc.max(..estimates.map(e => e.peak))
  let out = ()
  for est in estimates {
    for r in est.rows {
      // Keep y under its source column name (like stat-boxplot) so a
      // grouping aesthetic mapped to the same column still finds its value.
      let row = (
        x: r.x,
        height: r.density / shared-peak,
        _density: r.density,
        _scaled: r.density / est.peak,
        _n: est.n-obs,
      )
      row.insert(y-col, est.y)
      out.push(row)
    }
  }
  let out-mapping = base-mapping
  out-mapping.insert("y", y-col)
  (data: out, mapping: out-mapping)
}
