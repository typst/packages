// ===========================================================================
//  faboxyst/vintage.typ — two vintage frame families redrawn as vectors:
//
//    * `vintageframe` / `cadre-vintage` — the eight line-art label frames of
//      the scrollwork SVG sheet (styles "volutes", "curls", "loops",
//      "petals", "fans", "waves", "hooks", "fleuron");
//    * `vintagebox` / `plaque-vintage`  — the six bracket plaques of the
//      EPS sheet: white plate, black outer rule, thin inner rule and a grey
//      drop shadow (variants "medaillon", "carre", "haut", "colonne",
//      "ovale", "banniere").
//
//    #vintageframe(style: "volutes")[Mon titre]
//    #vintagebox(variant: "banniere")[VINTAGE]
// ===========================================================================

#import "volutebox.typ": spiral-pts, ink-pts
#import "antique.typ": vintage-pts
#import "engine.typ": rounded-rect-pts

// ---------------------------------------------------------------------------
//  shared helpers
// ---------------------------------------------------------------------------

// Sampled circular arc (screen angles: 0 = right, 90 = down).
#import "theme.typ": theme-state, grayscale-paint

#let varc(cx, cy, r, a0, a1, n: 32) = {
  range(n + 1).map(i => {
    let a = (a0 + (a1 - a0) * i / n) * 1deg
    (cx + r * calc.cos(a), cy + r * calc.sin(a))
  })
}

// Open ink polyline through sampled points.
#let vline(pts, paint, w, closed: false, dx: 0pt, dy: 0pt,
           vintage: false, vintage-pen: none) = {
  if pts.len() < 2 { return }
  if vintage {
    place(top + left, dx: dx, dy: dy,
      vintage-pts(pts, paint, w, closed: closed, vintage-pen: vintage-pen))
    return
  }
  let segs = (curve.move(pts.first()),) + pts.slice(1).map(p => curve.line(p))
  let segs = if closed { segs + (curve.close(mode: "straight"),) } else { segs }
  place(top + left, dx: dx, dy: dy, curve(
    stroke: (paint: paint, thickness: w, join: "round", cap: "round"),
    ..segs,
  ))
}

// Filled / stroked polygon from points.
#let vpoly(pts, paint, w: 0pt, closed: true, dx: 0pt, dy: 0pt,
           vintage: false, vintage-pen: none) = {
  if vintage {
    if paint != none {
      place(top + left, dx: dx, dy: dy,
        polygon(fill: paint, stroke: none, ..pts))
    }
    place(top + left, dx: dx, dy: dy,
      vintage-pts(pts, if paint == none { black } else { paint },
        if w == 0pt { 0.7pt } else { w }, closed: closed,
        vintage-pen: vintage-pen))
    return
  }
  place(top + left, dx: dx, dy: dy, curve(
    fill: if paint == none { none } else { paint },
    stroke: if w == 0pt { none } else { (paint: paint, thickness: w, join: "round", cap: "round") },
    curve.move(pts.first()),
    ..pts.slice(1).map(p => curve.line(p)),
    curve.close(mode: "straight"),
  ))
}

// ---------------------------------------------------------------------------
//  the bracket-plaque outline of the EPS sheet
// ---------------------------------------------------------------------------

// One side of a plaque, from corner to corner, as curve components.
// `kind` is "flat", "wave" (two shallow bumps) or "plain".
// A mid-side tip (small outward point) is added when `tip` is true.
#let _edge-segs(p0, p1, out, kind: "flat", tip: false, tl: 0.10, td: 3pt,
  bump: none) = {
  // p0 → p1 along an axis; `out` is the unit outward normal (nx, ny).
  // Segments as plain data: ("L", p) or ("C", c1, c2, p) — curve
  // components cannot be inspected (they are `content`), so the
  // geometry lives here and both renderers derive from it.
  let (x0, y0) = p0
  let (x1, y1) = p1
  let (nx, ny) = out
  let dx = x1 - x0
  let dy = y1 - y0
  let len = if dx == 0pt { dy } else { dx }
  let segs = ()
  if kind == "wave" {
    let b = if bump == none { 0.09 * len } else { bump }
    let q = a => (x0 + dx * a.at(0) + nx * b * a.at(1),
      y0 + dy * a.at(0) + ny * b * a.at(1))
    segs = segs + (
      ("C", q((0.10, 0)), q((0.16, 1.0)), q((0.25, 1.0))),
      ("C", q((0.34, 1.0)), q((0.40, 0)), q((0.46, 0))),
    )
    if tip {
      segs = segs + (
        ("L", q((0.485, 0))),
        ("L", q((0.50, 1.6))),
        ("L", q((0.515, 0))),
      )
    }
    segs = segs + (
      ("C", q((0.60, 0)), q((0.66, 1.0)), q((0.75, 1.0))),
      ("C", q((0.84, 1.0)), q((0.90, 0)), q((1.0, 0))),
    )
  } else if kind == "lobe" {
    // a protruding rounded tab with concave flanks, after the EPS column
    let d = 0.12 * len
    let q = a => (x0 + dx * a.at(0) + nx * d * a.at(1),
      y0 + dy * a.at(0) + ny * d * a.at(1))
    segs = segs + (
      ("L", q((0.24, 0))),
      ("C", q((0.285, 0.15)), q((0.30, 0.55)), q((0.345, 0.85))),
      ("C", q((0.40, 1.15)), q((0.60, 1.15)), q((0.655, 0.85))),
      ("C", q((0.70, 0.55)), q((0.715, 0.15)), q((0.76, 0))),
      ("L", p1),
    )
  } else {
    if tip {
      segs = segs + (
        ("L", (x0 + dx * (0.5 - tl / 2), y0 + dy * (0.5 - tl / 2))),
        ("L", (x0 + dx * 0.5 + nx * td, y0 + dy * 0.5 + ny * td)),
        ("L", (x0 + dx * (0.5 + tl / 2), y0 + dy * (0.5 + tl / 2))),
      )
    }
    segs = segs + (("L", p1),)
  }
  segs
}

// The edge as curve components (the native render path).
#let _edge(p0, p1, out, kind: "flat", tip: false, tl: 0.10, td: 3pt,
           bump: none) = {
  _edge-segs(p0, p1, out, kind: kind, tip: tip, tl: tl, td: td, bump: bump)
    .map(sg => if sg.at(0) == "L" { curve.line(sg.at(1)) }
               else { curve.cubic(sg.at(1), sg.at(2), sg.at(3)) })
}

// Concave corner fillet from edge end `pa` around corner `pc` to `pb`.
#let _corner(pa, pc, pb) = {
  (curve.cubic(
    (pa.at(0) + (pc.at(0) - pa.at(0)) * 0.22, pa.at(1) + (pc.at(1) - pa.at(1)) * 0.22),
    (pb.at(0) + (pc.at(0) - pb.at(0)) * 0.22, pb.at(1) + (pc.at(1) - pb.at(1)) * 0.22),
    pb,
  ),)
}

// The same fillet as sampled points (the vintage render path).
#let _corner-pts(pa, pc, pb) = {
  let c1 = (pa.at(0) + (pc.at(0) - pa.at(0)) * 0.22,
    pa.at(1) + (pc.at(1) - pa.at(1)) * 0.22)
  let c2 = (pb.at(0) + (pc.at(0) - pb.at(0)) * 0.22,
    pb.at(1) + (pc.at(1) - pb.at(1)) * 0.22)
  range(1, 11).map(i => {
    let tt = i / 10
    let mt = 1 - tt
    (
      mt * mt * mt * pa.at(0) + 3 * mt * mt * tt * c1.at(0)
        + 3 * mt * tt * tt * c2.at(0) + tt * tt * tt * pb.at(0),
      mt * mt * mt * pa.at(1) + 3 * mt * mt * tt * c1.at(1)
        + 3 * mt * tt * tt * c2.at(1) + tt * tt * tt * pb.at(1),
    )
  })
}

// The plaque outline as sampled points (native lengths, y down), for the
// vintage nib render.
#let _plaque-pts(W, H, o, c, kind, tips, bump) = {
  let x0 = o
  let y0 = o
  let x1 = W - o
  let y1 = H - o
  let tl = (x0 + c, y0)
  let tr = (x1 - c, y0)
  let rt = (x1, y0 + c)
  let rb = (x1, y1 - c)
  let br = (x1 - c, y1)
  let bl = (x0 + c, y1)
  let lb = (x0, y1 - c)
  let lt = (x0, y0 + c)
  let parts = (
    _edge-segs(tl, tr, (0, -1), kind: kind, tip: tips.t, bump: bump),
    _corner-pts(tr, (x1, y0), rt),
    _edge-segs(rt, rb, (1, 0), kind: "flat", tip: tips.r),
    _corner-pts(rb, (x1, y1), br),
    _edge-segs(br, bl, (0, 1), kind: kind, tip: tips.b, bump: bump),
    _corner-pts(bl, (x0, y1), lb),
    _edge-segs(lb, lt, (-1, 0), kind: "flat", tip: tips.l),
    _corner-pts(lt, (x0, y0), tl),
  )
  let pts = (tl,)
  let cur = tl
  for part in parts {
    let is-segs = part.at(0).at(0) == "L" or part.at(0).at(0) == "C"
    if not is-segs {
      pts = pts + part
      cur = part.at(part.len() - 1)
      continue
    }
    for sg in part {
      if sg.at(0) == "L" {
        let p = sg.at(1)
        let dx = p.at(0) - cur.at(0)
        let dy = p.at(1) - cur.at(1)
        let n = calc.max(2, calc.ceil(calc.sqrt(
          (dx / 4pt) * (dx / 4pt) + (dy / 4pt) * (dy / 4pt))))
        for i in range(1, n + 1) {
          pts.push((cur.at(0) + dx * i / n, cur.at(1) + dy * i / n))
        }
        cur = p
      } else {
        let c1 = sg.at(1)
        let c2 = sg.at(2)
        let p = sg.at(3)
        for i in range(1, 13) {
          let tt = i / 12
          let mt = 1 - tt
          pts.push((
            mt * mt * mt * cur.at(0) + 3 * mt * mt * tt * c1.at(0)
              + 3 * mt * tt * tt * c2.at(0) + tt * tt * tt * p.at(0),
            mt * mt * mt * cur.at(1) + 3 * mt * mt * tt * c1.at(1)
              + 3 * mt * tt * tt * c2.at(1) + tt * tt * tt * p.at(1),
          ))
        }
        cur = p
      }
    }
  }
  pts
}

// The full plaque outline as curve components, inset by `o` on every side.
#let plaque-comps(W, H, o, c, kind: "flat",
  tips: (t: true, b: true, l: true, r: true), bump: none) = {
  let x0 = o
  let y0 = o
  let x1 = W - o
  let y1 = H - o
  let tl = (x0 + c, y0)
  let tr = (x1 - c, y0)
  let rt = (x1, y0 + c)
  let rb = (x1, y1 - c)
  let br = (x1 - c, y1)
  let bl = (x0 + c, y1)
  let lb = (x0, y1 - c)
  let lt = (x0, y0 + c)
  (
    _edge(tl, tr, (0, -1), kind: kind, tip: tips.t, bump: bump),
    _corner(tr, (x1, y0), rt),
    _edge(rt, rb, (1, 0), kind: "flat", tip: tips.r),
    _corner(rb, (x1, y1), br),
    _edge(br, bl, (0, 1), kind: kind, tip: tips.b, bump: bump),
    _corner(bl, (x0, y1), lb),
    _edge(lb, lt, (-1, 0), kind: "flat", tip: tips.l),
    _corner(lt, (x0, y0), tl),
  ).flatten()
}

// Draw one plaque layer (fill + rule) at inset o.
#let _plaque-layer(W, H, o, c, kind, tips, fill, stroke-c, sw, bump: none,
                   vintage: false, vintage-pen: none) = {
  let comps = plaque-comps(W, H, o, c, kind: kind, tips: tips, bump: bump)
  if vintage {
    if sw == 0pt { return }
    if fill != none {
      place(top + left, polygon(fill: fill, stroke: none,
        .._plaque-pts(W, H, o, c, kind, tips, bump)))
    }
    place(top + left, vintage-pts(
      _plaque-pts(W, H, o, c, kind, tips, bump), stroke-c, sw,
      vintage-pen: vintage-pen))
  } else {
    place(top + left, curve(
      fill: fill,
      stroke: if sw == 0pt { none } else { (paint: stroke-c, thickness: sw) },
      ..comps,
    ))
  }
}

/// A bracket plaque after the EPS "vintage vector frame" sheet: a white
/// plate with concave corners, optional mid-side points or wavy long edges,
/// a black outer rule, a thin inner rule and a grey drop shadow.
///
/// ```typ
/// #vintagebox(variant: "banniere")[VINTAGE]
/// #vintagebox(variant: "medaillon", width: 4cm, height: 4cm)[1900]
/// ```
#let vintagebox(
  ..a,
  variant: "banniere",
  width: auto,
  height: auto,
  ink: rgb("#141414"),
  fill: white,
  shadow: rgb("#C9C9C9"),
  inset: (x: 1.2em, y: 0.7em),
  text-fill: rgb("#2A2A2A"),
  text-size: 0.9em,
  vintage: false,      // the plate rules engraved with a nib
  vintage-pen: none,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let ink = if print-mode { black } else { ink }
  let fill = if print-mode { white } else { fill }
  let shadow = if print-mode and shadow != none { grayscale-paint(shadow) } else { shadow }
  let text-fill = if print-mode { black } else { text-fill }
  if print-mode { set text(fill: black) }

  let body = a.pos().at(0, default: none)
  let label = if body == none { none } else {
    block(inset: 0pt, text(fill: text-fill, size: text-size, body))
  }
  // variant recipes: (kind, tips, corner cut, default aspect)
  let rec = (
    "medaillon": (kind: "flat", tips: (t: true, b: true, l: true, r: true), c: 0.22, ar: 1.05),
    "carre":     (kind: "flat", tips: (t: true, b: true, l: true, r: true), c: 0.26, ar: 1.15),
    "haut":      (kind: "flat", tips: (t: true, b: true, l: false, r: false), c: 0.20, ar: 0.62),
    "colonne":   (kind: "lobe", tips: (t: false, b: false, l: false, r: false), c: 0.18, ar: 0.34),
    "ovale":     (kind: "flat", tips: (t: true, b: true, l: true, r: true), c: 0.42, ar: 1.5),
    "banniere":  (kind: "wave", tips: (t: true, b: true, l: true, r: true), c: 0.30, ar: 3.4),
  ).at(variant)
  layout(avail => {
    let lm = if label == none { (width: 0pt, height: 0pt) } else { measure(label) }
    let ix = measure(box(width: inset.at("x", default: 1.2em), height: 0pt)).width
    let iy = measure(box(height: inset.at("y", default: 0.7em), width: 0pt)).height
    let H = if height == auto { lm.height + 2 * iy + 6pt } else { height }
    let W = if width == auto {
      calc.max(lm.width + 2 * ix + 8pt, H * rec.ar)
    } else if type(width) == ratio { avail.width * width } else { width }
    let c = rec.c * calc.min(H, W * 0.5, 3.2cm) * 0.5
    let bump = if rec.kind == "wave" { 0.05 * H } else { none }
    let kind = rec.kind
    let tips = rec.tips
    block(width: W, height: H + 3pt, {
      // grey drop shadow, offset to the lower right
      if shadow != none {
        place(top + left, dx: 2.2pt, dy: 3pt, curve(
          fill: shadow,
          ..plaque-comps(W, H, 0.8pt, c, kind: kind, tips: tips, bump: bump),
        ))
      }
      // outer plate
      _plaque-layer(W, H, 0.8pt, c, kind, tips, fill, ink, 1.5pt, bump: bump,
        vintage: vintage, vintage-pen: vintage-pen)
      // thin inner rule
      _plaque-layer(W, H, 3.4pt, c * 0.86, kind, tips, none, ink, 0.55pt, bump: bump,
        vintage: vintage, vintage-pen: vintage-pen)
      if label != none {
        place(top + left, block(width: W, height: H,
          align(center + horizon, label)))
      }
    })
  })
}

/// French alias for `vintagebox`.
#let plaque-vintage(..a) = vintagebox(..a)

// ---------------------------------------------------------------------------
//  vintageframe — the eight scrollwork frames of the SVG sheet
// ---------------------------------------------------------------------------

// corner volute used by several styles: a logarithmic spiral sample.
#let _spiral(cx, cy, r0, r1, a0, turns, paint, w, sx: 1, sy: 1,
             vintage: false, vintage-pen: none) = {
  if vintage {
    place(top + left, vintage-pts(
      spiral-pts(cx, cy, r0, r1, a0, turns, sx: sx, sy: sy), paint, w,
      closed: false, vintage-pen: vintage-pen))
    return
  }
  ink-pts(spiral-pts(cx, cy, r0, r1, a0, turns, sx: sx, sy: sy), paint, w)
}

/// A scrollwork label frame after the vintage SVG sheet. Eight line-art
/// styles are available through `style`; the content sits centred inside.
///
/// ```typ
/// #vintageframe(style: "volutes")[Chapitre I]
/// #vintageframe(style: "fleuron", ink: rgb("#5A4632"))[Sommaire]
/// ```
// Sample a list of ("L", p) / ("C", c1, c2, p) segments starting at `cur`.
#let _cpath(cur, segs) = {
  let pts = (cur,)
  let cur2 = cur
  for sg in segs {
    if sg.at(0) == "L" {
      let p = sg.at(1)
      let dx = p.at(0) - cur2.at(0)
      let dy = p.at(1) - cur2.at(1)
      let n = calc.max(2, calc.ceil(calc.sqrt(
        (dx / 4pt) * (dx / 4pt) + (dy / 4pt) * (dy / 4pt))))
      for i in range(1, n + 1) {
        pts.push((cur2.at(0) + dx * i / n, cur2.at(1) + dy * i / n))
      }
      cur2 = p
    } else {
      let c1 = sg.at(1)
      let c2 = sg.at(2)
      let p = sg.at(3)
      for i in range(1, 11) {
        let tt = i / 10
        let mt = 1 - tt
        pts.push((
          mt * mt * mt * cur2.at(0) + 3 * mt * mt * tt * c1.at(0)
            + 3 * mt * tt * tt * c2.at(0) + tt * tt * tt * p.at(0),
          mt * mt * mt * cur2.at(1) + 3 * mt * mt * tt * c1.at(1)
            + 3 * mt * tt * tt * c2.at(1) + tt * tt * tt * p.at(1),
        ))
      }
      cur2 = p
    }
  }
  pts
}

// The notched plaque contour (curls / fans / waves / fleuron styles) as
// points, inset by `o` on every side.
#let _plate-pts(W, H, e, c, o) = {
  let X0 = e * W
  let X1 = (1 - e) * W
  let x0 = X0 + c + o
  let x1 = X1 - c - o
  let y0 = o
  let y1 = H - o
  _cpath((x0, y0), (
    ("L", (x1, y0)),
    ("C", (X1 - c * 0.3, c * 0.3), (X1 - c * 0.3, c * 0.3), (X1 - o, c + o)),
    ("L", (X1 - o, H - c - o)),
    ("C", (X1 - c * 0.3, H - c * 0.3), (X1 - c * 0.3, H - c * 0.3),
      (X1 - c - o, H - o)),
    ("L", (X0 + c + o, H - o)),
    ("C", (X0 + c * 0.3, H - c * 0.3), (X0 + c * 0.3, H - c * 0.3),
      (X0 + o, H - c - o)),
    ("L", (X0 + o, c + o)),
    ("C", (X0 + c * 0.3, c * 0.3), (X0 + c * 0.3, c * 0.3), (x0, y0)),
  ))
}

// The leaf/plaque contour of the "petals" style.
#let _petal-pts(W, H) = {
  _cpath((0.14 * W, 0.06 * H), (
    ("C", (0.30 * W, -0.02 * H), (0.46 * W, 0.02 * H), (0.50 * W, -0.06 * H)),
    ("C", (0.54 * W, 0.02 * H), (0.70 * W, -0.02 * H), (0.86 * W, 0.06 * H)),
    ("C", (0.955 * W, 0.22 * H), (0.955 * W, 0.78 * H), (0.86 * W, 0.94 * H)),
    ("C", (0.70 * W, 1.02 * H), (0.54 * W, 0.98 * H), (0.50 * W, 1.06 * H)),
    ("C", (0.46 * W, 0.98 * H), (0.30 * W, 1.02 * H), (0.14 * W, 0.94 * H)),
    ("C", (0.045 * W, 0.78 * H), (0.045 * W, 0.22 * H), (0.14 * W, 0.06 * H)),
  ))
}

// A sampled ellipse centred on (cx, cy).
#let _ell-pts(cx, cy, rx, ry, n: 28) = range(n).map(i => {
  let t = (i / n) * 360deg
  (cx + rx * calc.cos(t), cy + ry * calc.sin(t))
})

#let vintageframe(
  body,
  style: "volutes",
  ink: rgb("#141414"),
  width: 100%,
  inset: (x: 1.4em, y: 0.8em),
  text-fill: auto,
  text-size: 1em,
  weight: auto,
  vintage: false,
  vintage-pen: none,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let ink = if print-mode { black } else { ink }
  let text-fill = if print-mode { black } else { text-fill }
  if print-mode { set text(fill: black) }

  let label = block(inset: 0pt, {
    if text-fill != auto { set text(fill: text-fill) }
    if weight != auto { set text(weight: weight) }
    set text(size: text-size)
    body
  })
  layout(avail => {
    let W = if type(width) == ratio { avail.width * width }
            else if width == auto { avail.width } else { width }
    let lm = measure(label)
    let ix = measure(box(width: inset.at("x", default: 1.4em), height: 0pt)).width
    let iy = measure(box(height: inset.at("y", default: 0.8em), width: 0pt)).height
    let H = lm.height + 2 * iy
    let w = calc.max(0.7pt, H * 0.035)     // main rule weight
    let L(pts, paint, wt, closed: false, dx: 0pt, dy: 0pt) = {
      vline(pts, paint, wt, closed: closed, dx: dx, dy: dy,
        vintage: vintage, vintage-pen: vintage-pen)
    }
    let SP(cx, cy, r0, r1, a0, turns, paint, wt, sx: 1, sy: 1) = {
      _spiral(cx, cy, r0, r1, a0, turns, paint, wt, sx: sx, sy: sy,
        vintage: vintage, vintage-pen: vintage-pen)
    }
    let VP(pts, paint, wt: 0pt, dx: 0pt, dy: 0pt) = {
      vpoly(pts, paint, w: wt, dx: dx, dy: dy,
        vintage: vintage, vintage-pen: vintage-pen)
    }
    let block-h = H + 1.2 * H             // room for the outer ornament
    block(width: W, height: if style == "loops" or style == "hooks" { H + 0.9em } else { H }, {
      let cy = H / 2
      if style == "volutes" {
        // double rules top and bottom, side ticks, corner + centre volutes
        let yo = 0pt
        let yi = 0.14 * H
        L(((0.10 * W, yo), (0.42 * W, yo)), ink, w)
        L(((0.58 * W, yo), (0.90 * W, yo)), ink, w)
        L(((0.10 * W, H), (0.42 * W, H)), ink, w)
        L(((0.58 * W, H), (0.90 * W, H)), ink, w)
        L(((0.115 * W, yi), (0.435 * W, yi)), ink, w * 0.6)
        L(((0.565 * W, yi), (0.885 * W, yi)), ink, w * 0.6)
        L(((0.115 * W, H - yi), (0.435 * W, H - yi)), ink, w * 0.6)
        L(((0.565 * W, H - yi), (0.885 * W, H - yi)), ink, w * 0.6)
        L(((0.045 * W, 0.30 * H), (0.045 * W, 0.70 * H)), ink, w * 0.7)
        L(((0.955 * W, 0.30 * H), (0.955 * W, 0.70 * H)), ink, w * 0.7)
        // centre ornaments: paired volutes and a double tick, top & bottom
        for sy in (1, -1) {
          let yy = if sy == 1 { 0pt } else { H }
          SP(0.455 * W, yy + sy * -0.10 * H, 0.16 * H, 0.015 * H, -90 * sy, 1.7, ink, w * 0.8, sx: 1, sy: sy)
          SP(0.545 * W, yy + sy * -0.10 * H, 0.16 * H, 0.015 * H, -90 * sy, 1.7, ink, w * 0.8, sx: -1, sy: sy)
          L(((0.492 * W, yy + sy * -0.16 * H), (0.492 * W, yy + sy * 0.02 * H)), ink, w * 0.7)
          L(((0.508 * W, yy + sy * -0.16 * H), (0.508 * W, yy + sy * 0.02 * H)), ink, w * 0.7)
          // small corner volutes at the four ends of the side ticks
          for sx2 in (1, -1) {
            let xx = if sx2 == 1 { 0.045 * W } else { 0.955 * W }
            SP(xx, yy + sy * -0.06 * H, 0.10 * H, 0.012 * H, 90 * sy, 1.6, ink, w * 0.7, sx: -sx2, sy: sy)
          }
        }
      } else if style == "curls" {
        // notched plaque with a corner curl outside each notch
        let c = 0.28 * H
        if vintage {
          place(top + left, vintage-pts(
            _plate-pts(W, H, 0.06, c, 0pt), ink, w * 1.5, closed: true,
            vintage-pen: vintage-pen))
        } else {
        place(top + left, curve(
          stroke: (paint: ink, thickness: w * 1.5),
          curve.move((0.06 * W + c, 0pt)),
          curve.line((0.94 * W - c, 0pt)),
          curve.cubic((0.94 * W - c * 0.25, c * 0.25), (0.94 * W - c * 0.25, c * 0.25), (0.94 * W, c)),
          curve.line((0.94 * W, H - c)),
          curve.cubic((0.94 * W - c * 0.25, H - c * 0.25), (0.94 * W - c * 0.25, H - c * 0.25), (0.94 * W - c, H)),
          curve.line((0.06 * W + c, H)),
          curve.cubic((0.06 * W + c * 0.25, H - c * 0.25), (0.06 * W + c * 0.25, H - c * 0.25), (0.06 * W, H - c)),
          curve.line((0.06 * W, c)),
          curve.cubic((0.06 * W + c * 0.25, c * 0.25), (0.06 * W + c * 0.25, c * 0.25), (0.06 * W + c, 0pt)),
          curve.close(mode: "straight"),
        ))
        }
        for sx in (1, -1) {
          for sy in (1, -1) {
            let xx = if sx == 1 { 0.045 * W } else { 0.955 * W }
            let yy = if sy == 1 { 0.10 * H } else { 0.90 * H }
            SP(xx, yy, 0.15 * H, 0.015 * H, 0, 1.8, ink, w * 1.1, sx: -sx, sy: -sy)
          }
        }
      } else if style == "loops" {
        // stadium outline with loop flourishes above and below
        if vintage {
          place(top + left, dx: 0.06 * W,
            vintage-pts(rounded-rect-pts((0pt, 0pt), (0.88 * W, H),
              radius: H / 2), ink, w * 1.4, closed: true,
              vintage-pen: vintage-pen))
        } else {
          place(top + left, dx: 0.06 * W, rect(
            width: 0.88 * W, height: H,
            radius: H / 2, stroke: (paint: ink, thickness: w * 1.4),
          ))
        }
        for sy in (1, -1) {
          let cy0 = if sy == 1 { -0.02 * H } else { 1.02 * H }
          let a0 = if sy == 1 { 200 } else { 20 }
          let a1 = if sy == 1 { 340 } else { 160 }
          L(varc(0.40 * W, cy0, 0.24 * H, a0, a1, n: 24), ink, w * 0.6)
          L(varc(0.60 * W, cy0, 0.24 * H, a0, a1, n: 24), ink, w * 0.6)
          for i in range(4) {
            let xx = (0.455 + 0.030 * i) * W
            let dy2 = if sy == 1 { -0.16 * H } else { H - 0.14 * H }
            if vintage {
              place(top + left, dx: xx, dy: dy2,
                vintage-pts(_ell-pts(0.015 * W, 0.15 * H, 0.015 * W,
                  0.15 * H), ink, w * 0.6, vintage-pen: vintage-pen))
            } else {
              place(top + left, dx: xx, dy: dy2,
                ellipse(width: 0.030 * W, height: 0.30 * H,
                  stroke: (paint: ink, thickness: w * 0.6)))
            }
          }
        }
      } else if style == "petals" {
        // slim plaque, pointed top and bottom, floral ends
        let c = 0.5 * H
        if vintage {
          place(top + left, vintage-pts(
            _petal-pts(W, H), ink, w, closed: true,
            vintage-pen: vintage-pen))
        } else {
        place(top + left, curve(
          stroke: (paint: ink, thickness: w),
          curve.move((0.14 * W, 0.06 * H)),
          curve.cubic((0.30 * W, -0.02 * H), (0.46 * W, 0.02 * H), (0.50 * W, -0.06 * H)),
          curve.cubic((0.54 * W, 0.02 * H), (0.70 * W, -0.02 * H), (0.86 * W, 0.06 * H)),
          curve.cubic((0.955 * W, 0.22 * H), (0.955 * W, 0.78 * H), (0.86 * W, 0.94 * H)),
          curve.cubic((0.70 * W, 1.02 * H), (0.54 * W, 0.98 * H), (0.50 * W, 1.06 * H)),
          curve.cubic((0.46 * W, 0.98 * H), (0.30 * W, 1.02 * H), (0.14 * W, 0.94 * H)),
          curve.cubic((0.045 * W, 0.78 * H), (0.045 * W, 0.22 * H), (0.14 * W, 0.06 * H)),
          curve.close(mode: "straight"),
        ))
        }
        for sx in (1, -1) {
          let xx = if sx == 1 { 0.055 * W } else { 0.945 * W }
          for k in (-1, 0, 1) {
            L(((xx - sx * 0.008 * W, cy + k * 0.16 * H),
              (xx - sx * 0.040 * W, cy + k * 0.26 * H)), ink, w * 0.9)
          }
          for t in ((-0.30, -0.34), (0.0, -0.40), (0.30, -0.34),
            (-0.30, 0.34), (0.0, 0.40), (0.30, 0.34)) {
            place(top + left, dx: xx - sx * 0.020 * W + t.at(0) * 0.06 * W,
              dy: cy + t.at(1) * H, circle(radius: 0.040 * H, fill: ink))
          }
        }
      } else if style == "fans" {
        // double-ruled notched plaque with fan volutes at both ends
        let c = 0.30 * H
        for (o, sw2) in ((0pt, w * 1.4), (0.10 * H, w * 0.55)) {
          if vintage {
            place(top + left, vintage-pts(
              _plate-pts(W, H, 0.10, c, o), ink, sw2, closed: true,
              vintage-pen: vintage-pen))
          } else {
          place(top + left, curve(
            stroke: (paint: ink, thickness: sw2),
            curve.move((0.10 * W + c + o, o)),
            curve.line((0.90 * W - c - o, o)),
            curve.cubic((0.90 * W - c * 0.3, c * 0.3), (0.90 * W - c * 0.3, c * 0.3), (0.90 * W - o, c + o)),
            curve.line((0.90 * W - o, H - c - o)),
            curve.cubic((0.90 * W - c * 0.3, H - c * 0.3), (0.90 * W - c * 0.3, H - c * 0.3), (0.90 * W - c - o, H - o)),
            curve.line((0.10 * W + c + o, H - o)),
            curve.cubic((0.10 * W + c * 0.3, H - c * 0.3), (0.10 * W + c * 0.3, H - c * 0.3), (0.10 * W + o, H - c - o)),
            curve.line((0.10 * W + o, c + o)),
            curve.cubic((0.10 * W + c * 0.3, c * 0.3), (0.10 * W + c * 0.3, c * 0.3), (0.10 * W + c + o, o)),
            curve.close(mode: "straight"),
          ))
          }
        }
        for sx in (1, -1) {
          let xx = if sx == 1 { 0.055 * W } else { 0.945 * W }
          SP(xx, cy - 0.22 * H, 0.17 * H, 0.015 * H, 90, 1.8, ink, w, sx: -sx, sy: 1)
          SP(xx, cy + 0.22 * H, 0.17 * H, 0.015 * H, -90, 1.8, ink, w, sx: -sx, sy: -1)
          VP(((xx - sx * 0.045 * W, cy), (xx - sx * 0.012 * W, cy - 0.10 * H), (xx + sx * 0.012 * W, cy), (xx - sx * 0.012 * W, cy + 0.10 * H)), ink)
        }
      } else if style == "waves" {
        // notched plaque with a wavy loop ornament top and bottom
        let c = 0.30 * H
        if vintage {
          place(top + left, vintage-pts(
            _plate-pts(W, H, 0.10, c, 0pt), ink, w * 1.5, closed: true,
            vintage-pen: vintage-pen))
        } else {
        place(top + left, curve(
          stroke: (paint: ink, thickness: w * 1.5),
          curve.move((0.10 * W + c, 0.04 * H)),
          curve.line((0.90 * W - c, 0.04 * H)),
          curve.cubic((0.90 * W - c * 0.3, 0.04 * H + c * 0.3), (0.90 * W - c * 0.3, 0.04 * H + c * 0.3), (0.90 * W, 0.04 * H + c)),
          curve.line((0.90 * W, 0.96 * H - c)),
          curve.cubic((0.90 * W - c * 0.3, 0.96 * H - c * 0.3), (0.90 * W - c * 0.3, 0.96 * H - c * 0.3), (0.90 * W - c, 0.96 * H)),
          curve.line((0.10 * W + c, 0.96 * H)),
          curve.cubic((0.10 * W + c * 0.3, 0.96 * H - c * 0.3), (0.10 * W + c * 0.3, 0.96 * H - c * 0.3), (0.10 * W, 0.96 * H - c)),
          curve.line((0.10 * W, 0.04 * H + c)),
          curve.cubic((0.10 * W + c * 0.3, 0.04 * H + c * 0.3), (0.10 * W + c * 0.3, 0.04 * H + c * 0.3), (0.10 * W + c, 0.04 * H)),
          curve.close(mode: "straight"),
        ))
        }
        for sy in (1, -1) {
          let yy = if sy == 1 { 0.04 * H } else { 0.96 * H }
          let s = -sy
          L(((0.36 * W, yy), (0.40 * W, yy + s * 0.10 * H), (0.44 * W, yy - s * 0.06 * H), (0.47 * W, yy + s * 0.06 * H)), ink, w * 0.9)
          L(((0.53 * W, yy + s * 0.06 * H), (0.56 * W, yy - s * 0.06 * H), (0.60 * W, yy + s * 0.10 * H), (0.64 * W, yy)), ink, w * 0.9)
          if vintage {
            place(top + left, dx: 0.485 * W, dy: yy - s * 0.09 * H,
              vintage-pts(_ell-pts(0.015 * W, 0.11 * H, 0.015 * W, 0.11 * H),
                ink, w * 0.9, vintage-pen: vintage-pen))
          } else {
            place(top + left, dx: 0.485 * W, dy: yy - s * 0.09 * H,
              ellipse(width: 0.030 * W, height: 0.22 * H, stroke: (paint: ink, thickness: w * 0.9)))
          }
        }
      } else if style == "hooks" {
        // top and bottom double rules with big comma volutes at the corners
        L(((0.14 * W, 0pt), (0.86 * W, 0pt)), ink, w * 1.5)
        L(((0.14 * W, 0.13 * H), (0.86 * W, 0.13 * H)), ink, w * 0.6)
        L(((0.14 * W, H), (0.86 * W, H)), ink, w * 1.5)
        L(((0.14 * W, 0.87 * H), (0.86 * W, 0.87 * H)), ink, w * 0.6)
        for sx in (1, -1) {
          for sy in (1, -1) {
            let xx = if sx == 1 { 0.10 * W } else { 0.90 * W }
            let yy = if sy == 1 { 0.10 * H } else { 0.90 * H }
            SP(xx, yy, 0.20 * H, 0.02 * H, 0, 1.9, ink, w * 1.2, sx: -sx, sy: -sy)
            SP(xx, yy + sy * 0.62 * H, 0.20 * H, 0.02 * H, 0, 1.9, ink, w * 1.2, sx: -sx, sy: -sy)
          }
        }
      } else if style == "fleuron" {
        // double-ruled notched plaque with a small fleuron at top centre
        let c = 0.30 * H
        for (o, sw2) in ((0pt, w * 1.4), (0.11 * H, w * 0.55)) {
          if vintage {
            place(top + left, vintage-pts(
              _plate-pts(W, H, 0.06, c, o), ink, sw2, closed: true,
              vintage-pen: vintage-pen))
          } else {
          place(top + left, curve(
            stroke: (paint: ink, thickness: sw2),
            curve.move((0.06 * W + c + o, o)),
            curve.line((0.94 * W - c - o, o)),
            curve.cubic((0.94 * W - c * 0.3, c * 0.3), (0.94 * W - c * 0.3, c * 0.3), (0.94 * W - o, c + o)),
            curve.line((0.94 * W - o, H - c - o)),
            curve.cubic((0.94 * W - c * 0.3, H - c * 0.3), (0.94 * W - c * 0.3, H - c * 0.3), (0.94 * W - c - o, H - o)),
            curve.line((0.06 * W + c + o, H - o)),
            curve.cubic((0.06 * W + c * 0.3, H - c * 0.3), (0.06 * W + c * 0.3, H - c * 0.3), (0.06 * W + o, H - c - o)),
            curve.line((0.06 * W + o, c + o)),
            curve.cubic((0.06 * W + c * 0.3, c * 0.3), (0.06 * W + c * 0.3, c * 0.3), (0.06 * W + c + o, o)),
            curve.close(mode: "straight"),
          ))
          }
        }
        // fleuron: three petals at the top centre
        VP(((0.50 * W, -0.22 * H), (0.52 * W, -0.06 * H), (0.50 * W, -0.10 * H), (0.48 * W, -0.06 * H)), ink)
        L(varc(0.475 * W, -0.02 * H, 0.09 * H, 180, 340, n: 16), ink, w * 0.7)
        L(varc(0.525 * W, -0.02 * H, 0.09 * H, 200, 360, n: 16), ink, w * 0.7)
      }
      place(top + left, block(width: W, height: H,
        align(center + horizon, label)))
    })
  })
}

/// French alias for `vintageframe`.
#let cadre-vintage(..a) = vintageframe(..a)
