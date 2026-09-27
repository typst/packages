///! Smoother statistic backing \@geom-smooth.
///!
///! `method: "lm"` fits a closed-form weighted OLS line; `method: "loess"`
///! fits tricube-weighted local polynomials (degree 1 or 2) at each grid
///! point, O(n²) per group. Both emit a dense grid of `(x, y, ymin, ymax)`
///! for the fitted curve and pointwise confidence band.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": read-weight
#import "../utils/late-binding.typ": after-scale-source
#import "../scale/train.typ": mapping-ref-col
#import "../utils/normal.typ": qnorm
#import "../utils/errors.typ": fail-enum, fail-range

/// Smoother statistic: fitted curve with a pointwise confidence band.
///
/// Returns a dense grid of `(x, y, ymin, ymax)` rows where `y` is the fitted value and `ymin`/`ymax` bound a pointwise confidence band.
///
/// The loess band uses normal quantiles with the residual variance estimated on `n - trace(L)` degrees of freedom (`L` the smoothing operator), a close approximation to R's t-interval construction.
///
/// - method: Smoother method: `"lm"` (weighted least squares line) or `"loess"` (tricube-weighted local polynomials).
/// - se: Whether to compute the confidence band. When `false`, `ymin == ymax == y`.
/// - level: Confidence level for the band (e.g., `0.95`).
/// - span: Loess neighbourhood as a fraction of the data in `(0, 1]`; smaller spans follow the data more closely.
/// - degree: Loess local polynomial degree: `0`, `1`, or `2`.
///
/// Returns: Statistic object with `name: "smooth"`, consumed by geom layers.
///
/// See also: `geom-smooth`, `stat-identity`.
///
/// Linear fit with the default 95% confidence band.
///
/// ```typst
/// #let d = range(0, 20).map(i => (
///   x: i,
///   y: i * 0.5 + calc.sin(i * 0.4) * 2,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-smooth(method: "lm"),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Constructor form: `stat: stat-smooth()` is equivalent to `stat: "smooth"` with defaults. Use the constructor on any geom and to customise `method`, `se`, or `level`. Both forms honour `colour` grouping.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 20) {
///     d.push((x: i, y: i * 0.5 + (if grp == "b" { 1.5 } else { 0 }) + calc.sin(i * 0.4), grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "grp"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-line(stat: stat-smooth(method: "lm", se: false)),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// A loess curve follows the oscillation the linear fit averages away; `span` tunes how locally it bends.
///
/// ```typst
/// #let d = range(0, 30).map(i => (
///   x: i * 0.4,
///   y: calc.sin(i * 0.4) * 2 + i * 0.1,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-smooth(method: "loess", span: 0.5),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-smooth(
  method: "lm",
  se: true,
  level: 0.95,
  span: 0.75,
  degree: 2,
) = (
  kind: "stat",
  name: "smooth",
  params: (method: method, se: se, level: level, span: span, degree: degree),
)

// Columns that implicitly group rows so each subset gets its own fit. The
// contract matches geom-line: `group`, `colour`, `fill`, `linetype` — any
// discrete aesthetic that would warrant a separate path.
#let _grouping-columns(mapping, x-col, y-col) = {
  let cols = ()
  let group-col = mapping-ref-col(
    after-scale-source(mapping.at("group", default: none)),
  )
  if group-col != none { cols.push(group-col) }
  for aes-name in ("colour", "fill", "linetype") {
    let col = mapping-ref-col(after-scale-source(mapping.at(
      aes-name,
      default: none,
    )))
    if (
      col != none and col != x-col and col != y-col and not cols.contains(col)
    ) {
      cols.push(col)
    }
  }
  cols
}

#let _group-key(row, cols) = {
  if cols.len() == 0 { return "_all" }
  cols.map(c => str(row.at(c, default: ""))).join("\u{1}")
}

// Solve the p×p system `A v = e0` (first unit vector) by Gaussian
// elimination with partial pivoting. Returns `none` when singular.
#let _solve-e0(A) = {
  let p = A.len()
  let M = A
    .enumerate()
    .map(((i, row)) => row + (if i == 0 { 1.0 } else { 0.0 },))
  for c in range(p) {
    let pivot = c
    for r in range(c + 1, p) {
      if calc.abs(M.at(r).at(c)) > calc.abs(M.at(pivot).at(c)) { pivot = r }
    }
    if calc.abs(M.at(pivot).at(c)) == 0 { return none }
    let tmp = M.at(c)
    M.at(c) = M.at(pivot)
    M.at(pivot) = tmp
    for r in range(p) {
      if r == c { continue }
      let factor = M.at(r).at(c) / M.at(c).at(c)
      for k in range(c, p + 1) {
        M.at(r).at(k) = M.at(r).at(k) - factor * M.at(c).at(k)
      }
    }
  }
  range(p).map(i => M.at(i).at(p) / M.at(i).at(i))
}

// `calc.pow(0, 0)` panics, but the polynomial design wants `z^0 == 1`.
#let _zpow(v, e) = if e == 0 { 1.0 } else { calc.pow(v, e) }

// One tricube-weighted local polynomial fit at `x0`. Returns
// `(fit, l)` where `l` is the smoothing-operator row, i.e.,
// `fit = Σ l.at(i) * pairs.at(i).y`, so callers can derive the pointwise
// standard error and the operator trace. Falls back to the weighted mean
// when the local design is singular (e.g., tied x values).
#let _loess-point(pairs, x0, span, degree) = {
  let n = pairs.len()
  let q = calc.max(degree + 1, calc.min(n, calc.floor(span * n)))
  let dist-q = pairs.map(p => calc.abs(p.x - x0)).sorted().at(q - 1)
  let weights = pairs.map(p => {
    let dist = calc.abs(p.x - x0)
    let tri = if dist-q == 0 {
      if dist == 0 { 1.0 } else { 0.0 }
    } else {
      let u = calc.min(dist / dist-q, 1.0)
      let c = 1 - u * u * u
      c * c * c
    }
    tri * p.w
  })
  let terms = degree + 1
  let z = pairs.map(p => p.x - x0)
  let A = range(terms).map(r => range(terms).map(c => {
    range(n).map(i => weights.at(i) * _zpow(z.at(i), r + c)).sum()
  }))
  let v = _solve-e0(A)
  let l = if v == none {
    let w-sum = weights.sum()
    weights.map(w => w / w-sum)
  } else {
    range(n).map(i => (
      weights.at(i) * range(terms).map(j => v.at(j) * _zpow(z.at(i), j)).sum()
    ))
  }
  let fit = range(n).map(i => l.at(i) * pairs.at(i).y).sum()
  (fit: fit, l: l)
}

// Loess rows for one group: residual variance from the fits at the data
// points (weighted RSS over `n - trace(L)` degrees of freedom), then the
// fitted curve and pointwise band over an even grid.
#let _loess-rows(pairs, span, degree, se-on, t-val, steps) = {
  let n = pairs.len()
  let trace = 0.0
  let rss = 0.0
  for (i, p) in pairs.enumerate() {
    let local = _loess-point(pairs, p.x, span, degree)
    trace += local.l.at(i)
    rss += p.w * (p.y - local.fit) * (p.y - local.fit)
  }
  let sigma2 = rss / calc.max(1.0, n - trace)

  let xs = pairs.map(p => p.x)
  let x-min = calc.min(..xs)
  let x-max = calc.max(..xs)
  range(steps + 1).map(i => {
    let x = x-min + (x-max - x-min) * i / steps
    let local = _loess-point(pairs, x, span, degree)
    let margin = if se-on {
      let norm2 = local.l.map(v => v * v).sum()
      t-val * calc.sqrt(calc.max(0.0, sigma2 * norm2))
    } else { 0.0 }
    (x: x, y: local.fit, ymin: local.fit - margin, ymax: local.fit + margin)
  })
}

#let _DEGREES = (0, 1, 2)

#let _validate(params) = {
  let method = params.at("method", default: "lm")
  if method not in ("lm", "loess") {
    fail-enum("stat-smooth", "method", method, ("lm", "loess"))
  }
  let span = params.at("span", default: 0.75)
  if type(span) not in (int, float) or span <= 0 or span > 1 {
    fail-range("stat-smooth", "span", span, 0, 1, hi-open: false)
  }
  let degree = params.at("degree", default: 2)
  if degree not in _DEGREES {
    fail-enum("stat-smooth", "degree", degree, _DEGREES)
  }
}

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  let y-col = if mapping != none { mapping.at("y", default: none) } else {
    none
  }
  let base-mapping = (x: "x", y: "y", ymin: "ymin", ymax: "ymax")
  if x-col == none or y-col == none { return (data: (), mapping: base-mapping) }

  let group-cols = _grouping-columns(mapping, x-col, y-col)

  let groups = (:)
  let samples = (:)
  for row in data {
    let key = _group-key(row, group-cols)
    let bucket = groups.at(key, default: ())
    bucket.push(row)
    groups.insert(key, bucket)
    if samples.at(key, default: none) == none { samples.insert(key, row) }
  }

  _validate(params)
  let weight-col = mapping.at("weight", default: none)
  let method = params.at("method", default: "lm")
  let span = params.at("span", default: 0.75)
  let degree = params.at("degree", default: 2)
  let se-on = params.at("se", default: true)
  let level = params.at("level", default: 0.95)
  let t-val = qnorm(0.5 + level / 2)
  let steps = 80

  let out = ()
  for (key, rows) in groups.pairs() {
    let pairs = rows
      .map(r => {
        let x = parse-number(r.at(x-col, default: none))
        let y = parse-number(r.at(y-col, default: none))
        if x == none or y == none { return none }
        (x: x, y: y, w: read-weight(r, weight-col))
      })
      .filter(p => p != none and p.w > 0)
    let n = pairs.len()
    if n < 2 { continue }
    if method == "loess" {
      if n < degree + 1 { continue }
      let sample = samples.at(key)
      for fitted in _loess-rows(pairs, span, degree, se-on, t-val, steps) {
        let row = fitted
        for col in group-cols {
          row.insert(col, sample.at(col, default: ""))
        }
        out.push(row)
      }
      continue
    }
    let w-sum = pairs.map(p => p.w).sum(default: 0.0)
    if w-sum == 0 { continue }
    let x-mean = pairs.map(p => p.w * p.x).sum(default: 0.0) / w-sum
    let y-mean = pairs.map(p => p.w * p.y).sum(default: 0.0) / w-sum
    let sxx = pairs
      .map(p => p.w * (p.x - x-mean) * (p.x - x-mean))
      .sum(default: 0.0)
    let sxy = pairs
      .map(p => p.w * (p.x - x-mean) * (p.y - y-mean))
      .sum(default: 0.0)
    if sxx == 0 { continue }
    let slope = sxy / sxx
    let intercept = y-mean - slope * x-mean
    let rss = pairs
      .map(p => {
        let resid = p.y - (intercept + slope * p.x)
        p.w * resid * resid
      })
      .sum(default: 0.0)
    let dof = calc.max(1, n - 2)
    let sigma2 = rss / dof
    let xs = pairs.map(p => p.x)
    let x-min = calc.min(..xs)
    let x-max = calc.max(..xs)
    let sample = samples.at(key)
    for i in range(steps + 1) {
      let t = i / steps
      let x = x-min + t * (x-max - x-min)
      let y-hat = intercept + slope * x
      let se = if se-on {
        let var = sigma2 * (1.0 / w-sum + (x - x-mean) * (x - x-mean) / sxx)
        calc.sqrt(calc.max(0.0, var))
      } else { 0.0 }
      let margin = t-val * se
      let row = (x: x, y: y-hat, ymin: y-hat - margin, ymax: y-hat + margin)
      for col in group-cols {
        row.insert(col, sample.at(col, default: ""))
      }
      out.push(row)
    }
  }

  // Echo the grouping aesthetics so the geom can drive per-group colour
  // and fill through the usual scale lookup on the tagged rows.
  let m = base-mapping
  for aes-name in ("group", "colour", "fill", "linetype") {
    let col = mapping.at(aes-name, default: none)
    if col != none and group-cols.contains(col) {
      m.insert(aes-name, col)
    }
  }

  (data: out, mapping: m)
}
