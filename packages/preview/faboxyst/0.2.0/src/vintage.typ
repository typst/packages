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

// ---------------------------------------------------------------------------
//  shared helpers
// ---------------------------------------------------------------------------

// Sampled circular arc (screen angles: 0 = right, 90 = down).
#let varc(cx, cy, r, a0, a1, n: 32) = {
  range(n + 1).map(i => {
    let a = (a0 + (a1 - a0) * i / n) * 1deg
    (cx + r * calc.cos(a), cy + r * calc.sin(a))
  })
}

// Open ink polyline through sampled points.
#let vline(pts, paint, w, closed: false, dx: 0pt, dy: 0pt) = {
  if pts.len() < 2 { return }
  let segs = (curve.move(pts.first()),) + pts.slice(1).map(p => curve.line(p))
  let segs = if closed { segs + (curve.close(mode: "straight"),) } else { segs }
  place(top + left, dx: dx, dy: dy, curve(
    stroke: (paint: paint, thickness: w, join: "round", cap: "round"),
    ..segs,
  ))
}

// Filled / stroked polygon from points.
#let vpoly(pts, paint, w: 0pt, closed: true, dx: 0pt, dy: 0pt) = {
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
#let _edge(p0, p1, out, kind: "flat", tip: false, tl: 0.10, td: 3pt, bump: none) = {
  // p0 → p1 along an axis; `out` is the unit outward normal (nx, ny)
  let comps = ()
  let (x0, y0) = p0
  let (x1, y1) = p1
  let (nx, ny) = out
  let dx = x1 - x0
  let dy = y1 - y0
  let len = if dx == 0pt { dy } else { dx }
  if kind == "wave" {
    let b = if bump == none { 0.09 * len } else { bump }
    let q = a => (x0 + dx * a.at(0) + nx * b * a.at(1),
      y0 + dy * a.at(0) + ny * b * a.at(1))
    comps = comps + (
      curve.cubic(q((0.10, 0)), q((0.16, 1.0)), q((0.25, 1.0))),
      curve.cubic(q((0.34, 1.0)), q((0.40, 0)), q((0.46, 0))),
    )
    if tip {
      comps = comps + (
        curve.line(q((0.485, 0))),
        curve.line(q((0.50, 1.6))),
        curve.line(q((0.515, 0))),
      )
    }
    comps = comps + (
      curve.cubic(q((0.60, 0)), q((0.66, 1.0)), q((0.75, 1.0))),
      curve.cubic(q((0.84, 1.0)), q((0.90, 0)), q((1.0, 0))),
    )
  } else if kind == "lobe" {
    // a protruding rounded tab with concave flanks, after the EPS column
    let d = 0.12 * len
    let q = a => (x0 + dx * a.at(0) + nx * d * a.at(1),
      y0 + dy * a.at(0) + ny * d * a.at(1))
    comps = comps + (
      curve.line(q((0.24, 0))),
      curve.cubic(q((0.285, 0.15)), q((0.30, 0.55)), q((0.345, 0.85))),
      curve.cubic(q((0.40, 1.15)), q((0.60, 1.15)), q((0.655, 0.85))),
      curve.cubic(q((0.70, 0.55)), q((0.715, 0.15)), q((0.76, 0))),
      curve.line(p1),
    )
  } else {
    if tip {
      comps = comps + (
        curve.line((x0 + dx * (0.5 - tl / 2), y0 + dy * (0.5 - tl / 2))),
        curve.line((x0 + dx * 0.5 + nx * td, y0 + dy * 0.5 + ny * td)),
        curve.line((x0 + dx * (0.5 + tl / 2), y0 + dy * (0.5 + tl / 2))),
      )
    }
    comps = comps + (curve.line(p1),)
  }
  comps
}

// Concave corner fillet from edge end `pa` around corner `pc` to `pb`.
#let _corner(pa, pc, pb) = {
  (curve.cubic(
    (pa.at(0) + (pc.at(0) - pa.at(0)) * 0.22, pa.at(1) + (pc.at(1) - pa.at(1)) * 0.22),
    (pb.at(0) + (pc.at(0) - pb.at(0)) * 0.22, pb.at(1) + (pc.at(1) - pb.at(1)) * 0.22),
    pb,
  ),)
}

// The full plaque outline as curve components, inset by `o` on every side.
#let plaque-comps(W, H, o, c, kind: "flat", tips: (t: true, b: true, l: true, r: true), bump: none) = {
  let x0 = o
  let y0 = o
  let x1 = W - o
  let y1 = H - o
  // corner cut points on each side
  let tl = (x0 + c, y0)
  let tr = (x1 - c, y0)
  let rt = (x1, y0 + c)
  let rb = (x1, y1 - c)
  let br = (x1 - c, y1)
  let bl = (x0 + c, y1)
  let lb = (x0, y1 - c)
  let lt = (x0, y0 + c)
  let comps = (curve.move(tl),)
  comps = comps + _edge(tl, tr, (0, -1), kind: kind, tip: tips.t, bump: bump)
  comps = comps + _corner(tr, (x1, y0), rt)
  comps = comps + _edge(rt, rb, (1, 0), kind: "flat", tip: tips.r)
  comps = comps + _corner(rb, (x1, y1), br)
  comps = comps + _edge(br, bl, (0, 1), kind: kind, tip: tips.b, bump: bump)
  comps = comps + _corner(bl, (x0, y1), lb)
  comps = comps + _edge(lb, lt, (-1, 0), kind: "flat", tip: tips.l)
  comps = comps + _corner(lt, (x0, y0), tl)
  comps + (curve.close(mode: "straight"),)
}

// Draw one plaque layer (fill + rule) at inset o.
#let _plaque-layer(W, H, o, c, kind, tips, fill, stroke-c, sw, bump: none) = {
  place(top + left, curve(
    fill: fill,
    stroke: if sw == 0pt { none } else { (paint: stroke-c, thickness: sw) },
    ..plaque-comps(W, H, o, c, kind: kind, tips: tips, bump: bump),
  ))
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
) = context {
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
      _plaque-layer(W, H, 0.8pt, c, kind, tips, fill, ink, 1.5pt, bump: bump)
      // thin inner rule
      _plaque-layer(W, H, 3.4pt, c * 0.86, kind, tips, none, ink, 0.55pt, bump: bump)
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
#let _spiral(cx, cy, r0, r1, a0, turns, paint, w, sx: 1, sy: 1) = {
  ink-pts(spiral-pts(cx, cy, r0, r1, a0, turns, sx: sx, sy: sy), paint, w)
}

/// A scrollwork label frame after the vintage SVG sheet. Eight line-art
/// styles are available through `style`; the content sits centred inside.
///
/// ```typ
/// #vintageframe(style: "volutes")[Chapitre I]
/// #vintageframe(style: "fleuron", ink: rgb("#5A4632"))[Sommaire]
/// ```
#let vintageframe(
  body,
  style: "volutes",
  ink: rgb("#141414"),
  width: 100%,
  inset: (x: 1.4em, y: 0.8em),
  text-fill: auto,
  text-size: 1em,
  weight: auto,
) = context {
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
    let block-h = H + 1.2 * H             // room for the outer ornament
    block(width: W, height: if style == "loops" or style == "hooks" { H + 0.9em } else { H }, {
      let cy = H / 2
      if style == "volutes" {
        // double rules top and bottom, side ticks, corner + centre volutes
        let yo = 0pt
        let yi = 0.14 * H
        vline(((0.10 * W, yo), (0.42 * W, yo)), ink, w)
        vline(((0.58 * W, yo), (0.90 * W, yo)), ink, w)
        vline(((0.10 * W, H), (0.42 * W, H)), ink, w)
        vline(((0.58 * W, H), (0.90 * W, H)), ink, w)
        vline(((0.115 * W, yi), (0.435 * W, yi)), ink, w * 0.6)
        vline(((0.565 * W, yi), (0.885 * W, yi)), ink, w * 0.6)
        vline(((0.115 * W, H - yi), (0.435 * W, H - yi)), ink, w * 0.6)
        vline(((0.565 * W, H - yi), (0.885 * W, H - yi)), ink, w * 0.6)
        vline(((0.045 * W, 0.30 * H), (0.045 * W, 0.70 * H)), ink, w * 0.7)
        vline(((0.955 * W, 0.30 * H), (0.955 * W, 0.70 * H)), ink, w * 0.7)
        // centre ornaments: paired volutes and a double tick, top & bottom
        for sy in (1, -1) {
          let yy = if sy == 1 { 0pt } else { H }
          _spiral(0.455 * W, yy + sy * -0.10 * H, 0.16 * H, 0.015 * H, -90 * sy, 1.7, ink, w * 0.8, sx: 1, sy: sy)
          _spiral(0.545 * W, yy + sy * -0.10 * H, 0.16 * H, 0.015 * H, -90 * sy, 1.7, ink, w * 0.8, sx: -1, sy: sy)
          vline(((0.492 * W, yy + sy * -0.16 * H), (0.492 * W, yy + sy * 0.02 * H)), ink, w * 0.7)
          vline(((0.508 * W, yy + sy * -0.16 * H), (0.508 * W, yy + sy * 0.02 * H)), ink, w * 0.7)
          // small corner volutes at the four ends of the side ticks
          for sx2 in (1, -1) {
            let xx = if sx2 == 1 { 0.045 * W } else { 0.955 * W }
            _spiral(xx, yy + sy * -0.06 * H, 0.10 * H, 0.012 * H, 90 * sy, 1.6, ink, w * 0.7, sx: -sx2, sy: sy)
          }
        }
      } else if style == "curls" {
        // notched plaque with a corner curl outside each notch
        let c = 0.28 * H
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
        for sx in (1, -1) {
          for sy in (1, -1) {
            let xx = if sx == 1 { 0.045 * W } else { 0.955 * W }
            let yy = if sy == 1 { 0.10 * H } else { 0.90 * H }
            _spiral(xx, yy, 0.15 * H, 0.015 * H, 0, 1.8, ink, w * 1.1, sx: -sx, sy: -sy)
          }
        }
      } else if style == "loops" {
        // stadium outline with loop flourishes above and below
        place(top + left, dx: 0.06 * W, rect(
          width: 0.88 * W, height: H,
          radius: H / 2, stroke: (paint: ink, thickness: w * 1.4),
        ))
        for sy in (1, -1) {
          let cy0 = if sy == 1 { -0.02 * H } else { 1.02 * H }
          let a0 = if sy == 1 { 200 } else { 20 }
          let a1 = if sy == 1 { 340 } else { 160 }
          vline(varc(0.40 * W, cy0, 0.24 * H, a0, a1, n: 24), ink, w * 0.6)
          vline(varc(0.60 * W, cy0, 0.24 * H, a0, a1, n: 24), ink, w * 0.6)
          for i in range(4) {
            let xx = (0.455 + 0.030 * i) * W
            place(top + left, dx: xx, dy: if sy == 1 { -0.16 * H } else { H - 0.14 * H },
              ellipse(width: 0.030 * W, height: 0.30 * H,
                stroke: (paint: ink, thickness: w * 0.6)))
          }
        }
      } else if style == "petals" {
        // slim plaque, pointed top and bottom, floral ends
        let c = 0.5 * H
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
        for sx in (1, -1) {
          let xx = if sx == 1 { 0.055 * W } else { 0.945 * W }
          for k in (-1, 0, 1) {
            vline(((xx - sx * 0.008 * W, cy + k * 0.16 * H),
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
        for sx in (1, -1) {
          let xx = if sx == 1 { 0.055 * W } else { 0.945 * W }
          _spiral(xx, cy - 0.22 * H, 0.17 * H, 0.015 * H, 90, 1.8, ink, w, sx: -sx, sy: 1)
          _spiral(xx, cy + 0.22 * H, 0.17 * H, 0.015 * H, -90, 1.8, ink, w, sx: -sx, sy: -1)
          vpoly(((xx - sx * 0.045 * W, cy), (xx - sx * 0.012 * W, cy - 0.10 * H), (xx + sx * 0.012 * W, cy), (xx - sx * 0.012 * W, cy + 0.10 * H)), ink)
        }
      } else if style == "waves" {
        // notched plaque with a wavy loop ornament top and bottom
        let c = 0.30 * H
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
        for sy in (1, -1) {
          let yy = if sy == 1 { 0.04 * H } else { 0.96 * H }
          let s = -sy
          vline(((0.36 * W, yy), (0.40 * W, yy + s * 0.10 * H), (0.44 * W, yy - s * 0.06 * H), (0.47 * W, yy + s * 0.06 * H)), ink, w * 0.9)
          vline(((0.53 * W, yy + s * 0.06 * H), (0.56 * W, yy - s * 0.06 * H), (0.60 * W, yy + s * 0.10 * H), (0.64 * W, yy)), ink, w * 0.9)
          place(top + left, dx: 0.485 * W, dy: yy - s * 0.09 * H,
            ellipse(width: 0.030 * W, height: 0.22 * H, stroke: (paint: ink, thickness: w * 0.9)))
        }
      } else if style == "hooks" {
        // top and bottom double rules with big comma volutes at the corners
        vline(((0.14 * W, 0pt), (0.86 * W, 0pt)), ink, w * 1.5)
        vline(((0.14 * W, 0.13 * H), (0.86 * W, 0.13 * H)), ink, w * 0.6)
        vline(((0.14 * W, H), (0.86 * W, H)), ink, w * 1.5)
        vline(((0.14 * W, 0.87 * H), (0.86 * W, 0.87 * H)), ink, w * 0.6)
        for sx in (1, -1) {
          for sy in (1, -1) {
            let xx = if sx == 1 { 0.10 * W } else { 0.90 * W }
            let yy = if sy == 1 { 0.10 * H } else { 0.90 * H }
            _spiral(xx, yy, 0.20 * H, 0.02 * H, 0, 1.9, ink, w * 1.2, sx: -sx, sy: -sy)
            _spiral(xx, yy + sy * 0.62 * H, 0.20 * H, 0.02 * H, 0, 1.9, ink, w * 1.2, sx: -sx, sy: -sy)
          }
        }
      } else if style == "fleuron" {
        // double-ruled notched plaque with a small fleuron at top centre
        let c = 0.30 * H
        for (o, sw2) in ((0pt, w * 1.4), (0.11 * H, w * 0.55)) {
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
        // fleuron: three petals at the top centre
        vpoly(((0.50 * W, -0.22 * H), (0.52 * W, -0.06 * H), (0.50 * W, -0.10 * H), (0.48 * W, -0.06 * H)), ink)
        vline(varc(0.475 * W, -0.02 * H, 0.09 * H, 180, 340, n: 16), ink, w * 0.7)
        vline(varc(0.525 * W, -0.02 * H, 0.09 * H, 200, 360, n: 16), ink, w * 0.7)
      }
      place(top + left, block(width: W, height: H,
        align(center + horizon, label)))
    })
  })
}

/// French alias for `vintageframe`.
#let cadre-vintage(..a) = vintageframe(..a)
