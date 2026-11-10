// Pure two-dimensional LP analysis. No drawing or angular sampling.
// All geometric comparisons use unit constraint normals; objective comparisons
// use a unit gradient, so multiplying coefficients by a positive scalar does
// not change the classification. Calculations still use floating-point numbers.
#let epsilon = 1e-10
#let numeric(x) = (type(x) == int or type(x) == float) and x > -calc.inf and x < calc.inf
#let dot(a, b) = a.at(0) * b.at(0) + a.at(1) * b.at(1)
#let sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let strict(s) = s == "<" or s == ">"
#let norm-op(s) = if s == "<" { "<=" } else if s == ">" { ">=" } else { s }
// Absolute distance tolerance plus a small roundoff allowance. Scaling the
// entire tolerance by the coordinate offset would erase narrow distant strips.
#let tolerance(r, p) = epsilon + 1e-14 * calc.max(calc.abs(r.at(2)), calc.abs(r.at(0) * p.at(0)), calc.abs(r.at(1) * p.at(1)))
#let same-point(p, q) = calc.abs(p.at(0) - q.at(0)) <= epsilon and calc.abs(p.at(1) - q.at(1)) <= epsilon
#let unique(points) = {
  let out = ()
  for p in points { if not out.any(q => same-point(p, q)) { out.push(p) } }
  out
}
#let unit(v) = {
  let scale = calc.max(calc.abs(v.at(0)), calc.abs(v.at(1)))
  if scale == 0 { return (0, 0) }
  let x = v.at(0) / scale
  let y = v.at(1) / scale
  let length = calc.sqrt(x * x + y * y)
  (x / length, y / length)
}
#let normalize(r) = {
  let (a, b, c, s, ..rest) = r
  let scale = calc.max(calc.abs(a), calc.abs(b))
  if scale == 0 { return (a, b, c, s, ..rest) }
  let x = a / scale
  let y = b / scale
  let length = calc.sqrt(x * x + y * y)
  let offset = (c / scale) / length
  assert(numeric(offset), message: "normalized constraint exceeds the floating-point range")
  (x / length, y / length, offset, s, ..rest)
}
#let validate(constraints, objective, sense, first-quadrant) = {
  assert(type(constraints) == array, message: "constraints must be an array")
  for (i, r) in constraints.enumerate() {
    assert(type(r) == array and (r.len() == 4 or r.len() == 5), message: "constraint " + str(i + 1) + " must contain (a, b, c, op[, color])")
    assert(r.slice(0, 3).all(numeric), message: "constraint coefficients must be finite numbers")
    assert(("<=", ">=", "<", ">").contains(r.at(3)), message: "constraint operator must be <=, >=, < or >")
    if r.len() == 5 { assert(type(r.at(4)) == color, message: "constraint color must be a color") }
  }
  assert(("max", "min").contains(sense), message: "sense must be max or min")
  assert(type(first-quadrant) == bool, message: "first-quadrant must be a boolean")
  if objective != none {
    assert(type(objective) == array and (objective.len() == 2 or objective.len() == 3), message: "objective must contain (c1, c2[, color])")
    assert(objective.slice(0, 2).all(numeric), message: "objective coefficients must be finite numbers")
    if objective.len() == 3 { assert(type(objective.at(2)) == color, message: "objective color must be a color") }
  }
}
#let satisfies(p, restrictions, open: false) = {
  for r in restrictions {
    let (a, b, c, s, ..) = r
    let residual = a * p.at(0) + b * p.at(1) - c
    if s == ">=" or s == ">" { residual = -residual }
    // Constant restrictions have no rounding error and include 0 < 0 cases.
    let tol = if a == 0 and b == 0 { 0 } else { tolerance(r, p) }
    if open and strict(s) {
      if residual >= -tol { return false }
    } else if residual > tol { return false }
  }
  true
}
#let intersect(r1, r2) = {
  let (a, b, c, ..) = r1
  let (d, e, f, ..) = r2
  let det = a * e - d * b
  if det == 0 { return none }
  let p = ((c * e - f * b) / det, (a * f - d * c) / det)
  assert(p.all(numeric), message: "constraint intersection exceeds the floating-point range")
  p
}
#let interior(points, directions) = {
  if points.len() == 0 { return none }
  let n = points.len()
  let p = (points.map(p => p.at(0) / n).sum(), points.map(p => p.at(1) / n).sum())
  if directions.len() > 0 {
    let scale = calc.max(1, ..points.map(p => calc.max(calc.abs(p.at(0)), calc.abs(p.at(1)))))
    let n = directions.len()
    p = (p.at(0) + scale * directions.map(d => d.at(0) / n).sum(), p.at(1) + scale * directions.map(d => d.at(1) / n).sum())
  }
  assert(p.all(numeric), message: "feasible-point calculation exceeds the floating-point range")
  p
}

/// Analyze the actual region, independently of any visible frame.
/// Strict regions are tested using a relative-interior witness of their closure.
/// status: none, infeasible, unbounded, unattained, unique, segment, ray, line, all.
#let analyze(constraints, objective: none, sense: "max", first-quadrant: true) = {
  validate(constraints, objective, sense, first-quadrant)
  let R = constraints.map(normalize)
  if first-quadrant { R += ((1, 0, 0, ">="), (0, 1, 0, ">=")) }
  let verts = ()
  let candidates = ((0, 0),)
  for (i, r) in R.enumerate() {
    let (a, b, c, ..) = r
    if a != 0 or b != 0 { candidates.push((a * c, b * c)) }
    for j in range(i + 1, R.len()) {
      let p = intersect(r, R.at(j))
      if p != none and satisfies(p, R) { verts.push(p) }
    }
  }
  verts = unique(verts)
  if verts.len() > 0 {
    let center = interior(verts, ())
    verts = verts.sorted(key: p => calc.atan2(p.at(0) - center.at(0), p.at(1) - center.at(1)))
  }
  candidates = unique((candidates + verts).filter(p => satisfies(p, R)))

  // Boundary tangents generate pointed cones. Inward normals also cover
  // half-planes with lineality; cardinal directions cover the whole plane.
  let directions = ((1, 0), (0, 1), (-1, 0), (0, -1))
  for (a, b, ..) in R {
    if a != 0 or b != 0 { directions += ((-b, a), (b, -a), (a, b), (-a, -b)) }
  }
  let homogeneous = R.map(r => (r.at(0), r.at(1), 0, norm-op(r.at(3))))
  let recession = unique(directions.filter(d => satisfies(d, homogeneous)))
  let witness = interior(candidates, recession)
  let feasible = witness != none and satisfies(witness, R, open: true)
  let status = if feasible { "none" } else { "infeasible" }
  let value = none
  let optimum = none
  let opt-idxs = ()
  let closure-idxs = ()
  let opt-dirs = ()
  let evals = if objective == none { () } else { verts.map(p => dot(objective, p)) }
  assert(evals.all(numeric), message: "objective value exceeds the floating-point range")
  if feasible and objective != none {
    let g = unit(objective)
    let sign = if sense == "max" { 1 } else { -1 }
    if g == (0, 0) {
      status = "all"
      value = 0
      optimum = witness
      closure-idxs = range(verts.len())
      opt-idxs = closure-idxs.filter(i => satisfies(verts.at(i), R, open: true))
      opt-dirs = recession
    } else if recession.any(d => sign * dot(g, d) > epsilon) {
      status = "unbounded"
    } else {
      let best = candidates.first()
      for p in candidates { if sign * dot(g, sub(p, best)) > 0 { best = p } }
      let tied = p => calc.abs(dot(g, sub(p, best))) <= epsilon
      let face = candidates.filter(tied)
      closure-idxs = range(verts.len()).filter(i => tied(verts.at(i)))
      opt-dirs = recession.filter(d => calc.abs(dot(g, d)) <= epsilon)
      let face-witness = interior(face, opt-dirs)
      value = dot(objective, best)
      optimum = face-witness
      if not satisfies(face-witness, R, open: true) {
        status = "unattained"
      } else {
        opt-idxs = closure-idxs.filter(i => satisfies(verts.at(i), R, open: true))
        status = if opt-dirs.len() > 0 {
          if opt-dirs.any(d => opt-dirs.any(e => dot(d, e) < -1 + epsilon)) { "line" } else { "ray" }
        } else if face.len() > 1 { "segment" } else { "unique" }
      }
    }
  }
  assert(value == none or numeric(value), message: "objective value exceeds the floating-point range")
  (constraints: R, feasible: feasible, bounded: not feasible or recession.len() == 0,
    vertices: verts, candidates: candidates, recession: if feasible { recession } else { () },
    witness: if feasible { witness } else { none },
    status: status, value: value, optimum: optimum, optimal-indices: opt-idxs,
    closure-indices: closure-idxs, optimal-directions: opt-dirs, evals: evals)
}

// Clip a line to a rectangle, removing duplicate intersections at its corners.
#let line-in-frame(a, b, c, minx, miny, maxx, maxy) = {
  let r = normalize((a, b, c, "<="))
  let (a, b, c, ..) = r
  let points = ()
  if b != 0 { points += ((minx, (c - a * minx) / b), (maxx, (c - a * maxx) / b)) }
  if a != 0 { points += (((c - b * miny) / a, miny), ((c - b * maxy) / a, maxy)) }
  unique(points.filter(p => p.at(0) >= minx - epsilon and p.at(0) <= maxx + epsilon and p.at(1) >= miny - epsilon and p.at(1) <= maxy + epsilon))
}
