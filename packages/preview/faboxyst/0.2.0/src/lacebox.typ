// ===========================================================================
//  faboxyst/lacebox.typ — the banknote frame: a guilloche lace border
//  around a clean panel, rosettes at the corners, a plaque for the title.
//
//    #lacebox(title: [Définition])[Le corps de la boîte.]
//    #lacebox(lace: "moire", band: 2cm, colour: rgb("#14424B"))[…]
//    #lacebox(model: "scallop", lace: "braid")[…]
//    #lacebox(rough: 1.2)[…]              // hand-drawn rules
//    #lacebox(ornament: 88)[…]            // pgfornament corners
//
//  The lace family comes from src/lace.typ — the same four line drawings
//  the guilloche cover offers through its `lace` parameter.
//
//  Frame width: `band` is exactly that — how deep the lace border runs.
//  `weight` sets the outer rule, `width` the box's own width.
//
//  `rough` > 0 redraws every straight rule (outer rule, panel rule, inner
//  ring, plaque) with the sketchbook's hand-drawn wobble, felt-tip style;
//  0 (the default) keeps the crisp engraved look. The scalloped panel of
//  model "scallop" stays a clean curve — waves already look hand-made.
//
//  `ornament` takes a pgfornament number (see src/pgfornament.typ) and
//  seats it, mirrored, in the four corners of the frame instead of the
//  rosettes (or the ray fans of model "corners").
// ===========================================================================

#import "@preview/cetz:0.5.2"
#import "engine.typ" as eng
#import "fabox.typ": is-rtl
#import "lace.typ": lace as lace-draw
#import "pgfornament.typ": pgfornament

/// A canvas of exactly (w, h), y running downward from the top-left corner.
#let _canvas(w, h, body) = {
  cetz.canvas(length: 1cm, {
    body(w / 1cm, h / 1cm)
  })
}

/// One hand-drawn rectangle rule inside such a canvas: (x, y) top-left in
/// cm, y downward; filled when `fillc` is not none (used to mask the lace).
#let _rrect(x, y, w, h, seed, rough, fillc, strokec, sw) = {
  eng.s-line(eng.rect-pts((x, -y), (x + w, -y - h)),
    seed: seed, closed: true, fill: fillc,
    stroke: (paint: strokec, thickness: sw),
    opts: (amplitude: 0.32 * rough, wavelength: 180.0))
}

/// A scalloped panel: four wavy cubic edges, like a stamp's perforation.
#let _scallop-panel(w, h, m, fillc, strokec) = {
  let a = 0.16cm
  let lam = 1.5cm
  let ops = (curve.move((m, m)),)
  let n = calc.max(2, calc.ceil((w - 2 * m) / lam))
  let seg = (w - 2 * m) / n
  for i in range(0, n) {
    let sgn = if calc.rem(i, 2) == 0 { -1 } else { 1 }
    ops += (curve.cubic(
      (m + seg * i + seg / 3, m + sgn * a),
      (m + seg * i + 2 * seg / 3, m + sgn * a),
      (m + seg * (i + 1), m),
    ),)
  }
  let nh = calc.max(2, calc.ceil((h - 2 * m) / lam))
  let segh = (h - 2 * m) / nh
  for i in range(0, nh) {
    let sgn = if calc.rem(i, 2) == 0 { -1 } else { 1 }
    ops += (curve.cubic(
      (w - m + sgn * a, m + segh * i + segh / 3),
      (w - m + sgn * a, m + segh * i + 2 * segh / 3),
      (w - m, m + segh * (i + 1)),
    ),)
  }
  for i in range(0, n) {
    let sgn = if calc.rem(i + n, 2) == 0 { -1 } else { 1 }
    ops += (curve.cubic(
      (w - m - seg * i - seg / 3, h - m + sgn * a),
      (w - m - seg * i - 2 * seg / 3, h - m + sgn * a),
      (w - m - seg * (i + 1), h - m),
    ),)
  }
  for i in range(0, nh) {
    let sgn = if calc.rem(i + nh, 2) == 0 { -1 } else { 1 }
    ops += (curve.cubic(
      (m + sgn * a, h - m - segh * i - segh / 3),
      (m + sgn * a, h - m - segh * i - 2 * segh / 3),
      (m, h - m - segh * (i + 1)),
    ),)
  }
  curve(fill: fillc, stroke: (paint: strokec, thickness: 0.6pt), ..ops)
}

/// A picture-frame box whose border is security-print lace.
///
/// The lace is drawn over the whole field and a panel in the body fill is
/// laid over its middle, so only the border band stays visible — exactly
/// how a banknote keeps its guilloche at the edges. Four frame models:
///
///   "band"     the plain lace band (default)
///   "double"   a lace band plus a thin lace ring inside the panel rule
///   "scallop"  the panel's edge waves in scallops, like a stamp
///   "corners"  no band at all: lace fans in the four corners of a
///              double-ruled frame
///
/// Hand-drawn mode: `rough: 1.2` (any value > 0) redraws the straight rules
/// with the sketchbook wobble — outer rule, panel rule, inner ring, plaque.
///
/// Ornaments: `ornament: 88` seats pgfornament no. 88 (family
/// `ornament-family`: "vectorian" | "han" | "am") mirrored in the four
/// corners of the frame, in place of the rosettes or ray fans.
#let lacebox(
  body,
  title: none,
  lace: "spiral",
  model: "band",
  colour: rgb("#1B2A41"),
  fill: white,
  band: 1.15cm,
  weight: 1pt,
  inset: 0.4cm,
  width: 100%,
  direction: auto,
  rough: 0,
  ornament: none,
  ornament-family: "vectorian",
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let pad = inset
    // "corners" keeps a slim double rule instead of a deep band
    let margin = if model == "corners" { 0.85cm } else { band }
    let inner-w = W - 2 * margin - 2 * pad
    let main = block(width: inner-w, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let body-h = measure(main).height
    let title-h = if title == none { 0pt } else {
      measure(text(weight: "bold", title)).height + 0.5cm
    }
    let H = 2 * margin + 2 * pad + body-h + title-h
    let lace-paint = colour.transparentize(55%)

    box(width: W, height: H, clip: true, {
      // the sheet; its outer rule is drawn later when rough
      if rough > 0 {
        place(top + left, rect(width: W, height: H, fill: fill))
      } else {
        place(top + left, rect(width: W, height: H, fill: fill,
          stroke: (paint: colour, thickness: weight)))
      }
      if model == "corners" {
        // a double rule round the sheet…
        if rough > 0 {
          place(top + left, _canvas(W, H, (Wc, Hc) => {
            _rrect(0, 0, Wc, Hc, 11, rough, none, colour, weight)
            _rrect(0.14, 0.14, Wc - 0.28, Hc - 0.28, 41, rough, none,
              colour, 0.6pt)
          }))
        } else {
          place(top + left, dx: 0.14cm, dy: 0.14cm,
            rect(width: W - 0.28cm, height: H - 0.28cm,
              stroke: (paint: colour, thickness: 0.6pt)))
        }
        // …and a ray-and-arc fan — or a pgfornament piece — in each corner
        let cs = calc.min(3.4cm, H * 0.42, W * 0.25)
        if ornament != none {
          let os = calc.min(2.8cm, H * 0.34, W * 0.22)
          let o = 0.16cm
          // a square seat, so the mirrored copies flip in place and the
          // four anchors stay exact
          let seat = (fx, fy) => box(width: os, height: os, {
            place(center + horizon,
              scale(x: fx, y: fy, pgfornament(ornament,
                family: ornament-family, width: os, paint: colour)))
          })
          place(top + left, dx: o, dy: o, seat(100%, 100%))
          place(top + left, dx: W - o - os, dy: o, seat(-100%, 100%))
          place(top + left, dx: o, dy: H - o - os, seat(100%, -100%))
          place(top + left, dx: W - o - os, dy: H - o - os,
            seat(-100%, -100%))
        } else {
          let fan-paint = colour.transparentize(35%)
          let corner = box(width: cs, height: cs, clip: true, {
            for a in range(0, 91, step: 6) {
              place(top + left,
                line(start: (0pt, 0pt),
                  end: (cs * 1.35 * calc.cos(a * 1deg),
                    cs * 1.35 * calc.sin(a * 1deg)),
                  stroke: (paint: fan-paint, thickness: 0.3pt)))
            }
            for r in (0.7, 1.3, 1.9, 2.5, 3.1, 3.7) {
              if r * 1cm < cs * 1.3 {
                place(top + left, dx: -r * 1cm, dy: -r * 1cm,
                  circle(radius: r * 1cm, fill: none,
                    stroke: (paint: fan-paint, thickness: 0.3pt)))
              }
            }
          })
          place(top + left, corner)
          place(top + left, dx: W - cs, scale(x: -100%, corner))
          place(top + left, dy: H - cs, scale(y: -100%, corner))
          place(top + left, dx: W - cs, dy: H - cs,
            scale(x: -100%, scale(y: -100%, corner)))
        }
      } else {
        // the lace over the whole field…
        place(top + left,
          lace-draw(lace, W, H, lace-paint, thickness: 0.3pt))
        // …masked by the panel, so it survives only as a border band
        if model == "scallop" {
          if rough > 0 {
            place(top + left, _canvas(W, H, (Wc, Hc) => {
              _rrect(0, 0, Wc, Hc, 11, rough, none, colour, weight)
            }))
          }
          place(top + left, _scallop-panel(W, H, band, fill, colour))
        } else if rough > 0 {
          place(top + left, _canvas(W, H, (Wc, Hc) => {
            let bc = band / 1cm
            _rrect(0, 0, Wc, Hc, 11, rough, none, colour, weight)
            _rrect(bc, bc, Wc - 2 * bc, Hc - 2 * bc, 23, rough, fill,
              colour, 0.6pt)
          }))
          if model == "double" {
            let m2 = band + 0.32cm
            if H - 2 * m2 - 0.84cm > 0.4cm {
              place(top + left, dx: m2, dy: m2,
                lace-draw(lace, W - 2 * m2, H - 2 * m2, lace-paint,
                  thickness: 0.25pt))
              place(top + left, _canvas(W, H, (Wc, Hc) => {
                let q = (m2 + 0.42cm) / 1cm
                _rrect(q, q, Wc - 2 * q, Hc - 2 * q, 37, rough, fill,
                  colour, 0.5pt)
              }))
            }
          }
        } else {
          place(top + left, dx: band, dy: band,
            rect(width: W - 2 * band, height: H - 2 * band, fill: fill,
              stroke: (paint: colour, thickness: 0.6pt)))
          if model == "double" {
            // a second, thin lace ring just inside the panel rule — skipped
            // when the box is too short to leave a centre at all
            let m2 = band + 0.32cm
            if H - 2 * m2 - 0.84cm > 0.4cm {
              place(top + left, dx: m2, dy: m2,
                lace-draw(lace, W - 2 * m2, H - 2 * m2, lace-paint,
                  thickness: 0.25pt))
              place(top + left, dx: m2 + 0.42cm, dy: m2 + 0.42cm,
                rect(width: W - 2 * m2 - 0.84cm,
                  height: H - 2 * m2 - 0.84cm,
                  fill: fill, stroke: (paint: colour, thickness: 0.5pt)))
            }
          }
        }
        // a rosette — or a pgfornament piece — in each corner of the band
        if ornament != none {
          let os = calc.min(1.6cm, band * 1.15)
          for cx in (band / 2, W - band / 2) {
            for cy in (band / 2, H - band / 2) {
              let sx = if cx < W / 2 { 100% } else { -100% }
              let sy = if cy < H / 2 { 100% } else { -100% }
              place(top + left, dx: cx, dy: cy,
                box(width: 0pt, height: 0pt, {
                  place(center + horizon,
                    scale(x: sx, y: sy, pgfornament(ornament,
                      family: ornament-family, width: os, paint: colour)))
                }))
            }
          }
        } else {
          let rw = calc.min(0.95cm, band * 0.8 + 0.2cm)
          for cx in (band / 2, W - band / 2) {
            for cy in (band / 2, H - band / 2) {
              place(top + left, dx: cx, dy: cy,
                box(width: 0pt, height: 0pt, {
                  for a in range(0, 360, step: 45) {
                    place(center + horizon,
                      rotate(a * 1deg, ellipse(width: rw, height: rw * 0.27,
                        stroke: (paint: colour.transparentize(30%),
                          thickness: 0.4pt),
                        fill: none)))
                  }
                }))
            }
          }
        }
      }
      // the title plaque, straddling the panel's top rule
      if title != none {
        let plate-y = if model == "corners" { 0.55cm } else { band }
        let tm = measure(text(weight: "bold", title))
        let pw2 = tm.width + 1.0cm
        let ph2 = tm.height + 0.5cm
        place(top + left, dx: W / 2 - pw2 / 2, dy: plate-y - ph2 / 2,
          box(width: pw2, height: ph2, {
            if rough > 0 {
              place(top + left, _canvas(pw2, ph2, (Wc, Hc) => {
                _rrect(0, 0, Wc, Hc, 53, rough, fill, colour, 0.8pt)
              }))
            } else {
              place(top + left, rect(width: pw2, height: ph2, fill: fill,
                radius: 2pt,
                stroke: (paint: colour, thickness: 0.8pt)))
            }
            place(top + left, dx: 0.5cm, dy: 0.25cm,
              text(fill: colour, weight: "bold", title))
          }))
      }
      // the body
      place(top + left, dx: margin + pad, dy: margin + pad + title-h, main)
    })
  })
}
