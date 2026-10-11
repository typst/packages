// engrave.typ — the "engraving" style: a copper-plate / banknote rendering of any scene.
//
// Principle (the "line screen" of engraved portraits): the shaded surfaces are replaced by a family of
// parallel lines — straight or wavy — whose *width follows the tone* of the lit surface: fat in the
// shadows, hairline in the lights, gaps in the highlights; a second, crossed family appears in the
// deepest shadows. Contours are drawn with a broad calligraphic nib by nibart (thick-thin strokes,
// dashes for hidden edges). Hidden lines are removed by the painter's algorithm: a nearer patch cuts
// the lines that were laid behind it.

#import "path2.typ"
#import "pens.typ": *
#import "nibridge.typ": items-paths, to-nib
#import "@preview/nibart:0.3.0" as nib

#let engraving-paper = rgbf(0.957, 0.929, 0.855)
#let engraving-ink = rgbf(0.105, 0.094, 0.125)

/// Options of the engraving style. Lengths are on paper (pt-based).
/// - `spacing`: distance between two lines of the screen. `angle`: direction of the first family (degrees).
/// - `cross`: add the crossed family in deep shadows. `cross-angle`: its offset from `angle`.
/// - `wave`: `none` (straight lines) or `(amplitude: 0.5pt, length: 14pt, shift: 0.0)` — banknote waves;
///   `shift` rotates the phase from one line to the next (a non-zero value gives a guilloché moiré).
/// - `gain`: ink quantity (1 = normal, > 1 darker). `minimum`: thinnest visible line (below: gap).
/// - `contours`: broad-nib contours (`nib-width` × the pen width, `nib-angle`, `nib-ratio`). `ink`, `paper`: colours.
#let engraving(spacing: 2.1pt, angle: 38, cross: true, cross-angle: 78, wave: none, gain: 1.0, minimum: 0.13pt,
  contours: true, nib-width: 1.35, nib-angle: 38, nib-ratio: 0.36, ink: auto, paper: auto, step: 1.6pt) = (
  kind: "engraving",
  spacing: spacing, angle: float(angle), cross: cross, cross-angle: float(cross-angle),
  wave: if wave == none { none } else { (amplitude: wave.at("amplitude", default: 0.5pt), length: wave.at("length", default: 14pt), shift: float(wave.at("shift", default: 0.0))) },
  gain: float(gain), minimum: minimum, contours: contours, nib-width: float(nib-width), nib-angle: float(nib-angle),
  nib-ratio: float(nib-ratio), ink: if ink == auto { engraving-ink } else { ink }, paper: if paper == auto { engraving-paper } else { paper }, step: step,
)

#let _lum(c) = 0.299 * c.at(0) + 0.587 * c.at(1) + 0.114 * c.at(2)
#let _lerp3(a, b, t) = (a.at(0) + (b.at(0) - a.at(0)) * t, a.at(1) + (b.at(1) - a.at(1)) * t, a.at(2) + (b.at(2) - a.at(2)) * t)
#let _clamp(x, lo, hi) = calc.min(hi, calc.max(lo, x))

// ink coverage (0…1) required by a luminance
#let _need(l, gain) = _clamp(calc.pow(_clamp(1 - l, 0.0, 1.0), 1.25) * gain, 0.0, 1.0)

// width (in pt) of family `f` for a luminance `l`, on a screen of spacing `d` (pt)
#let _width(f, l, gain, d) = {
  let c = _need(l, gain)
  if f == 0 { d * 0.78 * _clamp(c / 0.62, 0.0, 1.0) } else { d * 0.52 * _clamp((c - 0.46) / 0.46, 0.0, 1.0) }
}

// Insert the segment (a, b, la, lb) in a list of covered intervals: whatever lies behind is cut.
#let _cover(list, a, b, la, lb) = {
  let out = ()
  for s in list {
    let (s0, s1, l0, l1) = s
    if s1 <= a or s0 >= b { out.push(s); continue }
    let lerp-at = u => l0 + (l1 - l0) * (u - s0) / calc.max(s1 - s0, 1e-12)
    if a - s0 > 1e-9 { out.push((s0, a, l0, lerp-at(a))) }
    if s1 - b > 1e-9 { out.push((b, s1, lerp-at(b), l1)) }
  }
  out.push((a, b, la, lb))
  out
}

// the luminance function of a fill primitive
#let _tone-of(pr) = {
  if pr.grad != none {
    let (x1, y1, x2, y2, c1, c2, ..) = pr.grad
    let dx = x2 - x1
    let dy = y2 - y1
    let den = calc.max(dx * dx + dy * dy, 1e-18)
    let l1 = _lum(c1)
    let l2 = _lum(c2)
    z => {
      let t = _clamp(((z.at(0) - x1) * dx + (z.at(1) - y1) * dy) / den, 0.0, 1.0)
      l1 + (l2 - l1) * t
    }
  } else {
    let l = _lum(pr.fill)
    z => l
  }
}

// closed polygon (path2, straight edges) of a variable-width ribbon: samples (u, width), pointed ends
#let _ribbon(samples, center, nv) = {
  let (u0, w0) = samples.first()
  let (u1, w1) = samples.last()
  let left = ()
  let right = ()
  for (u, w) in samples {
    let c = center(u)
    left.push((c.at(0) + nv.at(0) * w / 2, c.at(1) + nv.at(1) * w / 2))
    right.push((c.at(0) - nv.at(0) * w / 2, c.at(1) - nv.at(1) * w / 2))
  }
  let pts = (center(u0 - 0.55 * w0),) + left + (center(u1 + 0.55 * w1),) + right.rev()
  (kind: "path", nodes: pts, pre: pts, post: pts, straight: pts.map(_ => true), cyclic: true)
}

// Turn a chain of samples (u, luminance) into ribbons: smooth the tone along the line (this hides the
// steps of the shading between neighbouring patches), convert it to widths, cut where the line gets
// thinner than `minimum` (the highlights stay white) and give every piece pointed ends.
#let _ribbons-of(chain, center, nv, role, spec, dpt, s0) = {
  let n = chain.len()
  let out = ()
  if n < 2 { return out }
  let ls = chain.map(c => c.at(1))
  let sm = ()
  for i in range(n) {
    let acc = 0.0
    let wt = 0.0
    for dj in range(-2, 3) {
      let j = i + dj
      if j >= 0 and j < n { let k = 3 - calc.abs(dj); acc += k * ls.at(j); wt += k }
    }
    sm.push(acc / wt)
  }
  let wmin = spec.minimum.pt()
  let cur = ()
  for i in range(n) {
    let w = _width(role, sm.at(i), spec.gain, dpt)
    if w < wmin {
      if cur.len() >= 2 { out.push(_ribbon(cur, center, nv)) }
      cur = ()
    } else { cur.push((chain.at(i).at(0), w / s0)) }
  }
  if cur.len() >= 2 { out.push(_ribbon(cur, center, nv)) }
  out
}

// Engrave one run of consecutive fills → (paper knock-outs…, ink polygons).
#let _engrave-run(run, s0, spec) = {
  let dpt = spec.spacing.pt()
  let d = dpt / s0
  let fams = if spec.cross { ((spec.angle, 0), (spec.angle + spec.cross-angle, 1)) } else { ((spec.angle, 0),) }
  let paper = rgba-of(spec.paper)
  let knock = ()
  let ink = ()
  let wmin = spec.minimum.pt()
  let stepu = spec.step.pt() / s0
  let polys = ()
  for pr in run {
    if pr.fill == none { continue }
    knock.push((type: "fill", p2: pr.p2, holes: pr.at("holes", default: ()), fill: (paper.at(0), paper.at(1), paper.at(2)),
      grad: none, alpha: 1.0, seam: true, mesh: none, hatch: none, stipple: none, group: false))
    polys.push((path2.flatten2(pr.p2, n: 6), _tone-of(pr)))
  }
  for (ang, role) in fams {
    let dv = (calc.cos(ang * 1deg), calc.sin(ang * 1deg))
    let nv = (-dv.at(1), dv.at(0))
    let lines = (:)
    for (nodes, tone) in polys {
      let n = nodes.len()
      if n < 3 { continue }
      let proj = nodes.map(z => z.at(0) * nv.at(0) + z.at(1) * nv.at(1))
      let lo = calc.min(..proj)
      let hi = calc.max(..proj)
      let k0 = int(calc.ceil(lo / d))
      let k1 = int(calc.floor(hi / d))
      for k in range(k0, k1 + 1) {
        let level = k * d
        let us = ()
        for i in range(n) {
          let j = if i + 1 == n { 0 } else { i + 1 }
          let pa = proj.at(i) - level
          let pb = proj.at(j) - level
          if (pa <= 0 and pb > 0) or (pa > 0 and pb <= 0) {
            let t = pa / (pa - pb)
            let a = nodes.at(i)
            let b = nodes.at(j)
            us.push((a.at(0) + t * (b.at(0) - a.at(0))) * dv.at(0) + (a.at(1) + t * (b.at(1) - a.at(1))) * dv.at(1))
          }
        }
        if us.len() < 2 { continue }
        us = us.sorted()
        let key = str(k)
        let list = lines.at(key, default: ())
        for q in range(0, us.len() - 1, step: 2) {
          let (ua, ub) = (us.at(q), us.at(q + 1))
          if ub - ua < 1e-9 { continue }
          let pa = (level * nv.at(0) + ua * dv.at(0), level * nv.at(1) + ua * dv.at(1))
          let pb = (level * nv.at(0) + ub * dv.at(0), level * nv.at(1) + ub * dv.at(1))
          list = _cover(list, ua, ub, tone(pa), tone(pb))
        }
        lines.insert(key, list)
      }
    }
    for (key, list) in lines {
      let k = int(key)
      let level = k * d
      let phase = if spec.wave == none { 0.0 } else { k * spec.wave.shift }
      let center = u => {
        let off = if spec.wave == none or role != 0 { 0.0 } else { spec.wave.amplitude.pt() / s0 * calc.sin(2 * calc.pi * (u * s0) / spec.wave.length.pt() + phase) }
        (level * nv.at(0) + u * dv.at(0) + off * nv.at(0), level * nv.at(1) + u * dv.at(1) + off * nv.at(1))
      }
      let cur = ()
      let last-u = none
      for sg in list.sorted(key: s => s.at(0)) + ((1e30, 1e30, 0.0, 0.0),) {
        let (u0, u1, l0, l1) = sg
        let contiguous = last-u != none and calc.abs(u0 - last-u) < 1e-6 * (1 + calc.abs(u0))
        if not contiguous and cur.len() > 0 {
          ink += _ribbons-of(cur, center, nv, role, spec, dpt, s0)
          cur = ()
        }
        if u0 > 1e29 { break }
        let m = calc.max(1, int(calc.ceil((u1 - u0) / stepu)))
        for j in range(m + 1) {
          if j == 0 and contiguous { continue }
          let t = j / m
          cur.push((u0 + (u1 - u0) * t, l0 + (l1 - l0) * t))
        }
        last-u = u1
      }
    }
  }
  (knock, ink)
}

#let _bb(paths) = {
  let xs = ()
  let ys = ()
  for p in paths { for z in p.nodes { xs.push(z.at(0)); ys.push(z.at(1)) } }
  ((calc.min(..xs), calc.min(..ys)), (calc.max(..xs), calc.max(..ys)))
}

// dash lengths (pt) of a resolved pen, or none
#let _dash-of(pen) = {
  let dd = pen.at("dash", default: none)
  if dd == none { return none }
  let th = pen.at("thickness", default: 0.5pt).to-absolute().pt()
  if "typst" in dd {
    let td = dd.typst
    let arr = if type(td) == dictionary { td.array.map(x => if type(x) == length { x.to-absolute().pt() } else { x * th }) } else if type(td) == array { td.map(x => if type(x) == length { x.to-absolute().pt() } else { x * th }) } else if type(td) == str {
      let named = ("dotted": (th, 2 * th), "densely-dotted": (th, th), "loosely-dotted": (th, 4 * th), "dashed": (3 * th, 3 * th), "densely-dashed": (3 * th, 2 * th), "loosely-dashed": (3 * th, 6 * th), "dash-dotted": (3 * th, 2 * th, th, 2 * th))
      named.at(td, default: none)
    } else { none }
    if arr == none or arr.len() == 0 { none } else { arr }
  } else {
    let unit = if dd.scale { th } else { 1.0 }
    dd.pattern.map(x => x * unit)
  }
}

// Contour of a path primitive drawn with a broad nib by nibart → closed polygons (user units).
#let _nib-contour(pr, s0, spec) = {
  let pen = pr.pen
  let th = pen.at("thickness", default: 0.5pt).to-absolute().pt()
  let w = th * spec.nib-width
  let q = to-nib(pr.p2, s0)
  if q.segs.len() == 0 { return () }
  let dash = _dash-of(pen)
  let items = nib.stroke-items(q, pen: nib.penellipse(w * 1pt, w * spec.nib-ratio * 1pt, angle: spec.nib-angle * 1deg),
    dash: if dash == none { none } else { nib.dashes(..dash.map(x => x * 1pt)) }, tol: 0.01pt)
  items-paths(items, s0)
}

/// Replace the surfaces of a primitive list by engraved ink.
// `only-marked`: engrave only the fills carrying `eng: true` (vintage / pencil styles: the other fills,
// e.g. explicit washes or hatch-only surfaces, are passed through unchanged).
#let engrave-prims(prims, s0, spec, only-marked: false) = {
  let out = ()
  let run = ()
  let flush = r => if r.len() == 0 { () } else {
    let (knock, ink) = _engrave-run(r, s0, spec)
    knock + (if ink.len() > 0 { ((type: "ink", paths: ink, paint: spec.ink, alpha: 1.0, bb: _bb(ink)),) } else { () })
  }
  for pr in prims {
    if pr.type == "fill" and (not only-marked or pr.at("eng", default: false)) { run.push(pr); continue }
    if not only-marked and (pr.type == "group" or pr.type == "endgroup") { continue }
    out += flush(run)
    run = ()
    if pr.type == "path" and spec.contours and pr.pen != none and pr.arrow == none and pr.p2.nodes.len() > 1 {
      let paths = _nib-contour(pr, s0, spec)
      if paths.len() > 0 {
        let pc = pen-paint(pr.pen)
        let u = rgba-of(pc)
        let dark = u.at(0) + u.at(1) + u.at(2) < 0.06
        out.push((type: "ink", paths: paths, paint: if dark { spec.ink } else { pc }, alpha: pr.pen.at("opacity", default: 1.0), bb: _bb(paths)))
        if pr.label != none { out.push((type: "path", p2: pr.p2, g: pr.at("g", default: none), pen: none, arrow: none, label: pr.label)) }
        continue
      }
    }
    out.push(pr)
  }
  out += flush(run)
  out
}
