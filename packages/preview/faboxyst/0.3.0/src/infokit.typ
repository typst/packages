// Shared kit for the infographic cards and sketched frames (infocards.typ,
// infostacks.typ, sketchframes.typ): direction detection, a tiny drawing API
// in centimetres, rounded polygons, seeded jitter.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "sketchcore.typ" as core
#import "antique.typ": nib

// ---------------------------------------------------------------------------
//  direction: `auto` also looks at the content (Arabic letters), because
//  `is-rtl()` can only read the text settings around the call.
// ---------------------------------------------------------------------------
#let plain-text(c) = {
  if type(c) == str { c }
  else if type(c) == content {
    if c.has("text") { c.text }
    else if c.has("children") { c.children.map(plain-text).join("") }
    else if c.has("body") { plain-text(c.body) }
    else if c.has("child") { plain-text(c.child) }
    else if c.func() == [ ].func() { " " }
    else { "" }
  } else if type(c) == array { c.map(plain-text).join("") }
  else if type(c) == dictionary { c.values().map(plain-text).join("") }
  else { "" }
}
#let _arabic = regex("[\u{0600}-\u{06FF}\u{0750}-\u{077F}]")
#let has-arabic(..xs) = xs.pos().any(x => plain-text(x).find(_arabic) != none)

/// `true` when the layout must be mirrored. Needs a `context`.
#let rtl-of(direction, ..xs) = {
  if direction == std.rtl { true }
  else if direction == ltr { false }
  else { is-rtl() or has-arabic(..xs) }
}

// ---------------------------------------------------------------------------
//  colours
// ---------------------------------------------------------------------------
#let info-colours = (
  rgb("#F4B400"), rgb("#4ABCE6"), rgb("#74B52D"), rgb("#E8431C"), rgb("#7B5EA7"),
)
#let pc(c, print) = if print { c.luma().lighten(30%) } else { c }
#let ink-of(print) = if print { black } else { rgb("#4A4A4A") }

#let two-digits(i) = if i < 9 { "0" + str(i + 1) } else { str(i + 1) }

// ---------------------------------------------------------------------------
//  geometry
// ---------------------------------------------------------------------------
/// Quadratic fillets on the corners of a closed polygon: ((x, y), radius), …
#let rpoly(corners, n: 7) = {
  let out = ()
  let k = corners.len()
  for i in range(k) {
    let (pt, rad) = corners.at(i)
    let prev = corners.at(calc.rem(i + k - 1, k)).first()
    let next = corners.at(calc.rem(i + 1, k)).first()
    let d1 = (prev.at(0) - pt.at(0), prev.at(1) - pt.at(1))
    let d2 = (next.at(0) - pt.at(0), next.at(1) - pt.at(1))
    let l1 = calc.max(0.0001, calc.sqrt(d1.at(0) * d1.at(0) + d1.at(1) * d1.at(1)))
    let l2 = calc.max(0.0001, calc.sqrt(d2.at(0) * d2.at(0) + d2.at(1) * d2.at(1)))
    let r = calc.min(rad, l1 * 0.5, l2 * 0.5)
    if r <= 0.001 { out.push(pt) } else {
      let a0 = (pt.at(0) + d1.at(0) / l1 * r, pt.at(1) + d1.at(1) / l1 * r)
      let a1 = (pt.at(0) + d2.at(0) / l2 * r, pt.at(1) + d2.at(1) / l2 * r)
      for j in range(n + 1) {
        let t = j / n
        let u = 1 - t
        out.push((u * u * a0.at(0) + 2 * u * t * pt.at(0) + t * t * a1.at(0),
                  u * u * a0.at(1) + 2 * u * t * pt.at(1) + t * t * a1.at(1)))
      }
    }
  }
  out
}

/// Rectangle outline points with a different radius on each corner.
#let rrect-pts(x, y, w, h, tl: 0, tr: 0, br: 0, bl: 0) = rpoly((
  ((x, y), tl), ((x + w, y), tr), ((x + w, y + h), br), ((x, y + h), bl)))

/// Quadratic bezier samples.
#let qbez(p0, c, p1, n: 10) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (u * u * p0.at(0) + 2 * u * t * c.at(0) + t * t * p1.at(0),
   u * u * p0.at(1) + 2 * u * t * c.at(1) + t * t * p1.at(1))
})

/// Ellipse samples.
#let ell-pts(cx, cy, rx, ry, n: 72) = range(n).map(i => {
  let a = i / n * 360deg
  (cx + rx * calc.cos(a), cy + ry * calc.sin(a))
})

#let jitter(seed, n) = core.randoms(seed, n)

// ---------------------------------------------------------------------------
//  a canvas in centimetres. `kit(Wc, Hc, rtl)` returns the drawing closures;
//  shapes go into one layer (mirrored as a whole in RTL), text boxes are
//  placed with mirrored coordinates so the words stay readable.
// ---------------------------------------------------------------------------
#let cm(x) = x * 1cm

#let kit(Wc, Hc, rtl) = {
  // y-up points in lengths, as nibart wants them
  let P(x, y) = (x * 1cm, (Hc - y) * 1cm)
  let info(s) = {
    if s == none { none } else {
      let d = type(s) == dictionary
      let w = if d { s.at("thickness", default: 1pt) } else if type(s) == length { s } else { s.thickness }
      let paint = if d { s.at("paint", default: black) } else if type(s) == length { black } else { s.paint }
      let dash = if d { s.at("dash", default: none) } else if type(s) == length { none } else { s.dash }
      if type(dash) == dictionary { dash = dash.at("array", default: none) }
      (w: w, paint: paint, dash: if type(dash) == array and dash.len() > 0 { dash } else { none })
    }
  }
  let auto-stroke(fill) = if type(fill) == color { 0.9pt + fill.darken(40%) }
    else if fill == none { none } else { 0.9pt + luma(70) }
  let fill-items(path, fill) = if fill == none { () } else { (nib.mp-fill(path, fill: fill),) }
  // calligraphic outline: broad nib at 38°
  let stroke-items(path, stroke, fill) = {
    let s = info(if stroke == auto { auto-stroke(fill) } else { stroke })
    if s == none { () } else {
      let pen = nib.nibpen(width: s.w * 1.7, thinness: 32%, angle: 38deg)
      let dsh = if s.dash == none { none } else { nib.dashes(..s.dash) }
      nib.stroke-items(path, pen: pen, fill: s.paint, dash: dsh)
    }
  }
  let soft-shadow(path) = ((1.0, -1.3), (2.2, -2.9), (3.6, -4.8)).map(d =>
    nib.mp-fill(nib.shifted(path, d.at(0) * 1pt, d.at(1) * 1pt), fill: black.transparentize(93%)))
  let shape(path, fill, stroke, shadow) = {
    (if shadow { soft-shadow(path) } else { () }) + fill-items(path, fill) + stroke-items(path, stroke, fill)
  }
  let poly(pts, fill: none, stroke: auto, smooth: false, shadow: false) = {
    let q = pts.map(p => P(p.at(0), p.at(1)))
    let path = if smooth { nib.mp-path-pts(q, cycle: true) } else { nib.polyline(q, cycle: true) }
    shape(path, fill, stroke, shadow)
  }
  let open(pts, stroke: 1pt + black, smooth: false) = {
    let q = pts.map(p => P(p.at(0), p.at(1)))
    let path = if smooth { nib.mp-path-pts(q) } else { nib.polyline(q) }
    stroke-items(path, stroke, none)
  }
  // exact ellipse: four cubic Béziers
  let ell-path(cx, cy, rx, ry) = {
    let k = 0.5523
    let pt(a, b) = P(cx + rx * a, cy + ry * b)
    nib.cubics((
      (pt(1, 0), pt(1, k), pt(k, 1), pt(0, 1)), (pt(0, 1), pt(-k, 1), pt(-1, k), pt(-1, 0)),
      (pt(-1, 0), pt(-1, -k), pt(-k, -1), pt(0, -1)), (pt(0, -1), pt(k, -1), pt(1, -k), pt(1, 0))), cycle: true)
  }
  let ell(cx, cy, rx, ry, fill: none, stroke: auto, shadow: false) = shape(ell-path(cx, cy, rx, ry), fill, stroke, shadow)
  let ell-ink(cx, cy, rx, ry, w: 1pt, paint: black, thin: 32%, angle: 38deg, press: none) = {
    nib.stroke-items(ell-path(cx, cy, rx, ry), pen: nib.nibpen(width: w, thinness: thin, angle: angle), fill: paint,
      pressure: if press == none { none } else { nib.pressure(minimum-width: press.at(0), period: press.at(1), seed: press.at(2)) })
  }
  let circ(cx, cy, r, fill: none, stroke: auto, shadow: false) = ell(cx, cy, r, r, fill: fill, stroke: stroke, shadow: shadow)
  // rounded rectangle; r = one radius or (tl, tr, br, bl)
  let rr(x, y, w, h, r: 0.3, tl: none, tr: none, br: none, bl: none, fill: none, stroke: auto, shadow: false) = {
    let q = (P(x, y), P(x + w, y), P(x + w, y + h), P(x, y + h))
    let rs = (tl, tr, br, bl).map(v => (if v == none { r } else { v }) * 1cm)
    shape(nib.round-corners(q, r: rs, cycle: true), fill, stroke, shadow)
  }
  let rect-at(x, y, w, h, fill: none, stroke: none, shadow: false) = {
    let q = (P(x, y), P(x + w, y), P(x + w, y + h), P(x, y + h))
    shape(nib.polyline(q, cycle: true), fill, stroke, shadow)
  }
  // a free pen line (pencil, crayon, charcoal…): `press: (min, period, seed)` breaks the
  // thin parts of the stroke like dry media on paper
  let ink(pts, w: 1pt, paint: black, smooth: false, closed: false, thin: 32%, angle: 38deg, press: none, dash: none) = {
    let q = pts.map(p => P(p.at(0), p.at(1)))
    let path = if smooth { nib.mp-path-pts(q, cycle: closed) } else { nib.polyline(q, cycle: closed) }
    nib.stroke-items(path, pen: nib.nibpen(width: w, thinness: thin, angle: angle), fill: paint,
      pressure: if press == none { none } else { nib.pressure(minimum-width: press.at(0), period: press.at(1), seed: press.at(2)) },
      dash: if dash == none { none } else { nib.dashes(..dash, jitter: dash.at(0) * 0.7, seed: if press == none { 1 } else { press.at(2) }) })
  }
  // text box: x is measured in the LTR drawing, mirrored here
  let tx(x, y, w, h, c, al: center + horizon) = place(top + left,
    dx: cm(if rtl { Wc - x - w } else { x }), dy: cm(y),
    box(width: cm(w), height: cm(h), align(al, c)))
  // text that fills a box and flows round circular holes `((cx, cy, r), …)`: every line starts
  // where the circles leave room. Words come from the plain text of `body`.
  let wrap(x0, y0, w, h, body, size, fill, holes: (), gap: 0.15, lead: 1.35, weight: "regular") = {
    let words = plain-text(body).split(regex("\\s+")).filter(s => s != "")
    let lh = size * lead / 1cm
    let sp = size * 0.27 / 1cm
    let wd = words.map(s => measure(text(size: size, weight: weight, s)).width / 1cm)
    let bounds(yt) = {
      let l = x0
      for (cx, cy, r) in holes {
        let dy = if cy >= yt and cy <= yt + lh { 0.0 } else { calc.min(calc.abs(cy - yt), calc.abs(cy - yt - lh)) }
        if dy < r + gap { l = calc.max(l, cx + calc.sqrt(calc.pow(r + gap, 2) - dy * dy)) }
      }
      l
    }
    let flow(ys) = {
      let lines = ()
      let cur = ""
      let curw = 0.0
      let left = bounds(ys)
      for (i, word) in words.enumerate() {
        let ww = wd.at(i)
        if cur != "" and curw + sp + ww > x0 + w - left {
          lines.push((cur, left))
          left = bounds(ys + lines.len() * lh)
          cur = word
          curw = ww
        } else {
          curw = if cur == "" { ww } else { curw + sp + ww }
          cur = if cur == "" { word } else { cur + " " + word }
        }
      }
      if cur != "" { lines.push((cur, left)) }
      lines
    }
    let first = flow(y0)
    let ys = calc.max(y0, y0 + (h - first.len() * lh) / 2)
    for (i, (line, left)) in flow(ys).enumerate() {
      tx(left, ys + i * lh, x0 + w - left, lh, text(size: size, fill: fill, weight: weight, line), al: start + horizon)
    }
  }
  // a mirrored x for things the caller places itself
  let mx(x, w: 0) = if rtl { Wc - x - w } else { x }
  // all the shapes of a drawing, as one nibart figure (mirrored as a whole in RTL)
  let layer(c) = {
    let fig = nib.mp-fig(c, width: cm(Wc), height: cm(Hc), pad: 0pt)
    place(top + left, if rtl { scale(x: -100%, reflow: false, origin: center + horizon, fig) } else { fig })
  }
  (poly: poly, open: open, ink: ink, ell-ink: ell-ink, circ: circ, ell: ell, rr: rr, rect: rect-at, tx: tx, wrap: wrap, mx: mx, layer: layer, Wc: Wc, Hc: Hc)
}

/// The usual entry: resolves width / direction / print mode, then calls
/// `build(Wc, Hc, rtl, print, k)` where `k` is the kit.
#let canvas(width, height, direction, xs, build, default-height: 6cm) = context layout(avail => {
  let rtl = rtl-of(direction, ..xs)
  let W = if width == auto { avail.width }
    else if type(width) == ratio { avail.width * width } else { width }
  let H = if height == auto { default-height } else { height }
  let print = theme-state.get().mode == "print"
  set text(dir: if rtl { std.rtl } else { ltr })
  let Wc = W / 1cm
  let Hc = H / 1cm
  box(width: W, height: H, build(Wc, Hc, rtl, print, kit(Wc, Hc, rtl)))
})

/// Steps may be given as plain content: `(title: …, body: …)` or just a body.
#let norm-step(s, i, colours) = {
  let d = if type(s) == dictionary { s } else { (body: s) }
  (
    title: d.at("title", default: none),
    body: d.at("body", default: none),
    icon: d.at("icon", default: none),
    label: d.at("label", default: none),
    colour: d.at("colour", default: colours.at(calc.rem(i, colours.len()))),
  )
}
