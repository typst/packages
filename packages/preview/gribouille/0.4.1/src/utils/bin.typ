// Shared uniform-width binning helpers used by stat-bin and stat-bindot.
// Computes the canonical `(lo, hi, n-bins, width)` partition from a numeric
// vector and a `bins`/`binwidth` parameter pair, plus the per-value bin index.

#import "types.typ": parse-number
#import "summaries.typ": read-weight
#import "errors.typ": check

// Compute `(lo, hi)` from a non-empty numeric vector. Spreads to `(lo, lo+1)`
// when all values are equal, so downstream computations don't divide by zero.
#let bin-domain(xs) = {
  let lo = calc.min(..xs)
  let hi = calc.max(..xs)
  if hi == lo { hi = lo + 1.0 }
  (lo, hi)
}

// Resolve `(n-bins, width)` from a domain and a `bins`/`binwidth` pair.
// `binwidth` wins when both are supplied; otherwise the domain is split into
// `bins` equal-width buckets.
#let bin-config(lo, hi, bins, binwidth) = {
  let n-bins = if binwidth != none and binwidth > 0 {
    calc.max(1, int(calc.ceil((hi - lo) / binwidth)))
  } else {
    check(
      bins != none and bins > 0,
      "bin-config",
      "bins must be a positive integer; got " + repr(bins),
    )
    bins
  }
  (n-bins: n-bins, width: (hi - lo) / n-bins)
}

// Assign `x` to the bin index containing it, clamped to `[0, n-bins - 1]`.
#let bin-of(x, lo, width, n-bins) = {
  let raw = int(calc.floor((x - lo) / width))
  calc.max(0, calc.min(n-bins - 1, raw))
}

// Midpoint of bin `i` over the partition starting at `lo` with bucket `width`.
#let bin-midpoint(lo, width, i) = lo + (i + 0.5) * width

// Compute a panel-wide bin grid `(lo, n-bins, width)` from the full layer data
// and stash it under `params.grid`, so per-group `apply()` calls share the
// same partition. Without this, two groups with different x-ranges end up on
// different bin midpoints and stacked positions cannot align.
//
// `grid` is a reserved internal protocol key on the binning stats' params
// dict; user-supplied stat params should not collide with it.
// Returns `params` unchanged when no x column is mapped or the data has no
// parseable x values.
#let panel-bin-grid(data, mapping, params) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  if x-col == none { return params }
  let xs = data
    .map(r => parse-number(r.at(x-col, default: none)))
    .filter(v => v != none)
  if xs.len() == 0 { return params }
  let (lo, hi) = bin-domain(xs)
  let (n-bins, width) = bin-config(
    lo,
    hi,
    params.at("bins", default: 30),
    params.at("binwidth", default: none),
  )
  let out = params
  out.insert("grid", (lo: lo, n-bins: n-bins, width: width))
  out
}

// Resolve the bin grid for a per-group `apply()`. Prefers a panel-level grid
// stashed in `params.grid` (set by `panel-bin-grid` during setup); otherwise
// derives a per-group grid from `xs`.
#let resolve-bin-grid(xs, params) = {
  let grid = params.at("grid", default: none)
  if grid != none { return grid }
  let (lo, hi) = bin-domain(xs)
  let (n-bins, width) = bin-config(
    lo,
    hi,
    params.at("bins", default: 30),
    params.at("binwidth", default: none),
  )
  (lo: lo, n-bins: n-bins, width: width)
}

// Aggregate `data` rows into a 1-D bin grid keyed on `x-col`.
//
// Returns `(grid, counts, buckets, total)` where:
//   `grid`    : `(lo, n-bins, width)` partition (panel-shared via `params.grid`).
//   `counts`  : array of `n-bins` weighted counts (`w` summed per bin).
//   `buckets` : array of `n-bins` records `(ys, ws)` carrying y-values and
//               weights for stats that summarise per bin (e.g., `summary-bin`).
//               Empty when `y-col` is `none`.
//   `total`   : sum of `counts`. Useful for density normalisation.
//
// Returns `none` when `x-col` is unmapped or no rows parse.
#let bin-1d-cells(data, x-col, weight-col, params, y-col: none) = {
  if x-col == none { return none }
  let collect-y = y-col != none
  let entries = ()
  for r in data {
    let xv = parse-number(r.at(x-col, default: none))
    if xv == none { continue }
    let entry = (x: xv, w: read-weight(r, weight-col))
    if collect-y { entry.y = r.at(y-col, default: none) }
    entries.push(entry)
  }
  if entries.len() == 0 { return none }
  let grid = resolve-bin-grid(entries.map(e => e.x), params)
  let counts = range(grid.n-bins).map(_ => 0)
  let buckets = if collect-y {
    range(grid.n-bins).map(_ => (ys: (), ws: ()))
  } else { () }
  let total = 0
  for e in entries {
    let idx = bin-of(e.x, grid.lo, grid.width, grid.n-bins)
    counts.at(idx) = counts.at(idx) + e.w
    total = total + e.w
    if collect-y {
      let bucket = buckets.at(idx)
      bucket.ys.push(e.y)
      bucket.ws.push(e.w)
      buckets.at(idx) = bucket
    }
  }
  (grid: grid, counts: counts, buckets: buckets, total: total)
}
