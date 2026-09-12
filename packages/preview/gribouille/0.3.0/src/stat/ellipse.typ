///! Per-group covariance-ellipse statistic.
///!
///! Backing statistic that pairs with \@geom-ellipse. For each group of
///! `(x, y)` rows, computes a confidence ellipse from the 2×2 sample
///! covariance and emits one row per group with `(x0, y0, a, b, angle)`
///! ready to be drawn.
///!
///! Eigenvalues of the 2×2 covariance come from the closed-form quadratic
///! `λ² − tr·λ + det = 0`. The ellipse axes are scaled by
///! `sqrt(λ · χ²(level, df=2))`. χ² for two degrees of freedom is the
///! closed-form `−2 · ln(1 − level)`, no numerical inversion required.

#import "../utils/types.typ": parse-number
#import "../utils/group.typ": group-aesthetics, group-key
#import "../utils/errors.typ": fail-range

/// Covariance-ellipse statistic: one ellipse per group from the sample covariance of `(x, y)`.
///
/// Each output row carries the parameters that `geom-ellipse` expects: `(x0, y0, a, b, angle)` with `x0`, `y0` the group centroid, `a`, `b` the semi-major and semi-minor radii in data units, and `angle` the rotation in radians. Pair with `geom-ellipse(stat: stat-ellipse())` or equivalently `geom-ellipse(stat: "ellipse")`.
///
/// - level: Coverage probability for the confidence ellipse, in `(0, 1)`.
///
/// Returns: Statistic object with `name: "ellipse"`, consumed by `geom-ellipse`.
///
/// See also: `geom-ellipse`, `stat-summary`.
///
/// Three Gaussian-like clusters, each enclosed by a 95% confidence ellipse.
///
/// ```typst
/// #let pts = ()
/// #for (cx, cy, k) in ((0, 0, "a"), (4, 1, "b"), (2, 4, "c")) {
///   for i in range(0, 30) {
///     let r = (calc.sin(i * 0.7) + calc.cos(i * 1.1)) * 0.4
///     pts.push((
///       x: cx + calc.cos(i * 0.5) + r,
///       y: cy + calc.sin(i * 0.5) + r,
///       k: k,
///     ))
///   }
/// }
/// #plot(
///   data: pts,
///   mapping: aes(x: "x", y: "y", fill: "k"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-ellipse(stat: stat-ellipse(), alpha: 0.2),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-ellipse(level: 0.95) = (
  kind: "stat",
  name: "ellipse",
  params: (level: level),
)

#let apply(data, mapping, params: (:)) = {
  let base-mapping = (
    x0: "x0",
    y0: "y0",
    a: "a",
    b: "b",
    angle: "angle",
  )
  if mapping == none { return (data: (), mapping: base-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: (), mapping: base-mapping)
  }

  let level = params.at("level", default: 0.95)
  if level <= 0 or level >= 1 {
    fail-range("stat-ellipse", "level", level, 0, 1)
  }
  // Inverse chi-square CDF for df=2 has the closed form −2·ln(1−p).
  let chi-sq = -2 * calc.ln(1 - level)

  // Bucket rows by the composite group key (canonical group aesthetics).
  let buckets = (:)
  let order = ()
  let proto = (:)
  for row in data {
    let key = group-key(row, mapping)
    let bucket = buckets.at(key, default: ())
    bucket.push(row)
    buckets.insert(key, bucket)
    if not order.contains(key) {
      order.push(key)
      proto.insert(key, row)
    }
  }

  let out-mapping = base-mapping
  for aes in group-aesthetics {
    let col = mapping.at(aes, default: none)
    if col != none { out-mapping.insert(aes, col) }
  }

  let out = ()
  for key in order {
    let rows = buckets.at(key)
    let pairs = rows
      .map(r => (
        x: parse-number(r.at(x-col, default: none)),
        y: parse-number(r.at(y-col, default: none)),
      ))
      .filter(p => p.x != none and p.y != none)
    let n = pairs.len()
    if n < 2 { continue }

    let xs = pairs.map(p => p.x)
    let ys = pairs.map(p => p.y)
    let x-mean = xs.sum() / n
    let y-mean = ys.sum() / n

    let sxx = 0.0
    let syy = 0.0
    let sxy = 0.0
    for p in pairs {
      let dx = p.x - x-mean
      let dy = p.y - y-mean
      sxx += dx * dx
      syy += dy * dy
      sxy += dx * dy
    }
    let denom = n - 1
    let cxx = sxx / denom
    let cyy = syy / denom
    let cxy = sxy / denom

    // Eigenvalues of the 2×2 covariance matrix [[cxx, cxy], [cxy, cyy]].
    let trace = cxx + cyy
    let det = cxx * cyy - cxy * cxy
    let disc = trace * trace / 4 - det
    let sqrt-disc = if disc < 0 { 0.0 } else { calc.sqrt(disc) }
    let lambda1 = trace / 2 + sqrt-disc
    let lambda2 = trace / 2 - sqrt-disc
    if lambda1 < 0 { lambda1 = 0.0 }
    if lambda2 < 0 { lambda2 = 0.0 }

    let a = calc.sqrt(lambda1 * chi-sq)
    let b = calc.sqrt(lambda2 * chi-sq)
    // Eigenvector of λ₁ for [[cxx, cxy], [cxy, cyy]] is (λ₁ - cyy, cxy);
    // the major-axis angle is its angle from the x-axis. Typst's
    // `calc.atan2(x, y)` takes the x-component first, opposite to R's
    // `atan2(y, x)`. The off-diagonal-zero branch keeps the ellipse axis-
    // aligned without taking atan2 of zero.
    let angle = if cxy == 0 {
      if cxx >= cyy { 0.0 } else { calc.pi / 2 }
    } else {
      calc.atan2(lambda1 - cyy, cxy) / 1rad
    }

    let row = (
      x0: x-mean,
      y0: y-mean,
      a: a,
      b: b,
      angle: angle,
    )
    let sample = proto.at(key)
    for col in group-aesthetics {
      let m-col = mapping.at(col, default: none)
      if m-col != none {
        row.insert(m-col, sample.at(m-col, default: ""))
      }
    }
    out.push(row)
  }

  (data: out, mapping: out-mapping)
}
