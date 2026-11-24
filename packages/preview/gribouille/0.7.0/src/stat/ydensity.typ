///! Per-group vertical kernel density estimate.
///!
///! Backing statistic for \@geom-violin. Buckets rows by their x value and
///! smooths each bucket's y sample into a dense density curve along y,
///! with a `violinwidth` column normalised for side-by-side display.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": read-weight
#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/errors.typ": fail-enum
#import "../utils/group.typ": bucket-by-col
#import "../utils/kde.typ": kde-1d, validate-kde-params

/// Y-density statistic: Gaussian kernel density estimate of y per x bucket.
///
/// For every distinct x value, emits `n` evenly spaced rows along y where `violinwidth` is the display width in `[0, 1]`, plus the after-stat columns `_density` (estimated density), `_count` (density scaled by the bucket's observation count), `_scaled` (density scaled to a per-bucket maximum of 1), and `_n` (the bucket's observation count).
///
/// Widths are normalised across the buckets of one aesthetic group; with a `colour`/`fill` grouping each group normalises independently.
///
/// (R's `bw.nrd0`); pass a positive number to fix it.
///
/// `adjust: 0.5` halves the smoothing.
///
/// per bucket.
///
/// `true` (default) trims the tails; `false` extends the grid by three bandwidths on each side.
///
/// divides every density by the largest density so equal areas read as equal mass, `"count"` additionally weights each bucket by its observation count, and `"width"` stretches every bucket to the full width.
///
/// - bw: Kernel bandwidth. `auto` applies Silverman's rule of thumb
/// - adjust: Bandwidth multiplier: the kernels use `adjust * bw`, so
/// - n: Number of evenly spaced grid points the density is evaluated at
/// - trim: Whether to restrict each curve to its bucket's y range.
/// - scale: Width normalisation across buckets. `"area"` (default)
///
/// Returns: Statistic object with `name: "ydensity"`, consumed by `geom-violin`.
///
/// See also: `geom-violin`, `stat-density`, `stat-boxplot`.
///
/// Wider smoothing via `adjust` on the backing statistic.
///
/// ```typst
/// #let ys = (1, 2, 2, 3, 4, 4, 4, 5, 6, 7)
/// #let d = ()
/// #for grp in ("a", "b") {
///   for y in ys {
///     d.push((grp: grp, y: y + (if grp == "b" { 2 } else { 0 })))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (geom-violin(stat: stat-ydensity(adjust: 2)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-ydensity(
  bw: auto,
  adjust: 1,
  n: 512,
  trim: true,
  scale: "area",
) = (
  kind: "stat",
  name: "ydensity",
  params: (bw: bw, adjust: adjust, n: n, trim: trim, scale: scale),
)

#let _SCALE-MODES = ("area", "count", "width")

#let apply(data, mapping, params: (:)) = {
  let base-mapping = stat-output-mapping(mapping, (y: "y"))
  if mapping == none { return (data: (), mapping: base-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: (), mapping: base-mapping)
  }
  validate-kde-params("stat-ydensity", params)
  let scale-mode = params.at("scale", default: "area")
  if scale-mode not in _SCALE-MODES {
    fail-enum("stat-ydensity", "scale", scale-mode, _SCALE-MODES)
  }
  let weight-col = mapping.at("weight", default: none)

  // Bucket rows by their raw x value in first-appearance order so the
  // downstream discrete x scale keeps the input's level ordering.
  // One KDE per bucket; width normalisation needs every bucket's peak, so
  // estimate first and scale in a second pass.
  let estimates = ()
  for rows in bucket-by-col(data, x-col) {
    let pairs = rows
      .map(r => {
        let yv = parse-number(r.at(y-col, default: none))
        if yv == none { return none }
        (x: yv, w: read-weight(r, weight-col))
      })
      .filter(p => p != none and p.w > 0)
    if pairs.len() < 2 { continue }
    let raw-x = rows.first().at(x-col, default: none)
    let parsed-x = parse-number(raw-x)
    let estimate = kde-1d(
      pairs,
      bw: params.at("bw", default: auto),
      adjust: params.at("adjust", default: 1),
      n: params.at("n", default: 512),
      trim: params.at("trim", default: true),
    )
    let peak = calc.max(..estimate.rows.map(r => r.density))
    estimates.push((
      x: if parsed-x != none { parsed-x } else { raw-x },
      rows: estimate.rows,
      peak: if peak > 0 { peak } else { 1 },
      n-obs: pairs.len(),
    ))
  }
  if estimates.len() == 0 { return (data: (), mapping: base-mapping) }

  let width-denominator(est) = if scale-mode == "area" {
    calc.max(..estimates.map(e => e.peak))
  } else if scale-mode == "count" {
    calc.max(..estimates.map(e => e.peak * e.n-obs)) / est.n-obs
  } else { est.peak }

  let out = ()
  for est in estimates {
    let denom = width-denominator(est)
    for r in est.rows {
      // Keep x under its source column name (like stat-boxplot) so a
      // grouping aesthetic mapped to the same column still finds its value.
      let row = (
        y: r.x,
        violinwidth: r.density / denom,
        _density: r.density,
        _count: r.density * est.n-obs,
        _scaled: r.density / est.peak,
        _n: est.n-obs,
      )
      row.insert(x-col, est.x)
      out.push(row)
    }
  }
  let out-mapping = base-mapping
  out-mapping.insert("x", x-col)
  (data: out, mapping: out-mapping)
}
