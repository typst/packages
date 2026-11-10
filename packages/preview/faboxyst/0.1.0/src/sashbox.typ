// ===========================================================================
//  faboxyst/sashbox.typ — folded ribbon banners (flat / arch / hang).
//
//    #sashbox(kind: "flat")[SALE]
//    #sashbox(kind: "arch", fill: rgb("#FF9EC8"))[Welcome]
//    #sashbox(kind: "hang", fill: rgb("#7ED4C8"))[Thank you]
//
//  After the three Illustrator sashes: a main band sitting on swallow-tail
//  folds. `arch` / `hang` bow the band and the lettering follows the curve.
//  Direction-aware: under RTL the clusters run the other way along the arc.
// ===========================================================================

#import "fabox.typ": is-rtl
#import "engine.typ": sketch-points, rough-points

#let _plain(it) = {
  if type(it) == str { it }
  else if type(it) == content {
    let f = it.func()
    if f == text { it.text }
    else if f == [].func() {
      it.children.map(_plain).join()
    } else if f == linebreak { " " }
    else { none }
  } else { none }
}

/// Draw a filled polygon in parent coordinates (place + local origin).
#let _poly(pts, fill) = {
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  let x0 = calc.min(..xs)
  let y0 = calc.min(..ys)
  place(top + left, dx: x0, dy: y0,
    polygon(fill: fill, ..pts.map(p => (p.at(0) - x0, p.at(1) - y0))))
}

/// Canvas (y-down, Typst lengths) → mapdraw cm, y-up.
#let _up(pts, H) = pts.map(p => (p.at(0) / 1cm, (H - p.at(1)) / 1cm))

#let _extend(pts, o) = {
  if pts.len() < 2 { return pts }
  let a = pts.first()
  let b = pts.at(1)
  let c = pts.at(pts.len() - 2)
  let d = pts.last()
  let nrm(u, v) = {
    let dx = v.at(0) - u.at(0)
    let dy = v.at(1) - u.at(1)
    let L = calc.sqrt(dx * dx + dy * dy)
    if L < 1e-6 { (0.0, 0.0) } else { (dx / L, dy / L) }
  }
  let f = nrm(b, a)
  let g = nrm(c, d)
  let head = ((a.at(0) + f.at(0) * o, a.at(1) + f.at(1) * o),)
  let mid = pts.slice(1, pts.len() - 1)
  let tail = ((d.at(0) + g.at(0) * o, d.at(1) + g.at(1) * o),)
  head + mid + tail
}

/// Wobbled polyline back into the sashbox canvas (y-down, lengths).
#let _down(pts, H) = pts.map(p => (p.at(0) * 1cm, H - p.at(1) * 1cm))

#let _stroke-pts(pts, paint, w, closed: false) = {
  if pts.len() < 2 { return }
  let segs = (curve.move(pts.first()),) + pts.slice(1).map(p => curve.line(p))
  let segs = if closed { segs + (curve.close(mode: "straight"),) } else { segs }
  place(top + left, curve(
    stroke: (paint: paint, thickness: w, join: "round", cap: "round"),
    ..segs,
  ))
}

/// Sloppy-box stroke in the SAME coordinates as `_poly`.
#let _ink(pts, H, paint, w, seed, mode: "sloppy", ghost: true, over: 0.20, amp: 2.6, closed: false) = {
  if pts.len() < 2 { return }
  let raw = _up(pts, H)
  let cm = if closed { raw } else { _extend(raw, over) }
  if mode == "roughjs" {
    for pass in rough-points(cm, closed: closed, roughness: 1.6,
        bowing: 1.1, seed: seed) {
      _stroke-pts(_down(pass, H), paint, w, closed: closed)
    }
  } else {
    if ghost {
      let off = sketch-points(
        cm.map(p => (p.at(0) + 0.08, p.at(1) - 0.06)),
        seed: seed + 20, amplitude: amp, closed: closed)
      _stroke-pts(_down(off, H), paint.transparentize(40%), w, closed: closed)
    }
    let main = sketch-points(cm, seed: seed, amplitude: amp, closed: closed)
    _stroke-pts(_down(main, H), paint, w, closed: closed)
  }
}

#let _q(a, c, b, n: 28) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * a.at(0) + 2 * u * t * c.at(0) + t * t * b.at(0),
    u * u * a.at(1) + 2 * u * t * c.at(1) + t * t * b.at(1),
  )
})

/// y-down: positive bow raises the middle (arch). hang uses a negative bow.
#let _bow-y(t, bow) = -4 * bow * t * (1 - t)
#let _bow-yp(t, bow, W) = if W == 0pt { 0.0 } else {
  // d/dx of -4 bow t(1-t) with t = x/W  →  -4 bow (1-2t) / W
  (-4 * bow * (1 - 2 * t)) / W
}

#let _place-along(label, x0, y0, W, bow, fill, size, weight, rtl) = {
  let s = _plain(label)
  let joining = rtl or (s != none and s.clusters().any(c => {
    let n = if type(c) == str and c.len() > 0 { c.to-unicode() } else { 0 }
    (n >= 0x0600 and n <= 0x06FF) or (n >= 0x0750 and n <= 0x077F) or (n >= 0x08A0 and n <= 0x08FF) or (n >= 0xFB50 and n <= 0xFDFF)
  }))
  if joining or s == none or s == "" {
    let m = measure(text(size: size, weight: weight, fill: fill, label))
    let t = 0.5
    let y = y0 + _bow-y(t, bow)
    let ang = calc.atan(_bow-yp(t, bow, W))
    return place(top + left,
      dx: x0 + W / 2 - m.width / 2,
      dy: y - m.height / 2,
      rotate(ang, origin: center + horizon, reflow: false,
        text(size: size, weight: weight, fill: fill, label)))
  }
  let clusters = s.clusters()
  if rtl { clusters = clusters.rev() }
  let glyphs = clusters.map(c => {
    let g = text(dir: ltr, size: size, weight: weight, fill: fill, c)
    (g, measure(g).width, measure(g).height)
  })
  let total = glyphs.fold(0pt, (a, g) => a + g.at(1))
  let gap = 0.35pt
  let extra = gap * calc.max(0, glyphs.len() - 1)
  let rest = W - total - extra
  let cursor = x0 + (if rest > 0pt { rest / 2 } else { 0pt })
  let bits = ()
  for g in glyphs {
    let (pic, gw, gh) = g
    let mid = cursor + gw / 2
    let t = if W == 0pt { 0.5 } else {
      calc.max(0.0, calc.min(1.0, (mid - x0) / W))
    }
    let y = y0 + _bow-y(t, bow)
    let ang = calc.atan(_bow-yp(t, bow, W))
    bits.push(place(top + left,
      dx: mid - gw / 2,
      dy: y - gh * 0.55,
      rotate(ang, origin: center + horizon, reflow: false, pic)))
    cursor = cursor + gw + gap
  }
  bits.join()
}

/// A folded sash / ribbon banner.
///
///   kind     "flat" | "arch" | "hang"
///   incline  curve intensity. `auto` = the kind's default (nothing changes).
///            `1` = that default; `0` = flat; `1.4` = stronger; negative
///            flips the bow. A length is the rise/drop itself.
///   bow      absolute rise (arch) or drop (hang); overrides `incline`
///   fold     depth of the tucked underside flap; auto from the curve
///   tail     how far the swallow-tails stick out; auto from the curve
///   rough    overlay sloppy-box (or Rough.js) ink on the contours
///   hand     auto | "sloppy" | "roughjs" | "sketch"
#let sashbox(
  body,
  kind: "flat",
  fill: rgb("#FFE566"),
  shade: auto,
  text-colour: auto,
  height: 1.22cm,
  width: 100%,
  tail: auto,
  fold: auto,
  bow: auto,
  incline: auto,
  weight: "bold",
  size: 1.15em,
  inset: 0.28cm,
  direction: auto,
  rough: false,
  hand: auto,
  seed: 31,
  ink: auto,
  pen: 3.1pt,
  ghost: true,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let dark = if shade == auto { fill.darken(20%) } else { shade }
  let tc = if text-colour == auto {
    if luma(fill).components().first() > 62% { luma(35) } else { white }
  } else { text-colour }
  let k = kind
  let base-bow = if k == "arch" { 0.52cm }
                 else if k == "hang" { -0.46cm }
                 else { 0cm }
  let unit = if k == "hang" { -0.46cm } else { 0.52cm }
  let bow = if bow != auto { bow }
            else if incline != auto {
              if type(incline) == length { incline }
              else { incline * unit }
            }
            else { base-bow }
  // Wings, not legs. The repli is the underside triangle under the band:
  // right angle inward, hypotenuse from the band's corner down-and-in —
  // that diagonal is the 3-D wrap in the reference zooms.
  let curved = bow != 0cm
  let tail-w = if tail != auto { tail }
               else if curved { 1.20cm }
               else { 0.95cm }
  let fold-in = if fold != auto { fold }
                else if curved { 0.92cm }
                else { 0.68cm }
  let splay = if curved { height * 0.22 } else { 0pt }
  let tail-drop = height * 0.28
  let tail-half = height * 0.52 + splay

  layout(avail => {
    let W0 = if type(width) == ratio { avail.width * width } else { width }
    let band-w = calc.max(2.2cm, W0 - 2 * tail-w)
    let H-band = height
    let fold-in = calc.min(fold-in, band-w * 0.22)
    let fold-down = tail-drop + tail-half - H-band * 0.50
    let tail-above = calc.max(0pt, tail-half - tail-drop - H-band * 0.50)

    let top-pad = calc.max(0.10cm, if bow > 0cm { bow } else { 0cm }) + tail-above + 0.06cm
    let bot-pad = calc.max(fold-down, if bow < 0cm { -bow } else { 0cm }) + 0.14cm
    let H = top-pad + H-band + bot-pad
    let W = 2 * tail-w + band-w
    let xL = tail-w
    let xR = tail-w + band-w
    let yTop0 = top-pad
    let yBot0 = top-pad + H-band

    let y-top(t) = yTop0 + _bow-y(t, bow)
    let y-bot(t) = yBot0 + _bow-y(t, bow)

    let n = 32
    let top-pts = range(n + 1).map(i => {
      let t = i / n
      (xL + band-w * t, y-top(t))
    })
    let bot-pts = range(n + 1).map(i => {
      let t = 1 - i / n
      (xL + band-w * t, y-bot(t))
    })
    let band = top-pts + bot-pts

    // Swallow-wing behind each end. The top sits below the band top on
    // every kind (the flat plate), so the band overlaps the tail.
    let tail-poly(left) = {
      let t = if left { 0.0 } else { 1.0 }
      let yt = y-top(t)
      let yb = y-bot(t)
      let ym = (yt + yb) / 2
      let y1 = ym + tail-drop - tail-half
      let y2 = ym + tail-drop + tail-half
      // same sit-down as flat: ~28 % below the local band top
      let y-in-top = yt + H-band * 0.28
      let y1 = calc.max(y1, y-in-top)
      let xj = if left { xL } else { xR }
      let xo = if left { 0pt } else { W }
      let under = if left { 0.05cm } else { -0.05cm }
      let xi = xj + under
      let notch = tail-w * 0.46
      let xn = if left { xo + notch } else { xo - notch }
      let yn = (y1 + y2) / 2
      if bow == 0cm {
        (
          (xi, y-in-top),
          (xo, y1),
          (xn, yn),
          (xo, y2),
          (xi, y2),
        )
      } else {
        let mid-x = (xi + xo) / 2
        let top = _q((xi, y-in-top), (mid-x, y-in-top + (y1 - y-in-top) * 0.45), (xo, y1), n: 7)
        let bot = _q((xo, y2), (mid-x, y2 + H-band * 0.04), (xi, y2), n: 7)
        top + ((xn, yn),) + bot
      }
    }

    // Underside wrap. A = band corner, B = inward on the band bottom,
    // C = inward and down. The 3-D face is triangle A-B-C.
    // Triangle A-D-C (D = directly below A) is the white hole under the
    // hypotenuse — filled with the ribbon colour so the tail continues.
    let fold-pts(left) = {
      let sign = if left { 1 } else { -1 }
      let xj = if left { xL } else { xR }
      let t-end = if left { 0.0 } else { 1.0 }
      let span = if band-w == 0pt { 0.0 } else { fold-in / band-w }
      let t-in = if left { span } else { 1.0 - span }
      let yb0 = y-bot(t-end)
      let yb1 = y-bot(t-in)
      let y2 = ((y-top(t-end) + y-bot(t-end)) / 2) + tail-drop + tail-half
      let A = (xj, yb0 - 0.4pt)
      let B = (xj + sign * fold-in, yb1 - 0.4pt)
      let C = (xj + sign * fold-in, y2)
      let D = (xj, y2)
      (A, B, C, D)
    }

    block(width: W, height: H, clip: false, {
      _poly(tail-poly(true), fill)
      _poly(tail-poly(false), fill)
      // close the white hole under the fold, then the dark 3-D face
      let (Al, Bl, Cl, Dl) = fold-pts(true)
      let (Ar, Br, Cr, Dr) = fold-pts(false)
      _poly((Al, Dl, Cl), fill)
      _poly((Ar, Dr, Cr), fill)
      _poly((Al, Bl, Cl), dark)
      _poly((Ar, Br, Cr), dark)
      _poly(band, fill)

      if rough {
        let mode = if hand == "roughjs" { "roughjs" } else { "sloppy" }
        let paint = if ink == auto { luma(22) } else { ink }
        let Lt = tail-poly(true)
        let Rt = tail-poly(false)
        let bottom = range(n + 1).map(i => {
          let t = i / n
          (xL + band-w * t, y-bot(t))
        })
        let top-back = range(n + 1).map(i => {
          let t = 1 - i / n
          (xL + band-w * t, y-top(t))
        })
        // One closed ring: left wing → band bottom → right wing → band top.
        let ring = Lt + bottom + Rt.rev() + top-back
        _ink(ring, H, paint, pen, seed + 2, mode: mode, ghost: ghost,
          closed: true)
        // fold creases stay interior ticks
        _ink((Al, Cl), H, paint, pen * 0.85, seed + 14, mode: mode,
          ghost: false, over: 0.02)
        _ink((Ar, Cr), H, paint, pen * 0.85, seed + 17, mode: mode,
          ghost: false, over: 0.02)
      }

      let y-mid0 = (yTop0 + yBot0) / 2
      _place-along(
        body,
        xL + inset,
        y-mid0,
        band-w - 2 * inset,
        bow,
        tc,
        size,
        weight,
        rtl,
      )
    })
  })
}

#let ruban = sashbox
