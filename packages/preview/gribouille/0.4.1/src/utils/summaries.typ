///! Summary helpers: `mean-*` and `median-hilow` family.
///!
///! Each helper accepts an array of numbers and returns a dict
///! `(y: <central>, ymin: <low>, ymax: <high>)`. Empty or all-`none` inputs
///! collapse to `(y: none, ymin: none, ymax: none)` so the caller can decide
///! how to handle missing buckets.

#import "types.typ": parse-number
#import "normal.typ": qnorm
#import "errors.typ": fail, fail-range, fail-type

#let _to-numeric(values) = {
  values.map(v => parse-number(v)).filter(v => v != none)
}

// Read a weight value from a row, coercing strings via `float`. Treats a
// `none` weight column as unit weight; treats a missing/`none` cell as
// zero so the row is filtered out by the weighted helpers' `w > 0` test.
#let read-weight(row, weight-col) = {
  if weight-col == none { return 1 }
  let raw = row.at(weight-col, default: none)
  if raw == none { return 0 }
  if type(raw) == str { return float(raw) }
  raw
}

// Pair each value with its weight, drop non-numeric values, and treat
// missing weights as 1. Returns `(xs, ws)` arrays with matching lengths;
// when `weights` is `none`, every entry weights as 1.
#let _to-weighted(values, weights) = {
  let n = values.len()
  let xs = ()
  let ws = ()
  for i in range(n) {
    let v = parse-number(values.at(i))
    if v == none { continue }
    let w = if weights == none { 1 } else {
      let raw = weights.at(i, default: none)
      if raw == none {
        0
      } else if type(raw) == str { float(raw) } else { raw }
    }
    if w <= 0 { continue }
    xs.push(v)
    ws.push(w)
  }
  (xs: xs, ws: ws)
}

#let _empty-summary = (y: none, ymin: none, ymax: none)

#let _sum(xs) = {
  let acc = 0.0
  for v in xs { acc = acc + v }
  acc
}

#let _mean(xs) = _sum(xs) / xs.len()

// Weighted mean with non-negative weights. Returns `none` when the total
// weight is zero so the caller can treat the bucket as empty (matching the
// `_empty-summary` shape). The companion `_wsd` returns `0.0` for the
// degenerate cases instead, mirroring `_sd`'s contract for unit weights.
#let _wmean(xs, ws) = {
  let total = _sum(ws)
  if total == 0 { return none }
  let acc = 0.0
  for i in range(xs.len()) { acc += ws.at(i) * xs.at(i) }
  acc / total
}

// Weighted sample standard deviation with frequency-weight semantics
// (divisor `(n-1) / n * Σw`). Mirrors `_sd` for unit weights.
#let _wsd(xs, ws) = {
  let n = xs.len()
  if n < 2 { return 0.0 }
  let total = _sum(ws)
  if total == 0 { return 0.0 }
  let m = _wmean(xs, ws)
  if m == none { return 0.0 }
  let ss = 0.0
  for i in range(n) {
    let d = xs.at(i) - m
    ss += ws.at(i) * d * d
  }
  // Frequency-weight Bessel correction: divisor = total * (n - 1) / n.
  calc.sqrt(ss / (total * (n - 1) / n))
}

// Sample standard deviation (Bessel's correction, divisor n - 1). Returns
// 0 when the sample has a single observation.
#let _sd(xs) = {
  let n = xs.len()
  if n < 2 { return 0.0 }
  let m = _mean(xs)
  let ss = _sum(xs.map(v => (v - m) * (v - m)))
  calc.sqrt(ss / (n - 1))
}

// Linear-interpolation quantile (R type 7, numpy default) on a sorted
// array. Single shared implementation; also imported by the boxplot and
// Q-Q line statistics.
#let quantile-type-7(sorted, q) = {
  let n = sorted.len()
  if n == 0 { return none }
  if n == 1 { return sorted.at(0) }
  let pos = q * (n - 1)
  let lo = int(calc.floor(pos))
  let hi = int(calc.ceil(pos))
  if lo == hi { return sorted.at(lo) }
  let frac = pos - lo
  sorted.at(lo) * (1 - frac) + sorted.at(hi) * frac
}

/// Mean as a degenerate summary `(y, ymin: y, ymax: y)`.
///
/// Useful as a callable building block when only a central value is needed, or as `fun: "mean"` to draw a plain point summary with no band.
///
/// - values: Array of numbers; non-numeric entries are dropped.
/// - weights: Optional array of non-negative weights (`none` for unit weights). Pairs are dropped when the weight is `none`, zero, or negative.
///
/// Returns: Dict `(y, ymin, ymax)` with `ymin == ymax == y`; all-`none` if `values` has no numerics.
///
/// Plain mean of a small sample.
///
/// ```typst
/// #let s = mean((2, 3, 4, 5, 6))
/// // s.y == 4, s.ymin == 4, s.ymax == 4
/// ```
#let mean(values, weights: none) = {
  if weights != none {
    let p = _to-weighted(values, weights)
    if p.xs.len() == 0 { return _empty-summary }
    let m = _wmean(p.xs, p.ws)
    if m == none { return _empty-summary }
    return (y: m, ymin: m, ymax: m)
  }
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let m = _mean(xs)
  (y: m, ymin: m, ymax: m)
}

/// Median as a degenerate summary `(y, ymin: y, ymax: y)`.
///
/// Uses the same type-7 linear-interpolation rule as `quantile-type-7`, kept consistent with `src/stat/boxplot.typ` and `median-hilow`.
///
/// - values: Array of numbers; non-numeric entries are dropped.
///
/// Returns: Dict `(y, ymin, ymax)` with `ymin == ymax == y`; all-`none` if `values` has no numerics.
///
/// Median of a small sample.
///
/// ```typst
/// #let s = median((1, 2, 3, 4))
/// // s.y == 2.5
/// ```
#let median(values) = {
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let m = quantile-type-7(xs.sorted(), 0.5)
  (y: m, ymin: m, ymax: m)
}

/// Single quantile as a degenerate summary `(y, ymin: y, ymax: y)`.
///
/// Quantiles use the type-7 / numpy default linear interpolation rule, the same convention as `median-hilow` and `src/stat/boxplot.typ`.
///
/// - values: Array of numbers; non-numeric entries are dropped.
/// - q: Probability in the closed interval `[0, 1]`.
///
/// Returns: Dict `(y, ymin, ymax)` with `ymin == ymax == y`; all-`none` if `values` has no numerics.
///
/// Lower quartile.
///
/// ```typst
/// #let s = quantile((1, 2, 3, 4), q: 0.25)
/// ```
#let quantile(values, q: 0.5) = {
  if q < 0 or q > 1 {
    fail-range("quantile", "q", q, 0, 1, lo-open: false, hi-open: false)
  }
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let v = quantile-type-7(xs.sorted(), q)
  (y: v, ymin: v, ymax: v)
}

/// Three quantiles packed into the standard summary shape.
///
/// Returns `(y: <mid>, ymin: <lo>, ymax: <hi>)` where each component is the type-7 quantile at the matching probability in `probs`. Probabilities are not reordered: pass them in `(low, central, high)` order.
///
/// - values: Array of numbers; non-numeric entries are dropped.
/// - probs: Three probabilities in `[0, 1]`, ordered low-mid-high.
///
/// Returns: Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// Median plus the IQR via explicit probabilities.
///
/// ```typst
/// #let s = quantiles(range(1, 10), probs: (0.25, 0.5, 0.75))
/// ```
#let quantiles(values, probs: (0.25, 0.5, 0.75)) = {
  if type(probs) != array or probs.len() != 3 {
    fail-type("quantiles", "probs", probs, "an array of three probabilities")
  }
  for p in probs {
    if p < 0 or p > 1 {
      fail-range(
        "quantiles",
        "every prob",
        p,
        0,
        1,
        lo-open: false,
        hi-open: false,
      )
    }
  }
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let sorted = xs.sorted()
  (
    y: quantile-type-7(sorted, probs.at(1)),
    ymin: quantile-type-7(sorted, probs.at(0)),
    ymax: quantile-type-7(sorted, probs.at(2)),
  )
}

/// Mean and standard-error band: `mean ± multiplier * se`.
///
/// `se = sd / sqrt(n)` using the sample standard deviation. Returns `(y: <mean>, ymin: <mean - multiplier * se>, ymax: <mean + multiplier * se>)`.
///
/// - values: Array of numbers; non-numeric entries are dropped.
/// - multiplier: Multiplier on the standard error.
/// - weights: Optional array of non-negative weights (`none` for unit weights). Frequency-weight semantics; total weight stands in for `n` in the standard-error denominator.
///
/// Returns: Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// One-σ band around the sample mean.
///
/// ```typst
/// #let s = mean-se((2, 3, 4, 5, 6))
/// // s.y == 4, s.ymin ≈ 3.29, s.ymax ≈ 4.71
/// ```
///
/// Bump `multiplier` to 2 for an approximate 95% interval (assuming a roughly normal sampling distribution).
///
/// ```typst
/// #let s = mean-se((2, 3, 4, 5, 6), multiplier: 2)
/// ```
#let mean-se(values, multiplier: 1, weights: none) = {
  if weights != none {
    let p = _to-weighted(values, weights)
    let n = p.xs.len()
    if n == 0 { return _empty-summary }
    let m = _wmean(p.xs, p.ws)
    if m == none { return _empty-summary }
    let total = _sum(p.ws)
    let se = if n < 2 or total == 0 {
      0.0
    } else { _wsd(p.xs, p.ws) / calc.sqrt(total) }
    return (y: m, ymin: m - multiplier * se, ymax: m + multiplier * se)
  }
  let xs = _to-numeric(values)
  let n = xs.len()
  if n == 0 { return _empty-summary }
  let m = _mean(xs)
  let se = if n < 2 { 0.0 } else { _sd(xs) / calc.sqrt(n) }
  (y: m, ymin: m - multiplier * se, ymax: m + multiplier * se)
}

/// Mean with normal-approximation confidence interval.
///
/// The two-sided z critical value `qnorm((1 + conf) / 2)` is computed from Acklam's inverse-normal approximation, so any `conf` in the open interval `(0, 1)` is supported.
///
/// - values: Array of numbers; non-numeric entries are dropped.
/// - conf: Confidence level in the open interval `(0, 1)`.
/// - weights: Optional array of non-negative weights (`none` for unit weights). Frequency-weight semantics; total weight stands in for `n` in the standard-error denominator.
///
/// Returns: Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// Standard 95% normal-approximation interval.
///
/// ```typst
/// #let s = mean-cl-normal((2, 3, 4, 5, 6))
/// ```
///
/// Tighten to a 50% interval to highlight the central location.
///
/// ```typst
/// #let s = mean-cl-normal((2, 3, 4, 5, 6), conf: 0.5)
/// ```
#let mean-cl-normal(values, conf: 0.95, weights: none) = {
  if conf <= 0 or conf >= 1 {
    fail-range("mean-cl-normal", "conf", conf, 0, 1)
  }
  let z = qnorm((1 + conf) / 2)
  if weights != none {
    let p = _to-weighted(values, weights)
    let n = p.xs.len()
    if n == 0 { return _empty-summary }
    let m = _wmean(p.xs, p.ws)
    if m == none { return _empty-summary }
    let total = _sum(p.ws)
    let se = if n < 2 or total == 0 {
      0.0
    } else { _wsd(p.xs, p.ws) / calc.sqrt(total) }
    return (y: m, ymin: m - z * se, ymax: m + z * se)
  }
  let xs = _to-numeric(values)
  let n = xs.len()
  if n == 0 { return _empty-summary }
  let m = _mean(xs)
  let se = if n < 2 { 0.0 } else { _sd(xs) / calc.sqrt(n) }
  (y: m, ymin: m - z * se, ymax: m + z * se)
}

/// Mean and standard-deviation band: `mean ± multiplier * sd`.
///
/// - values: Array of numbers; non-numeric entries are dropped.
/// - multiplier: Multiplier on the sample standard deviation.
/// - weights: Optional array of non-negative weights (`none` for unit weights). Frequency-weight semantics for the weighted standard deviation.
///
/// Returns: Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// Default ±1 σ band.
///
/// ```typst
/// #let s = mean-sd((2, 3, 4, 5, 6))
/// ```
///
/// Widen to ±2 σ for a two-deviation spread.
///
/// ```typst
/// #let s = mean-sd((2, 3, 4, 5, 6), multiplier: 2)
/// ```
#let mean-sd(values, multiplier: 1, weights: none) = {
  if weights != none {
    let p = _to-weighted(values, weights)
    if p.xs.len() == 0 { return _empty-summary }
    let m = _wmean(p.xs, p.ws)
    if m == none { return _empty-summary }
    let s = _wsd(p.xs, p.ws)
    return (y: m, ymin: m - multiplier * s, ymax: m + multiplier * s)
  }
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let m = _mean(xs)
  let s = _sd(xs)
  (y: m, ymin: m - multiplier * s, ymax: m + multiplier * s)
}

/// Median plus a central interval covering `conf` proportion of the data.
///
/// Quantiles use the type-7 / numpy default linear interpolation rule, the same convention as `src/stat/boxplot.typ`. The default `conf: 0.5` returns the median with the IQR (25th to 75th percentile).
///
/// - values: Array of numbers; non-numeric entries are dropped.
/// - conf: Proportion of the data covered by the interval, in `(0, 1)`.
///
/// Returns: Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// Default 50% interval returns the median plus the IQR.
///
/// ```typst
/// #let s = median-hilow((1, 2, 3, 4, 5, 6, 7, 8))
/// ```
///
/// A 90% interval covers the bulk of the data while still trimming the tails.
///
/// ```typst
/// #let s = median-hilow((1, 2, 3, 4, 5, 6, 7, 8, 9, 10), conf: 0.9)
/// ```
#let median-hilow(values, conf: 0.5) = {
  if conf <= 0 or conf >= 1 {
    fail-range("median-hilow", "conf", conf, 0, 1)
  }
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let sorted = xs.sorted()
  let tail = (1 - conf) / 2
  (
    y: quantile-type-7(sorted, 0.5),
    ymin: quantile-type-7(sorted, tail),
    ymax: quantile-type-7(sorted, 1 - tail),
  )
}

// Deterministic pseudo-random in [0, 1) seeded by an integer index. Uses the
// same sin-fract noise trick as `position-jitter` so bootstrap resamples are
// reproducible across renders without any RNG state.
#let _rand01(seed) = {
  let v = calc.sin(seed * 12.9898 + 78.233) * 43758.5453
  v - calc.floor(v)
}

/// Mean with a bootstrap percentile confidence interval.
///
/// Resamples `values` with replacement `n-boot` times, computes the bootstrap mean for each resample, and returns the requested central percentiles of the bootstrap distribution. The resampling indices are drawn from a deterministic noise sequence seeded by `seed`, so identical inputs always produce identical bounds.
///
/// - values: Array of numbers; non-numeric entries are dropped.
/// - conf: Confidence level in the open interval `(0, 1)`.
/// - n-boot: Number of bootstrap resamples.
/// - seed: Integer seed for the deterministic resampling sequence.
///
/// Returns: Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// Default 95% bootstrap interval with 1000 resamples.
///
/// ```typst
/// #let s = mean-cl-boot((2, 3, 4, 5, 6, 7))
/// ```
///
/// Bump `n-boot` for a smoother bound and pin `seed` to keep results reproducible across renders.
///
/// ```typst
/// #let s = mean-cl-boot((2, 3, 4, 5, 6, 7), n-boot: 5000, seed: 42)
/// ```
#let mean-cl-boot(values, conf: 0.95, n-boot: 1000, seed: 0) = {
  if conf <= 0 or conf >= 1 {
    fail-range("mean-cl-boot", "conf", conf, 0, 1)
  }
  let xs = _to-numeric(values)
  let n = xs.len()
  if n == 0 { return _empty-summary }
  let m = _mean(xs)
  if n < 2 { return (y: m, ymin: m, ymax: m) }
  let nb = calc.max(1, int(n-boot))
  let means = ()
  for b in range(0, nb) {
    let acc = 0.0
    for j in range(0, n) {
      let r = _rand01(seed + b * 100003 + j * 1009)
      let raw = int(calc.floor(r * n))
      let idx = if raw >= n { n - 1 } else if raw < 0 { 0 } else { raw }
      acc = acc + xs.at(idx)
    }
    means.push(acc / n)
  }
  let sorted = means.sorted()
  let tail = (1 - conf) / 2
  (
    y: m,
    ymin: quantile-type-7(sorted, tail),
    ymax: quantile-type-7(sorted, 1 - tail),
  )
}

/// Look up a summary helper by name, or invoke a user-supplied callable.
///
/// String names use the kebab form (`"mean-se"`, `"mean-cl-normal"`, `"mean-cl-boot"`, `"mean-sd"`, `"median-hilow"`, `"mean"`, `"median"`, `"quantile"`, `"quantiles"`). When `name` is a function, it is called as `name(values, ..fun-args)` and must return a dict `(y, ymin, ymax)`; custom callables can take a sink (`..args`) to ignore extras. Unknown string names panic.
///
/// - name: Summary helper name, or a callable returning `(y, ymin, ymax)`.
/// - values: Array of numbers; non-numeric entries are dropped.
/// - fun-args: Keyword arguments forwarded to the helper or callable.
/// - weights: Optional array of non-negative weights aligned with `values` (`none` for unit weights). Forwarded to helpers that honour weights (`mean`, `mean-se`, `mean-sd`, `mean-cl-normal`); helpers without a weighted formulation ignore the parameter.
///
/// Returns: Dict `(y, ymin, ymax)`.
///
/// Dispatch by name; equivalent to calling `mean-se` directly.
///
/// ```typst
/// #let s = summarise("mean-se", (2, 3, 4, 5, 6))
/// ```
///
/// Pass keyword arguments via `fun-args` to forward helper-specific parameters.
///
/// ```typst
/// #let s = summarise(
///   "median-hilow",
///   (1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
///   fun-args: (conf: 0.9),
/// )
/// ```
///
/// Pass a callable to compute an arbitrary summary.
///
/// ```typst
/// #let s = summarise(
///   (xs, ..args) => (y: xs.sum() / xs.len(), ymin: xs.first(), ymax: xs.last()),
///   (1, 2, 3, 4, 5),
/// )
/// ```
#let summarise(name, values, fun-args: (:), weights: none) = {
  if type(name) == function {
    if weights == none { return name(values, ..fun-args) }
    return name(values, weights: weights, ..fun-args)
  }
  if name == "mean-se" {
    let multiplier = fun-args.at("multiplier", default: 1)
    return mean-se(values, multiplier: multiplier, weights: weights)
  } else if name == "mean-cl-normal" {
    let conf = fun-args.at("conf", default: 0.95)
    return mean-cl-normal(values, conf: conf, weights: weights)
  } else if name == "mean-cl-boot" {
    let conf = fun-args.at("conf", default: 0.95)
    let n-boot = fun-args.at("n-boot", default: 1000)
    let seed = fun-args.at("seed", default: 0)
    return mean-cl-boot(values, conf: conf, n-boot: n-boot, seed: seed)
  } else if name == "mean-sd" {
    let multiplier = fun-args.at("multiplier", default: 1)
    return mean-sd(values, multiplier: multiplier, weights: weights)
  } else if name == "median-hilow" {
    let conf = fun-args.at("conf", default: 0.5)
    return median-hilow(values, conf: conf)
  } else if name == "mean" {
    return mean(values, weights: weights)
  } else if name == "median" {
    return median(values)
  } else if name == "quantile" {
    let q = fun-args.at("q", default: 0.5)
    return quantile(values, q: q)
  } else if name == "quantiles" {
    let probs = fun-args.at("probs", default: (0.25, 0.5, 0.75))
    return quantiles(values, probs: probs)
  }
  fail(
    "summarise",
    "unknown summary function "
      + repr(name)
      + "; expected a callable or one of mean-se, mean-cl-normal, "
      + "mean-cl-boot, mean-sd, median-hilow, mean, median, quantile, "
      + "quantiles",
  )
}

#let _scalar-reducers = (
  mean: values => mean(values).y,
  median: values => median(values).y,
  sum: values => {
    let xs = _to-numeric(values)
    if xs.len() == 0 { none } else { xs.sum() }
  },
  min: values => {
    let xs = _to-numeric(values)
    if xs.len() == 0 { none } else { calc.min(..xs) }
  },
  max: values => {
    let xs = _to-numeric(values)
    if xs.len() == 0 { none } else { calc.max(..xs) }
  },
)

/// Apply a reduction by keyword (`"mean"`, `"median"`, `"sum"`, `"min"`, `"max"`) or a callable `values => scalar`. Used by 2D summary stats.
///
/// Distinct from `summarise`, which returns a `(y, ymin, ymax)` triple for 1D bands.
///
/// - name: Reduction keyword or callable `values => scalar`.
/// - values: Sequence of input values to reduce.
#let reduce-scalar(name, values) = {
  if type(name) == function { return name(values) }
  let fn = _scalar-reducers.at(name, default: none)
  if fn == none {
    fail("reduce-scalar", "unknown reduction " + repr(name))
  }
  fn(values)
}
