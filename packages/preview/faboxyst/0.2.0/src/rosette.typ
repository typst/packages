#import "fabox.typ": is-rtl

// The dedication-page ornaments of the supplied the supplied dedication sheet sheet:
// a triple rule (ink, gold, rounded light-gold), four interlaced corner
// curves with sage leaves and eight-petal rosettes, diamond rows along the
// top and bottom bands and a centre rosette flanked by two segments.
// Rebuilt here as a content-adaptive box (`rosettebox`) and a page frame
// (`rosette-pages`), parametrable in LTR and RTL.

#let rosette-ink = rgb("#285B60")
#let rosette-gold = rgb("#B79A60")
#let rosette-leaf = rgb("#729291")

// One eight-petal rosette: cubic petals around a 16-point star and a gold
// heart. `s` scales the millimetre geometry of the source sheet.
#let _rosette-flower(x, y, s, ink, gold, paper) = {
  let mm(v) = v * 1mm * s
  for turn in range(0, 360, step: 45) {
    let c = calc.cos(turn * 1deg)
    let n = calc.sin(turn * 1deg)
    let pp(across, along) = (
      x + mm(across * c - along * n),
      y + mm(across * n + along * c),
    )
    place(top + left,
      curve(fill: paper, stroke: 0.45pt + gold,
        curve.move(pp(0, 0)),
        curve.cubic(pp(-4, 4), pp(-3, 8), pp(0, 10)),
        curve.cubic(pp(3, 8), pp(4, 4), pp(0, 0)),
        curve.close()))
  }
  place(top + left,
    polygon(..range(16).map(i => {
      let a = i * 22.5deg
      let r = if calc.rem(i, 2) == 0 { 5 } else { 5 / 1.65 }
      (x + mm(r * calc.cos(a)), y + mm(r * calc.sin(a)))
    }), fill: ink, stroke: 0.45pt + gold))
  place(top + left, dx: x - 1.25mm * s, dy: y - 1.25mm * s,
    circle(radius: 1.25mm * s, fill: gold, stroke: none))
}

// One corner ornament: two interlaced cubic sweeps, six sage leaves and a
// rosette; mirrored through `mx` / `my` onto the four corners.
#let _rosette-corner(W, H, k, mx, my, ink, gold, leaf, paper) = {
  let X(u) = if mx { W - u * 1mm * k } else { u * 1mm * k }
  let Y(v) = if my { H - v * 1mm * k } else { v * 1mm * k }
  place(top + left,
    curve(stroke: 0.65pt + ink,
      curve.move((X(14), Y(47))),
      curve.cubic((X(29), Y(36)), (X(5), Y(25)), (X(22), Y(22))),
      curve.cubic((X(25), Y(5)), (X(36), Y(29)), (X(47), Y(14)))))
  place(top + left,
    curve(stroke: 0.45pt + gold,
      curve.move((X(17), Y(46))),
      curve.cubic((X(32), Y(34)), (X(12), Y(29)), (X(25), Y(25))),
      curve.cubic((X(29), Y(12)), (X(34), Y(32)), (X(46), Y(17)))))
  for position in (30, 39, 48) {
    place(top + left,
      curve(fill: leaf, stroke: none,
        curve.move((X(position), Y(15))),
        curve.cubic((X(position + 2), Y(9)), (X(position + 6), Y(10)),
          (X(position + 7), Y(9))),
        curve.cubic((X(position + 6), Y(15)), (X(position + 3), Y(16)),
          (X(position), Y(15))),
        curve.close()))
    place(top + left,
      curve(fill: leaf, stroke: none,
        curve.move((X(15), Y(position))),
        curve.cubic((X(9), Y(position + 2)), (X(10), Y(position + 6)),
          (X(9), Y(position + 7))),
        curve.cubic((X(15), Y(position + 6)), (X(16), Y(position + 3)),
          (X(15), Y(position))),
        curve.close()))
  }
  _rosette-flower(X(18), Y(18), 0.85 * k, ink, gold, paper)
}

#let _rosette-diamond(x, y, s, paint) = place(top + left,
  polygon(
    (x - 1mm * s, y), (x, y + 1.6mm * s),
    (x + 1mm * s, y), (x, y - 1.6mm * s),
    fill: paint, stroke: none))

/// The rosette dedication frame as a box: triple rule, corner ornaments,
/// diamond rows and centre medallions around a content-adaptive panel.
/// Mirrors and text direction follow `direction` (auto detects RTL).
///
/// ```typ
/// #rosettebox(title: [إهداء])[To my parents, my teachers, my friends.]
/// ```
#let rosettebox(
  body,
  title: none,
  width: 100%,
  height: auto,
  inset: auto,         // extra daylight inside the inner rule (auto: 22mm*k)
  ink: rosette-ink,
  gold: rosette-gold,
  leaf: rosette-leaf,
  paper: none,
  scale: auto,         // ornament scale; auto fits the smallest side
  corners: true,
  diamonds: auto,      // auto: fill the bands; an int fixes the count
  medallions: true,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    // Ornaments scale with the smallest side so corner art never escapes.
    let make = (kk) => {
      let r1 = 2mm * kk
      let r2 = r1 + 6mm * kk
      let extra = if inset == auto { 22mm * kk } else { inset }
      let ii = r2 + extra
      let content = block(width: W,
        inset: (
          x: ii,
          top: if title != none { 1mm } else { ii },
          bottom: ii,
        ),
        {
          set align(start)
          text(dir: if rtl { std.rtl } else { ltr }, body)
        })
      let stacked = block(width: W, {
        if title != none {
          block(width: W, inset: (x: ii, top: ii),
            align(center,
              text(fill: ink, weight: "bold", size: 1.25em,
                dir: if rtl { std.rtl } else { ltr }, title)))
        }
        content
      })
      (stacked: stacked, r1: r1, r2: r2)
    }
    let k-of = hh => calc.min(1.0, calc.max(0.25,
      calc.min(W / 160mm, hh / 100mm)))
    let k0 = if scale != auto { scale }
      else if height != auto { k-of(height) }
      else { calc.min(1.0, calc.max(0.25, W / 160mm)) }
    let first = make(k0)
    let k = if scale != auto or height != auto { k0 }
      else { k-of(measure(first.stacked).height) }
    let built = if k == k0 { first } else { make(k) }
    let r1 = built.r1
    let r2 = built.r2
    let stacked = built.stacked
    let cz = 50mm * k            // corner zone kept clear of diamonds
    let H = if height != auto { height } else { measure(stacked).height }
    let band-y = (r1 + r2) / 2
    box(width: W, height: H, {
      if paper != none {
        place(top + left, rect(width: W, height: H, fill: paper))
      }
      place(top + left,
        rect(width: W, height: H, fill: none, stroke: 1.1pt + ink))
      place(top + left, dx: r1, dy: r1,
        rect(width: W - 2 * r1, height: H - 2 * r1, fill: none,
          stroke: 0.5pt + gold))
      place(top + left, dx: r2, dy: r2,
        rect(width: W - 2 * r2, height: H - 2 * r2, fill: none,
          radius: 2mm * k, stroke: 0.45pt + gold.lighten(35%)))
      if corners {
        _rosette-corner(W, H, k, false, false, ink, gold, leaf, paper)
        _rosette-corner(W, H, k, true, false, ink, gold, leaf, paper)
        _rosette-corner(W, H, k, false, true, ink, gold, leaf, paper)
        _rosette-corner(W, H, k, true, true, ink, gold, leaf, paper)
      }
      let n = if diamonds == none { 0 }
        else if diamonds != auto { int(diamonds) }
        else { calc.max(0, int(calc.floor((W - 2 * cz) / (12mm * k)))) }
      let pale = gold.lighten(30%)
      for i in range(n) {
        let x = W / 2 + (i - (n - 1) / 2) * 12mm * k
        _rosette-diamond(x, band-y, k, pale)
        _rosette-diamond(x, H - band-y, k, pale)
      }
      if medallions and W > 2 * cz + 30mm * k {
        for yy in (band-y, H - band-y) {
          _rosette-flower(W / 2, yy, 0.5 * k, ink, gold, paper)
          place(top + left,
            line(start: (W / 2 - 40mm * k, yy), end: (W / 2 - 11mm * k, yy),
              stroke: 0.45pt + gold.lighten(40%)))
          place(top + left,
            line(start: (W / 2 + 11mm * k, yy), end: (W / 2 + 40mm * k, yy),
              stroke: 0.45pt + gold.lighten(40%)))
        }
      }
      place(top + left, stacked)
    })
  })
}

/// French alias for `rosettebox`.
#let cadre-rosette(..a) = rosettebox(..a)

/// The rosette frame on every page, like `ornate-pages` / `volute-pages`.
///
/// ```typ
/// #show: rosette-pages.with(margin: 1.2cm)
/// ```
#let rosette-pages(doc, margin: 1.2cm, gap: 2.4cm, ..args) = {
  let m = margin + gap
  set page(
    margin: (top: m, bottom: m, left: m, right: m),
    background: context {
      let fw = page.width - 2 * margin
      let fh = page.height - 2 * margin
      place(top + left, dx: margin, dy: margin,
        rosettebox([], width: fw, height: fh, inset: 0mm, ..args.named()))
    },
  )
  doc
}
