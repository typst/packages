// nibridge.typ — the bridge between solids3d and nibart.
//
// solids3d works with projected 2D paths in *user units* (floats, y up);
// nibart works with Bézier paths in *points* (y up) and computes pen envelopes,
// dashes, pressure, variable nibs, knot gaps, … This file converts back and forth.
//
// Everything that needs the geometry of a pen stroke in solids3d goes through here
// (pencil / vintage / engraving styles, knots, braces).

#import "@preview/nibart:0.3.0" as nib

// ── conversions ────────────────────────────────────────────────────────────────

// path2 ((kind: "path", nodes, pre, post, straight, cyclic), user units) → nibart path (pt).
// `k` = points per user unit.
#let to-nib(p, k) = {
  let n = p.nodes.len()
  let cnt = if p.cyclic { n } else { calc.max(n - 1, 0) }
  let segs = ()
  for i in range(cnt) {
    let j = if p.cyclic { calc.rem-euclid(i + 1, n) } else { i + 1 }
    let a = p.nodes.at(i)
    let d = p.nodes.at(j)
    let (b, c) = if p.straight.at(i, default: false) {
      ((a.at(0) + (d.at(0) - a.at(0)) / 3, a.at(1) + (d.at(1) - a.at(1)) / 3),
       (a.at(0) + 2 * (d.at(0) - a.at(0)) / 3, a.at(1) + 2 * (d.at(1) - a.at(1)) / 3))
    } else { (p.post.at(i), p.pre.at(j)) }
    segs.push((a.at(0) * k, a.at(1) * k, b.at(0) * k, b.at(1) * k, c.at(0) * k, c.at(1) * k, d.at(0) * k, d.at(1) * k))
  }
  (segs: segs, cycle: p.cyclic)
}

// polyline of user-unit points → nibart path (pt), straight segments.
#let poly-to-nib(pts, k, cycle: false) = to-nib((kind: "path", nodes: pts, pre: pts, post: pts,
  straight: pts.map(_ => true), cyclic: cycle), k)

// nibart path (pt) → path2 (user units)
#let from-nib(q, k) = {
  let nodes = (); let pre = (); let post = (); let straight = ()
  for s in q.segs {
    nodes.push((s.at(0) / k, s.at(1) / k)); post.push((s.at(2) / k, s.at(3) / k))
    pre.push((s.at(4) / k, s.at(5) / k)); straight.push(false)
  }
  if not q.cycle and q.segs.len() > 0 {
    let s = q.segs.last()
    nodes.push((s.at(6) / k, s.at(7) / k)); post.push((s.at(6) / k, s.at(7) / k)); pre.push((s.at(4) / k, s.at(5) / k))
  }
  // `pre.at(j)` must be the incoming control of node j: shift
  let pre2 = if q.cycle { (pre.last(),) + pre.slice(0, -1) } else { (nodes.first(),) + pre.slice(0, -1) + (pre.last(),) }
  (kind: "path", nodes: nodes, pre: pre2, post: post, straight: straight, cyclic: q.cycle)
}

// contour commands of a nibart shape ((0 x y) move, (1 x y) line, (2 c1 c2 p) cubic) → closed path2 (user units)
#let contour-path(cmds, k) = {
  let nodes = (); let pre = (); let post = (); let straight = ()
  for c in cmds {
    if c.at(0) == 0 {
      nodes.push((c.at(1) / k, c.at(2) / k)); pre.push((c.at(1) / k, c.at(2) / k)); post.push((c.at(1) / k, c.at(2) / k))
    } else if c.at(0) == 1 {
      post.at(post.len() - 1) = (nodes.last().at(0), nodes.last().at(1))
      straight.push(true)
      nodes.push((c.at(1) / k, c.at(2) / k)); pre.push((c.at(1) / k, c.at(2) / k)); post.push((c.at(1) / k, c.at(2) / k))
    } else {
      post.at(post.len() - 1) = (c.at(1) / k, c.at(2) / k)
      straight.push(false)
      nodes.push((c.at(5) / k, c.at(6) / k)); pre.push((c.at(3) / k, c.at(4) / k)); post.push((c.at(5) / k, c.at(6) / k))
    }
  }
  // the contour is closed: drop a repeated last node
  let n = nodes.len()
  if n > 2 {
    let f = nodes.first(); let l = nodes.last()
    if calc.abs(f.at(0) - l.at(0)) < 1e-9 and calc.abs(f.at(1) - l.at(1)) < 1e-9 {
      pre.at(0) = pre.last(); nodes = nodes.slice(0, -1); pre = pre.slice(0, -1); post = post.slice(0, -1)
    }
  }
  while straight.len() < nodes.len() { straight.push(true) }
  (kind: "path", nodes: nodes, pre: pre, post: post, straight: straight.slice(0, nodes.len()), cyclic: true)
}

// All contours of a list of nibart drawables, as closed path2 (user units).
#let items-paths(items, k) = {
  let out = ()
  for it in items {
    if type(it) == dictionary and it.at("kind", default: none) == "shape" {
      for c in it.contours { if c.len() > 2 { out.push(contour-path(c, k)) } }
    }
  }
  out
}

// ── the pen engine used by the pencil / vintage styles ────────────────────────────

// Stroke the path2 `q` with an elliptical nib of
// semi-axes `a`, `b` (user units) at `angle`; optional dash / pressure / explicit pen samples.
// `k` = points per user unit.
#let envelope-paths(q, a, b, angle: 0deg, closed: false, dash: none, pressure: none, epsilon: 0.01, pen: none, k: 1.0) = {
  if q.nodes.len() < 2 { return () }
  let p = to-nib(q, k)
  if p.segs.len() == 0 { return () }
  let tol = calc.max(epsilon * k, 0.004) * 1pt
  let items = if pen != none and pen.at("samples", default: none) != none {
    let stops = pen.samples.map(s => {
      let (arc, sa, sb, ang) = if type(s) == dictionary { (s.at("arclength", default: 0.0), s.a, s.b, s.at("angle", default: 0deg)) } else { (s.at(0), s.at(1), s.at(2), s.at(3)) }
      (at: arc * k * 1pt, width: 2 * sa * k * 1pt, minor-width: 2 * sb * k * 1pt, angle: if type(ang) == type(1deg) { ang } else { ang * 1deg })
    })
    nib.stroke-items(p, pen: nib.nibpen(..stops), dash: if dash == none { none } else { nib.dashes(..dash.lengths.map(x => x * k * 1pt), offset: dash.at("offset", default: 0.0) * k * 1pt, jitter: dash.at("jitter", default: 0.0) * k * 1pt, seed: dash.at("seed", default: 0)) },
      pressure: if pressure == none { none } else { nib.pressure(minimum-width: 2 * pressure.minimum-axis * k * 1pt, period: pressure.period * k * 1pt, seed: pressure.at("seed", default: 0)) },
      tol: tol)
  } else {
    nib.stroke-items(p, pen: nib.penellipse(2 * a * k * 1pt, 2 * b * k * 1pt, angle: angle),
      dash: if dash == none { none } else { nib.dashes(..dash.lengths.map(x => x * k * 1pt), offset: dash.at("offset", default: 0.0) * k * 1pt, jitter: dash.at("jitter", default: 0.0) * k * 1pt, seed: dash.at("seed", default: 0)) },
      pressure: if pressure == none { none } else { nib.pressure(minimum-width: 2 * pressure.minimum-axis * k * 1pt, period: pressure.period * k * 1pt, seed: pressure.at("seed", default: 0)) },
      tol: tol)
  }
  items-paths(items, k)
}
