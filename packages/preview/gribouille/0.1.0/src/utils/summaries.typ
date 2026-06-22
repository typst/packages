///! Summary helpers: `mean-*` and `median-hilow` family.
///!
///! Each helper accepts an array of numbers and returns a dict
///! `(y: <central>, ymin: <low>, ymax: <high>)`. Empty or all-`none` inputs
///! collapse to `(y: none, ymin: none, ymax: none)` so the caller can decide
///! how to handle missing buckets.

#import "types.typ": parse-number
#import "normal.typ": qnorm

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

// Linear-interpolation quantile (R type 7) on a sorted array. Mirrors the
// helper used in `src/stat/boxplot.typ` so summaries here stay consistent
// with the boxplot statistic.
#let _quantile(sorted, q) = {
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
/// Useful as a callable building block when only a central value is needed,
/// or as `fun: "mean"` to draw a plain point summary with no band.
///
/// \@category Helpers
/// \@subcategory Summary functions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric entries are dropped.
///
/// \@param weights Optional array of non-negative weights (`none` for unit weights). Pairs are dropped when the weight is `none`, zero, or negative.
///
/// \@returns Dict `(y, ymin, ymax)` with `ymin == ymax == y`; all-`none` if
///   `values` has no numerics.
///
/// \@examples-static Plain mean of a small sample.
/// ```
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
/// Uses the same type-7 linear-interpolation rule as `_quantile`, kept
/// consistent with `src/stat/boxplot.typ` and `median-hilow`.
///
/// \@category Helpers
/// \@subcategory Summary functions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric entries are dropped.
///
/// \@returns Dict `(y, ymin, ymax)` with `ymin == ymax == y`; all-`none` if
///   `values` has no numerics.
///
/// \@examples-static Median of a small sample.
/// ```
/// #let s = median((1, 2, 3, 4))
/// // s.y == 2.5
/// ```
#let median(values) = {
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let m = _quantile(xs.sorted(), 0.5)
  (y: m, ymin: m, ymax: m)
}

/// Single quantile as a degenerate summary `(y, ymin: y, ymax: y)`.
///
/// Quantiles use the type-7 / numpy default linear interpolation rule, the
/// same convention as `median-hilow` and `src/stat/boxplot.typ`.
///
/// \@category Helpers
/// \@subcategory Summary functions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric entries are dropped.
///
/// \@param q Probability in the closed interval `[0, 1]`.
///
/// \@returns Dict `(y, ymin, ymax)` with `ymin == ymax == y`; all-`none` if
///   `values` has no numerics.
///
/// \@examples-static Lower quartile.
/// ```
/// #let s = quantile((1, 2, 3, 4), q: 0.25)
/// ```
#let quantile(values, q: 0.5) = {
  if q < 0 or q > 1 {
    panic("quantile: q must be in [0, 1]; got " + repr(q))
  }
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let v = _quantile(xs.sorted(), q)
  (y: v, ymin: v, ymax: v)
}

/// Three quantiles packed into the standard summary shape.
///
/// Returns `(y: <mid>, ymin: <lo>, ymax: <hi>)` where each component is the
/// type-7 quantile at the matching probability in `probs`. Probabilities are
/// not reordered: pass them in `(low, central, high)` order.
///
/// \@category Helpers
/// \@subcategory Summary functions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric entries are dropped.
///
/// \@param probs Three probabilities in `[0, 1]`, ordered low-mid-high.
///
/// \@returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// \@examples-static Median plus the IQR via explicit probabilities.
/// ```
/// #let s = quantiles(range(1, 10), probs: (0.25, 0.5, 0.75))
/// ```
#let quantiles(values, probs: (0.25, 0.5, 0.75)) = {
  if type(probs) != array or probs.len() != 3 {
    panic(
      "quantiles: probs must be an array of three probabilities; got "
        + repr(probs),
    )
  }
  for p in probs {
    if p < 0 or p > 1 {
      panic("quantiles: every prob must be in [0, 1]; got " + repr(p))
    }
  }
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let sorted = xs.sorted()
  (
    y: _quantile(sorted, probs.at(1)),
    ymin: _quantile(sorted, probs.at(0)),
    ymax: _quantile(sorted, probs.at(2)),
  )
}

/// Mean and standard-error band: `mean ± multiplier * se`.
///
/// `se = sd / sqrt(n)` using the sample standard deviation. Returns
/// `(y: <mean>, ymin: <mean - multiplier * se>, ymax: <mean + multiplier * se>)`.
///
/// \@category Helpers
/// \@subcategory Summary functions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric entries are dropped.
///
/// \@param multiplier Multiplier on the standard error.
///
/// \@param weights Optional array of non-negative weights (`none` for unit weights). Frequency-weight semantics; total weight stands in for `n` in the standard-error denominator.
///
/// \@returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// \@examples-static One-σ band around the sample mean.
/// ```
/// #let s = mean-se((2, 3, 4, 5, 6))
/// // s.y == 4, s.ymin ≈ 3.29, s.ymax ≈ 4.71
/// ```
///
/// \@examples-static Bump `multiplier` to 2 for an approximate 95% interval
/// (assuming a roughly normal sampling distribution).
/// ```
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
/// The two-sided z critical value `qnorm((1 + conf) / 2)` is computed from
/// Acklam's inverse-normal approximation, so any `conf` in the open interval
/// `(0, 1)` is supported.
///
/// \@category Helpers
/// \@subcategory Summary functions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric entries are dropped.
///
/// \@param conf Confidence level in the open interval `(0, 1)`.
///
/// \@param weights Optional array of non-negative weights (`none` for unit weights). Frequency-weight semantics; total weight stands in for `n` in the standard-error denominator.
///
/// \@returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// \@examples-static Standard 95% normal-approximation interval.
/// ```
/// #let s = mean-cl-normal((2, 3, 4, 5, 6))
/// ```
///
/// \@examples-static Tighten to a 50% interval to highlight the central
/// location.
/// ```
/// #let s = mean-cl-normal((2, 3, 4, 5, 6), conf: 0.5)
/// ```
#let mean-cl-normal(values, conf: 0.95, weights: none) = {
  if conf <= 0 or conf >= 1 {
    panic("mean-cl-normal: conf must be in (0, 1); got " + repr(conf))
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
/// \@category Helpers
/// \@subcategory Summary functions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric entries are dropped.
///
/// \@param multiplier Multiplier on the sample standard deviation.
///
/// \@param weights Optional array of non-negative weights (`none` for unit weights). Frequency-weight semantics for the weighted standard deviation.
///
/// \@returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// \@examples-static Default ±1 σ band.
/// ```
/// #let s = mean-sd((2, 3, 4, 5, 6))
/// ```
///
/// \@examples-static Widen to ±2 σ for a two-deviation spread.
/// ```
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
/// Quantiles use the type-7 / numpy default linear interpolation rule, the
/// same convention as `src/stat/boxplot.typ`. The default `conf: 0.5`
/// returns the median with the IQR (25th to 75th percentile).
///
/// \@category Helpers
/// \@subcategory Summary functions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric entries are dropped.
///
/// \@param conf Proportion of the data covered by the interval, in `(0, 1)`.
///
/// \@returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// \@examples-static Default 50% interval returns the median plus the IQR.
/// ```
/// #let s = median-hilow((1, 2, 3, 4, 5, 6, 7, 8))
/// ```
///
/// \@examples-static A 90% interval covers the bulk of the data while still
/// trimming the tails.
/// ```
/// #let s = median-hilow((1, 2, 3, 4, 5, 6, 7, 8, 9, 10), conf: 0.9)
/// ```
#let median-hilow(values, conf: 0.5) = {
  if conf <= 0 or conf >= 1 {
    panic("median-hilow: conf must be in (0, 1); got " + repr(conf))
  }
  let xs = _to-numeric(values)
  if xs.len() == 0 { return _empty-summary }
  let sorted = xs.sorted()
  let tail = (1 - conf) / 2
  (
    y: _quantile(sorted, 0.5),
    ymin: _quantile(sorted, tail),
    ymax: _quantile(sorted, 1 - tail),
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
/// Resamples `values` with replacement `n-boot` times, computes the bootstrap
/// mean for each resample, and returns the requested central percentiles of
/// the bootstrap distribution. The resampling indices are drawn from a
/// deterministic noise sequence seeded by `seed`, so identical inputs always
/// produce identical bounds.
///
/// \@category Helpers
/// \@subcategory Summary functions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric entries are dropped.
///
/// \@param conf Confidence level in the open interval `(0, 1)`.
///
/// \@param n-boot Number of bootstrap resamples.
///
/// \@param seed Integer seed for the deterministic resampling sequence.
///
/// \@returns Dict `(y, ymin, ymax)`; all-`none` if `values` has no numerics.
///
/// \@examples-static Default 95% bootstrap interval with 1000 resamples.
/// ```
/// #let s = mean-cl-boot((2, 3, 4, 5, 6, 7))
/// ```
///
/// \@examples-static Bump `n-boot` for a smoother bound and pin `seed` to
/// keep results reproducible across renders.
/// ```
/// #let s = mean-cl-boot((2, 3, 4, 5, 6, 7), n-boot: 5000, seed: 42)
/// ```
#let mean-cl-boot(values, conf: 0.95, n-boot: 1000, seed: 0) = {
  if conf <= 0 or conf >= 1 {
    panic("mean-cl-boot: conf must be in (0, 1); got " + repr(conf))
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
    ymin: _quantile(sorted, tail),
    ymax: _quantile(sorted, 1 - tail),
  )
}

/// Look up a summary helper by name, or invoke a user-supplied callable.
///
/// String names use the kebab form (`"mean-se"`, `"mean-cl-normal"`,
/// `"mean-cl-boot"`, `"mean-sd"`, `"median-hilow"`, `"mean"`, `"median"`,
/// `"quantile"`, `"quantiles"`). When `name` is a function, it is called as
/// `name(values, ..fun-args)` and must return a dict `(y, ymin, ymax)`;
/// custom callables can take a sink (`..args`) to ignore extras. Unknown
/// string names panic.
///
/// \@category Helpers
/// \@subcategory Summary functions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Summary helper name, or a callable returning `(y, ymin, ymax)`.
///
/// \@param values Array of numbers; non-numeric entries are dropped.
///
/// \@param fun-args Keyword arguments forwarded to the helper or callable.
///
/// \@param weights Optional array of non-negative weights aligned with `values` (`none` for unit weights). Forwarded to helpers that honour weights (`mean`, `mean-se`, `mean-sd`, `mean-cl-normal`); helpers without a weighted formulation ignore the parameter.
///
/// \@returns Dict `(y, ymin, ymax)`.
///
/// \@examples-static Dispatch by name; equivalent to calling \@mean-se
/// directly.
/// ```
/// #let s = summarise("mean-se", (2, 3, 4, 5, 6))
/// ```
///
/// \@examples-static Pass keyword arguments via `fun-args` to forward
/// helper-specific parameters.
/// ```
/// #let s = summarise(
///   "median-hilow",
///   (1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
///   fun-args: (conf: 0.9),
/// )
/// ```
///
/// \@examples-static Pass a callable to compute an arbitrary summary.
/// ```
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
  panic(
    "summarise: unknown summary function "
      + repr(name)
      + "; expected a callable or one of mean-se, mean-cl-normal, "
      + "mean-cl-boot, mean-sd, median-hilow, mean, median, quantile, "
      + "quantiles.",
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

/// Apply a reduction by keyword (`"mean"`, `"median"`, `"sum"`, `"min"`,
/// `"max"`) or a callable `values => scalar`. Used by 2D summary stats.
///
/// Distinct from `summarise`, which returns a `(y, ymin, ymax)` triple for
/// 1D bands.
///
/// \@param name Reduction keyword or callable `values => scalar`.
///
/// \@param values Sequence of input values to reduce.
///
/// \@internal
#let reduce-scalar(name, values) = {
  if type(name) == function { return name(values) }
  let fn = _scalar-reducers.at(name, default: none)
  if fn == none {
    panic("reduce-scalar: unknown reduction " + repr(name))
  }
  fn(values)
}
