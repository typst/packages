///! Smoother statistic backing \@geom-smooth.
///!
///! v1 supports `method: "lm"` only (closed-form OLS). Emits a dense grid of
///! `(x, y, ymin, ymax)` for the fitted line and pointwise confidence band.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": read-weight
#import "../utils/late-binding.typ": after-scale-source
#import "../scale/train.typ": mapping-ref-col
#import "../utils/normal.typ": qnorm

/// Smoother statistic: closed-form linear fit with a pointwise confidence band.
///
/// Returns a dense grid of `(x, y, ymin, ymax)` rows where `y` is the fitted value and `ymin`/`ymax` bound a pointwise confidence band.
///
/// - method: Smoother method. `"lm"` is the only supported value in v1.
/// - se: Whether to compute the confidence band. When `false`, `ymin == ymax == y`.
/// - level: Confidence level for the band (e.g., `0.95`).
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
#let stat-smooth(method: "lm", se: true, level: 0.95) = (
  kind: "stat",
  name: "smooth",
  params: (method: method, se: se, level: level),
)

#let _sum(xs) = {
  let acc = 0.0
  for v in xs { acc = acc + v }
  acc
}

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

  let weight-col = mapping.at("weight", default: none)
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
    let w-sum = _sum(pairs.map(p => p.w))
    if w-sum == 0 { continue }
    let x-mean = _sum(pairs.map(p => p.w * p.x)) / w-sum
    let y-mean = _sum(pairs.map(p => p.w * p.y)) / w-sum
    let sxx = _sum(pairs.map(p => p.w * (p.x - x-mean) * (p.x - x-mean)))
    let sxy = _sum(pairs.map(p => p.w * (p.x - x-mean) * (p.y - y-mean)))
    if sxx == 0 { continue }
    let slope = sxy / sxx
    let intercept = y-mean - slope * x-mean
    let rss = _sum(pairs.map(p => {
      let resid = p.y - (intercept + slope * p.x)
      p.w * resid * resid
    }))
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
