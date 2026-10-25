// Infographic stacks and compound frames: rows linked by rings or wires,
// brush strokes, twisted ribbons, bubble boxes, poster cards, pencil frame,
// index notebook, film strip, slideshow frame. Everything is drawn.
#import "infokit.typ": *

#let _t(s, size, fill, weight: "bold") = {
  if s.title == none { none } else { text(size: size, weight: weight, fill: fill, s.title) }
}
#let _b(s, size, fill) = {
  if s.body == none { none } else { text(size: size, fill: fill, s.body) }
}
#let _tb(s, ts, bs, tc, bc) = {
  _t(s, ts, tc)
  if s.title != none and s.body != none { v(0.12em) }
  _b(s, bs, bc)
}

// height of a vertical stack when the caller leaves it `auto`
#let _stack-h(height, n, rh, gap, pad) = {
  if height != auto { height } else { (n * rh / 1cm + (n - 1) * gap / 1cm + 2 * pad) * 1cm }
}

#let _stack(steps, width, height, row-height, gap, pad, direction, colours, draw) = {
  let n = steps.len()
  let H = _stack-h(height, n, row-height, gap, pad)
  canvas(width, H, direction, steps, (Wc, Hc, rtl, print, k) => {
    let rh = row-height / 1cm
    let gp = gap / 1cm
    let st = steps.enumerate().map(((i, s)) => norm-step(s, i, colours))
    let parts = st.enumerate().map(((i, s)) => draw(i, s, pad + i * (rh + gp), rh, gp, Wc, k, print, n))
    (k.layer)(parts.map(p => p.at(0)).join()) + parts.map(p => p.at(1)).join()
  }, default-height: H)
}

// ---------------------------------------------------------------------------
/// Stacked boxes with a thick coloured border, hooked together by black rings.
#let ring-linked-boxes(
  steps: (), width: auto, height: auto, row-height: 2.2cm, gap: 0.9cm, direction: auto,
  colours: (rgb("#FFB400"),), title-size: 10pt, body-size: 8pt, ring-colour: luma(135),
) = _stack(steps, width, height, row-height, gap, 0.25, direction, colours, (i, s, y, rh, gp, Wc, k, print, n) => {
  let c = pc(s.colour, print)
  let shapes = {
    (k.rr)(0.1, y, Wc - 0.2, rh, r: 0.45, fill: c, stroke: 1.6pt + black, shadow: true)
    (k.rr)(0.42, y + 0.32, Wc - 0.84, rh - 0.64, r: 0.3, fill: white, stroke: 1.3pt + black)
    if i < n - 1 {
      for xr in (Wc * 0.2, Wc * 0.8) {
        (k.rr)(xr - 0.24, y + rh - 0.55, 0.48, gp + 1.1, r: 0.24, fill: ring-colour, stroke: 0.7pt + ring-colour.darken(25%))
        (k.rr)(xr - 0.1, y + rh - 0.4, 0.2, gp + 0.8, r: 0.1, fill: white, stroke: none)
      }
    }
  }
  let texts = (k.tx)(0.9, y + 0.45, Wc - 1.8, rh - 0.9, _tb(s, title-size, body-size, black, luma(60)), al: start + horizon)
  (shapes, texts)
})

// ---------------------------------------------------------------------------
/// Pills strung together by wires that run through eyelets at both ends.
#let wire-linked-pills(
  steps: (), width: auto, height: auto, row-height: 1.7cm, gap: 1.0cm, direction: auto,
  colours: (rgb("#D400FF"), rgb("#00FFD0"), rgb("#FFD000")),
  title-size: 11pt, body-size: 8pt,
) = _stack(steps, width, height, row-height, gap, 0.2, direction, colours, (i, s, y, rh, gp, Wc, k, print, n) => {
  let c = pc(s.colour, print)
  let l = 0.85
  let r = Wc - 0.85
  let ym = y + rh / 2
  let shapes = {
    if i < n - 1 {
      let y2 = ym + rh + gp
      let mid = ym + (rh + gp) / 2
      let wire(xe, xo) = qbez((xe, ym), (xo, ym - 0.1), (xo, mid), n: 8) + qbez((xo, mid), (xo, y2 + 0.1), (xe, y2), n: 8).slice(1)
      (k.open)(wire(l + 0.55, 0.12), stroke: 1.5pt + black)
      (k.open)(wire(r - 0.55, Wc - 0.12), stroke: 1.5pt + black)
    }
    (k.rr)(l, y, r - l, rh, r: rh / 2, fill: c, stroke: 1.8pt + black, shadow: true)
    for xe in (l + 0.55, r - 0.55) { (k.circ)(xe, ym, 0.26, fill: white, stroke: 1.5pt + black) }
  }
  let texts = (k.tx)(l + 1.2, y + 0.1, r - l - 2.4, rh - 0.2, _tb(s, title-size, body-size, black, luma(40)))
  (shapes, texts)
})

// ---------------------------------------------------------------------------
/// Paint-brush strokes carrying a big number, a thin divider and a text.
#let brush-stroke-rows(
  steps: (), width: auto, height: auto, row-height: 3.0cm, gap: 0.45cm, direction: auto,
  colours: (rgb("#E8431C"), rgb("#7DB61C"), rgb("#3F5FE0")),
  title-size: 11pt, body-size: 7.5pt, number-size: 34pt, seed: 5,
) = _stack(steps, width, height, row-height, gap, 0.1, direction, colours, (i, s, y, rh, gp, Wc, k, print, n) => {
  let c = pc(s.colour, print)
  let J = jitter(seed + i * 17, 120)
  let top = ()
  let bot = ()
  let m = 28
  for j in range(m + 1) {
    let t = j / m
    let ends = calc.min(t, 1 - t) * 14
    let ytop = y + 0.22 + rh * 0.03 * J.at(j) - 0.3 * calc.max(0, 1 - ends) + 0.04 * J.at(j + 40)
    let ybot = y + rh - 0.18 + rh * 0.045 * J.at(j + 60) + 0.05 * J.at(j + 80)
    top.push((0.35 + (Wc - 0.9) * t, ytop))
    bot.push((0.35 + (Wc - 0.9) * t, ybot))
  }
  let outline = top + (
    (Wc - 0.25, y + rh * 0.3 + 0.2 * J.at(100)), (Wc - 0.05, y + rh * 0.55 + 0.2 * J.at(101)),
    (Wc - 0.3, y + rh * 0.8)) + bot.rev() + ((0.15, y + rh * 0.7), (0.0, y + rh * 0.45), (0.2, y + rh * 0.25))
  let shapes = {
    (k.poly)(outline, fill: gradient.linear(c.lighten(14%), c.darken(10%), angle: 20deg), stroke: none, smooth: true)
    (k.rect)(Wc * 0.29, y + rh * 0.24, 0.025, rh * 0.5, fill: white)
  }
  let texts = {
    (k.tx)(0.7, y + 0.2, Wc * 0.26, rh - 0.4, text(size: number-size, fill: white, weight: "light", two-digits(i)))
    (k.tx)(Wc * 0.32, y + 0.25, Wc * 0.6, rh - 0.5, _tb(s, title-size, body-size, white, white), al: start + horizon)
  }
  (shapes, texts)
})

// ---------------------------------------------------------------------------
/// A white numbered tab that twists into a coloured text band.
#let twisted-ribbon-rows(
  steps: (), width: auto, height: auto, row-height: 2.7cm, gap: 0.3cm, direction: auto,
  colours: (rgb("#F58220"), rgb("#3E4F5F"), rgb("#17A2D6"), rgb("#9DB1B3")),
  title-size: 10pt, body-size: 6.8pt, caption: "OPTIONS", twist: 70%, depth: 0.06cm,
) = _stack(steps, width, height, row-height, gap, 0.1, direction, colours, (i, s, y, rh, gp, Wc, k, print, n) => {
  let c = pc(s.colour, print)
  let tw = Wc * 0.2
  let ym = y + rh / 2
  let y1 = y + rh
  // a strip of paper turning over: a large white lobe that tapers to the crossing, and a coloured
  // sheet whose tail slips down to the lower edge of the white one and covers the centre. The
  // outlines are the cubic Béziers of a 307-unit-high master drawing (x from -12, y from 30).
  let sc = rh / 307
  let sx = sc * (twist / 100%)
  let P(px, py) = (tw + (px + 12) * sx, y + (py - 30) * sc)
  let bez(p0, c1, c2, p1, n: 12) = range(1, n + 1).map(j => {
    let t = j / n
    let u = 1 - t
    let f(a, b, c, d) = u * u * u * a + 3 * u * u * t * b + 3 * u * t * t * c + t * t * t * d
    P(f(p0.at(0), c1.at(0), c2.at(0), p1.at(0)), f(p0.at(1), c1.at(1), c2.at(1), p1.at(1)))
  })
  let chain(start, segs) = {
    let out = (P(..start),)
    let cur = start
    for sg in segs {
      out += bez(cur, ..sg)
      cur = sg.at(2)
    }
    out
  }
  let white-pts = chain((-12, 30), (
    ((48, 21), (91, 38), (126, 70)), ((158, 100), (178, 138), (202, 158)), ((215, 169), (227, 174), (240, 174)),
    ((225, 190), (207, 204), (190, 219)), ((172, 236), (155, 258), (135, 282)), ((98, 325), (55, 343), (-12, 337))))
  let orange-lobe = chain((490, 28), (
    ((430, 23), (389, 41), (351, 69)), ((313, 98), (282, 136), (250, 166)), ((231, 184), (213, 202), (194, 220)),
    ((176, 237), (157, 259), (135, 282)), ((111, 310), (70, 336), (25, 338)), ((45, 338.5), (65, 331), (87, 322)), ((103, 315), (120, 300), (135, 286)), ((150, 271), (176, 247), (198, 232)), ((222, 214), (240, 208), (262, 213)), ((304, 222), (335, 252), (373, 283)), ((411, 314), (449, 332), (490, 337))))
  let x1 = Wc - 0.05
  let xr = P(490, 0).at(0)
  // the lobe goes on as a straight band up to the right edge
  let orange-pts = orange-lobe + if x1 > xr { ((x1, orange-lobe.last().at(1)), (x1, orange-lobe.first().at(1))) } else { () }
  let xe = P(440, 0).at(0)
  // the 3D edge skips the tail (segments 3 to 7 = points 37 … 95), which has to stay a hairline
  let body-pts = orange-lobe.slice(0, 37) + orange-lobe.slice(96) + if x1 > xr { ((x1, orange-lobe.last().at(1)), (x1, orange-lobe.first().at(1))) } else { () }
  let paper = gradient.linear(white, luma(237), angle: 63deg)
  // soft shadow (a drop shadow plus a faint halo all round); it starts a hair right of the tab so
  // that the tab and the white lobe stay one piece
  let shadow(pts) = for (dx, dy, a) in ((0, 0.02, 90%), (0, 0.05, 92%), (0, 0.09, 94%), (0, 0.14, 96%), (0.035, -0.035, 95%), (-0.035, 0.0, 95%), (0.035, 0.0, 95%)) {
    (k.poly)(pts.map(p => (calc.max(p.at(0) + dx, tw + 0.04), p.at(1) + dy)), fill: black.transparentize(a), stroke: none)
  }
  // the 3D edge: a few copies of each shape shifted down, in a darker tone, like the thickness of the paper
  let dd = depth / 1cm
  let steps3 = 4
  let side(pts, col) = for j in range(steps3, 0, step: -1) {
    (k.poly)(pts.map(p => (p.at(0), p.at(1) + dd * j / steps3)), fill: col.darken(8% * j), stroke: none)
  }
  let shapes = {
    for j in range(steps3, 0, step: -1) {
      (k.rr)(0, y + dd * j / steps3, tw + 0.02, rh, tl: 0.8, bl: 0.8, r: 0, fill: luma(232).darken(8% * j), stroke: none)
    }
    (k.rr)(0, y, tw + 0.02, rh, tl: 0.8, bl: 0.8, r: 0, fill: white, stroke: none, shadow: true)
    shadow(white-pts)
    side(white-pts, luma(232))
    (k.poly)(white-pts, fill: paper, stroke: none)
    shadow(orange-pts)
    side(body-pts, c.darken(18%))
    (k.poly)(orange-pts, fill: gradient.linear((c.lighten(10%), 0%), (c, 65%), (c.darken(14%), 100%), angle: 70deg), stroke: none)
    // a thin light bevel along the upper edge of the coloured sheet
    (k.open)((if x1 > xr { ((x1, orange-lobe.first().at(1)),) } else { () }) + orange-lobe.slice(0, 37), stroke: 0.8pt + white.transparentize(45%))
  }
  let texts = {
    (k.tx)(0.3, y + 0.1, tw - 0.1, rh * 0.62, text(size: 24pt, weight: "bold", fill: luma(110), two-digits(i)))
    (k.tx)(0.3, y + rh * 0.58, tw - 0.1, 0.5, text(size: 8pt, weight: "bold", fill: luma(110), caption))
    (k.tx)(xe + 0.2, y + 0.15, Wc - xe - 0.65, rh - 0.3, _tb(s, title-size, body-size, white, white), al: start + horizon)
  }
  (shapes, texts)
})

// ---------------------------------------------------------------------------
/// Thick-outlined rounded boxes in a grid, each with a numbered bubble on a
/// short tail at one of its corners (upper left, upper right, lower right,
/// lower left, in turn).
#let bubble-tail-boxes(
  steps: (), width: auto, height: auto, columns: 2, cell-height: 3.6cm, direction: auto,
  colours: (rgb("#D4707F"), rgb("#E5A800"), rgb("#7BB92C"), rgb("#1AA7E0")),
  title-size: 9pt, body-size: 7pt, stroke-weight: 4.2pt,
) = {
  let n = steps.len()
  let rows = calc.ceil(n / columns)
  let H = if height == auto { cell-height * rows } else { height }
  canvas(width, H, direction, steps, (Wc, Hc, rtl, print, k) => {
    let st = steps.enumerate().map(((i, s)) => norm-step(s, i, colours))
    let cw = Wc / columns
    let ch = Hc / rows
    let parts = st.enumerate().map(((i, s)) => {
      let c = pc(s.colour, print)
      let cx = calc.rem(i, columns) * cw
      let cy = calc.floor(i / columns) * ch
      let corner = (0, 1, 3, 2).at(calc.rem(i, 4))
      let m = 0.62
      let bx = cx + m
      let by = cy + m
      let bw = cw - 2 * m
      let bh = ch - 2 * m
      let (sx, sy) = ((-1, -1), (1, -1), (1, 1), (-1, 1)).at(corner)
      let (kx, ky) = ((bx, by), (bx + bw, by), (bx + bw, by + bh), (bx, by + bh)).at(corner)
      let (px, py) = (kx - sx * 0.2, ky - sy * 0.2)
      let (qx, qy) = (kx + sx * 0.32, ky + sy * 0.32)
      let shapes = {
        (k.open)(((px, py), (qx, qy)), stroke: (paint: c, thickness: stroke-weight, cap: "round"))
        (k.rr)(bx, by, bw, bh, r: 0.9, fill: white, stroke: stroke-weight + c, shadow: true)
        (k.circ)(qx, qy, 0.5, fill: c)
      }
      let texts = {
        (k.tx)(qx - 0.4, qy - 0.4, 0.8, 0.8, text(size: 9pt, weight: "bold", fill: white, two-digits(i)))
        (k.tx)(bx + 0.4, by + 0.25, bw - 0.8, bh - 0.5, _tb(s, title-size, body-size, c, luma(70)), al: start + horizon)
      }
      (shapes, texts)
    })
    (k.layer)(parts.map(p => p.at(0)).join()) + parts.map(p => p.at(1)).join()
  }, default-height: H)
}

// ---------------------------------------------------------------------------
/// Poster cards: a patterned ground (grid, stripes, plain), a hand-drawn
/// border (plain, wavy, scalloped, dashed) and a white label.
#let striped-poster-cards(
  steps: (), width: auto, height: 7.2cm, gap: 0.35cm, direction: auto,
  palette: (rgb("#E8502A"), rgb("#2B3FA6"), rgb("#F6C928"), rgb("#B9D4E8")),
  title-size: 12pt, body-size: 7pt, seed: 3,
) = {
  let n = steps.len()
  let (orange, blue, yellow, sky) = palette
  canvas(width, height, direction, steps, (Wc, Hc, rtl, print, k) => {
    let gp = gap / 1cm
    let cw = (Wc - (n - 1) * gp) / n
    let st = steps.enumerate().map(((i, s)) => norm-step(s, i, (blue,)))
    // grounds are drawn as plain rectangles (no tiling), so every stripe runs unbroken
    let stripes(x, w, base, col, lw, pitch, vertical: true) = {
      let L = if vertical { w } else { Hc }
      let m = calc.max(1, int(calc.round(L / pitch)))
      let p = L / m
      if base != none { (k.rect)(x, 0, w, Hc, fill: base) }
      for j in range(m) {
        if vertical { (k.rect)(x + (j + 0.5) * p - lw / 2, 0, lw, Hc, fill: col) }
        else { (k.rect)(x, (j + 0.5) * p - lw / 2, w, lw, fill: col) }
      }
    }
    let grounds = (
      ((x, w) => {
        stripes(x, w, orange, white, 0.18, 0.9, vertical: true)
        stripes(x, w, none, white, 0.18, 0.9, vertical: false)
      }, blue, "wave", none),
      ((x, w) => (k.rect)(x, 0, w, Hc, fill: yellow), blue, "dash", none),
      ((x, w) => stripes(x, w, white, blue, 0.16, 0.45), blue, "plain", "v"),
      ((x, w) => stripes(x, w, white, orange, 0.2, 0.5), orange, "scallop", none),
      ((x, w) => stripes(x, w, sky, white, 0.1, 0.5, vertical: false), orange, "plain", "h"),
    )
    let parts = st.enumerate().map(((i, s)) => {
      let x = i * (cw + gp)
      let (ground, ink, kind, dir) = grounds.at(calc.rem(i, grounds.len()))
      let ink = pc(ink, print)
      // striped grounds get a smaller label, so the stripes run visibly from top to bottom
      let big = kind == "plain"
      // the frame of a striped label sits in a gap between two stripes, never on one
      let pv = cw / calc.max(1, int(calc.round(cw / 0.45)))
      let ph = Hc / calc.max(1, int(calc.round(Hc / 0.5)))
      let ix = x + if big and dir == "v" { pv } else if big { 0.8 } else { 0.55 }
      let iy = if big and dir == "h" { 3 * ph } else if big { 1.35 } else { 0.55 }
      let iw = cw - 2 * (ix - x)
      let ih = Hc - 2 * iy
      let J = jitter(seed + i * 5, 80)
      let pts = {
        let out = ()
        let steps-n = 18
        for e in range(4) {
          for j in range(steps-n) {
            let t = j / steps-n
            let off = if kind == "wave" { 0.1 * calc.sin(t * 360deg * 3) }
              else if kind == "scallop" { 0.12 * calc.abs(calc.sin(t * 180deg * 6)) }
              else { 0.03 * J.at(e * steps-n + j) }
            let (a, b, nx, ny) = (
              (ix + iw * t, iy, 0, -1), (ix + iw, iy + ih * t, 1, 0),
              (ix + iw * (1 - t), iy + ih, 0, 1), (ix, iy + ih * (1 - t), -1, 0)).at(e)
            out.push((a + nx * off, b + ny * off))
          }
        }
        out
      }
      let shapes = {
        ground(x, cw)
        // a white margin keeps the stripes from running into the hand-drawn border
        if kind != "dash" and not big { (k.rect)(ix - 0.15, iy - 0.15, iw + 0.3, ih + 0.3, fill: white) }
        (k.poly)(pts, fill: white, stroke: if kind == "dash" { (paint: ink, thickness: 2pt, dash: (2pt, 2pt)) } else { 2.2pt + ink })
      }
      let texts = {
        (k.tx)(ix + 0.2, iy + 0.25, iw - 0.4, 1.1, _t(s, title-size, ink))
        (k.tx)(ix + 0.25, iy + 1.45, iw - 0.5, ih - 1.7, { _b(s, body-size, luma(70)); if s.icon != none { v(0.5em); s.icon } }, al: top + center)
      }
      (shapes, texts)
    })
    (k.layer)(parts.map(p => p.at(0)).join()) + parts.map(p => p.at(1)).join()
  }, default-height: height)
}

// ---------------------------------------------------------------------------
/// Four coloured pencils laid out as a square frame; `steps` (four labels,
/// clockwise from the top) are written along the pencils, `body` fills the
/// middle, `cross` draws the two coloured diagonals.
#let pencil-frame-flow(
  body, steps: (), width: auto, height: 9.5cm, direction: auto, thickness: 0.85cm,
  colours: (rgb("#4F8A5E"), rgb("#B8651B"), rgb("#D5B510"), rgb("#EC5FA3")),
  cross: true, title-size: 12pt, scalex: 150%, scaley: 100%,
) = canvas(width, height, direction, (body, ..steps), (Wc, Hc, rtl, print, k) => {
  let S = calc.min(Wc, Hc)
  let ox = (Wc - S) / 2
  let oy = (Hc - S) / 2
  let t = thickness / 1cm
  let st = range(4).map(i => norm-step(if i >= steps.len() { (title: none) } else if type(steps.at(i)) == dictionary { steps.at(i) } else { (title: steps.at(i)) }, i, colours))
  let pencil(L, c, label, flip: false) = {
    let pk = kit(L, t, false)
    let tipL = t * 0.95
    box(width: cm(L), height: cm(t), {
     (pk.layer)({
      (pk.rr)(0, 0, L - tipL + 0.05, t, tl: 0.18, bl: 0.18, r: 0, fill: c)
      (pk.rect)(0.1, t * 0.12, L - tipL - 0.1, t * 0.08, fill: white.transparentize(75%))
      (pk.rect)(0.1, t * 0.8, L - tipL - 0.1, t * 0.08, fill: black.transparentize(80%))
      (pk.poly)(((L - tipL, 0), (L, t / 2), (L - tipL, t)), fill: rgb("#EFCB93"))
      (pk.poly)(((L - tipL * 0.38, t * 0.31), (L, t / 2), (L - tipL * 0.38, t * 0.69)), fill: c.darken(15%))
     })
      place(top + left, box(width: cm(L - tipL), height: cm(t), align(center + horizon,
        scale(x: scalex, y: scaley, reflow: true, text(size: title-size, weight: "bold", fill: white, if flip { rotate(180deg, label) } else { label })))))
    })
  }
  let inner = S - 2 * t
  let diag = if cross {
    let dc = (k.open)
    (
      (k.open)(((ox + t + 0.2, oy + t + 0.2), (ox + S - t - 0.2, oy + S - t - 0.2)), stroke: (paint: colours.at(0), thickness: 1.1pt, dash: (4pt, 3pt))),
      (k.open)(((ox + S - t - 0.2, oy + t + 0.2), (ox + t + 0.2, oy + S - t - 0.2)), stroke: (paint: colours.at(3), thickness: 1.1pt, dash: (4pt, 3pt))),
    ).join()
  }
  let paper = (k.rect)(ox + t * 0.5, oy + t * 0.5, S - t, S - t, fill: rgb("#FBF3DC"))
  let rot(a, dx, dy, c) = place(top + left, dx: cm(dx), dy: cm(dy), rotate(a, origin: top + left, reflow: false, c))
  (k.layer)(paper + if diag == none { () } else { diag }) + {
    place(top + left, dx: cm(ox + t * 1.25), dy: cm(oy + t * 1.25),
      box(width: cm(inner - 0.5 * t), height: cm(inner - 0.5 * t), align(center + horizon, body)))
    rot(0deg, ox, oy, pencil(S - t, st.at(0).colour, st.at(0).title))
    rot(90deg, ox + S, oy, pencil(S - t, st.at(1).colour, st.at(1).title))
    rot(180deg, ox + S, oy + S, pencil(S - t, st.at(2).colour, st.at(2).title, flip: true))
    rot(270deg, ox, oy + S, pencil(S - t, st.at(3).colour, st.at(3).title))
  }
}, default-height: height)

// ---------------------------------------------------------------------------
/// A ring-bound leather notebook with a bookmark ribbon, entries on the cover
/// and index tabs (with flags) down the right-hand edge.
#let index-notebook(
  steps: (), title: [INFOGRAPHICS], width: auto, height: 11cm, direction: auto,
  cover: rgb("#B07F0C"), tab-colours: (rgb("#FFCF8B"), rgb("#8A5A14"), rgb("#5C3A06"), rgb("#0E3345")),
  ribbon: rgb("#1E5F74"), title-size: 17pt, body-size: 7pt,
) = {
  let n = steps.len()
  canvas(width, height, direction, (title, ..steps), (Wc, Hc, rtl, print, k) => {
    let st = steps.enumerate().map(((i, s)) => norm-step(s, i, tab-colours))
    let cv = pc(cover, print)
    let tabw = 2.7
    let cx0 = 1.2
    let cx1 = Wc - tabw + 0.15
    let item-y0 = 2.7
    let rh = (Hc - item-y0 - 0.5) / calc.max(n, 1)
    let shapes = {
      (k.rr)(cx0, 0.15, cx1 - cx0, Hc - 0.35, r: 0.5, fill: cv, stroke: 1.2pt + cv.darken(40%), shadow: true)
      for j in range(5) {
        let ry = 1.0 + j * (Hc - 2.0) / 4
        (k.rr)(0.25, ry - 0.2, 2.1, 0.42, r: 0.21, fill: gradient.linear(luma(240), luma(130), luma(235), angle: 90deg), stroke: 0.4pt + luma(120))
      }
      (k.poly)(((cx0 + 0.9, 0), (cx0 + 1.9, 0), (cx0 + 1.9, Hc * 0.9), (cx0 + 1.4, Hc * 0.9 - 0.45), (cx0 + 0.9, Hc * 0.9)), fill: pc(ribbon, print))
      for (j, s) in st.enumerate() {
        let y = item-y0 + j * rh
        let tc = pc(s.colour, print)
        (k.rr)(cx1 - 0.35, y + 0.05, tabw - 0.1, rh - 0.12, r: 0.45, fill: tc, stroke: 0.5pt + luma(200))
        (k.poly)(((cx0 + 3.2, y + 0.18), (cx0 + 3.2, y + 0.5), (cx0 + 3.5, y + 0.34)), fill: tc.lighten(10%))
      }
    }
    let texts = {
      (k.tx)(cx0 + 3.0, 0.5, cx1 - cx0 - 3.2, 1.4, text(size: title-size, weight: "bold", fill: cv.darken(55%), title), al: start + horizon)
      for (j, s) in st.enumerate() {
        let y = item-y0 + j * rh
        (k.tx)(cx0 + 3.7, y + 0.05, cx1 - cx0 - 4.0, rh - 0.2, _tb(s, 10pt, body-size, black, luma(35)), al: start + top)
        let tink = if luma(pc(s.colour, print)).components(alpha: false).first() > 60% { black } else { white }
        (k.tx)(cx1 - 0.3, y + 0.15, tabw - 0.3, rh - 0.4, {
          align(center, text(fill: tink, s.icon))
          text(size: 8pt, fill: tink, if s.label != none { s.label } else { [OPTION #(j + 1)] })
        })
      }
    }
    (k.layer)(shapes) + texts
  }, default-height: height)
}

// ---------------------------------------------------------------------------
/// A strip of film: sprocket holes along both edges and one window per entry
/// of `frames` (any content: an image, a text, …).
#let film-strip(
  frames: (), width: auto, height: 4.2cm, gap: 0.22cm, direction: auto,
  film: luma(95), band: 0.62cm, hole-pitch: 0.5cm,
) = {
  let n = frames.len()
  canvas(width, height, direction, frames, (Wc, Hc, rtl, print, k) => {
    let bd = band / 1cm
    let hh = bd * 0.42
    let gp = gap / 1cm
    let pitch = hole-pitch / 1cm
    let cw = (Wc - 0.5 - (n - 1) * gp) / n
    let shapes = {
      (k.rect)(0, 0, Wc, Hc, fill: film)
      let holes = calc.floor((Wc - 0.3) / pitch)
      for j in range(holes) {
        for yy in ((bd - hh) / 2, Hc - bd + (bd - hh) / 2) {
          (k.rr)(0.2 + j * pitch, yy, pitch * 0.5, hh, r: 0.05, fill: white, stroke: none)
        }
      }
      for j in range(n) { (k.rect)(0.25 + j * (cw + gp), bd, cw, Hc - 2 * bd, fill: white) }
    }
    let texts = for j in range(n) {
      (k.tx)(0.25 + j * (cw + gp), bd, cw, Hc - 2 * bd, frames.at(j))
    }
    (k.layer)(shapes) + texts
  }, default-height: height)
}

// ---------------------------------------------------------------------------
/// A white rounded frame round a grey panel with a red double chevron on each
/// side — a slideshow viewer. `body` sits in the panel.
#let chevron-slideshow-frame(
  body, width: auto, height: 6cm, direction: auto,
  panel: luma(190), frame: white, arrow: rgb("#E80C16"),
) = canvas(width, height, direction, (body,), (Wc, Hc, rtl, print, k) => {
  let ac = pc(arrow, print)
  let fx = 1.1
  let shapes = {
    (k.rr)(fx + 0.12, 0.3, Wc - 2 * fx, Hc - 0.5, r: 0.8, fill: luma(205))
    (k.rr)(fx, 0.18, Wc - 2 * fx, Hc - 0.5, r: 0.8, fill: frame, stroke: 0.6pt + luma(225))
    (k.rr)(fx + 0.45, 0.63, Wc - 2 * fx - 0.9, Hc - 1.4, r: 0.45, fill: panel)
    for sgn in (-1, 1) {
      let cx = if sgn < 0 { 0.62 } else { Wc - 0.62 }
      let cy = Hc / 2
      for (d, w) in ((0.0, 0.55), (0.46, 0.55)) {
        let x0 = cx + sgn * (d - 0.25)
        (k.poly)(((x0 - sgn * 0.2, cy - 0.6), (x0 + sgn * 0.3, cy), (x0 - sgn * 0.2, cy + 0.6),
          (x0 - sgn * 0.45, cy + 0.6), (x0 + sgn * 0.0, cy), (x0 - sgn * 0.45, cy - 0.6)),
          fill: ac, stroke: 2.2pt + white)
      }
    }
  }
  let texts = (k.tx)(fx + 0.6, 0.8, Wc - 2 * fx - 1.2, Hc - 1.7, text(fill: white, body))
  (k.layer)(shapes) + texts
}, default-height: height)
