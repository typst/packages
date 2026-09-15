// ===========================================================================
//  faboxyst/volutebox.typ — the fine double-line stationery frame with
//  scrolled volute corners, after the blush certificate border.
//
//    #volutebox[Une annonce élégante…]          // as a box
//    #show: volute-pages                        // as a frame on every page
//
//  Two chamfered hairline rectangles, a pair of ink spirals (volutes)
//  and a tiny bud at each corner, plus short double dashes echoing the
//  corners along the edges.
// ===========================================================================

#import "fabox.typ": is-rtl

/// The stationery palette.
#let volute-colours = (
  ink:   rgb("#33241E"),   // the warm near-black line work
  blush: rgb("#F6E7E4"),   // the blush ground of the reference
  paper: rgb("#FCFAF8"),   // the paper inside the frame
)

// An Archimedean spiral polyline. `cx/cy/r0/r1` are lengths; the spiral
// starts at radius `r0`, angle `a0` (deg) and winds `turns` times inwards
// to `r1`. `sx/sy` mirror it into the four corners.
#let spiral-pts(cx, cy, r0, r1, a0, turns, n: 64, sx: 1, sy: 1) = {
  range(n + 1).map(i => {
    let t = i / n
    let r = r0 + (r1 - r0) * t
    let a = (a0 + turns * 360 * t) * 1deg
    (cx + sx * r * calc.cos(a), cy + sy * r * calc.sin(a))
  })
}

/// An open or closed ink polyline in local (placed) coordinates.
#let ink-pts(pts, paint, w, closed: false) = {
  if pts.len() < 2 { return }
  let segs = (curve.move(pts.first()),) + pts.slice(1).map(p => curve.line(p))
  let segs = if closed { segs + (curve.close(mode: "straight"),) } else { segs }
  place(top + left, curve(
    stroke: (paint: paint, thickness: w, join: "round", cap: "round"),
    ..segs,
  ))
}

// A rectangle with chamfered corners, as a point list.
#let _chamfer(o, W, H, c) = (
  (o + c, o), (W - o - c, o), (W - o, o + c), (W - o, H - o - c),
  (W - o - c, H - o), (o + c, H - o), (o, H - o - c), (o, o + c),
)

// The corner flourish: two volutes hugging the edges and a small bud on
// the diagonal, mirrored by (sx, sy) into each corner at (cx, cy).
#let _flourish(cx, cy, sx, sy, ink-c, w) = {
  ink-pts(spiral-pts(cx + sx * 0.50cm, cy + sy * 0.26cm, 0.22cm, 0.02cm,
    -90, 1.85, sx: sx, sy: sy), ink-c, w)
  ink-pts(spiral-pts(cx + sx * 0.26cm, cy + sy * 0.50cm, 0.22cm, 0.02cm,
    0, 1.85, sx: sx, sy: sy), ink-c, w)
  ink-pts(spiral-pts(cx + sx * 0.12cm, cy + sy * 0.12cm, 0.10cm, 0.015cm,
    45, 1.25, sx: sx, sy: sy), ink-c, w * 0.9)
}

// Short double dashes echoing a corner along both neighbouring edges,
// just inside the inner rule.
#let _dashes(cx, cy, sx, sy, o2, ink-c, w) = {
  let d = o2 + 0.14cm
  let a = 0.72cm
  let b = 1.55cm
  ink-pts(((cx + sx * a, cy + sy * d), (cx + sx * b, cy + sy * d)), ink-c, w * 0.8)
  ink-pts(((cx + sx * a, cy + sy * (d + 0.09cm)), (cx + sx * (b - 0.25cm), cy + sy * (d + 0.09cm))), ink-c, w * 0.6)
  ink-pts(((cx + sx * d, cy + sy * a), (cx + sx * d, cy + sy * b)), ink-c, w * 0.8)
  ink-pts(((cx + sx * (d + 0.09cm), cy + sy * a), (cx + sx * (d + 0.09cm), cy + sy * (b - 0.25cm))), ink-c, w * 0.6)
}

/// The volute stationery frame as a box: two chamfered hairline rules
/// with scrolled corners around the content.
///
/// ```typ
/// #volutebox[Une annonce élégante.]
/// ```
#let volutebox(
  body,
  line: auto,
  fill: none,
  weight: 0.9pt,
  inset: (x: 1.15cm, y: 1.0cm),
  width: 100%,
  height: auto,      // force the frame's height (page frames)
  flourish: true,
) = layout(avail => {
  let vc = volute-colours
  let ink-c = if line == auto { vc.ink } else { line }
  let ix = inset.at("x", default: 1.15cm)
  let iy = inset.at("y", default: 1.0cm)
  let W = if type(width) == ratio { avail.width * width } else { width }
  let inner = block(width: W - 2 * ix, body)
  let H = measure(inner).height + 2 * iy
  if height != auto { H = height }
  let o = 0.10cm
  let o2 = 0.34cm
  let c1 = 0.52cm
  let c2 = 0.36cm
  block(width: W, height: H, breakable: false, {
    if fill != none {
      place(top + left, rect(width: W, height: H, fill: fill))
    }
    // the two chamfered rules
    ink-pts(_chamfer(o, W, H, c1), ink-c, weight, closed: true)
    ink-pts(_chamfer(o2, W, H, c2), ink-c, weight * 0.75, closed: true)
    if flourish {
      for (cx, cy, sx, sy) in (
        (o, o, 1, 1), (W - o, o, -1, 1),
        (o, H - o, 1, -1), (W - o, H - o, -1, -1),
      ) {
        _flourish(cx, cy, sx, sy, ink-c, weight)
        _dashes(cx, cy, sx, sy, o2, ink-c, weight)
      }
    }
    place(top + left, dx: ix, dy: iy, inner)
  })
})

/// French alias.
#let cadre-volute(..a) = volutebox(..a)

/// The corner flourish, exported so other modules (parchemin) can set
/// the same volutes at their own corners.
#let flourish = _flourish

/// The volute frame on every page, after `ornate-pages` / `coil-pages`:
/// use `#show: volute-pages` to frame a whole document, or call the rule
/// directly on a section to chain several frames in one document.
#let volute-pages(doc, margin: 0.55cm, gap: 0.85cm, ..args) = {
  let m = margin + gap
  set page(
    margin: (top: m, bottom: m, left: m, right: m),
    background: context {
      let fw = page.width - 2 * margin
      let fh = page.height - 2 * margin
      place(top + left, dx: margin, dy: margin,
        volutebox([], width: fw, height: fh, inset: (x: 0pt, y: 0pt),
          ..args.named()))
    },
  )
  doc
}
