// Shared uniform-width binning helpers used by stat-bin and stat-bindot.
// Computes the canonical `(lo, hi, n-bins, width)` partition from a numeric
// vector and a `bins`/`binwidth` parameter pair, plus the per-value bin index.

#import "types.typ": parse-number
#import "summaries.typ": read-weight
#import "errors.typ": fail-type

// Split a scalar-or-`(x, y)` parameter (e.g., `bins`, `binwidth`) into a
// per-axis pair, applying `fallback` to a `none` value.
#let split-pair(value, fallback: none) = {
  if value == none { return (fallback, fallback) }
  if type(value) == array { return (value.at(0), value.at(1)) }
  (value, value)
}

// Compute `(lo, hi)` from a non-empty numeric vector. Spreads to `(lo, lo+1)`
// when all values are equal, so downstream computations don't divide by zero.
#let bin-domain(xs) = {
  let lo = calc.min(..xs)
  let hi = calc.max(..xs)
  if hi == lo { hi = lo + 1.0 }
  (lo, hi)
}

// Panic unless `bins` and `binwidth` can bin an axis. `binwidth` wins when it
// is set, so `bins` is checked only when it will be used. With `pair`, either
// argument may also be an `(x, y)` pair, and a pair is checked per axis. `scope`
// names the public function that the user called.
#let check-bin-params(scope, bins, binwidth, pair: false) = {
  let valid-bins(v) = type(v) == int and v >= 1
  let valid-width(v) = type(v) in (int, float) and v > 0
  let valid(v, ok) = if pair and type(v) == array {
    v.len() == 2 and v.all(ok)
  } else { ok(v) }
  if binwidth != none {
    if not valid(binwidth, valid-width) {
      fail-type(
        scope,
        "binwidth",
        binwidth,
        if pair { "a positive number or an `(x, y)` pair of them" } else {
          "a positive number"
        },
        hint: "Use `none` to set the number of bins instead.",
      )
    }
  } else if not valid(bins, valid-bins) {
    fail-type(
      scope,
      "bins",
      bins,
      if pair { "a positive integer or an `(x, y)` pair of them" } else {
        "a positive integer"
      },
    )
  }
}

// Resolve `(n-bins, width)` from a domain and a `bins`/`binwidth` pair.
// `binwidth` wins when both are supplied; otherwise the domain is split into
// `bins` equal-width buckets. The constructors of the binning stats run
// `check-bin-params`, so both arguments are valid here.
#let bin-config(lo, hi, bins, binwidth) = {
  let n-bins = if binwidth != none {
    calc.max(1, int(calc.ceil((hi - lo) / binwidth)))
  } else { bins }
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
// derives a per-group grid from the values `get-xs` returns.
//
// The values arrive through a thunk rather than as an array because the
// stashed grid is the normal case, and a caller that materialises its values
// first pays a full pass per group for a resolver that never reads them. A
// captured array is reference-counted, so wrapping it in a thunk copies no
// data.
#let resolve-bin-grid(params, get-xs) = {
  let grid = params.at("grid", default: none)
  if grid != none { return grid }
  let (lo, hi) = bin-domain((get-xs)())
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
  // The thunk must stay unevaluated here: a stashed panel grid answers
  // without it, and building the array first restores the per-group pass.
  let grid = resolve-bin-grid(params, () => entries.map(e => e.x))
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
      // Appended in place: reading the bucket out and writing it back shares
      // the arrays, so each push would copy the whole bin.
      buckets.at(idx).ys.push(e.y)
      buckets.at(idx).ws.push(e.w)
    }
  }
  (grid: grid, counts: counts, buckets: buckets, total: total)
}

// Half the widest bin in the rows of stat-bin or stat-bindot, read from the
// `width` column that both publish. Callers pass only rows from those stats,
// so a data column of the same name never reaches here.
#let bin-half-width(rows) = {
  let half = 0.0
  for row in rows {
    let w = row.at("width", default: none)
    if type(w) == int or type(w) == float { half = calc.max(half, w / 2) }
  }
  half
}

// The `x` range of binned rows, widened by half a bin on each side so the
// outer bins stay inside the panel. `none` when the rows have no bin width or
// no numeric `x`.
#let bin-x-extents(rows, x-col) = {
  let half = bin-half-width(rows)
  if half <= 0 or x-col == none { return none }
  let xs = rows
    .map(r => parse-number(r.at(x-col, default: none)))
    .filter(v => v != none)
  if xs.len() == 0 { return none }
  (calc.min(..xs) - half, calc.max(..xs) + half)
}
