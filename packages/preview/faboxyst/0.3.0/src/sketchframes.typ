// Hand-sketched frames for a block of content, drawn with nibart pens:
// vintage ink (double border, corner hatches, oval / twin windows or a bevelled
// "THE END" panel), charcoal, wax crayon and pencil. The dry media use nibart's
// `pressure` so that the thin parts of the stroke break up like grain on paper.
#import "infokit.typ": *

// a slightly shaky straight line from p to q
#let _seg(p, q, J, o, amp, n: 7) = {
  let dx = q.at(0) - p.at(0)
  let dy = q.at(1) - p.at(1)
  let l = calc.max(0.001, calc.sqrt(dx * dx + dy * dy))
  range(n + 1).map(i => {
    let t = i / n
    let e = if i == 0 or i == n { 0 } else { J.at(o + i) * amp }
    (p.at(0) + dx * t - dy / l * e, p.at(1) + dy * t + dx / l * e)
  })
}
#let _wob-rect(x, y, w, h, J, o, amp) = {
  let a = (x, y)
  let b = (x + w, y)
  let c = (x + w, y + h)
  let d = (x, y + h)
  _seg(a, b, J, o, amp) + _seg(b, c, J, o + 10, amp).slice(1) + _seg(c, d, J, o + 20, amp).slice(1) + _seg(d, a, J, o + 30, amp).slice(1)
}
#let _ell(cx, cy, rx, ry, J, o, amp, n: 12) = range(n).map(i => {
  let a = i / n * 360deg
  let e = 1 + J.at(o + i) * amp
  (cx + rx * e * calc.cos(a), cy + ry * e * calc.sin(a))
})

// ---------------------------------------------------------------------------
/// Inked frame: thick calligraphic outline, two fine inner lines, corner
/// hatches; optionally a window.
///
/// - `window`: `none`, `"oval"`, `"rect"`, `"twin-oval"`, `"twin-rect"` (give
///   `body` as an array of two contents for the twin windows).
/// - `inner`: `none` or `"bevel"` (grey chamfered panel, "THE END" style).
#let vintage-frame(
  body, width: auto, height: 7cm, direction: auto,
  window: none, inner: none, ink: black, thickness: 3.2pt, seed: 4, align: center + horizon,
) = canvas(width, height, direction, (body,), (Wc, Hc, rtl, print, k) => {
  let ink = if print { black } else { ink }
  let J = jitter(seed, 400)
  let a = 0.045
  let pen(pts, w, closed: false, smooth: false) = (k.ink)(pts, w: w, paint: ink, closed: closed, smooth: smooth)
  let shapes = {
    pen(_wob-rect(0.12, 0.12, Wc - 0.24, Hc - 0.24, J, 0, a).slice(0, -1), thickness, closed: true)
    pen(_wob-rect(0.42, 0.42, Wc - 0.84, Hc - 0.84, J, 60, a * 0.4).slice(0, -1), 1.0pt, closed: true)
    pen(_wob-rect(0.58, 0.58, Wc - 1.16, Hc - 1.16, J, 120, a * 0.4).slice(0, -1), 1.0pt, closed: true)
    for (cx, cy, sx, sy) in ((0.42, 0.42, 1, 1), (Wc - 0.42, 0.42, -1, 1), (Wc - 0.42, Hc - 0.42, -1, -1), (0.42, Hc - 0.42, 1, -1)) {
      for d in (0.0, 0.17, 0.34) {
        pen(((cx + sx * (0.95 - d), cy), (cx, cy + sy * (0.95 - d))), 1.0pt)
      }
    }
    let x0 = 1.0
    let y0 = 1.0
    let w = Wc - 2.0
    let h = Hc - 2.0
    if inner == "bevel" {
      let ch(x, y, w, h, c) = ((x + c, y), (x + w - c, y), (x + w, y + c), (x + w, y + h - c), (x + w - c, y + h), (x + c, y + h), (x, y + h - c), (x, y + c))
      (k.poly)(ch(x0, y0, w, h, 0.45), fill: gradient.linear(luma(95), luma(150), luma(80), angle: 90deg), stroke: 1.2pt + ink)
      (k.poly)(ch(x0 + 0.35, y0 + 0.3, w - 0.7, h - 0.6, 0.25), fill: white, stroke: 0.9pt + luma(60))
    } else if window == "oval" {
      (k.ell-ink)(Wc / 2, Hc / 2, w / 2, h / 2, w: 1.7pt, paint: ink)
    } else if window == "rect" {
      pen(_wob-rect(x0, y0, w, h, J, 200, a * 0.5).slice(0, -1), 1.7pt, closed: true)
    } else if window == "twin-oval" or window == "twin-rect" {
      let ww = w * 0.455
      for (j, xx) in (x0, x0 + w - ww).enumerate() {
        if window == "twin-oval" {
          (k.ell-ink)(xx + ww / 2, Hc / 2, ww / 2, h / 2, w: 1.7pt, paint: ink)
        } else {
          pen(_wob-rect(xx, y0, ww, h, J, 250 + j * 40, a * 0.5).slice(0, -1), 1.7pt, closed: true)
        }
      }
      let mx = Wc / 2
      pen(((mx, y0 + 0.9), (mx, Hc / 2 - 0.2)), 1.2pt)
      pen(((mx, Hc / 2 + 0.2), (mx, Hc - y0 - 0.9)), 1.2pt)
      pen(((mx - 0.13, Hc / 2 - 0.12), (mx + 0.13, Hc / 2 + 0.12)), 1.2pt)
      pen(((mx + 0.13, Hc / 2 - 0.12), (mx - 0.13, Hc / 2 + 0.12)), 1.2pt)
      pen(((mx - 0.5, y0 + 0.05), (mx + 0.5, y0 + 0.05), (mx, y0 + 0.75)), 1.2pt, closed: true)
      pen(((mx - 0.5, Hc - y0 - 0.05), (mx + 0.5, Hc - y0 - 0.05), (mx, Hc - y0 - 0.75)), 1.2pt, closed: true)
    }
  }
  let texts = {
    let pad = if inner == "bevel" { 1.7 } else if window == none { 1.2 } else { 2.0 }
    if window == "twin-oval" or window == "twin-rect" {
      let ww = (Wc - 2.0) * 0.455
      let bs = if type(body) == array { body } else { (body, none) }
      (k.tx)(1.0 + 0.5, 1.4, ww - 1.0, Hc - 2.8, bs.at(0), al: align)
      (k.tx)(Wc - 1.0 - ww + 0.5, 1.4, ww - 1.0, Hc - 2.8, bs.at(1), al: align)
    } else {
      (k.tx)(pad, pad, Wc - 2 * pad, Hc - 2 * pad, body, al: align)
    }
  }
  (k.layer)(shapes) + texts
}, default-height: height)

// ---------------------------------------------------------------------------
// rows of hatching over a band: `inter(y)` gives the x-intervals of the band at
// height y; every group of rows is one boustrophedon scribble (one nib stroke).
#let _hatch(inter, y0, y1, dy, J, o, rag) = {
  let paths = ()
  let cur = ()
  let last-n = 0
  let n = int((y1 - y0) / dy)
  let sweep(r, key) = cur  // (placeholder to keep the closure style simple)
  let groups = (top: (), left: (), right: (), bottom: ())
  let phase = "top"
  for r in range(n + 1) {
    let y = y0 + r * dy + J.at(calc.rem(o + r * 3, 400)) * dy * 0.4
    let iv = inter(y)
    let fwd = calc.even(r)
    if iv.len() == 2 {
      if phase == "top" { phase = "mid" }
      for (c, key) in ((iv.at(0), "left"), (iv.at(1), "right")) {
        let a = c.at(0) + J.at(calc.rem(o + r * 5 + 1, 400)) * rag
        let b = c.at(1) + J.at(calc.rem(o + r * 5 + 2, 400)) * rag
        let e1 = J.at(calc.rem(o + r * 7 + 3, 400)) * dy * 2.2
        let e2 = J.at(calc.rem(o + r * 7 + 4, 400)) * dy * 2.2
        groups.insert(key, groups.at(key) + if fwd { ((a, y + e1), (b, y + e2)) } else { ((b, y + e2), (a, y + e1)) })
      }
    } else if iv.len() == 1 {
      let key = if phase == "top" { "top" } else { phase = "bottom"; "bottom" }
      let c = iv.at(0)
      let a = c.at(0) + J.at(calc.rem(o + r * 5 + 1, 400)) * rag
      let b = c.at(1) + J.at(calc.rem(o + r * 5 + 2, 400)) * rag
      let e1 = J.at(calc.rem(o + r * 7 + 3, 400)) * dy * 2.2
      let e2 = J.at(calc.rem(o + r * 7 + 4, 400)) * dy * 2.2
      groups.insert(key, groups.at(key) + if fwd { ((a, y + e1), (b, y + e2)) } else { ((b, y + e2), (a, y + e1)) })
    }
  }
  groups.values().filter(g => g.len() > 1)
}

/// Charcoal: scribbled horizontal hatching round the content, rectangular or
/// elliptic, dark on the line of the frame and fading outwards and inwards.
/// `shape`: `"rect"` or `"ellipse"`.
#let charcoal-frame(
  body, width: auto, height: 7cm, direction: auto,
  shape: "rect", ink: luma(30), density: 1.0, band: 0.3, weight: 100%, seed: 11, align: center + horizon,
) = canvas(width, height, direction, (body,), (Wc, Hc, rtl, print, k) => {
  let J = jitter(seed, 400)
  let mg = 0.35 + band
  let (x0, y0, w, h) = (mg, mg, Wc - 2 * mg, Hc - 2 * mg)
  let (cx, cy) = (Wc / 2, Hc / 2)
  let inter(b) = y => {
    if shape == "ellipse" {
      let (rxo, ryo, rxi, ryi) = (w / 2 + b, h / 2 + b, w / 2 - b, h / 2 - b)
      let dy = y - cy
      if calc.abs(dy) >= ryo { () } else {
        let xo = rxo * calc.sqrt(1 - calc.pow(dy / ryo, 2))
        if calc.abs(dy) < ryi {
          let xi = rxi * calc.sqrt(1 - calc.pow(dy / ryi, 2))
          ((cx - xo, cx - xi), (cx + xi, cx + xo))
        } else { ((cx - xo, cx + xo),) }
      }
    } else {
      if y < y0 - b or y > y0 + h + b { () }
      else if y > y0 + b and y < y0 + h - b { ((x0 - b, x0 + b), (x0 + w - b, x0 + w + b)) }
      else { ((x0 - b, x0 + w + b),) }
    }
  }
  let shapes = {
    // soft smudge under the hatching: a few very wide, nearly transparent strokes
    let ring = range(16).map(i => {
      let t = i / 16 * 360deg
      let e = 1 + J.at(300 + i) * 0.015
      if shape == "ellipse" { (cx + w / 2 * e * calc.cos(t), cy + h / 2 * e * calc.sin(t)) }
      else {
        let (c, s) = (calc.cos(t), calc.sin(t))
        let m = calc.max(calc.abs(c) * h / w, calc.abs(s))   // push the points out to the rectangle
        (cx + w / 2 * c / calc.max(calc.abs(c), calc.abs(s) * w / h) * e, cy + h / 2 * s / calc.max(calc.abs(c) * h / w, calc.abs(s)) * e)
      }
    })
    for j in range(3) {
      (k.ink)(ring.map(p => (p.at(0) + J.at(320 + j * 20) * 0.1, p.at(1) + J.at(321 + j * 20) * 0.1)), w: 14pt * band * weight + 4pt * j, paint: ink.transparentize(88%), thin: 90%, angle: 0deg, closed: true, smooth: true)
    }
    for (pi, (bf, al, wd, dy, rag)) in ((1.0, 35%, 1.3pt, 0.08, 0.9), (0.7, 55%, 2.0pt, 0.06, 0.6), (0.42, 78%, 2.8pt, 0.05, 0.45), (0.2, 92%, 3.4pt, 0.045, 0.3)).enumerate() {
      let paths = _hatch(inter(band * bf), y0 - band * bf, y0 + h + band * bf, dy / density, J, pi * 77, rag * band / 0.9)
      for (gi, g) in paths.enumerate() {
        (k.ink)(g, w: wd * weight, paint: ink.transparentize(100% - al), thin: 60%, angle: 0deg, press: (0.35pt, 2.2pt, seed + pi * 9 + gi), dash: (46pt, 7pt))
      }
    }
  }
  let pad = mg + 0.5
  (k.layer)(shapes) + (k.tx)(pad, pad, Wc - 2 * pad, Hc - 2 * pad, body, al: align)
}, default-height: height)

// ---------------------------------------------------------------------------
/// Wax-crayon scribbles in a few colours, running round the frame.
#let crayon-frame(
  body, width: auto, height: 7cm, direction: auto,
  colours: (rgb("#8DC21F"), rgb("#FFC800"), rgb("#8AA316")), band: 0.5, weight: 100%, density: 1.0, seed: 8,
  align: center + horizon,
) = canvas(width, height, direction, (body,), (Wc, Hc, rtl, print, k) => {
  let per = 2 * (Wc + Hc)
  let at(s, o) = {
    let s = calc.rem(s, per)
    if s < Wc { (s, o) }
    else if s < Wc + Hc { (Wc - o, s - Wc) }
    else if s < 2 * Wc + Hc { (Wc - (s - Wc - Hc), Hc - o) }
    else { (o, Hc - (s - 2 * Wc - Hc)) }
  }
  let shapes = for (ci, c) in colours.enumerate() {
    let c = pc(c, print)
    // the pen drifts forward, swings in and out of the band, now and then goes back
    let n = int(per / 0.2 * 1.08 * density)
    let R = jitter(seed + ci * 13, n * 3 + 6)
    let pts = ()
    let s = ci * 0.4
    for j in range(n) {
      s += -0.2 + (R.at(j * 3) + 1) * 0.4
      let inside = calc.even(j) == (R.at(j * 3 + 2) > -0.6)
      let o = if inside { band * (0.5 + 0.5 * (R.at(j * 3 + 1) + 1) / 2) } else { band * 0.35 * (R.at(j * 3 + 1) + 1) / 2 }
      pts.push(at(s, calc.max(0.02, o)))
    }
    (k.ink)(pts, w: 3.4pt * weight, paint: c, thin: 70%, angle: 30deg, press: (1.3pt, 5pt, seed + ci))
  }
  let pad = band + 0.5
  (k.layer)(shapes) + (k.tx)(pad, pad, Wc - 2 * pad, Hc - 2 * pad, body, al: align)
}, default-height: height)

// ---------------------------------------------------------------------------
/// Pencil outline: several shaky lines per side that overshoot the corners, one
/// or two panels, and a small row of doodled shapes at the foot.
#let pencil-sketch-frame(
  body, width: auto, height: 7cm, direction: auto,
  panels: 1, doodles: true, ink: luma(45), lines: 3, seed: 6, align: center + horizon,
) = canvas(width, height, direction, (body,), (Wc, Hc, rtl, print, k) => {
  let ink = if print { black } else { ink }
  let J = jitter(seed, 600)
  let pw = (Wc - 0.5 - (panels - 1) * 0.5) / panels
  let pencil(pts, w, o, closed: false, smooth: false) = (k.ink)(pts, w: w, paint: ink, thin: 75%, angle: 20deg, closed: closed, smooth: smooth,
    press: (0.3pt, 3pt, seed + o))
  let shapes = {
    for p in range(panels) {
      let px = 0.25 + p * (pw + 0.5)
      for l in range(lines) {
        let o = p * 100 + l * 20
        let (a, b, c, d) = (px + J.at(o) * 0.08, 0.25 + J.at(o + 1) * 0.08, px + pw + J.at(o + 2) * 0.08, 0.25 + Hc - 0.5 + J.at(o + 3) * 0.08)
        let ov = 0.05 + 0.15 * (J.at(o + 4) + 1) / 2
        let w = 1.1pt + 0.3pt * l
        pencil(_seg((a - ov, b + J.at(o + 5) * 0.05), (c + ov, b + J.at(o + 6) * 0.05), J, o + 10, 0.02), w, o)
        pencil(_seg((c + J.at(o + 7) * 0.05, b - ov), (c + J.at(o + 8) * 0.05, d + ov), J, o + 20, 0.02), w, o + 1)
        pencil(_seg((c + ov, d + J.at(o + 9) * 0.05), (a - ov, d + J.at(o + 11) * 0.05), J, o + 30, 0.02), w, o + 2)
        pencil(_seg((a + J.at(o + 12) * 0.05, d + ov), (a + J.at(o + 13) * 0.05, b - ov), J, o + 40, 0.02), w, o + 3)
      }
    }
    if doodles {
      let y = Hc - 0.95
      let x = Wc - 4.2
      pencil(((x, y), (x + 0.5, y), (x + 0.5, y + 0.5), (x, y + 0.5)), 1.1pt, 500, closed: true)
      pencil(((x + 0.7, y - 0.05), (x + 1.2, y), (x + 1.15, y + 0.6), (x + 0.7, y + 0.55)), 1.1pt, 501, closed: true)
      pencil(range(10).map(i => (x + 2.0 + 0.5 * calc.cos(i * 36deg) - 0.2 * calc.sin(i * 36deg) * 1.0, y + 0.3 + 0.14 * calc.sin(i * 36deg) + 0.25 * calc.cos(i * 36deg) * 0.5)), 1.1pt, 502, closed: true, smooth: true)
      pencil(range(8).map(i => (x + 2.95 + 0.27 * calc.cos(i * 45deg), y + 0.3 + 0.27 * calc.sin(i * 45deg))), 1.1pt, 503, closed: true, smooth: true)
      pencil(((x + 3.35, y), (x + 3.95, y), (x + 3.65, y + 0.55)), 1.1pt, 504, closed: true)
    }
  }
  let texts = for p in range(panels) {
    let b = if type(body) == array { body.at(p, default: none) } else if p == 0 { body } else { none }
    (k.tx)(0.25 + p * (pw + 0.5) + 0.5, 0.7, pw - 1.0, Hc - 1.4 - if doodles { 0.5 } else { 0 }, b, al: align)
  }
  (k.layer)(shapes) + texts
}, default-height: height)
