// ===========================================================================
//  faboxyst/coilbox.typ — a spiral-notebook page, after the pink clip-art
//  frame: rounded pink double frame, a pink spine with black punch holes
//  and alternating pink/purple coils drawn with a 3D tube shading.
//
//    #coilbox[Une page de cahier à spirale.]
//    #show: coil-pages   // the same, as a frame on every page
// ===========================================================================

#import "fabox.typ": is-rtl
#import "engine.typ": bezier-pts

/// The clip-art's palette.
#let coil-colours = (
  frame:      rgb("#F27BB4"),   // the pink band and frame
  frame-dark: rgb("#C2185B"),   // outer rule / spine edge
  pink:       rgb("#F062A8"),   // coil colour A
  purple:     rgb("#7E4FBF"),   // coil colour B
  hole:       rgb("#141414"),   // punch holes
  paper:      white,
)

// One coil as a sampled cubic Bezier (hole centre at the origin, hook
// sweeping in from the lower left). Returns (points, rebased end).
#let _coil-pts(sgn) = {
  let raw = bezier-pts(
    (-0.88, 0.44), (-1.02, 0.02), (-0.46, -0.22), (-0.04, 0.02), n: 20)
  let xs = raw.map(p => p.at(0) * sgn * 1cm)
  let ys = raw.map(p => p.at(1) * 1cm)
  let x0 = calc.min(..xs)
  let y0 = calc.min(..ys)
  let pts = raw.map(p => (p.at(0) * sgn * 1cm - x0, p.at(1) * 1cm - y0))
  let end = (raw.last().at(0) * sgn * 1cm - x0, raw.last().at(1) * 1cm - y0)
  (pts, end)
}

// A 3D coil seated on its hole: dark under-copy, gradient tube, highlight.
#let _coil(hx, hy, colr, sgn, geo) = {
  let pts = geo.at(0)
  let end = geo.at(1)
  let dx = hx - end.at(0)
  let dy = hy - end.at(1)
  let g = gradient.linear(colr.darken(30%), colr.lighten(20%),
    colr.darken(8%), angle: 90deg)
  place(top + left, dx: dx + 0.5pt, dy: dy + 1.0pt,
    curve(stroke: (thickness: 4.8pt, paint: colr.darken(45%), cap: "round"),
      curve.move(pts.at(0)), ..pts.slice(1).map(p => curve.line(p))))
  place(top + left, dx: dx, dy: dy,
    curve(stroke: (thickness: 4.4pt, paint: g, cap: "round"),
      curve.move(pts.at(0)), ..pts.slice(1).map(p => curve.line(p))))
  let hl = pts.slice(0, 13)
  place(top + left, dx: dx - 0.5pt, dy: dy - 0.8pt,
    curve(stroke: (thickness: 1.1pt, paint: white.transparentize(40%), cap: "round"),
      curve.move(hl.at(0)), ..hl.slice(1).map(p => curve.line(p))))
}

/// A spiral-notebook page: rounded pink double frame with a 3D lip, a
/// pink spine with black punch holes and alternating pink/purple coils.
///
/// ```typ
/// #coilbox(title: [Lundi])[Une page de cahier.]
/// #cahier[Alias français.]
/// ```
#let coilbox(
  body,
  title: none,
  frame: auto,
  coil-a: auto,
  coil-b: auto,
  title-size: 1.2em,
  coil-gap: 1.05cm,
  radius: 0.55cm,
  inset: (x: 0.6cm, y: 0.6cm),
  width: 100%,
  height: auto,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let cc = coil-colours
  let frame-c = if frame == auto { cc.frame } else { frame }
  let dark-c = frame-c.darken(28%)
  let a-c = if coil-a == auto { cc.pink } else { coil-a }
  let b-c = if coil-b == auto { cc.purple } else { coil-b }
  let ix = inset.at("x", default: 0.6cm)
  let iy = inset.at("y", default: 0.6cm)
  let sgn = if rtl { -1 } else { 1 }
  let geoA = _coil-pts(sgn)
  let geoB = _coil-pts(sgn)

  let title-body = if title == none { none } else {
    text(fill: dark-c, weight: "bold", size: title-size, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let title-h = if title == none { 0pt } else { tm.height + 0.4cm }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let spine-x = if rtl { W - 0.67cm } else { 0.67cm }
    let content-x = if rtl { ix } else { 1.15cm }
    let content-w = W - content-x - (if rtl { 1.15cm } else { ix })
    let main = block(width: content-w, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let mh = measure(main).height
    let Hc = title-h + mh + 2 * iy
    let H = if height != auto {
      if type(height) == ratio { avail.height * height } else { height }
    } else { calc.max(Hc + 1.2cm, 6cm) }

    block(width: W, height: H, {
      set text(dir: body-dir)
      let r = radius
      // 3D lip: a faint dark copy peeking below the frame
      place(top + left, dy: 2.2pt,
        rect(width: W - 2pt, height: H - 2pt, radius: r,
          stroke: 1.2pt + dark-c.transparentize(50%)))
      // outer rule + pink band + white paper
      place(top + left,
        rect(width: W - 2pt, height: H - 2pt, radius: r,
          stroke: 1.4pt + dark-c))
      place(top + left, dx: 4.4pt, dy: 4.4pt,
        rect(width: W - 2pt - 8.8pt, height: H - 2pt - 8.8pt, radius: r - 3pt,
          stroke: 4.6pt + frame-c))
      place(top + left, dx: 9pt, dy: 9pt,
        rect(width: W - 18pt, height: H - 18pt, radius: r - 5pt,
          fill: cc.paper))
      // spine band with its dark edge
      let band-x = if rtl { W - 0.79cm } else { 0.55cm }
      place(top + left, dx: band-x, dy: 0.45cm,
        rect(width: 0.24cm, height: H - 0.9cm, fill: frame-c, radius: 2pt))
      place(top + left, dx: if rtl { band-x } else { band-x + 0.24cm },
        dy: 0.45cm,
        rect(width: 0.7pt, height: H - 0.9cm, fill: dark-c))
      // punch holes + coils
      let run = H - 1.4cm
      let n = calc.max(2, int(run / coil-gap) + 1)
      let y0 = (H - (n - 1) * coil-gap) / 2
      for i in range(n) {
        let hy = y0 + i * coil-gap
        place(top + left, dx: spine-x - 0.08cm, dy: hy - 0.11cm,
          ellipse(width: 0.16cm, height: 0.22cm, fill: cc.hole))
        let colr = if calc.even(i) { a-c } else { b-c }
        let hx = if rtl { spine-x + 0.06cm } else { spine-x - 0.06cm }
        _coil(hx, hy, colr, sgn, if calc.even(i) { geoA } else { geoB })
      }
      // title + body
      if title != none {
        place(top + left, dx: content-x, dy: iy,
          block(width: content-w, align(center, title-body)))
      }
      place(top + left, dx: content-x, dy: iy + title-h, main)
    })
  })
}

/// French alias.
#let cahier(..a) = coilbox(..a)

/// The notebook frame on every page, after `ornate-pages`: the spine
/// side gets a wider margin so the text clears the coils. Use `#show: coil-pages` to frame a whole document, or call the rule
/// directly on a section (`#coil-pages[...]`) to chain several different
/// frames in one document.
#let coil-pages(doc, margin: 0.45cm, gap: 0.6cm, spine-gap: 1.5cm, rtl: false, ..args) = {
  let mt = margin + gap
  let ml = if rtl { margin + gap } else { margin + spine-gap }
  let mr = if rtl { margin + spine-gap } else { margin + gap }
  set page(
    margin: (top: mt, bottom: mt, left: ml, right: mr),
    background: context {
      let fw = page.width - 2 * margin
      let fh = page.height - 2 * margin
      place(top + left, dx: margin, dy: margin,
        coilbox([], width: fw, height: fh, ..args.named()))
    },
  )
  doc
}
