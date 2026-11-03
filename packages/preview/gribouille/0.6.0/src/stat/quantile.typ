///! Linear quantile regression.
///!
///! For each user-supplied quantile τ, fits the line `y = β₀ + β₁·x` that
///! minimises the asymmetric absolute loss
///! `Σ ρ_τ(yᵢ − β₀ − β₁·xᵢ)` where `ρ_τ(r) = r·(τ − I(r<0))`.
///! With the intercept profiled out, the loss is convex piecewise-linear in
///! the slope with kinks only at pairwise slopes, so the optimum sits
///! exactly on one of them: binary-search the sorted pairwise-slope array,
///! then snap to the exact two-point line through the near-zero-residual
///! points. O(n² log n) — usable to a few thousand rows.

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

// Exact asymmetric absolute loss of the line `y = intercept + slope * x`.
#let _loss-line(pairs, tau, intercept, slope) = {
  let loss = 0.0
  for p in pairs {
    let r = p.y - (intercept + slope * p.x)
    let weight = if r < 0 { tau - 1.0 } else { tau }
    loss = loss + r * weight
  }
  loss
}

// Profile the intercept out at a fixed slope: the minimiser of
// `Σ ρ_τ(zᵢ − a)` over `a` is the type-1 τ-quantile of `zᵢ = yᵢ − b·xᵢ`.
#let _loss-at-slope(pairs, tau, b) = {
  let zs = pairs.map(p => p.y - b * p.x).sorted()
  let n = zs.len()
  let k = calc.clamp(calc.ceil(tau * n), 1, n)
  let a = zs.at(k - 1)
  let loss = 0.0
  for z in zs {
    let r = z - a
    let weight = if r < 0 { tau - 1.0 } else { tau }
    loss = loss + r * weight
  }
  (intercept: a, loss: loss)
}

// Every kink of the profiled loss is a pairwise slope, so the optimum sits
// exactly on one of these candidates. Sorted and deduped; shared across τ.
#let _candidate-slopes(pairs) = {
  let n = pairs.len()
  let slopes = ()
  let i = 0
  while i < n {
    let pi = pairs.at(i)
    let j = i + 1
    while j < n {
      let pj = pairs.at(j)
      let dx = pj.x - pi.x
      if dx != 0 { slopes.push((pj.y - pi.y) / dx) }
      j = j + 1
    }
    i = i + 1
  }
  let sorted = slopes.sorted()
  let out = ()
  for s in sorted {
    if out.len() == 0 or out.last() != s { out.push(s) }
  }
  out
}

// Snap the winning line onto the exact two-point form the loss geometry
// guarantees: an optimal vertex interpolates at least two data points, so
// re-derive candidate lines from the near-zero-residual points with the
// pair arithmetic (`intercept` anchored on the smaller index) and keep the
// strict loss minimiser. Makes unique-optimum fits bit-exact and settles
// flat optima deterministically.
#let _snap(pairs, tau, b, a, base-loss) = {
  let ys = pairs.map(p => p.y)
  let y-lo = calc.min(..ys)
  let y-hi = calc.max(..ys)
  let yscale = calc.max(y-hi - y-lo, calc.abs(y-hi), calc.abs(y-lo))
  let tol = 1e-9 * yscale
  let near = ()
  for (idx, p) in pairs.enumerate() {
    let r = calc.abs(p.y - (a + b * p.x))
    if r <= tol { near.push((idx: idx, r: r)) }
  }
  // Stable sort: exact-zero ties keep original index order.
  let near = near.sorted(key: e => e.r)
  if near.len() > 8 { near = near.slice(0, 8) }
  let idxs = near.map(e => e.idx).sorted()
  let best = (intercept: a, slope: b, loss: base-loss)
  let ci = 0
  while ci < idxs.len() {
    let pi = pairs.at(idxs.at(ci))
    let cj = ci + 1
    while cj < idxs.len() {
      let pj = pairs.at(idxs.at(cj))
      let dx = pj.x - pi.x
      if dx != 0 {
        let slope = (pj.y - pi.y) / dx
        let intercept = pi.y - slope * pi.x
        let loss = _loss-line(pairs, tau, intercept, slope)
        if loss < best.loss {
          best = (intercept: intercept, slope: slope, loss: loss)
        }
      }
      cj = cj + 1
    }
    ci = ci + 1
  }
  best
}

// Binary-search the sorted candidate slopes for the convex loss minimum:
// the predicate `g(s₍ᵢ₊₁₎) ≥ g(s₍ᵢ₎)` flips from false to true exactly once.
// Float loss evaluations can wobble by ulps near the optimum, so the
// neighbours of the landing index are re-checked before snapping.
#let _fit-one-tau(pairs, slopes, tau) = {
  let lo = 0
  let hi = slopes.len() - 1
  while lo < hi {
    let mid = calc.quo(lo + hi, 2)
    let g-mid = _loss-at-slope(pairs, tau, slopes.at(mid))
    let g-next = _loss-at-slope(pairs, tau, slopes.at(mid + 1))
    if g-next.loss < g-mid.loss { lo = mid + 1 } else { hi = mid }
  }
  let best-i = calc.max(0, lo - 1)
  let best = _loss-at-slope(pairs, tau, slopes.at(best-i))
  let i = best-i + 1
  while i <= calc.min(slopes.len() - 1, lo + 1) {
    let g = _loss-at-slope(pairs, tau, slopes.at(i))
    if g.loss < best.loss {
      best = g
      best-i = i
    }
    i = i + 1
  }
  _snap(pairs, tau, slopes.at(best-i), best.intercept, best.loss)
}

// Fit one line per τ over the shared candidate-slope array.
#let _fit-quantiles(pairs, taus) = {
  let slopes = _candidate-slopes(pairs)
  if slopes.len() == 0 {
    let fallback = if pairs.len() > 0 { pairs.first().y } else { 0.0 }
    return taus.map(_ => (intercept: fallback, slope: 0.0, loss: none))
  }
  taus.map(tau => _fit-one-tau(pairs, slopes, tau))
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
