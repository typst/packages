// ===========================================================================
//  faboxyst/meter.typ — tiny inline meters, after the TikZ speedometer.
//
//  A small box that reads at a glance: how hard is this exercise? how full
//  is this battery? Four instruments share one API:
//
//    #meter(3, style: "gauge")      a speedometer: needle over coloured zones
//    #meter(3, style: "thermo")     a thermometer: mercury in a tube
//    #meter(3, style: "battery")    a phone battery: charge in a shell
//    #meter(3, style: "bars")       signal bars: one column per step
//    #meter(3, style: "dots")       filled circles
//    #meter(3, style: "stars")      ★ row
//    #meter(3, style: "hearts")     ♥ row
//    #meter(3, style: "pie")        circular slice
//    #meter(3, style: "steps")      cell strip
//    #meter(3, style: "flame")      stacked flames
//
//  All of them are inline boxes a few centimetres wide, so they sit beside
//  an exercise statement, in a margin, or in a table cell. Under RTL the
//  asymmetric parts (battery cap, thermo ticks, bar order) mirror.
// ===========================================================================

#import "fabox.typ": is-rtl

#let _ramp(f, reverse: false) = {
  let g = rgb("#2E9E5B")
  let a = rgb("#E8A33D")
  let r = rgb("#D64545")
  let x = if reverse { 1 - f } else { f }
  if x <= 0.40 { g } else if x <= 0.70 { a } else { r }
}

/// A compact difficulty / level meter.
///
///   value    the reading, between 0 and `max`
///   max      the top of the scale (also the bar count for "bars")
///   style    "gauge" | "thermo" | "battery" | "bars" | "dots" | "stars"
///            | "hearts" | "pie" | "steps" | "flame"
///   label    text under the instrument; auto = "value/max"
///   colour   the reading's paint; auto = a green-amber-red ramp
///   track    the empty part's paint; auto = a grey of `colour`
///   size     the instrument's characteristic length
///   digits   true prints `label`; none hides it
///   direction  auto follows the document; force with ltr / rtl
#let meter(
  value,
  max: 5,
  style: "gauge",
  label: auto,
  colour: auto,
  track: auto,
  size: 1.5cm,
  digits: true,
  shaded: false,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let f = calc.min(1, calc.max(0, value / max))
  let col = if colour == auto {
    _ramp(f, reverse: style == "battery")
  } else { colour }
  let trk = if track == auto { luma(78) } else { track }
  let paint-of(c, ang: 0deg) = if shaded {
    std.gradient.linear(c.lighten(42%), c.darken(8%), angle: ang)
  } else { c }
  // Western digits even under `lang: ar`.
  let lab = text(lang: "en", dir: ltr,
    if label == auto { [#value/#max] } else { label })
  let s = size

  let gauge = {
    // a half dial: three coloured zones, ticks, a needle and a hub
    let W = 2 * s + 0.5cm
    let H = s + 1.05cm
    let cx = W / 2
    let cy = s + 0.25cm
    let rad = ang => (
      cx + s * calc.cos(ang * 1deg),
      cy - s * calc.sin(ang * 1deg),
    )
    box(width: W, height: H, {
      // three coloured zones laid on the upper half, as annular sectors
      let ring(a0, a1, r0, r1) = {
        let pts = ()
        let n = 14
        for i in range(0, n + 1) {
          let a = a0 + (a1 - a0) * i / n
          pts += ((cx + r1 * calc.cos(a * 1deg), cy - r1 * calc.sin(a * 1deg)),)
        }
        for i in range(0, n + 1).rev() {
          let a = a0 + (a1 - a0) * i / n
          pts += ((cx + r0 * calc.cos(a * 1deg), cy - r0 * calc.sin(a * 1deg)),)
        }
        pts
      }
      for z in range(0, 3) {
        place(top + left,
          polygon(fill: _ramp(z * 0.35 + 0.2), stroke: none,
            ..ring(180 - z * 60, 120 - z * 60, s - 0.09cm, s + 0.09cm)))
      }
      // ticks, one per step of the scale
      for i in range(0, calc.min(max, 10) + 1) {
        let a = 180 - 180 * i / calc.min(max, 10)
        let p0 = rad(a)
        let p1 = (cx + (s - 0.28cm) * calc.cos(a * 1deg),
                  cy - (s - 0.28cm) * calc.sin(a * 1deg))
        place(top + left,
          line(start: p0, end: p1, stroke: (paint: luma(45), thickness: 0.7pt)))
      }
      // the needle
      let na = 180 - 180 * f
      place(top + left, dx: cx, dy: cy,
        rotate(-na * 1deg, origin: left + horizon,
          line(length: s * 0.78, stroke: (paint: luma(25), thickness: 1.4pt,
            cap: "round"))))
      place(top + left, dx: cx - 0.11cm, dy: cy - 0.11cm,
        circle(radius: 0.11cm, fill: luma(25), stroke: 0.6pt + white))
      if digits != none {
        place(top + left, dx: 0pt, dy: cy + 0.18cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let thermo = {
    let tw = 0.36cm
    let bulb = 0.30cm
    let W = 1.15cm
    let H = s + 2 * bulb + 0.85cm
    let tx = (W - tw) / 2 + (if rtl { 0.18cm } else { -0.18cm })
    box(width: W, height: H, {
      let y0 = 0.1cm
      let tube-h = s + bulb
      // glass tube
      place(top + left, dx: tx, dy: y0,
        rect(width: tw, height: tube-h, radius: tw / 2,
          fill: white, stroke: (paint: luma(45), thickness: 0.8pt)))
      // mercury, from the bulb up
      let fh = f * (tube-h - 0.16cm)
      place(top + left, dx: tx + tw * 0.25, dy: y0 + tube-h - fh - 0.08cm,
        rect(width: tw * 0.5, height: fh, radius: tw * 0.25, fill: col))
      // the bulb
      place(top + left, dx: tx + tw / 2 - bulb, dy: y0 + tube-h - bulb * 0.7,
        circle(radius: bulb, fill: col, stroke: (paint: luma(45), thickness: 0.8pt)))
      // ticks on the trailing side
      for i in range(0, calc.min(max, 8) + 1) {
        let y = y0 + 0.12cm + (tube-h - 0.3cm) * (1 - i / calc.min(max, 8))
        let x0 = if rtl { tx - 0.16cm } else { tx + tw }
        place(top + left, dx: x0, dy: y,
          line(length: 0.14cm, stroke: (paint: luma(45), thickness: 0.6pt)))
      }
      if digits != none {
        place(top + left, dx: 0pt, dy: H - 0.72cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let battery = {
    let bh = 0.72cm
    let cap-w = 0.18cm
    let gap = 0.05cm
    let W = s + cap-w + gap + 0.16cm
    let H = bh + 0.95cm
    box(width: W, height: H, {
      // Cap = positive nub. Charge fills from the OPEN end.
      // LTR: [████ empty ]▮     RTL: ▮[ empty ████]
      let bx = if rtl { cap-w + gap + 0.06cm } else { 0.06cm }
      let capx = if rtl { 0.06cm } else { bx + s + gap }
      place(top + left, dx: capx, dy: (bh - 0.34cm) / 2 + 0.04cm,
        rect(width: cap-w, height: 0.34cm, radius: 0.06cm, fill: luma(25)))
      place(top + left, dx: bx, dy: 0.06cm,
        rect(width: s, height: bh, radius: 0.12cm,
          fill: luma(245), stroke: (paint: luma(35), thickness: 1.1pt)))
      let inner = s - 0.16cm
      let iw = inner * f
      let ix = if rtl { bx + s - 0.08cm - iw } else { bx + 0.08cm }
      if f > 0.02 {
        place(top + left, dx: ix, dy: 0.16cm,
          rect(width: iw, height: bh - 0.20cm, radius: 0.06cm,
            fill: paint-of(col, ang: if rtl { 180deg } else { 0deg })))
      }
      if digits != none {
        place(top + left, dx: 0pt, dy: bh + 0.22cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let dots = {
    let n = calc.min(calc.max(2, calc.round(max)), 10)
    let d = s * 0.28
    let gap = d * 0.45
    let W = n * d + (n - 1) * gap + 0.16cm
    let H = d + 0.85cm
    box(width: W, height: H, {
      for i in range(0, n) {
        let k = if rtl { n - 1 - i } else { i }
        let on = value > i
        place(top + left, dx: 0.08cm + k * (d + gap), dy: 0.06cm,
          circle(radius: d / 2,
            fill: if on { col } else { none },
            stroke: (paint: if on { col } else { trk }, thickness: 1.1pt)))
      }
      if digits != none {
        place(top + left, dx: 0pt, dy: d + 0.16cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let stars = {
    let n = calc.min(calc.max(2, calc.round(max)), 8)
    let d = s * 0.42
    let gap = d * 0.18
    let W = n * d + (n - 1) * gap + 0.12cm
    let H = d + 0.85cm
    box(width: W, height: H, {
      for i in range(0, n) {
        let k = if rtl { n - 1 - i } else { i }
        let on = value > i
        place(top + left, dx: 0.06cm + k * (d + gap), dy: 0.04cm,
          text(size: d, fill: if on { col } else { trk.transparentize(30%) },
            [★]))
      }
      if digits != none {
        place(top + left, dx: 0pt, dy: d + 0.12cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let bars = {
    let n = calc.min(calc.max(2, calc.round(max)), 8)
    let bw = 0.24cm
    let gap = 0.10cm
    let W = n * bw + (n - 1) * gap + 0.2cm
    let H = s + 0.95cm
    box(width: W, height: H, {
      for i in range(0, n) {
        let k = if rtl { n - 1 - i } else { i }
        let h = 0.35cm + (s - 0.35cm) * (i + 1) / n
        let on = value > i
        place(top + left, dx: 0.1cm + k * (bw + gap), dy: s - h + 0.1cm,
          rect(width: bw, height: h, radius: 0.06cm,
            fill: if on { col } else { trk.transparentize(55%) }))
      }
      if digits != none {
        place(top + left, dx: 0pt, dy: s + 0.24cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let hearts = {
    let n = calc.min(calc.max(2, calc.round(max)), 8)
    let d = s * 0.40
    let gap = d * 0.14
    let W = n * d + (n - 1) * gap + 0.12cm
    let H = d + 0.85cm
    let hc = if colour == auto { rgb("#C2185B") } else { col }
    box(width: W, height: H, {
      for i in range(0, n) {
        let k = if rtl { n - 1 - i } else { i }
        let on = value > i
        place(top + left, dx: 0.06cm + k * (d + gap), dy: 0.02cm,
          text(size: d, fill: if on { hc } else { trk.transparentize(25%) }, [♥]))
      }
      if digits != none {
        place(top + left, dx: 0pt, dy: d + 0.10cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: hc, lab))))
      }
    })
  }

  let pie = {
    let W = s * 1.35 + 0.2cm
    let H = s * 1.35 + 0.95cm
    let cx = W / 2
    let cy = s * 0.68
    let r = s * 0.58
    box(width: W, height: H, {
      place(top + left, dx: cx - r, dy: cy - r,
        circle(radius: r, fill: trk.transparentize(55%), stroke: 0.8pt + luma(45)))
      if f > 0.01 {
        let n = 24
        let pts = ((cx, cy),)
        let a0 = -90deg
        for i in range(0, n + 1) {
          let a = a0 + 360deg * f * i / n
          pts.push((cx + r * calc.cos(a), cy + r * calc.sin(a)))
        }
        place(top + left, polygon(fill: col, stroke: none, ..pts))
      }
      place(top + left, dx: cx - r, dy: cy - r,
        circle(radius: r, fill: none, stroke: 0.9pt + luma(40)))
      if digits != none {
        place(top + left, dx: 0pt, dy: cy + r + 0.14cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let steps = {
    let n = calc.min(calc.max(2, calc.round(max)), 10)
    let cw = s * 0.42
    let ch = s * 0.34
    let gap = 0.08cm
    let W = n * cw + (n - 1) * gap + 0.16cm
    let H = ch + 0.95cm
    box(width: W, height: H, {
      for i in range(0, n) {
        let k = if rtl { n - 1 - i } else { i }
        let on = value > i
        place(top + left, dx: 0.08cm + k * (cw + gap), dy: 0.08cm,
          rect(width: cw, height: ch, radius: 0.08cm,
            fill: if on { col } else { trk.transparentize(50%) },
            stroke: 0.7pt + luma(50)))
      }
      if digits != none {
        place(top + left, dx: 0pt, dy: ch + 0.22cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let flame = {
    let n = calc.min(calc.max(2, calc.round(max)), 6)
    let d = s * 0.40
    let gap = d * 0.12
    let W = n * d + (n - 1) * gap + 0.14cm
    let H = d * 1.15 + 0.85cm
    let fc = if colour == auto { rgb("#EF6C00") } else { col }
    box(width: W, height: H, {
      for i in range(0, n) {
        let k = if rtl { n - 1 - i } else { i }
        let on = value > i
        let x = 0.06cm + k * (d + gap)
        let paint = if on { fc } else { trk.transparentize(20%) }
        place(top + left, polygon(fill: paint, stroke: none,
          (x + d * 0.50, 0.04cm),
          (x + d * 0.12, d * 0.72),
          (x + d * 0.32, d * 0.58),
          (x + d * 0.50, d * 1.05),
          (x + d * 0.68, d * 0.58),
          (x + d * 0.88, d * 0.72),
        ))
        if on {
          place(top + left, polygon(fill: rgb("#FFEE58"), stroke: none,
            (x + d * 0.50, d * 0.38),
            (x + d * 0.34, d * 0.78),
            (x + d * 0.50, d * 0.92),
            (x + d * 0.66, d * 0.78),
          ))
        }
      }
      if digits != none {
        place(top + left, dx: 0pt, dy: d * 1.10,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: fc, lab))))
      }
    })
  }

  let speedo = {
    // Discrete pads along a semicircle, green → red, needle at `value`.
    let n = calc.min(calc.max(5, calc.round(max)), 12)
    let W = 2.2 * s + 0.4cm
    let H = s * 1.15 + 1.0cm
    let cx = W / 2
    let cy = s + 0.28cm
    let r = s * 0.92
    box(width: W, height: H, {
      for i in range(0, n) {
        let t = i / (n - 1)
        let a = 180deg - 180deg * t
        let pad-c = if t < 0.35 { rgb("#7CB342") }
                    else if t < 0.55 { rgb("#FDD835") }
                    else if t < 0.75 { rgb("#FB8C00") }
                    else { rgb("#E53935") }
        let pw = if t < 0.4 { s * 0.14 } else { s * 0.22 }
        let ph = s * 0.28
        let px = cx + r * calc.cos(a) - pw / 2
        let py = cy - r * calc.sin(a) - ph / 2
        place(top + left, dx: px, dy: py,
          rotate(90deg - a, origin: center,
            rect(width: pw, height: ph, radius: 0.10cm,
              fill: if shaded { paint-of(pad-c, ang: 90deg) } else { pad-c })))
      }
      let na = 180deg - 180deg * f
      let nx = cx + (r * 0.62) * calc.cos(na)
      let ny = cy - (r * 0.62) * calc.sin(na)
      place(top + left, line(start: (cx, cy), end: (nx, ny),
        stroke: (paint: luma(20), thickness: 2.4pt, cap: "round")))
      place(top + left, dx: cx - 0.13cm, dy: cy - 0.13cm,
        circle(radius: 0.13cm, fill: luma(20)))
      if digits != none {
        place(top + left, dx: 0pt, dy: cy + 0.22cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let chrono = {
    let W = s * 1.45
    let H = s * 1.65 + 0.75cm
    let cx = W / 2
    let cy = s * 0.78
    let r = s * 0.58
    box(width: W, height: H, {
      place(top + left, dx: cx - 0.08cm, dy: cy - r - 0.16cm,
        rect(width: 0.16cm, height: 0.16cm, fill: luma(40), radius: 0.03cm))
      place(top + left, dx: cx + r * 0.55, dy: cy - r * 0.85,
        circle(radius: 0.07cm, fill: luma(40)))
      place(top + left, dx: cx - r, dy: cy - r,
        circle(radius: r, fill: white, stroke: 1.6pt + luma(30)))
      if f > 0.01 {
        let n = 28
        let pts = ((cx, cy),)
        for i in range(0, n + 1) {
          let a = -90deg + 360deg * f * i / n
          pts.push((cx + r * 0.92 * calc.cos(a), cy + r * 0.92 * calc.sin(a)))
        }
        place(top + left, polygon(fill: paint-of(col, ang: 90deg), stroke: none, ..pts))
      }
      place(top + left, dx: cx - 0.06cm, dy: cy - 0.06cm,
        circle(radius: 0.06cm, fill: luma(25)))
      if digits != none {
        place(top + left, dx: 0pt, dy: cy + r + 0.12cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let wifi = {
    // Classic wifi: hub + concentric upward chevron-arcs (not customenvs bar).
    let nbar = calc.min(calc.max(3, int(max)), 6)
    let W = s * 1.45
    let H = s * 1.25 + 0.85cm
    let cx = W / 2
    let cy = s * 1.08
    let R = s * 0.98
    let a0 = 48deg
    let a1 = 132deg
    let polar(ang, r) = (cx + r * calc.cos(ang), cy - r * calc.sin(ang))
    let ring(r0, r1, paint) = {
      let n = 18
      let outer = range(n + 1).map(i => polar(a0 + (a1 - a0) * i / n, r1))
      let inner = range(n + 1).rev().map(i => polar(a0 + (a1 - a0) * i / n, r0))
      place(top + left, polygon(fill: paint, stroke: none, ..(outer + inner)))
    }
    box(width: W, height: H, {
      let hub = R * 0.13
      place(top + left, dx: cx - hub, dy: cy - hub,
        circle(radius: hub, fill: if value > 0 { col } else { trk }))
      for i in range(1, nbar) {
        let on = value > i
        let r1 = R * (i + 1) / nbar
        let r0 = r1 - R * 0.14
        ring(r0, r1, if on { col } else { trk.transparentize(35%) })
      }
      if digits != none {
        place(top + left, dx: 0pt, dy: H - 0.72cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  let cible = {
    // Exact customenvs `\inttkzArrowBullsEye` polar path (cm units of the
    // original: circles 0.6 / 1.36 / 2.25, dart along 45°).
    let u = s / 2.25
    let W = 7.2 * u
    let H = 6.4 * u + 0.80cm
    let cx = 3.2 * u
    let cy = 3.5 * u
    let polar(ang, r) = (cx + r * u * calc.cos(ang), cy - r * u * calc.sin(ang))
    box(width: W, height: H, {
      place(top + left, dx: cx - 2.25 * u, dy: cy - 2.25 * u,
        circle(radius: 2.25 * u, fill: rgb("#4FC3F7"), stroke: 1.1pt + luma(20)))
      place(top + left, dx: cx - 1.36 * u, dy: cy - 1.36 * u,
        circle(radius: 1.36 * u, fill: rgb("#E53935"), stroke: 1.1pt + luma(20)))
      place(top + left, dx: cx - 0.60 * u, dy: cy - 0.60 * u,
        circle(radius: 0.60 * u, fill: rgb("#FDD835"), stroke: 1.1pt + luma(20)))
      // White dart, black 2pt outline. Thin rectangular shaft (not a taper).
      let st = (paint: black, thickness: 2pt, join: "miter", cap: "butt")
      let along(r) = polar(45deg, r)
      let nrm(r, n) = {
        let p = polar(45deg, r)
        let o = polar(45deg + 90deg, n)
        (p.at(0) + (o.at(0) - cx), p.at(1) + (o.at(1) - cy))
      }
      let hw = 0.07   // half-width of the rectangular stem, in polar units
      // head (triangle pointing at the centre)
      place(top + left, polygon(fill: white, stroke: st,
        polar(45deg, 0), nrm(1.05, 0.22), nrm(1.05, -0.22)))
      // rectangular stem
      place(top + left, polygon(fill: white, stroke: st,
        nrm(0.95, hw), nrm(2.55, hw), nrm(2.55, -hw), nrm(0.95, -hw)))
      // swallow-tail
      place(top + left, polygon(fill: white, stroke: st,
        nrm(2.45, hw),
        polar(55deg, 2.5),
        polar(52deg, 3.5),
        polar(45deg, 3.1),
        polar(38deg, 3.5),
        polar(35deg, 2.5),
        nrm(2.45, -hw)))
      if digits != none {
        place(top + left, dx: 0pt, dy: H - 0.70cm,
          box(width: W, align(center,
            text(size: 0.78em, weight: "bold", fill: col, lab))))
      }
    })
  }

  if style == "thermo" { thermo }
  else if style == "battery" { battery }
  else if style == "bars" { bars }
  else if style == "dots" { dots }
  else if style == "stars" { stars }
  else if style == "hearts" or style == "coeurs" { hearts }
  else if style == "pie" { pie }
  else if style == "steps" { steps }
  else if style == "flame" or style == "feu" { flame }
  else if style == "speedo" or style == "speedometer" { speedo }
  else if style == "chrono" or style == "pictochrono" { chrono }
  else if style == "wifi" { wifi }
  else if style == "cible" or style == "bullseye" { cible }
  else { gauge }
}

/// A meter pre-set for exercise difficulty: the label reads "difficulté"
/// (or `label`) and the value sits over `max` stars of effort.
#let difficulty(
  value,
  max: 5,
  style: "gauge",
  label: auto,
  ..a,
) = meter(
  value, max: max, style: style,
  label: if label == auto { text(lang: "en", dir: ltr)[diff. #value/#max] } else { label },
  ..a,
)

/// Inline stopwatch (pictochrono): filled sector = duration / `max`.
#let pictochrono(
  minutes,
  max: 60,
  size: 1.2cm,
  label: auto,
  colour: rgb("#1565C0"),
  ..a,
) = meter(
  minutes, max: max, style: "chrono", size: size, colour: colour,
  label: if label == auto {
    text(lang: "en", dir: ltr)[#minutes min]
  } else { label },
  ..a,
)
