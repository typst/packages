// Sampling functions and clipping curves to the visible window.

// A number we can draw: not none, not nan, not infinite.
#let finite(v) = type(v) in (int, float) and v == v and calc.abs(v) != float.inf

// f(x) as a float, or none where f is undefined (f returned none, nan or inf).
#let value-at(f, x, who) = {
  let y = f(x)
  if y == none or (type(y) in (int, float) and not finite(y)) { return none }
  assert(type(y) in (int, float), message: "quadrille: " + who + ": the function returned "
    + repr(y) + " at " + str(x) + " - it must return a number, or none where it is undefined")
  float(y)
}

// n + 1 evenly spaced values from a to b, or every `step` from a when a step is given.
#let spaced(a, b, step, n) = {
  if step != auto {
    assert(type(step) in (int, float) and step > 0, message: "quadrille: step must be a positive number, got " + repr(step))
    let k = calc.floor((b - a) / step + 1e-9)
    let xs = range(k + 1).map(i => a + i * step)
    if b - xs.last() > step * 1e-6 { xs.push(b) }
    xs
  } else {
    range(n + 1).map(i => a + (b - a) * i / n)
  }
}

// Samples y = f(x) as a list of points, with none marking a gap: where f is
// undefined, and at jumps such as tan(x) crossing pi/2 (so no vertical line is
// drawn there). `span` is the visible height, used to recognise a jump.
#let sample-fn(f, xs, span, who) = {
  let out = ()
  let prev = none
  for x in xs {
    let y = value-at(f, x, who)
    if prev != none and y != none and calc.abs(y - prev.at(1)) > span {
      // A continuous piece passes between its end values somewhere in the middle;
      // across a pole it doesn't. (Off-centre so we don't land on the pole itself.)
      let m = value-at(f, prev.at(0) + (x - prev.at(0)) * 0.4839, who)
      let (lo, hi) = (calc.min(y, prev.at(1)), calc.max(y, prev.at(1)))
      if m == none or m < lo - span or m > hi + span { out.push(none) }
    }
    out.push(if y == none { none } else { (x, y) })
    prev = if y == none { none } else { (x, y) }
  }
  out
}

// Liang-Barsky: the part of segment p-q inside rect (x0, x1, y0, y1), as
// (start, end, starts-at-p, ends-at-q), or none when it is all outside.
#let clip-segment(p, q, rect) = {
  let (x0, y0) = p
  let (dx, dy) = (q.at(0) - x0, q.at(1) - y0)
  let (t0, t1) = (0.0, 1.0)
  for (pp, qq) in ((-dx, x0 - rect.at(0)), (dx, rect.at(1) - x0), (-dy, y0 - rect.at(2)), (dy, rect.at(3) - y0)) {
    if pp == 0 {
      if qq < 0 { return none }
    } else {
      let t = qq / pp
      if pp < 0 {
        if t > t1 { return none }
        if t > t0 { t0 = t }
      } else {
        if t < t0 { return none }
        if t < t1 { t1 = t }
      }
    }
  }
  ((x0 + t0 * dx, y0 + t0 * dy), (x0 + t1 * dx, y0 + t1 * dy), t0 == 0.0, t1 == 1.0)
}

// Splits a point list (none = gap) into the connected runs that are inside rect.
#let visible-runs(pts, rect) = {
  let runs = ()
  let cur = ()
  for i in range(calc.max(0, pts.len() - 1)) {
    let (p, q) = (pts.at(i), pts.at(i + 1))
    let c = if p == none or q == none { none }
      else if (p.at(0) >= rect.at(0) and p.at(0) <= rect.at(1) and p.at(1) >= rect.at(2) and p.at(1) <= rect.at(3)
        and q.at(0) >= rect.at(0) and q.at(0) <= rect.at(1) and q.at(1) >= rect.at(2) and q.at(1) <= rect.at(3)) {
        (p, q, true, true)       // all inside: the usual case
      } else { clip-segment(p, q, rect) }
    if c == none {
      if cur.len() > 1 { runs.push(cur) }
      cur = ()
      continue
    }
    let (a, b, from-p, to-q) = c
    if cur.len() == 0 or not from-p {
      if cur.len() > 1 { runs.push(cur) }
      cur = (a,)
    }
    cur.push(b)
    if not to-q {
      runs.push(cur)
      cur = ()
    }
  }
  if cur.len() > 1 { runs.push(cur) }
  runs
}

// The range of values, ignoring the few extreme ones near a pole (1/x at 0.001)
// so that an automatic y range still shows the shape of the curve.
#let robust-range(vs) = {
  if vs.len() == 0 { return none }
  let s = vs.sorted()
  let (lo, hi) = (s.first(), s.last())
  if s.len() >= 20 {
    let (q-lo, q-hi) = (s.at(int(s.len() * 0.03)), s.at(int(s.len() * 0.97)))
    if hi - lo > 8 * (q-hi - q-lo) and q-hi > q-lo {
      let pad = (q-hi - q-lo) * 0.25
      return (q-lo - pad, q-hi + pad)
    }
  }
  (lo, hi)
}
