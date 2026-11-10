// ===========================================================================
//  faboxyst/sketchcore.typ — the pure-Typst numerical core of the sketch engine.
//
//  Everything works on plain numbers (points as (x, y) pairs in pt, angles in
//  degrees) and is deterministic: a seed always draws the same wobble.
//    * decorate   — the PGF-style "sketch" decoration of a polyline
//    * hatch      — scanline hatching of a set of contours (holes included)
//    * rough-*    — a Rough.js-style double stroke (lines, ellipses, curves,
//                   arcs) and its fill patterns
//  The pen strokes themselves (vintage mode) are computed by nibart in
//  antique.typ.
// ===========================================================================

#let _M = 2147483647

/// Initial PRNG state of a seed (Park–Miller generator).
#let init(seed) = calc.rem(calc.abs(int(seed)) * 7919 + 12345, _M - 1) + 1

// (value in [0, 1), next state)
#let _r(s) = {
  let t = calc.rem(s * 48271, _M)
  (t / _M, t)
}

/// `n` pseudo-random values in [-1, 1] for a seed.
#let randoms(seed, n) = {
  let st = init(seed)
  let out = ()
  for _ in range(n) {
    let (r, s2) = _r(st)
    st = s2
    out.push(2 * r - 1)
  }
  out
}

#let _len(a, b) = calc.sqrt((b.at(0) - a.at(0)) * (b.at(0) - a.at(0)) + (b.at(1) - a.at(1)) * (b.at(1) - a.at(1)))

// ---------------------------------------------------------------------------
//  decorate — resample a polyline and push it sideways by a smooth random noise
// ---------------------------------------------------------------------------
#let decorate(pts, segment: 0.5, amplitude: 0.5, randomness: 2.0, wavelength: 100.0, seed: 1, closed: false) = {
  let n = pts.len()
  if n < 2 or amplitude == 0 { return pts }
  let path = if closed { pts + (pts.first(),) } else { pts }
  // arclength of the whole path
  let total = 0.0
  for i in range(path.len() - 1) { total += _len(path.at(i), path.at(i + 1)) }
  if total <= 0 { return pts }
  // random knots (smooth noise), spacing about wavelength / 5
  let ks = calc.max(wavelength / 6, 1.0)
  let nk = calc.max(int(calc.ceil(total / ks)) + 2, 3)
  let st = init(seed)
  let knots = ()
  for _ in range(nk) {
    let (r, s2) = _r(st)
    st = s2
    knots.push(1.6 * amplitude * (2 * r - 1))
  }
  if closed { knots.at(nk - 1) = knots.at(0) }
  let kstep = total / (nk - 2)
  let noise(s) = {
    let u = s / kstep
    let i = calc.min(int(calc.floor(u)), nk - 2)
    let f = u - i
    let w = f * f * (3 - 2 * f)
    knots.at(i) * (1 - w) + knots.at(i + 1) * w
  }
  let step = calc.max(segment, kstep / 4)
  let out = ()
  let s0 = 0.0
  for i in range(path.len() - 1) {
    let a = path.at(i)
    let b = path.at(i + 1)
    let l = _len(a, b)
    if l <= 0 { continue }
    let ux = (b.at(0) - a.at(0)) / l
    let uy = (b.at(1) - a.at(1)) / l
    let m = calc.max(int(calc.ceil(l / step)), 1)
    for k in range(m) {
      let t = k / m * l
      let o = noise(s0 + t)
      out.push((a.at(0) + ux * t - uy * o, a.at(1) + uy * t + ux * o))
    }
    s0 += l
  }
  if not closed {
    let b = path.last()
    out.push(b)
  }
  out
}

// ---------------------------------------------------------------------------
//  hatch — scanlines of direction `angle` (degrees) clipped by the contours
//  (even-odd rule: the further contours are holes).
//  Returns a list of ((x1, y1), (x2, y2)).
// ---------------------------------------------------------------------------
#let hatch(contours, angle: 45, spacing: 4.0, offset: 0.0) = {
  if spacing <= 0 or contours.len() == 0 { return () }
  let ca = calc.cos(angle * 1deg)
  let sa = calc.sin(angle * 1deg)
  let rot = ct => ct.map(p => (p.at(0) * ca + p.at(1) * sa, -p.at(0) * sa + p.at(1) * ca))
  let cs = contours.map(rot)
  let ymin = float.inf
  let ymax = -float.inf
  for ct in cs { for p in ct {
    if p.at(1) < ymin { ymin = p.at(1) }
    if p.at(1) > ymax { ymax = p.at(1) }
  } }
  let k0 = int(calc.ceil((ymin - offset) / spacing))
  let k1 = int(calc.floor((ymax - offset) / spacing))
  let out = ()
  for k in range(k0, k1 + 1) {
    let y = offset + k * spacing
    let xs = ()
    for ct in cs {
      let m = ct.len()
      for i in range(m) {
        let p = ct.at(i)
        let q = ct.at(calc.rem(i + 1, m))
        let (y1, y2) = (p.at(1), q.at(1))
        if (y1 <= y and y < y2) or (y2 <= y and y < y1) {
          xs.push(p.at(0) + (y - y1) / (y2 - y1) * (q.at(0) - p.at(0)))
        }
      }
    }
    xs = xs.sorted()
    let j = 0
    while j + 1 < xs.len() {
      let (x1, x2) = (xs.at(j), xs.at(j + 1))
      out.push(((x1 * ca - y * sa, x1 * sa + y * ca), (x2 * ca - y * sa, x2 * sa + y * ca)))
      j += 2
    }
  }
  out
}

// ---------------------------------------------------------------------------
//  Rough.js-style strokes
// ---------------------------------------------------------------------------

// signed jitter of amplitude x: roughness * gain * x * (2r - 1)
#let _jit(x, o, gain, st) = {
  let (r, s2) = _r(st)
  (o.roughness * gain * x * (2 * r - 1), s2)
}

#let _bez(p0, p1, p2, p3, n) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0) + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
   u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1) + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1))
})

// one bowed double-stroke pass from a to b: (points, state)
#let _line-pass(a, b, o, overlay, st) = {
  let (x1, y1) = a
  let (x2, y2) = b
  let l = _len(a, b)
  if l < 1e-9 { return ((a, b), st) }
  let gain = if l < 200 { 1.0 } else if l > 500 { 0.4 } else { -0.0016668 * l + 1.233334 }
  let off = o.max-offset
  if off * off * 100 > l * l { off = l / 10 }
  let half = off / 2
  let amount = if overlay { half } else { off }
  let (r, st1) = _r(st)
  st = st1
  let dp = 0.2 + r * 0.2
  let mx = o.bowing * o.max-offset * (y2 - y1) / 200
  let my = o.bowing * o.max-offset * (x1 - x2) / 200
  let (j, s1) = _jit(mx, o, gain, st)
  mx = j; st = s1
  let (j2, s2) = _jit(my, o, gain, st)
  my = j2; st = s2
  let pv = o.preserve-vertices
  let jj(v, st) = { let (a, s) = _jit(v, o, gain, st); (a, s) }
  let (e1, st) = if pv { (0.0, st) } else { jj(amount, st) }
  let (e2, st) = if pv { (0.0, st) } else { jj(amount, st) }
  let p0 = (x1 + e1, y1 + e2)
  let (c1x, st) = jj(half, st)
  let (c1y, st) = jj(half, st)
  let (c2x, st) = jj(half, st)
  let (c2y, st) = jj(half, st)
  let (e3, st) = if pv { (0.0, st) } else { jj(amount, st) }
  let (e4, st) = if pv { (0.0, st) } else { jj(amount, st) }
  let p1 = (mx + x1 + (x2 - x1) * dp + c1x, my + y1 + (y2 - y1) * dp + c1y)
  let p2 = (mx + x1 + 2 * (x2 - x1) * dp + c2x, my + y1 + 2 * (y2 - y1) * dp + c2y)
  let p3 = (x2 + e3, y2 + e4)
  let n = calc.max(4, calc.min(24, int(calc.ceil(l / 10))))
  (_bez(p0, p1, p2, p3, n), st)
}

/// Rough double stroke of a polyline: a list of passes (usually two), each a point list.
#let rough-poly(pts, o, closed: false) = {
  let n = pts.len()
  if n < 2 { return () }
  let st = init(o.seed)
  let segs = ()
  for i in range(n - 1) { segs.push((pts.at(i), pts.at(i + 1))) }
  if closed and n > 2 { segs.push((pts.last(), pts.first())) }
  let pass1 = ()
  let pass2 = ()
  for (a, b) in segs {
    let (q, s1) = _line-pass(a, b, o, false, st)
    st = s1
    pass1 += q
    if not o.disable-multi-stroke {
      let (q2, s2) = _line-pass(a, b, o, true, st)
      st = s2
      pass2 += q2
    }
  }
  if o.disable-multi-stroke { (pass1,) } else { (pass1, pass2) }
}

// Catmull–Rom spline through points, sampled `sub` times per span
#let spline(pts, closed: false, sub: 4, tension: 0.0) = {
  let n = pts.len()
  if n < 3 { return pts }
  let k = (1 - tension) / 6
  let at(i) = if closed { pts.at(calc.rem-euclid(i, n)) } else { pts.at(calc.max(0, calc.min(n - 1, i))) }
  let out = ()
  let spans = if closed { n } else { n - 1 }
  for i in range(spans) {
    let (p0, p1, p2, p3) = (at(i - 1), at(i), at(i + 1), at(i + 2))
    let c1 = (p1.at(0) + (p2.at(0) - p0.at(0)) * k, p1.at(1) + (p2.at(1) - p0.at(1)) * k)
    let c2 = (p2.at(0) - (p3.at(0) - p1.at(0)) * k, p2.at(1) - (p3.at(1) - p1.at(1)) * k)
    let seg = _bez(p1, c1, c2, p2, sub)
    out += if i == 0 { seg } else { seg.slice(1) }
  }
  out
}

/// Rough ellipse: two slightly different, overlapping loops.
#let rough-ellipse(cx, cy, w, h, o) = {
  let rx = calc.abs(w) / 2
  let ry = calc.abs(h) / 2
  let st = init(o.seed)
  let psq = calc.sqrt(2 * calc.pi * calc.sqrt((rx * rx + ry * ry) / 2))
  let steps = int(calc.ceil(calc.max(o.curve-step-count, o.curve-step-count / calc.sqrt(200) * psq)))
  let incr = 2 * calc.pi / steps
  let fit = 1 - o.curve-fitting
  let (a, s1) = _jit(rx * fit, o, 1.0, st)
  let (b, s2) = _jit(ry * fit, o, 1.0, s1)
  st = s2
  rx += a
  ry += b
  let passes = ()
  for pass in range(if o.disable-multi-stroke { 1 } else { 2 }) {
    let off = if pass == 0 { 1.0 } else { 0.8 }
    let (r0, s3) = _jit(0.5, o, 1.0, st)
    st = s3
    let start = r0 - calc.pi / 2
    let ring = ()
    for k in range(steps + 3) {
      let th = start + k * incr
      let (ex, s4) = _jit(off, o, 1.0, st)
      let (ey, s5) = _jit(off, o, 1.0, s4)
      st = s5
      ring.push((cx + ex + rx * calc.cos(th), cy + ey + ry * calc.sin(th)))
    }
    passes.push(spline(ring, sub: 4))
  }
  passes
}

/// Rough open curve through the points.
#let rough-curve(pts, o) = {
  let n = pts.len()
  if n < 2 { return () }
  if n == 2 { return rough-poly(pts, o) }
  let st = init(o.seed)
  let passes = ()
  for pass in range(if o.disable-multi-stroke { 1 } else { 2 }) {
    let off = if pass == 0 { 1 * (1 + o.roughness * 0.2) } else { 1.5 * (1 + o.roughness * 0.22) }
    let q = ()
    for p in pts {
      let (ex, s1) = if o.preserve-vertices { (0.0, st) } else { _jit(off, o, 1.0, st) }
      let (ey, s2) = if o.preserve-vertices { (0.0, s1) } else { _jit(off, o, 1.0, s1) }
      st = s2
      q.push((p.at(0) + ex, p.at(1) + ey))
    }
    passes.push(spline(q, sub: calc.max(3, int(o.curve-step-count / 3)), tension: o.curve-tightness))
  }
  passes
}

/// Rough arc (angles in radians); `closed` adds the two radii of the pie wedge.
#let rough-arc(cx, cy, w, h, a0, a1, closed, o) = {
  let rx = calc.abs(w) / 2
  let ry = calc.abs(h) / 2
  let st = init(o.seed)
  let span = a1 - a0
  let steps = calc.max(int(calc.ceil(calc.abs(span) / (2 * calc.pi) * o.curve-step-count * 2)), 4)
  let passes = ()
  for pass in range(if o.disable-multi-stroke { 1 } else { 2 }) {
    let off = if pass == 0 { 1.0 } else { 0.8 }
    let q = ()
    for k in range(steps + 1) {
      let th = a0 + span * k / steps
      let (ex, s1) = _jit(off, o, 1.0, st)
      let (ey, s2) = _jit(off, o, 1.0, s1)
      st = s2
      q.push((cx + ex + rx * calc.cos(th), cy + ey + ry * calc.sin(th)))
    }
    if closed { q = ((cx, cy),) + q + ((cx, cy),) }
    passes.push(spline(q, sub: 3))
  }
  passes
}

// ---------------------------------------------------------------------------
//  Rough.js fill patterns: lists of polylines (dots: small closed polygons)
// ---------------------------------------------------------------------------
#let rough-fill(contours, style, angle, gap, seed) = {
  if contours.len() == 0 or gap <= 0 { return () }
  let lines = hatch(contours, angle: angle, spacing: gap)
  if style == "hachure" {
    lines.map(s => (s.at(0), s.at(1)))
  } else if style == "cross-hatch" {
    lines.map(s => (s.at(0), s.at(1))) + hatch(contours, angle: angle + 90, spacing: gap).map(s => (s.at(0), s.at(1)))
  } else if style == "zigzag" {
    // consecutive hatch lines joined end to end
    let out = ()
    let cur = ()
    let flip = false
    for s in lines {
      let (a, b) = if flip { (s.at(1), s.at(0)) } else { (s.at(0), s.at(1)) }
      cur += (a, b)
      flip = not flip
    }
    if cur.len() > 1 { out.push(cur) }
    out
  } else if style == "dashed" {
    let out = ()
    let dash = gap * 1.2
    let space = gap * 0.7
    for s in lines {
      let (a, b) = s
      let l = _len(a, b)
      let ux = (b.at(0) - a.at(0)) / calc.max(l, 1e-9)
      let uy = (b.at(1) - a.at(1)) / calc.max(l, 1e-9)
      let t = 0.0
      while t < l {
        let t2 = calc.min(t + dash, l)
        out.push(((a.at(0) + ux * t, a.at(1) + uy * t), (a.at(0) + ux * t2, a.at(1) + uy * t2)))
        t += dash + space
      }
    }
    out
  } else if style == "zigzag-line" {
    let out = ()
    let amp = gap / 3
    for s in lines {
      let (a, b) = s
      let l = _len(a, b)
      let ux = (b.at(0) - a.at(0)) / calc.max(l, 1e-9)
      let uy = (b.at(1) - a.at(1)) / calc.max(l, 1e-9)
      let m = calc.max(int(calc.ceil(l / (gap / 2))), 1)
      let q = ()
      for k in range(m + 1) {
        let t = k / m * l
        let sgn = if calc.rem(k, 2) == 0 { 1 } else { -1 }
        let d = if k == 0 or k == m { 0 } else { sgn * amp }
        q.push((a.at(0) + ux * t - uy * d, a.at(1) + uy * t + ux * d))
      }
      out.push(q)
    }
    out
  } else if style == "dots" {
    let out = ()
    let r = gap * 0.14
    for s in lines {
      let (a, b) = s
      let l = _len(a, b)
      let ux = (b.at(0) - a.at(0)) / calc.max(l, 1e-9)
      let uy = (b.at(1) - a.at(1)) / calc.max(l, 1e-9)
      let t = gap / 2
      while t < l {
        let c = (a.at(0) + ux * t, a.at(1) + uy * t)
        out.push(range(8).map(i => (c.at(0) + r * calc.cos(i * 45deg), c.at(1) + r * calc.sin(i * 45deg))))
        t += gap
      }
    }
    out
  } else if style == "sunburst" {
    // rays from the centre of the outline, clipped by the contours
    let c0 = contours.first()
    let xs = c0.map(p => p.at(0))
    let ys = c0.map(p => p.at(1))
    let cx = (calc.min(..xs) + calc.max(..xs)) / 2
    let cy = (calc.min(..ys) + calc.max(..ys)) / 2
    let R = calc.sqrt(calc.pow(calc.max(..xs) - calc.min(..xs), 2) + calc.pow(calc.max(..ys) - calc.min(..ys), 2)) / 2
    let nr = calc.max(int(calc.ceil(2 * calc.pi * R / 2 / gap)), 8)
    let out = ()
    for k in range(nr) {
      let th = k / nr * 2 * calc.pi
      let (dx, dy) = (calc.cos(th), calc.sin(th))
      // intersections of the ray with all edges
      let ts = ()
      for ct in contours {
        let m = ct.len()
        for i in range(m) {
          let p = ct.at(i)
          let q = ct.at(calc.rem(i + 1, m))
          let (ex, ey) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
          let den = dx * ey - dy * ex
          if calc.abs(den) < 1e-12 { continue }
          let t = ((p.at(0) - cx) * ey - (p.at(1) - cy) * ex) / den
          let u = ((p.at(0) - cx) * dy - (p.at(1) - cy) * dx) / den
          if t >= 0 and u >= 0 and u < 1 { ts.push(t) }
        }
      }
      ts = ts.sorted()
      let j = 0
      // the centre is inside the outline: the first segment starts at 0
      let ts2 = (0.0,) + ts
      while j + 1 < ts2.len() {
        out.push(((cx + dx * ts2.at(j), cy + dy * ts2.at(j)), (cx + dx * ts2.at(j + 1), cy + dy * ts2.at(j + 1))))
        j += 2
      }
    }
    out
  } else {
    lines.map(s => (s.at(0), s.at(1)))
  }
}
