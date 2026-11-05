// nibart — the "art" layer: knots & links, calligraphic decorations, path surgery.
//
// Everything here is built on the geometry engine of `core.typ` (Hobby splines, pens, intersections…).
// The ideas come from the LaTeX packages `spath3` / `knots` / `calligraphy` (A. Stacey); this is an independent
// implementation for Typst, sharing no code with them.
//
// Conventions as in core.typ: y points UP; positions are Typst lengths; angles are Typst angles (or degrees).
#import "core.typ": *
#import "core.typ": _op, _pt, _rad, _pl

// ───────────────────────────────────────────────────────────────── small helpers (pt floats inside)
#let _pts(p) = (p.segs.first().at(0), p.segs.first().at(1))
#let _pte(p) = (p.segs.last().at(6), p.segs.last().at(7))
#let _unit(v) = { let n = calc.sqrt(v.at(0) * v.at(0) + v.at(1) * v.at(1)); if n < 1e-12 { (1.0, 0.0) } else { (v.at(0) / n, v.at(1) / n) } }
#let _seg-line(a, b) = {
  let l(u) = (a.at(0) + (b.at(0) - a.at(0)) * u, a.at(1) + (b.at(1) - a.at(1)) * u)
  (a.at(0), a.at(1), l(1 / 3).at(0), l(1 / 3).at(1), l(2 / 3).at(0), l(2 / 3).at(1), b.at(0), b.at(1))
}
#let _seg-cub(a, b, c, d) = (a.at(0), a.at(1), b.at(0), b.at(1), c.at(0), c.at(1), d.at(0), d.at(1))
#let _mk(segs, cycle: false) = (segs: segs, cycle: cycle)
#let _len(p) = _op(p, "arclength")
/// Time (segment index + fraction) at arc length `s` (pt, number); on closed paths `s` may fall outside [0, L]
/// (the time then falls outside [0, n], which `subpath` understands).
#let _time-at(p, s, L) = {
  let n = p.segs.len()
  if p.cycle {
    if s < 0 { arctime(p, s + L) - n } else if s > L { arctime(p, s - L) + n } else if s == L { float(n) } else { arctime(p, s) }
  } else if s <= 0 { 0.0 } else if s >= L { float(n) } else { arctime(p, s) }
}
/// Arc length (pt) at time `t`.
#let _arc-at(p, t) = if t <= 1e-9 { 0.0 } else { _len(subpath(p, 0, t)) }

// ───────────────────────────────────────────────────────────────── path surgery
/// Remove `start` from the beginning and `end` from the end of an open path (lengths).
#let shorten(p, start: 0pt, end: 0pt) = {
  let L = _len(p)
  let (a, b) = (_pt(start), L - _pt(end))
  if b <= a { panic("nibart: shorten removes more than the whole path") }
  subpath(p, _time-at(p, a, L), _time-at(p, b, L))
}

/// Cut a path at the given times. Open path: `n + 1` pieces; closed path: `n` pieces (the last one wraps around).
#let split-at(p, times) = {
  let n = p.segs.len()
  let ts = times.sorted()
  if p.cycle {
    if ts.len() == 0 { return (p,) }
    let ts2 = ts + (ts.first() + n,)
    ts2.windows(2).map(w => subpath(p, w.first(), w.last()))
  } else {
    let ts2 = (0.0,) + ts + (float(n),)
    ts2.windows(2).filter(w => w.last() - w.first() > 1e-9).map(w => subpath(p, w.first(), w.last()))
  }
}

/// Remove arc-length intervals `((a, b), …)` (lengths or pt numbers) from a path and return the remaining pieces.
/// On closed paths the intervals may wrap around the start and the seam piece is welded back together.
#let remove-intervals(p, ivs, min-piece: 0.05pt) = {
  let L = _len(p)
  let cyc = p.cycle
  let n = p.segs.len()
  let norm = ()
  for iv in ivs {
    let (a, b) = (_pt(iv.at(0)), _pt(iv.at(1)))
    if b < a { (a, b) = (b, a) }
    if cyc {
      if b - a >= L { return () }
      let a2 = calc.rem(calc.rem(a, L) + L, L)
      let b2 = a2 + (b - a)
      if b2 > L { norm.push((a2, L)); norm.push((0.0, b2 - L)) } else { norm.push((a2, b2)) }
    } else if b > 0 and a < L { norm.push((calc.max(a, 0.0), calc.min(b, L))) }
  }
  if norm.len() == 0 { return (p,) }
  norm = norm.sorted(key: v => v.at(0))
  let merged = ()
  for iv in norm {
    if merged.len() > 0 and iv.at(0) <= merged.last().at(1) + 1e-9 { merged.last() = (merged.last().at(0), calc.max(merged.last().at(1), iv.at(1))) } else { merged.push(iv) }
  }
  // complement on [0, L]
  let keep = ()
  let cur = 0.0
  for iv in merged {
    if iv.at(0) > cur + 1e-9 { keep.push((cur, iv.at(0))) }
    cur = iv.at(1)
  }
  if cur < L - 1e-9 { keep.push((cur, L)) }
  if keep.len() == 0 { return () }
  let pieces = keep.map(k => subpath(p, _time-at(p, k.at(0), L), _time-at(p, k.at(1), L)))
  if cyc and keep.first().at(0) < 1e-9 and keep.last().at(1) > L - 1e-9 and keep.len() > 1 {
    let w = path-join-all((pieces.last(), pieces.first()))
    pieces = pieces.slice(1, pieces.len() - 1) + (w,)
  }
  pieces.filter(q => _len(q) > _pt(min-piece))
}

/// Gaps around given times: remove an interval of half-length `half` (arc length) around each time of `times`.
#let gap-at(p, times, half) = {
  let L = _len(p)
  let hs = if type(half) == array { half } else { (half,) * times.len() }
  remove-intervals(p, times.enumerate().map(((i, t)) => { let s = _arc-at(p, t); let h = _pt(hs.at(i)); (s - h, s + h) }))
}

/// Join a list of open paths end to end when the end of one lies within `tol` of the start of the next.
#let weld(paths, tol: 0.05pt) = {
  let out = ()
  for q in paths {
    if out.len() > 0 {
      let (e, s) = (_pte(out.last()), _pts(q))
      if calc.sqrt(calc.pow(e.at(0) - s.at(0), 2) + calc.pow(e.at(1) - s.at(1), 2)) <= _pt(tol) {
        out.last() = path-join-all((out.last(), q)); continue
      }
    }
    out.push(q)
  }
  out
}

/// Similarity transformation (rotation + uniform scale + translation) that maps the start of `p` to `a` and its end to `b`.
#let fit-between(p, a, b) = {
  let (s0, s1) = (_pts(p), _pte(p))
  let d = (s1.at(0) - s0.at(0), s1.at(1) - s0.at(1))
  let e = (_pt(b.at(0)) - _pt(a.at(0)), _pt(b.at(1)) - _pt(a.at(1)))
  let den = d.at(0) * d.at(0) + d.at(1) * d.at(1)
  if den < 1e-12 { panic("nibart: fit-between needs a path whose endpoints differ") }
  let A = (e.at(0) * d.at(0) + e.at(1) * d.at(1)) / den
  let B = (e.at(1) * d.at(0) - e.at(0) * d.at(1)) / den
  let tx = _pt(a.at(0)) - (A * s0.at(0) - B * s0.at(1))
  let ty = _pt(a.at(1)) - (B * s0.at(0) + A * s0.at(1))
  transformed(p, A, B, -B, A, e: tx * 1pt, f: ty * 1pt)
}

/// Join the end of `a` to the start of `b` with a smooth (Hobby) curve that leaves `a` and enters `b` along their tangents.
#let join-smooth(a, b, tension: 1) = {
  let (e, s) = (_pte(a), _pts(b))
  let da = _unit(direction-of(a, a.segs.len()))
  let db = _unit(direction-of(b, 0))
  let f(v) = str(calc.round(v, digits: 5))
  let t = if tension == 1 { ".." } else { "..tension " + str(tension) + ".." }
  let c = mp-path("(" + f(e.at(0)) + "," + f(e.at(1)) + "){" + f(da.at(0)) + "," + f(da.at(1)) + "}" + t + "{" + f(db.at(0)) + "," + f(db.at(1)) + "}(" + f(s.at(0)) + "," + f(s.at(1)) + ")")
  path-join-all((a, c, b))
}

/// Close an open path with a smooth curve from its end back to its start, matching both tangents.
#let close-smooth(p, tension: 1) = {
  let (e, s) = (_pte(p), _pts(p))
  let da = _unit(direction-of(p, p.segs.len()))
  let db = _unit(direction-of(p, 0))
  let f(v) = str(calc.round(v, digits: 5))
  let t = if tension == 1 { ".." } else { "..tension " + str(tension) + ".." }
  let c = mp-path("(" + f(e.at(0)) + "," + f(e.at(1)) + "){" + f(da.at(0)) + "," + f(da.at(1)) + "}" + t + "{" + f(db.at(0)) + "," + f(db.at(1)) + "}(" + f(s.at(0)) + "," + f(s.at(1)) + ")")
  path-join-all((p, c), cycle: true)
}

/// Polygon with rounded corners (circular arcs of radius `r`, reduced where the sides are too short).
/// `pts`: corners (lengths); `r`: a length or an array (one radius per corner).
#let round-corners(pts, r: 4pt, cycle: false) = {
  let P = pts.map(q => (_pt(q.at(0)), _pt(q.at(1))))
  let n = P.len()
  let rs = if type(r) == array { r.map(_pt) } else { (_pt(r),) * n }
  let dist(a, b) = calc.sqrt(calc.pow(a.at(0) - b.at(0), 2) + calc.pow(a.at(1) - b.at(1), 2))
  // for each corner: entry point, exit point, handle length, unit vectors
  let info = ()
  for i in range(n) {
    let corner = (cycle or (i > 0 and i < n - 1))
    if not corner { info.push(none); continue }
    let (pp, pc, pn) = (P.at(calc.rem(i + n - 1, n)), P.at(i), P.at(calc.rem(i + 1, n)))
    let u = _unit((pp.at(0) - pc.at(0), pp.at(1) - pc.at(1)))
    let v = _unit((pn.at(0) - pc.at(0), pn.at(1) - pc.at(1)))
    let dot = calc.max(-1.0, calc.min(1.0, u.at(0) * v.at(0) + u.at(1) * v.at(1)))
    let phi = calc.acos(dot)
    if phi.rad() > 3.14159 - 1e-4 or phi.rad() < 1e-4 { info.push(none); continue }
    let tn = calc.tan(phi / 2)
    let lim = calc.min(dist(pp, pc) / (if cycle or i > 1 { 2 } else { 1 }), dist(pn, pc) / (if cycle or i < n - 2 { 2 } else { 1 }))
    let d = calc.min(rs.at(i) / tn, lim)
    let rr = d * tn
    let tau = calc.pi - phi.rad()
    let h = 4 / 3 * calc.tan(tau / 4 * 1rad) * rr
    info.push((a: (pc.at(0) + u.at(0) * d, pc.at(1) + u.at(1) * d), b: (pc.at(0) + v.at(0) * d, pc.at(1) + v.at(1) * d), u: u, v: v, h: h))
  }
  let segs = ()
  let cur = if info.at(0) == none { P.at(0) } else { info.at(0).b }
  let order = if cycle { range(1, n + 1) } else { range(1, n) }
  for k in order {
    let i = calc.rem(k, n)
    let inf = info.at(i)
    if inf == none {
      segs.push(_seg-line(cur, P.at(i))); cur = P.at(i)
    } else {
      segs.push(_seg-line(cur, inf.a))
      let c1 = (inf.a.at(0) - inf.u.at(0) * inf.h, inf.a.at(1) - inf.u.at(1) * inf.h)
      let c2 = (inf.b.at(0) - inf.v.at(0) * inf.h, inf.b.at(1) - inf.v.at(1) * inf.h)
      segs.push(_seg-cub(inf.a, c1, c2, inf.b)); cur = inf.b
    }
  }
  _mk(segs, cycle: cycle)
}

/// Parallel curve at signed distance `d` from `p` (positive: to the LEFT of the direction of travel). Pieces are
/// joined by straight bevels; on closed paths the result is closed. `tol`: approximation accuracy.
#let offset(p, d, tol: 0.02pt) = _op(p, "offset", args: (_pt(d), _pt(tol)))

/// Self-intersections of a path: array of time pairs `(t1, t2)` with `t1 < t2`.
#let self-intersections(p) = _op(p, "self_intersections")

/// Position and direction at time `t`: `(pos: (x, y), angle: Angle)`.
#let frame-at(p, t) = (pos: point-of(p, t), angle: direction-angle(p, t))
/// Place a path drawn in a local frame (x along the tangent, y to the left) into the frame `fr` given by `frame-at`.
#let in-frame(q, fr, scale: 1) = {
  let (c, s) = (calc.cos(fr.angle) * scale, calc.sin(fr.angle) * scale)
  transformed(q, c, s, -s, c, e: fr.pos.at(0), f: fr.pos.at(1))
}
/// Frames regularly spaced along a path: `count` of them (from `start` to `end`, lengths from the ends; on closed paths
/// evenly around the loop) or one every `step`.
#let frames-along(p, count: none, step: none, start: 0pt, end: 0pt) = {
  let L = _len(p)
  let (a, b) = (_pt(start), L - _pt(end))
  let cyc = p.cycle
  let ss = if step != none {
    let k = calc.floor((b - a) / _pt(step) + 1e-9)
    range(k + 1).map(i => a + i * _pt(step))
  } else if cyc {
    range(count).map(i => a + (b - a) * i / count)
  } else if count == 1 { ((a + b) / 2,) } else { range(count).map(i => a + (b - a) * i / (count - 1)) }
  ss.map(s => frame-at(p, _time-at(p, s, L)))
}

// ───────────────────────────────────────────────────────────────── knots & links
/// Crossings of a set of strands (including self-intersections), as `(a: (strand, t), b: (strand, t))`.
#let crossings(strands) = {
  let strands = if type(strands) == array { strands } else { (strands,) }
  let out = ()
  for i in range(strands.len()) {
    for j in range(i + 1, strands.len()) {
      for r in intersection-times(strands.at(i), strands.at(j)) { out.push((a: (i, r.at(0)), b: (j, r.at(1)))) }
    }
    for r in self-intersections(strands.at(i)) { out.push((a: (i, r.at(0)), b: (i, r.at(1)))) }
  }
  out
}

#let _band(p, w, fill, outline, outline-fill) = {
  let out = ()
  if outline != none { out += stroke-items(p, pen: pencircle(w + 2 * outline), fill: outline-fill) }
  out += stroke-items(p, pen: pencircle(w), fill: fill)
  out
}

/// Interlaced strands (knots, links, braids, Celtic work).
///
/// - `strands`: a path, or an array of paths (open or closed); crossings — between strands and within a strand — are
///   found automatically. Crossings are numbered in order of first encounter (walking the strands in order).
/// - `style`: `"gap"` — the under-strand is interrupted (classic knot diagram); `"weave"` — every strand is a ribbon with an
///   outline and the over-strand is redrawn on top at each crossing (Celtic interlace; needs `outline`).
/// - `rule`: `"alternate"` (alternating diagram: over, under, over… along every strand) or `"first"`
///   (strand of lower index passes over; within one strand, the later passage).
/// - `flips`: numbers of the crossings to invert. `draft: true` prints the crossing numbers.
/// - `width`, `fill`: length / colour, or arrays (one per strand); `outline` (length) and `outline-fill`; `gap`: clearance on each side of a
///   gap (style "gap"), default = 0.6 × width.
#let knot(strands, style: "gap", rule: "alternate", width: 4pt, fill: black, outline: none, outline-fill: black,
    gap: auto, flips: (), draft: false, draft-size: 7pt) = {
  assert(style in ("gap", "weave"), message: "nibart: knot style must be \"gap\" or \"weave\"")
  assert(rule in ("alternate", "first"), message: "nibart: knot rule must be \"alternate\" or \"first\"")
  let S = if type(strands) == array { strands } else { (strands,) }
  let pick(v, i) = if type(v) == array { v.at(calc.rem(i, v.len())) } else { v }
  let W = range(S.len()).map(i => _pt(pick(width, i)))
  let OL = if outline == none { 0.0 } else { _pt(outline) }
  let style = if style == "weave" and outline == none { "gap" } else { style }
  let cs = crossings(S)
  let n = cs.len()
  // ── numbering and over/under
  // Crossings are numbered in order of first encounter. Over/under: every passage of a strand alternates and the two
  // passages of one crossing are opposite — a 2-colouring of the "passage graph" (always possible for closed strands).
  let num = (none,) * n
  let counter = 1
  let vis = ()          // passages: (strand, t, crossing, branch)
  let by-strand = ()
  for i in range(S.len()) {
    let v = ()
    for (k, c) in cs.enumerate() {
      if c.a.at(0) == i { v.push((c.a.at(1), k, "a")) }
      if c.b.at(0) == i { v.push((c.b.at(1), k, "b")) }
    }
    v = v.sorted(key: q => q.at(0))
    let ids = ()
    for (t, k, br) in v {
      if num.at(k) == none { num.at(k) = counter; counter += 1 }
      ids.push(vis.len()); vis.push((i, t, k, br))
    }
    by-strand.push(ids)
  }
  let over = (none,) * n
  if rule == "first" {
    for k in range(n) { over.at(k) = if cs.at(k).a.at(0) != cs.at(k).b.at(0) { "a" } else { "b" } }
  } else {
    let adj = range(vis.len()).map(_ => ())
    for ids in by-strand { for w in ids.windows(2) { adj.at(w.first()).push(w.last()); adj.at(w.last()).push(w.first()) } }
    let first-of = (none,) * n
    for (v, q) in vis.enumerate() { if first-of.at(q.at(2)) == none { first-of.at(q.at(2)) = v } else { adj.at(v).push(first-of.at(q.at(2))); adj.at(first-of.at(q.at(2))).push(v) } }
    let col = (none,) * vis.len()
    for v0 in range(vis.len()) {
      if col.at(v0) != none { continue }
      col.at(v0) = 0
      let stack = (v0,)
      while stack.len() > 0 {
        let v = stack.pop()
        for w in adj.at(v) { if col.at(w) == none { col.at(w) = 1 - col.at(v); stack.push(w) } }
      }
    }
    for (v, q) in vis.enumerate() { if col.at(v) == 0 and over.at(q.at(2)) == none { over.at(q.at(2)) = q.at(3) } }
    for k in range(n) { if over.at(k) == none { over.at(k) = "a" } }
  }
  for k in range(n) { if flips.contains(num.at(k)) { over.at(k) = if over.at(k) == "a" { "b" } else { "a" } } }
  // ── geometry of each crossing
  let info = ()
  for (k, c) in cs.enumerate() {
    let (sa, sb) = (S.at(c.a.at(0)), S.at(c.b.at(0)))
    let da = _unit(direction-of(sa, c.a.at(1)))
    let db = _unit(direction-of(sb, c.b.at(1)))
    let sn = calc.max(calc.abs(da.at(0) * db.at(1) - da.at(1) * db.at(0)), 0.25)
    let ov = over.at(k)
    let (o, u) = if ov == "a" { (c.a, c.b) } else { (c.b, c.a) }
    info.push((over: o, under: u, sn: sn, num: num.at(k)))
  }
  let items = ()
  if style == "gap" {
    for (i, s) in S.enumerate() {
      let ivs = ()
      for inf in info {
        if inf.under.at(0) == i {
          let wo = W.at(inf.over.at(0)) + 2 * OL
          let g = if gap == auto { 0.6 * W.at(i) } else { _pt(gap) }
          let half = (wo / 2 + g) / inf.sn
          let sc = _arc-at(s, inf.under.at(1))
          ivs.push((sc - half, sc + half))
        }
      }
      for piece in remove-intervals(s, ivs) {
        items += _band(piece, W.at(i) * 1pt, pick(fill, i), if OL > 0 { OL * 1pt } else { none }, pick(outline-fill, i))
      }
    }
  } else {
    // full ribbons first
    for (i, s) in S.enumerate() {
      items += _band(s, W.at(i) * 1pt, pick(fill, i), OL * 1pt, pick(outline-fill, i))
    }
    // then redraw the over-strand around every crossing
    for inf in info {
      let (i, t) = inf.over
      let s = S.at(i)
      let L = _len(s)
      let sc = _arc-at(s, t)
      let wu = W.at(inf.under.at(0)) + 2 * OL
      let R = (wu / 2 + 0.6) / inf.sn + 0.3
      let R2 = R + 2 * OL + 0.8
      let piece(r) = subpath(s, _time-at(s, sc - r, L), _time-at(s, sc + r, L))
      // outer piece, then inner piece slightly longer (hides the round cap of the outer one)
      items += stroke-items(piece(R), pen: pencircle((W.at(i) + 2 * OL) * 1pt), fill: pick(outline-fill, i))
      items += stroke-items(piece(R2), pen: pencircle(W.at(i) * 1pt), fill: pick(fill, i))
    }
  }
  if draft {
    for (i, s) in S.enumerate() { items.push(mp-skeleton(s, stroke: 0.3pt + red)) }
    for (k, c) in cs.enumerate() {
      items.push(mp-label(text(size: draft-size, fill: red, weight: "bold")[#num.at(k)], point-of(S.at(c.a.at(0)), c.a.at(1))))
    }
  }
  items
}

// ───────────────────────────────────────────────────────────────── calligraphic pens & decorations
/// Stroke with a *pointed pen*: thin on the upstrokes, thick on the downstrokes (as in copperplate / roundhand).
/// - `light`, `heavy`: hairline and shade widths. `slant`: direction of the shading axis (default: vertical).
/// - `sharpness`: > 1 confines the shade to strokes closer to the axis. `taper`: `none`, `"start"`, `"end"`, `"both"`
///   (hairline entry/exit strokes over a length `taper-length`). `step`: sampling distance.
#let copperplate(p, light: 0.4pt, heavy: 2.4pt, slant: 90deg, sharpness: 1.0, taper: "both", taper-length: 6pt,
    step: 1.5pt, fill: black, outline: none) = {
  let L = _len(p)
  let k = calc.max(4, calc.ceil(L / _pt(step)))
  let th = _rad(slant)
  let (lw, hw, tl) = (_pt(light), _pt(heavy), _pt(taper-length))
  let stops = ()
  for i in range(k + 1) {
    let s = L * i / k
    let t = _time-at(p, s, L)
    let d = _unit(direction-of(p, t))
    let dot = -(d.at(0) * calc.cos(th) + d.at(1) * calc.sin(th))
    let w = lw + (hw - lw) * calc.pow(calc.max(0.0, dot), sharpness)
    let f = 1.0
    if taper in ("start", "both") and s < tl { let u = s / tl; f = calc.min(f, 0.15 + 0.85 * u * u * (3 - 2 * u)) }
    if taper in ("end", "both") and L - s < tl { let u = (L - s) / tl; f = calc.min(f, 0.15 + 0.85 * u * u * (3 - 2 * u)) }
    stops.push((at: s * 1pt, width: calc.max(w * f, 0.05) * 1pt, thinness: 100%, angle: 0deg))
  }
  stroke-items(p, pen: nibpen(..stops, follow: false), fill: fill, refine: 1, outline: outline)
}

/// A stroke drawn with several parallel "prongs" (split nib / engraver's pen): one thin line per offset in `offsets`
/// (lengths, positive = left of travel).
#let prongs(p, offsets, width: 0.6pt, fill: black, tol: 0.02pt) = {
  let out = ()
  for d in offsets {
    let q = if _pt(d) == 0 { p } else { offset(p, d, tol: tol) }
    out += stroke-items(q, pen: pencircle(width), fill: fill)
  }
  out
}

/// Path of a calligraphic brace from (0,0) to (length,0), bulging to y > 0 with its tip at `amplitude`.
#let brace-path(length, amplitude) = {
  let (L, A) = (_pt(length), _pt(amplitude))
  let m = L / 2
  let pt(x, y) = (x, y)
  let segs = (
    _seg-cub((0.0, 0.0), (0.15 * A, 0.3 * A), (0.5 * A, 0.5 * A), (A, 0.5 * A)),
    _seg-line((A, 0.5 * A), (m - A, 0.5 * A)),
    _seg-cub((m - A, 0.5 * A), (m - 0.5 * A, 0.5 * A), (m - 0.15 * A, 0.7 * A), (m, A)),
    _seg-cub((m, A), (m + 0.15 * A, 0.7 * A), (m + 0.5 * A, 0.5 * A), (m + A, 0.5 * A)),
    _seg-line((m + A, 0.5 * A), (L - A, 0.5 * A)),
    _seg-cub((L - A, 0.5 * A), (L - 0.5 * A, 0.5 * A), (L - 0.15 * A, 0.3 * A), (L, 0.0)),
  )
  _mk(segs)
}

/// Path of a parenthesis-like arc from (0,0) to (length,0), bulging to y > 0 by `amplitude`.
/// `straight: true`: curved ends joined by a straight middle (like a long bracket-paren).
#let paren-path(length, amplitude, straight: false) = {
  let (L, A) = (_pt(length), _pt(amplitude))
  if straight {
    let e = calc.min(3.333 * A, L / 2)
    let k = e / 3.333
    let segs = (
      _seg-cub((0.0, 0.0), (0.766 * k, 0.643 * k), (2.333 * k, k), (e, k)),
      _seg-line((e, k), (L - e, k)),
      _seg-cub((L - e, k), (L - 2.333 * k, k), (L - 0.766 * k, 0.643 * k), (L, 0.0)),
    )
    _mk(segs)
  } else {
    mp-path("(0,0){dir 62}..(" + str(L / 2) + "," + str(A) + ")..{dir -62}(" + str(L) + ",0)")
  }
}

/// Calligraphic brace or parenthesis between two points `a` and `b`, bulging to the left of `a → b`
/// (`flip: true` for the other side). `kind`: `"brace"`, `"paren"` or `"paren-straight"`.
/// Returns stroke items (pen widths `light` at the ends and `heavy` where the curve swells).
#let delimiter(a, b, kind: "brace", amplitude: 6pt, flip: false, light: 0.4pt, heavy: 1.8pt, fill: black) = {
  let (ax, ay, bx, by) = (_pt(a.at(0)), _pt(a.at(1)), _pt(b.at(0)), _pt(b.at(1)))
  let L = calc.sqrt(calc.pow(bx - ax, 2) + calc.pow(by - ay, 2))
  let loc = if kind == "brace" { brace-path(L * 1pt, amplitude) } else if kind == "paren" { paren-path(L * 1pt, amplitude) } else { paren-path(L * 1pt, amplitude, straight: true) }
  let loc = if flip { yscaled(loc, -1) } else { loc }
  let q = fit-between(loc, a, b)
  let stops = if kind == "brace" {
    ((at: 0%, width: light), (at: 22%, width: heavy), (at: 50%, width: light), (at: 78%, width: heavy), (at: 100%, width: light))
  } else if kind == "paren" { ((at: 0%, width: light), (at: 50%, width: heavy), (at: 100%, width: light)) }
  else { ((at: 0%, width: light), (at: 12%, width: heavy), (at: 88%, width: heavy), (at: 100%, width: light)) }
  let stops = stops.map(s => (at: s.at, width: s.width, thinness: 100%, angle: 0deg))
  stroke-items(q, pen: nibpen(..stops), fill: fill, refine: 6)
}
