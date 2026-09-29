///! Linear quantile regression.
///!
///! For each user-supplied quantile τ, fits the line `y = β₀ + β₁·x` that
///! minimises the asymmetric absolute loss
///! `Σ ρ_τ(yᵢ − β₀ − β₁·xᵢ)` where `ρ_τ(r) = r·(τ − I(r<0))`.
///! The optimum line passes through two data points; the algorithm enumerates
///! every pair (xᵢ, xⱼ) with xᵢ ≠ xⱼ, evaluates the loss, and keeps the
///! minimiser. O(n³) — workable for plot-sized inputs (n up to a few hundred).

#import "../utils/types.typ": parse-number

/// Quantile regression statistic: fit one line per τ and sample it.
///
/// Returns one row per `(τ, sample)` with columns `x`, `y`, `group` (a per-τ key for grouping in line geoms), and `_quantile` (the τ value).
///
/// - quantiles: Array of τ values in `(0, 1)` to fit, e.g., `(0.25, 0.5, 0.75)`.
/// - n-samples: Number of evenly-spaced x positions sampled per fitted line.
///
/// Returns: Statistic object with `name: "quantile"`, consumed by `geom-quantile`.
///
/// See also: `geom-quantile`, `geom-smooth`.
///
/// Fit the 0.25, 0.5, 0.75 quantile lines through a noisy linear cloud via `geom-line(stat: stat-quantile(...))`; the stat's `group` column auto-splits the lines.
///
/// ```typst
/// #let n = 70
/// #let d = range(0, n).map(i => {
///   let x = i / n * 10
///   let noise = calc.sin(i * 0.7) + calc.cos(i * 1.9)
///   (x: x, y: 1.2 * x + noise)
/// })
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 1.5pt, alpha: 0.6),
///     geom-line(stat: stat-quantile(quantiles: (0.25, 0.5, 0.75)), stroke: 1pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-quantile(quantiles: (0.25, 0.5, 0.75), n-samples: 64) = (
  kind: "stat",
  name: "quantile",
  params: (quantiles: quantiles, n-samples: n-samples),
)

// Fit one line per τ in a single pair-enumeration sweep. Residuals are
// computed once per candidate line and reused across all τ values, avoiding
// the K-times redundant scan of an outer-τ loop.
#let _fit-quantiles(pairs, taus) = {
  let n = pairs.len()
  let fallback = if n > 0 { pairs.first().y } else { 0.0 }
  let best = taus.map(_ => (intercept: fallback, slope: 0.0, loss: none))
  let k-count = taus.len()
  let i = 0
  while i < n {
    let pi = pairs.at(i)
    let pi-x = pi.x
    let pi-y = pi.y
    let j = i + 1
    while j < n {
      let pj = pairs.at(j)
      let dx = pj.x - pi-x
      if dx != 0 {
        let slope = (pj.y - pi-y) / dx
        let intercept = pi-y - slope * pi-x
        let losses = taus.map(_ => 0.0)
        for p in pairs {
          let r = p.y - (intercept + slope * p.x)
          let neg = r < 0
          let k = 0
          while k < k-count {
            let tau = taus.at(k)
            let weight = if neg { tau - 1.0 } else { tau }
            losses.at(k) = losses.at(k) + r * weight
            k = k + 1
          }
        }
        let k = 0
        while k < k-count {
          let cur = best.at(k)
          let lk = losses.at(k)
          if cur.loss == none or lk < cur.loss {
            best.at(k) = (intercept: intercept, slope: slope, loss: lk)
          }
          k = k + 1
        }
      }
      j = j + 1
    }
    i = i + 1
  }
  best
}

#let apply(data, mapping, params: (:)) = {
  let out-mapping = (x: "x", y: "y", group: "group")
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  let y-col = if mapping != none { mapping.at("y", default: none) } else {
    none
  }
  if x-col == none or y-col == none {
    return (data: (), mapping: out-mapping)
  }
  let pairs = data
    .map(r => {
      let x = parse-number(r.at(x-col, default: none))
      let y = parse-number(r.at(y-col, default: none))
      if x == none or y == none { return none }
      (x: x, y: y)
    })
    .filter(p => p != none)
  if pairs.len() < 2 { return (data: (), mapping: out-mapping) }
  let xs = pairs.map(p => p.x)
  let lo = calc.min(..xs)
  let hi = calc.max(..xs)
  if hi == lo { return (data: (), mapping: out-mapping) }
  let n-samples = params.at("n-samples", default: 64)
  let quantiles = params.at("quantiles", default: (0.25, 0.5, 0.75))
  let fits = _fit-quantiles(pairs, quantiles)
  let rows = ()
  for k in range(quantiles.len()) {
    let tau = quantiles.at(k)
    let fit = fits.at(k)
    let group-key = "q" + str(tau)
    for s in range(n-samples + 1) {
      let t = s / n-samples
      let x = lo + t * (hi - lo)
      rows.push((
        x: x,
        y: fit.intercept + fit.slope * x,
        group: group-key,
        _quantile: tau,
      ))
    }
  }
  (data: rows, mapping: out-mapping)
}
