// braces.typ — calligraphic braces, brackets and parentheses between two 3D points (drawn by nibart).
//
// The two points are shifted by `offset` in 3D, projected, and joined by a brace whose pen swells where the curve
// bends (nibart's `delimiter`). The label is centred on the tip of the brace.

#import "@preview/nibart:0.3.0" as nib
#import "projection.typ": project-point
#import "nibridge.typ": items-paths
#import "pens.typ": *
#import "vec.typ": *

/// A brace (or `kind: "paren"`, `"paren-straight"`) from `a` to `b` (3D points); `brace3(a, b, $h$)` is enough:
/// the brace is drawn on the outer side of the figure, a few points away from the segment.
/// - `label`: content centred beyond the tip (can also be given as the third, positional argument).
/// - `flip`: `auto` (outer side of the figure), `true` or `false` (explicit side).
/// - `distance`: gap, on paper, between the segment and the brace (along the outer side).
/// - `outside`: push the brace beyond the bounding box of the figure (default `true`); `false` keeps it at `distance` from the segment.
/// - `offset`: optional 3D displacement of the whole brace. `amplitude`: height of the tip on paper.
/// - `light`, `heavy`: hairline and shade widths of the pen. `pen`: colour/pen of the ink; `gap`: distance of the label from the tip.
#let brace3(a, b, ..rest, label: none, offset: (0, 0, 0), kind: "brace", amplitude: 9pt, flip: auto,
  light: 0.35pt, heavy: 1.7pt, pen: auto, gap: 5pt, distance: 6pt, outside: true) = {
  let lab = if rest.pos().len() > 0 { rest.pos().first() } else { label }
  ((cmd: "brace3", a: vadd(a.map(float), offset.map(float)), b: vadd(b.map(float), offset.map(float)),
    label: lab, kind: kind, amplitude: amplitude, flip: flip, light: light, heavy: heavy, pen: pen, gap: gap, distance: distance, outside: outside),)
}

#let brace-prims(c, P, s0, ink, bnds) = {
  let ctr3 = vmul(0.5, vadd(bnds.at(0), bnds.at(1)))
  let za = project-point(P, c.a)
  let zb = project-point(P, c.b)
  let d0 = (zb.at(0) - za.at(0), zb.at(1) - za.at(1))
  let n0 = calc.max(calc.sqrt(d0.at(0) * d0.at(0) + d0.at(1) * d0.at(1)), 1e-12)
  let left0 = (-d0.at(1) / n0, d0.at(0) / n0)
  let flip = c.flip
  if flip == auto {
    let zc = project-point(P, ctr3)
    let mid0 = ((za.at(0) + zb.at(0)) / 2 - zc.at(0), (za.at(1) + zb.at(1)) / 2 - zc.at(1))
    flip = left0.at(0) * mid0.at(0) + left0.at(1) * mid0.at(1) < 0
  }
  let nrm = if flip { (-left0.at(0), -left0.at(1)) } else { left0 }
  let dist = c.distance.to-absolute().pt() / s0
  if c.outside {
    // push the brace beyond the projected bounding box of the scene, along its outer normal
    let (m, M) = bnds
    let mid = ((za.at(0) + zb.at(0)) / 2, (za.at(1) + zb.at(1)) / 2)
    let need = 0.0
    for i in range(8) {
      let v = (if calc.rem(i, 2) == 0 { m.at(0) } else { M.at(0) }, if calc.rem(calc.quo(i, 2), 2) == 0 { m.at(1) } else { M.at(1) }, if i < 4 { m.at(2) } else { M.at(2) })
      let z = project-point(P, v)
      need = calc.max(need, (z.at(0) - mid.at(0)) * nrm.at(0) + (z.at(1) - mid.at(1)) * nrm.at(1))
    }
    dist += need
  }
  za = (za.at(0) + nrm.at(0) * dist, za.at(1) + nrm.at(1) * dist)
  zb = (zb.at(0) + nrm.at(0) * dist, zb.at(1) + nrm.at(1) * dist)
  let col = if c.pen == auto { ink } else { pen-paint(resolve-pen(c.pen)) }
  let items = nib.delimiter((za.at(0) * s0 * 1pt, za.at(1) * s0 * 1pt), (zb.at(0) * s0 * 1pt, zb.at(1) * s0 * 1pt), kind: c.kind,
    amplitude: c.amplitude, flip: flip, light: c.light, heavy: c.heavy, fill: col)
  let ps = items-paths(items, s0)
  let prims = ()
  if ps.len() > 0 {
    let xs = ()
    let ys = ()
    for p in ps { for z in p.nodes { xs.push(z.at(0)); ys.push(z.at(1)) } }
    prims.push((type: "ink", paths: ps, paint: col, alpha: 1.0, bb: ((calc.min(..xs), calc.min(..ys)), (calc.max(..xs), calc.max(..ys)))))
  }
  if c.label != none {
    let d = (zb.at(0) - za.at(0), zb.at(1) - za.at(1))
    let amp = c.amplitude.pt() / s0
    let mid = ((za.at(0) + zb.at(0)) / 2 + nrm.at(0) * amp, (za.at(1) + zb.at(1)) / 2 + nrm.at(1) * amp)
    let lp = resolve-pen(if c.pen == auto { default-pen } else { c.pen })
    let ang = calc.rem-euclid(-calc.atan2(d.at(0), d.at(1)).rad() + calc.pi / 2, calc.pi) - calc.pi / 2
    prims.push((type: "label", z: mid, body: rotate(ang * 1rad, reflow: true, c.label), align: (nrm.at(0), nrm.at(1)), pen: lp, v: none, rotation: none,
      dx: 0, dy: 0, center: true, normal: nrm, extra: c.gap))
  }
  prims
}
