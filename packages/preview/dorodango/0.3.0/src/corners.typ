#import "geometry.typ": _hypot, _vadd, _vscale, _vsub

// Clockwise corner order and adjacency mappings.
#let _corner-order = ("top-left", "top-right", "bottom-right", "bottom-left")
#let _next-cw = (
  top-left: "top-right",
  top-right: "bottom-right",
  bottom-right: "bottom-left",
  bottom-left: "top-left",
)
#let _next-ccw = (
  top-left: "bottom-left",
  top-right: "top-left",
  bottom-right: "top-right",
  bottom-left: "bottom-right",
)
#let _side-cw = (
  top-left: "top",
  top-right: "right",
  bottom-right: "bottom",
  bottom-left: "left",
)
#let _side-ccw = (
  top-left: "left",
  top-right: "top",
  bottom-right: "right",
  bottom-left: "bottom",
)

// Corner edge unit vectors (edge-in, edge-out) and arc angle bounds.
#let _corner-geom = (
  top-left: (edge-in: (0, 1), edge-out: (1, 0), base0: 180deg, base1: 270deg),
  top-right: (edge-in: (-1, 0), edge-out: (0, 1), base0: -90deg, base1: 0deg),
  bottom-right: (
    edge-in: (0, -1),
    edge-out: (-1, 0),
    base0: 0deg,
    base1: 90deg,
  ),
  bottom-left: (
    edge-in: (1, 0),
    edge-out: (0, -1),
    base0: 90deg,
    base1: 180deg,
  ),
)

// Straight-edge budgets for each corner's edges. Adjacent corners split
// shared sides by radius.
#let _budgets(radii, side-lens, per-edge-smoothing) = {
  let budget = (
    top-left: (cw: -1pt, ccw: -1pt),
    top-right: (cw: -1pt, ccw: -1pt),
    bottom-right: (cw: -1pt, ccw: -1pt),
    bottom-left: (cw: -1pt, ccw: -1pt),
  )
  for corner in _corner-order.sorted(key: c => -radii.at(c)) {
    let r = radii.at(corner)
    // Shared edge budget lookup from adjacent corner.
    let term(side, adj-corner, adj-field) = {
      let ar = radii.at(adj-corner)
      if r <= 0pt and ar <= 0pt { 0pt } else {
        let side-len = side-lens.at(side)
        let adj-budget = budget.at(adj-corner).at(adj-field)
        if adj-budget >= 0pt { side-len - adj-budget } else {
          (r / (r + ar)) * side-len
        }
      }
    }
    let cw = term(_side-cw.at(corner), _next-cw.at(corner), "ccw")
    let ccw = term(_side-ccw.at(corner), _next-ccw.at(corner), "cw")
    budget.at(corner) = if per-edge-smoothing { (cw: cw, ccw: ccw) } else {
      let combined = calc.min(cw, ccw)
      (cw: combined, ccw: combined)
    }
  }
  budget
}

// Figma corner smoothing parameters.
// https://www.figma.com/blog/desperately-seeking-squircles/
#let _corner-params(r, s, budget, preserve-smoothing) = {
  if r <= 0pt {
    (
      a: 0pt,
      b: 0pt,
      c: 0pt,
      d: 0pt,
      p: 0pt,
      angle-alpha: 45deg,
    )
  } else {
    let p = (1 + s) * r
    // Clamp smoothing to budget, or compress handles when preserving smoothing.
    if not preserve-smoothing {
      s = calc.min(s, budget / r - 1)
      p = calc.min(p, budget)
    }
    let arc-measure = 90deg * (1 - s)
    let arc-len = calc.sin(arc-measure / 2) * r * calc.sqrt(2)
    let angle-alpha = (90deg - arc-measure) / 2
    let p3-p4 = r * calc.tan(angle-alpha / 2)
    let angle-beta = 45deg * s
    let c = p3-p4 * calc.cos(angle-beta)
    let d = c * calc.tan(angle-beta)
    let b = (p - arc-len - c - d) / 3
    let a = 2 * b
    if preserve-smoothing and p > budget {
      let p1-p3-max = budget - d - arc-len - c
      let min-a = p1-p3-max / 6
      let max-b = p1-p3-max - min-a
      b = calc.min(b, max-b)
      a = p1-p3-max - b
      p = budget
    }
    (
      a: a,
      b: b,
      c: c,
      d: d,
      p: p,
      angle-alpha: angle-alpha,
    )
  }
}

// Segment records with endpoints and control points.
#let _cubic(from, c1, c2, to) = (from: from, c1: c1, c2: c2, to: to)
#let _emit(segs) = segs.map(s => curve.cubic(s.c1, s.c2, s.to))
#let _emit-rev(segs) = segs.rev().map(s => curve.cubic(s.c2, s.c1, s.from))

// Cubic curve subdivision at parameter t.
#let _lerp(a, b, t) = _vadd(_vscale(a, 1.0 - t), _vscale(b, t))
#let _cubic-at(seg, t) = {
  let u = 1.0 - t
  _vadd(
    _vadd(
      _vscale(seg.from, u * u * u),
      _vscale(seg.c1, 3.0 * u * u * t),
    ),
    _vadd(
      _vscale(seg.c2, 3.0 * u * t * t),
      _vscale(seg.to, t * t * t),
    ),
  )
}
#let _split-cubic(seg, t) = {
  let a = _lerp(seg.from, seg.c1, t)
  let b = _lerp(seg.c1, seg.c2, t)
  let c = _lerp(seg.c2, seg.to, t)
  let d = _lerp(a, b, t)
  let e = _lerp(b, c, t)
  let mid = _lerp(d, e, t)
  (
    first: _cubic(seg.from, a, d, mid),
    second: _cubic(mid, e, c, seg.to),
    mid: mid,
  )
}

// Signed cross and dot products against a ray.
#let _ray-cross(center, direction, point) = {
  let d = _vsub(point, center)
  (
    (d.at(0) / 1pt) * (direction.at(1) / 1pt)
      - (d.at(1) / 1pt) * (direction.at(0) / 1pt)
  )
}
#let _ray-dot(center, direction, point) = {
  let d = _vsub(point, center)
  (
    (d.at(0) / 1pt) * (direction.at(0) / 1pt)
      + (d.at(1) / 1pt) * (direction.at(1) / 1pt)
  )
}

// Split cubic segments where they cross the ray from center through split.
#let _split-segs-on-ray(segs, center, split) = {
  let direction = _vsub(split, center)
  let dir-len = _hypot(direction)
  if dir-len == 0pt {
    return (mid: segs.first().from, first: (), second: segs)
  }
  let dir-len-num = dir-len / 1pt

  // Check segment endpoints close to the ray.
  let near-ray(point) = {
    let scale = calc.max(
      1.0,
      (_hypot(_vsub(point, center)) / 1pt) * dir-len-num,
    )
    calc.abs(_ray-cross(center, direction, point)) <= 1e-10 * scale
  }

  let before = ()
  for (i, seg) in segs.enumerate() {
    if (
      i > 0
        and near-ray(seg.from)
        and _ray-dot(center, direction, seg.from) >= 0.0
    ) {
      return (mid: seg.from, first: before, second: segs.slice(i))
    }
    let lo-t = 0.0
    let lo-v = _ray-cross(center, direction, seg.from)
    for step in range(1, 33) {
      let hi-t = step / 32.0
      let hi-v = _ray-cross(center, direction, _cubic-at(seg, hi-t))
      let crosses = (
        lo-v == 0.0
          or hi-v == 0.0
          or (
            (lo-v < 0.0 and hi-v > 0.0) or (lo-v > 0.0 and hi-v < 0.0)
          )
      )
      if crosses {
        let cut-t = if lo-v == 0.0 { lo-t } else if hi-v == 0.0 { hi-t } else {
          let left-t = lo-t
          let right-t = hi-t
          let left-v = lo-v
          let found-t = none
          for _ in range(48) {
            let mid-t = (left-t + right-t) / 2.0
            let mid-v = _ray-cross(
              center,
              direction,
              _cubic-at(seg, mid-t),
            )
            if mid-v == 0.0 {
              // Stop early on an exact root.
              found-t = mid-t
              break
            } else if (
              (left-v < 0.0 and mid-v > 0.0)
                or (
                  left-v > 0.0 and mid-v < 0.0
                )
            ) {
              right-t = mid-t
            } else {
              left-t = mid-t
              left-v = mid-v
            }
          }
          if found-t == none {
            (left-t + right-t) / 2.0
          } else {
            found-t
          }
        }
        let cut = _split-cubic(seg, cut-t)
        if _ray-dot(center, direction, cut.mid) >= 0.0 {
          return (
            mid: cut.mid,
            first: before + (cut.first,),
            second: (cut.second,) + segs.slice(i + 1),
          )
        }
      }
      lo-t = hi-t
      lo-v = hi-v
    }
    before.push(seg)
  }

  // Fall back to nearest endpoint when the ray falls outside the curve sweep.
  let start = segs.first().from
  let end = segs.last().to
  let start-reach = _hypot(_vsub(start, center))
  let end-reach = _hypot(_vsub(end, center))
  let start-offset = if start-reach == 0pt { calc.inf } else {
    calc.abs(_ray-cross(center, direction, start)) / (start-reach / 1pt)
  }
  let end-offset = if end-reach == 0pt { calc.inf } else {
    calc.abs(_ray-cross(center, direction, end)) / (end-reach / 1pt)
  }
  if start-offset <= end-offset {
    let cut = _split-cubic(segs.first(), 0.0)
    (mid: cut.mid, first: (cut.first,), second: (cut.second,) + segs.slice(1))
  } else {
    let before = ()
    for i in range(segs.len() - 1) { before.push(segs.at(i)) }
    let cut = _split-cubic(segs.last(), 1.0)
    (mid: cut.mid, first: before + (cut.first,), second: (cut.second,))
  }
}

#let _angle-of(center, p) = {
  let d = _vsub(p, center)
  calc.atan2(d.at(0) / 1pt, d.at(1) / 1pt)
}

// Sharp corner with inward pull for negative radii.
#let _sharp-piece(corner, pt, pull) = {
  let (edge-in, edge-out, ..) = _corner-geom.at(corner)
  (
    pt: pt,
    arc: false,
    start: _vadd(pt, _vscale(edge-in, pull)),
    mid: pt,
    end: _vadd(pt, _vscale(edge-out, pull)),
    full: (),
    first: (),
    second: (),
  )
}

// Rounded squircle corner with optional smoothing and split points.
#let _piece(corner, pt, r, params-in, params-out, split: none) = {
  let (edge-in, edge-out, base0, base1) = _corner-geom.at(corner)
  if r <= 0pt {
    // Negative radius pulls sharp corner inward, matching rect.
    return _sharp-piece(corner, pt, r)
  }

  let center = _vadd(pt, _vscale(_vadd(edge-in, edge-out), r))
  let neg-edge-in = _vscale(edge-in, -1)

  // Half-angles stay within 45 degrees.
  let angle0 = base0 + params-in.angle-alpha
  let angle1 = base1 - params-out.angle-alpha

  // Radius circle endpoints and tangents.
  let arc-end(angle) = {
    let c = calc.cos(angle)
    let s = calc.sin(angle)
    (
      pt: (center.at(0) + r * c, center.at(1) + r * s),
      tangent: (-s, c),
      angle: angle,
    )
  }

  // Approximate circle arc using standard cubic construction.
  let arc-seg(from, to) = {
    let kappa = 4.0 / 3.0 * calc.tan((to.angle - from.angle) / 4)
    _cubic(
      from.pt,
      _vadd(from.pt, _vscale(from.tangent, kappa * r)),
      _vadd(to.pt, _vscale(to.tangent, -kappa * r)),
      to.pt,
    )
  }

  let e0 = arc-end(angle0)
  let e1 = arc-end(angle1)

  let start = _vadd(pt, _vscale(edge-in, params-in.p))
  let end = _vadd(pt, _vscale(edge-out, params-out.p))

  let lead-in = _cubic(
    start,
    _vadd(start, _vscale(neg-edge-in, params-in.a)),
    _vadd(start, _vscale(neg-edge-in, params-in.a + params-in.b)),
    e0.pt,
  )
  // Lead-out cubic from arc end to corner end.
  let lead-out = _cubic(
    e1.pt,
    _vsub(end, _vscale(edge-out, params-out.a + params-out.b)),
    _vsub(end, _vscale(edge-out, params-out.a)),
    end,
  )

  let base = (
    pt: pt,
    arc: true,
    start: start,
    end: end,
    full: (lead-in, arc-seg(e0, e1), lead-out),
  )
  if split == none {
    return (..base, mid: pt, first: (), second: ())
  }

  // Clamp split angle to remaining arc span.
  let angle-mid = {
    let s = _angle-of(center, split)
    while s < base0 { s += 360deg }
    while s > base1 { s -= 360deg }
    calc.max(angle0, calc.min(angle1, s))
  }

  let em = arc-end(angle-mid)

  (
    ..base,
    mid: em.pt,
    first: (lead-in, arc-seg(e0, em)),
    second: (arc-seg(em, e1), lead-out),
  )
}

// Single cubic arc around center.
#let _arc-through(start, center, end) = {
  let a = _vsub(start, center)
  let b = _vsub(end, center)
  let ax = a.at(0) / 1pt
  let ay = a.at(1) / 1pt
  let bx = b.at(0) / 1pt
  let by = b.at(1) / 1pt
  let q1 = ax * ax + ay * ay
  let q2 = q1 + ax * bx + ay * by
  let denom = ax * by - ay * bx
  if denom == 0 { return curve.line(end) }
  let k2 = 4.0 / 3.0 * (calc.sqrt(calc.max(0.0, 2 * q1 * q2)) - q2) / denom
  curve.cubic(
    (
      center.at(0) + a.at(0) - k2 * a.at(1),
      center.at(1) + a.at(1) + k2 * a.at(0),
    ),
    (
      center.at(0) + b.at(0) + k2 * b.at(1),
      center.at(1) + b.at(1) - k2 * b.at(0),
    ),
    end,
  )
}

// Unit normal perpendicular to vector from -> to.
#let _line-normal(from, to) = {
  let d = _vsub(to, from)
  let h = _hypot(d) / 1pt
  if h == 0 { (0, 0) } else { (d.at(1) / 1pt / h, -(d.at(0) / 1pt) / h) }
}

// Small chord offset for round caps.
#let _cap-nudge = 1pt / 127

// Sample angles and midpoints for superellipse cubic fitting.
#let _se-thetas = (0deg, 30deg, 60deg, 90deg)
#let _se-theta-mids = (15deg, 45deg, 75deg)

// Superellipse corner via Lamé curve |X/p|^n + |Y/p|^n = 1.
#let _superellipse-piece(
  corner,
  pt,
  r,
  r-fit,
  budget,
  exponent,
  split: none,
) = {
  let (edge-in, edge-out, ..) = _corner-geom.at(corner)
  let p = calc.min(r-fit, budget.cw, budget.ccw)
  if p <= 0pt {
    return _sharp-piece(corner, pt, calc.min(0pt, r))
  }

  // Clamp exponent to supported range [2, 12].
  let n = float(calc.min(calc.max(exponent, 2), 12))

  // Exponent 2 is an exact circular arc.
  if n == 2.0 {
    return _piece(
      corner,
      pt,
      r,
      _corner-params(r-fit, 0.0, budget.ccw, false),
      _corner-params(r-fit, 0.0, budget.cw, false),
      split: split,
    )
  }

  let e = 2.0 / n
  let e1 = e - 1.0

  let pow-e(x) = {
    if n == 2.0 { x } else if n == 4.0 { calc.sqrt(x) } else if n == 8.0 {
      calc.sqrt(calc.sqrt(x))
    } else { calc.pow(x, e) }
  }
  let pow-e1(x) = {
    if n == 2.0 { 1.0 } else if n == 4.0 { 1.0 / calc.sqrt(x) } else {
      calc.pow(x, e1)
    }
  }

  let points = ()
  for (i, th) in _se-thetas.enumerate() {
    if i == 0 {
      points.push((0pt, 0pt))
    } else if i == _se-thetas.len() - 1 {
      points.push((p, p))
    } else {
      let sth = calc.sin(th)
      let cth = calc.cos(th)
      points.push((p * pow-e(sth), p * (1.0 - pow-e(cth))))
    }
  }

  let tangents = ()
  for (i, th) in _se-thetas.enumerate() {
    if i == 0 {
      tangents.push((1.0, 0.0))
    } else if i == _se-thetas.len() - 1 {
      tangents.push((0.0, 1.0))
    } else {
      let sth = calc.sin(th)
      let cth = calc.cos(th)
      let dx = e * pow-e1(sth) * cth * (p / 1pt)
      let dy = e * pow-e1(cth) * sth * (p / 1pt)
      let m = calc.sqrt(dx * dx + dy * dy)
      if m == 0 { m = 1.0 }
      tangents.push((dx / m, dy / m))
    }
  }

  let canonical-to-display(px, py) = {
    _vadd(_vadd(pt, _vscale(edge-in, p - px)), _vscale(edge-out, py))
  }

  let segs = ()
  for i in range(3) {
    let (x0, y0) = points.at(i)
    let (x1, y1) = points.at(i + 1)
    let (t0x, t0y) = tangents.at(i)
    let (t1x, t1y) = tangents.at(i + 1)

    let th-m = _se-theta-mids.at(i)
    let mx = p * pow-e(calc.sin(th-m))
    let my = p * (1.0 - pow-e(calc.cos(th-m)))

    let rhs-x = (8.0 / 3.0) * (mx - (x0 + x1) / 2.0) / 1pt
    let rhs-y = (8.0 / 3.0) * (my - (y0 + y1) / 2.0) / 1pt
    let det = t1x * t0y - t1y * t0x
    let h0 = (
      (if det != 0 { (-t1y * rhs-x + t1x * rhs-y) / det } else { 0.0 }) * 1pt
    )
    let h1 = (
      (if det != 0 { (t0x * rhs-y - t0y * rhs-x) / det } else { 0.0 }) * 1pt
    )

    let b0 = canonical-to-display(x0, y0)
    let b1 = canonical-to-display(x0 + h0 * t0x, y0 + h0 * t0y)
    let b2 = canonical-to-display(x1 - h1 * t1x, y1 - h1 * t1y)
    let b3 = canonical-to-display(x1, y1)

    segs.push(_cubic(b0, b1, b2, b3))
  }

  let start = canonical-to-display(0pt, 0pt)
  let end = canonical-to-display(p, p)
  let base = (
    pt: pt,
    arc: true,
    start: start,
    end: end,
    full: segs,
  )
  if split == none {
    return (..base, mid: pt, first: (), second: ())
  }

  // Ray origins use the fitted corner footprint.
  let diag = _vadd(edge-in, edge-out)
  let center = _vadd(pt, _vscale(diag, p))
  let cut = _split-segs-on-ray(segs, center, _vadd(split, _vscale(diag, p - r)))
  (:..base, ..cut)
}

// Simpson's rule integration for clothoid coordinates.
#let _integrate-clothoid(A, L) = {
  if L <= 0.0 { return (x: 0.0, y: 0.0) }
  let steps = 32
  let step = L / steps
  let half-a = A / 2.0
  let sixth-step = step / 6.0
  let x-acc = 0.0
  let y-acc = 0.0
  for i in range(1, steps + 1) {
    let s-a = (i - 1) * step
    let s-b = s-a + step
    let s-m = (s-a + s-b) / 2.0
    let th-a = half-a * s-a * s-a
    let th-b = half-a * s-b * s-b
    let th-m = half-a * s-m * s-m
    x-acc += (
      sixth-step * (calc.cos(th-a) + 4.0 * calc.cos(th-m) + calc.cos(th-b))
    )
    y-acc += (
      sixth-step * (calc.sin(th-a) + 4.0 * calc.sin(th-m) + calc.sin(th-b))
    )
  }
  (x: x-acc, y: y-acc)
}

// Clothoid blend corner with linear curvature ramp.
#let _clothoid-piece(corner, pt, r, r-fit, budget, s, split: none) = {
  let (edge-in, edge-out, ..) = _corner-geom.at(corner)
  let available-budget = calc.min(budget.cw, budget.ccw)
  if r-fit <= 0pt or available-budget <= 0pt {
    return _sharp-piece(corner, pt, calc.min(0pt, r))
  }

  let s-clamped = calc.max(0.0, calc.min(1.0, s))
  let R = r-fit / 1pt
  let d-theta = (calc.pi / 4.0) * s-clamped
  let L = (calc.pi / 2.0) * R * s-clamped

  // Zero smoothing uses exact circular arc.
  if L <= 0.0 {
    return _piece(
      corner,
      pt,
      r,
      _corner-params(r-fit, 0.0, budget.ccw, false),
      _corner-params(r-fit, 0.0, budget.cw, false),
      split: split,
    )
  }

  let A = 1.0 / (R * L)

  let end-pt = _integrate-clothoid(A, L)
  let mid-pt = _integrate-clothoid(A, L / 2.0)
  let x-c = end-pt.x
  let y-c = end-pt.y
  let x-mid = mid-pt.x
  let y-mid = mid-pt.y

  let arc-cx = x-c - R * calc.sin(d-theta * 1rad)
  let arc-cy = y-c + R * calc.cos(d-theta * 1rad)
  let natural-p = (arc-cx + arc-cy) * 1pt

  let p = natural-p
  let eff-R = R * 1pt
  let eff-x = x-c * 1pt
  let eff-y = y-c * 1pt
  let eff-mx = x-mid * 1pt
  let eff-my = y-mid * 1pt

  if natural-p > available-budget {
    // Scale clothoid lengths and radius when footprint exceeds budget.
    let scale-fac = available-budget / natural-p
    p = available-budget
    eff-R = eff-R * scale-fac
    eff-x = eff-x * scale-fac
    eff-y = eff-y * scale-fac
    eff-mx = eff-mx * scale-fac
    eff-my = eff-my * scale-fac
  }

  let cos-dt = calc.cos(d-theta * 1rad)
  let sin-dt = calc.sin(d-theta * 1rad)
  let h1 = if sin-dt > 1e-12 {
    ((8.0 / 3.0) * (eff-y / 2.0 - eff-my)) / sin-dt
  } else { 0pt }
  let h0 = (8.0 / 3.0) * (eff-mx - eff-x / 2.0) + h1 * cos-dt

  let canonical-to-display(px, py) = {
    _vadd(_vadd(pt, _vscale(edge-in, p - px)), _vscale(edge-out, py))
  }

  let head-cubic = {
    let b0 = canonical-to-display(0pt, 0pt)
    let b1 = canonical-to-display(h0, 0pt)
    let b2 = canonical-to-display(eff-x - h1 * cos-dt, eff-y - h1 * sin-dt)
    let b3 = canonical-to-display(eff-x, eff-y)
    _cubic(b0, b1, b2, b3)
  }

  let tail-cubic = {
    let b0 = canonical-to-display(p - eff-y, p - eff-x)
    let b1 = canonical-to-display(
      p - eff-y + h1 * sin-dt,
      p - eff-x + h1 * cos-dt,
    )
    // Tail cubic segment.
    let b2 = canonical-to-display(p, p - h0)
    let b3 = canonical-to-display(p, p)
    _cubic(b0, b1, b2, b3)
  }

  let arc-sweep = 90deg - 2.0 * (d-theta * 1rad)
  let has-arc = calc.abs(arc-sweep) > 1e-6deg

  // Canonical arc endpoints and tangents.
  let arc-from = (eff-x, eff-y)
  let arc-to = (p - eff-y, p - eff-x)
  let tangent-from = (cos-dt, sin-dt)
  let tangent-to = (sin-dt, cos-dt)

  // Cubic segment along central arc.
  let arc-cubic-between(from, t-from, to, t-to, sweep) = {
    let a0 = canonical-to-display(from.at(0), from.at(1))
    let a1 = canonical-to-display(to.at(0), to.at(1))
    let kappa = (4.0 / 3.0) * calc.tan(sweep / 4.0)
    // Transform tangent to display orientation.
    let heading(at, t) = _vsub(
      canonical-to-display(at.at(0) + t.at(0) * 1pt, at.at(1) + t.at(1) * 1pt),
      canonical-to-display(at.at(0), at.at(1)),
    )
    _cubic(
      a0,
      _vadd(a0, _vscale(heading(from, t-from), kappa * (eff-R / 1pt))),
      _vsub(a1, _vscale(heading(to, t-to), kappa * (eff-R / 1pt))),
      a1,
    )
  }

  let full-segs = if has-arc {
    (
      head-cubic,
      arc-cubic-between(
        arc-from,
        tangent-from,
        arc-to,
        tangent-to,
        arc-sweep,
      ),
      tail-cubic,
    )
  } else { (head-cubic, tail-cubic) }

  let start = canonical-to-display(0pt, 0pt)
  let end = canonical-to-display(p, p)

  let base = (
    pt: pt,
    arc: true,
    start: start,
    end: end,
    full: full-segs,
  )
  if split == none {
    return (..base, mid: pt, first: (), second: ())
  }

  // Ray origins use fitted footprint.
  let diag = _vadd(edge-in, edge-out)
  let center = _vadd(pt, _vscale(diag, p))
  let cut = _split-segs-on-ray(full-segs, center, _vadd(split, _vscale(
    diag,
    p - r,
  )))
  (:..base, ..cut)
}
