// Infographic cards in a row, after contemporary slide templates: every card
// is drawn (no images), RTL mirrors the row, `print` mode goes grey.
//
//   steps   array of (title:, body:, icon:, label:, colour:)  — or plain bodies
//   width   `auto` = the line;  height  a length;  gap  between the cards
#import "infokit.typ": *

#let _row(steps, width, height, gap, direction, colours, draw, default-height, lead: 0, icon-size: 15pt) = {
  let n = steps.len()
  canvas(width, height, direction, steps, (Wc, Hc, rtl, print, k) => {
    let gp = gap / 1cm
    let cw = (Wc - lead - (n - 1) * gp) / n
    let st = steps.enumerate().map(((i, s)) => {
      let d = norm-step(s, i, colours)
      d + (icon: if d.icon == none { none } else { text(size: icon-size, d.icon) })
    })
    let parts = st.enumerate().map(((i, s)) => draw(i, s, lead + i * (cw + gp), cw, Hc, k, print))
    (k.layer)(parts.map(p => p.at(0)).join()) + parts.map(p => p.at(1)).join()
  }, default-height: default-height)
}

#let _t(s, size, fill, weight: "bold") = {
  if s.title == none { none } else { text(size: size, weight: weight, fill: fill, s.title) }
}
#let _b(s, size, fill) = {
  if s.body == none { none } else { text(size: size, fill: fill, s.body) }
}

// ---------------------------------------------------------------------------
/// Cards with a round icon on top, a header band and a body that carries a
/// lettered puzzle notch on its left side; a double chevron runs underneath.
#let puzzle-tab-cards(
  steps: (), width: auto, height: 8.2cm, gap: 0.55cm, direction: auto,
  colours: (rgb("#74B52D"), rgb("#E8431C"), rgb("#F79A32")),
  background: rgb("#4B0A4F"), icon-size: 15pt, title-size: 11pt, body-size: 7.6pt,
  letters: auto, footer: true,
) = _row(steps, width, height, gap, direction, colours, (i, s, x, cw, H, k, print) => {
  let c = pc(s.colour, print)
  let bgc = if background == none { white } else { background }
  let body-y = 3.0
  let body-h = H - body-y - if footer { 1.05 } else { 0.2 }
  let mid = body-y + body-h * 0.5
  let letter = if letters == auto { str.from-unicode(65 + i) } else { letters.at(i) }
  let shapes = {
    if i == 0 and background != none { (k.rect)(0, 0, k.Wc, k.Hc, fill: background) }
    if i == 0 and footer {
      for (y, dx) in ((H - 1.0, 0.0), (H - 0.5, 0.45)) {
        (k.poly)(((0.15 + dx, y), (k.Wc - 0.6, y), (k.Wc - 0.2, y + 0.2), (k.Wc - 0.6, y + 0.4), (0.15 + dx, y + 0.4)),
          fill: white.transparentize(82%))
      }
    }
    (k.circ)(x + cw / 2, 1.0, 0.95, fill: c.darken(32%))
    (k.rr)(x, 1.15, cw, 1.55, r: 0.4, fill: c.darken(14%))
    (k.rect)(x, 1.55, cw, 0.75, fill: c.darken(26%).transparentize(40%))
    (k.rr)(x, body-y, cw, body-h, r: 0.3, fill: c, shadow: true)
    (k.circ)(x, mid, 0.8, fill: bgc)
    (k.circ)(x, mid, 0.56, fill: c, stroke: 1.2pt + white)
  }
  let ink = white
  let texts = {
    (k.tx)(x + 0.2, 0.45, cw - 0.4, 1.1, text(fill: white, s.icon))
    (k.tx)(x + 0.15, 1.15, cw - 0.3, 1.55, _t(s, title-size, ink))
    (k.wrap)(x + 0.3, body-y + 0.3, cw - 0.6, body-h - 0.6, s.body, body-size, ink, holes: ((x, mid, 0.8),))
    (k.tx)(x - 0.56, mid - 0.56, 1.12, 1.12, text(size: 13pt, weight: "bold", fill: white, letter))
  }
  (shapes, texts)
}, 8.2cm, lead: 0.85, icon-size: icon-size)

// ---------------------------------------------------------------------------
/// A coloured card folded back at the top corner, with a white face carrying a
/// round icon, a title, a text and a number.
#let folded-tab-cards(
  steps: (), width: auto, height: 8.4cm, gap: 0.35cm, direction: auto,
  colours: (rgb("#F25C6E"), rgb("#FFC845"), rgb("#7CC68F"), rgb("#6BB0DD"), rgb("#9A8FD0")),
  icon-size: 15pt, title-size: 9pt, body-size: 6.8pt, numbers: true,
) = _row(steps, width, height, gap, direction, colours, (i, s, x, cw, H, k, print) => {
  let c = pc(s.colour, print)
  let shapes = {
    // the back card has the size of the front one, raised by the same gap at the bottom as at the top
    let (dx, dy) = (cw * 0.12, 0.55)
    (k.rr)(x, 1.0 - dy, cw - dx, H - 1.0, tl: 1.5, bl: 1.5, r: 0, fill: c)
    // the grey fold: from the top-left corner of the front card to the top-right corner of the back one
    (k.poly)(((x + dx, 1.0), (x + cw - dx, 1.0 - dy), (x + cw - dx, 1.0)),
      fill: luma(150).transparentize(25%), stroke: none)
    (k.rr)(x + dx, 1.0, cw - dx, H - 1.0, tr: 0.9, br: 0.9, r: 0, fill: white, stroke: 0.9pt + luma(205), shadow: true)
    (k.circ)(x + cw * 0.56, 3.0, 1.0, fill: luma(246), stroke: 0.8pt + luma(232))
  }
  let ink = luma(120)
  let texts = {
    (k.tx)(x + cw * 0.56 - 0.7, 2.3, 1.4, 1.4, s.icon)
    (k.tx)(x + cw * 0.2, 4.4, cw * 0.74, 0.7, _t(s, title-size, c.darken(8%)))
    (k.tx)(x + cw * 0.2, 5.15, cw * 0.74, H - 6.7, _b(s, body-size, ink), al: top + start)
    if numbers {
      (k.tx)(x + cw * 0.2, H - 1.45, cw * 0.74, 0.9,
        text(size: 15pt, weight: "bold", fill: luma(130), two-digits(i)))
    }
  }
  (shapes, texts)
}, 8.4cm, icon-size: icon-size)

// ---------------------------------------------------------------------------
/// Cards under a half-disc tab ("01 OPTIONS"), coloured top to bottom.
#let half-disc-tab-cards(
  steps: (), width: auto, height: 6.6cm, gap: 0.5cm, direction: auto,
  colours: (rgb("#F58220"), rgb("#1B7BA6"), rgb("#3D4B5C"), rgb("#4A3A36"), rgb("#B0A184")),
  icon-size: 15pt, title-size: 9pt, body-size: 6.6pt, caption: "OPTIONS",
) = _row(steps, width, height, gap, direction, colours, (i, s, x, cw, H, k, print) => {
  let c = pc(s.colour, print)
  let shapes = {
    (k.poly)(range(0, 25).map(j => (x + cw / 2 - 1.2 * calc.cos(j / 24 * 180deg), 1.2 - 1.2 * calc.sin(j / 24 * 180deg) + 0.05)),
      fill: luma(250), stroke: 1.1pt + luma(70))
    (k.rect)(x - 0.1, 1.25, cw + 0.2, 0.18, fill: luma(245))
    (k.rect)(x, 1.43, cw, H - 1.43, fill: gradient.linear(c.lighten(12%), c.darken(14%), angle: 90deg), stroke: 1.2pt + c.darken(55%), shadow: true)
  }
  let texts = {
    (k.tx)(x + cw / 2 - 1.0, 0.1, 2.0, 0.65, text(size: 15pt, weight: "bold", fill: luma(95), two-digits(i)))
    (k.tx)(x + cw / 2 - 1.0, 0.72, 2.0, 0.4, text(size: 6pt, weight: "bold", fill: luma(120), caption))
    (k.tx)(x + 0.35, 1.8, cw - 0.7, 0.9, _t(s, title-size, white), al: start + horizon)
    (k.tx)(x + 0.35, 2.75, cw - 0.7, H - 3.0, _b(s, body-size, white), al: top + start)
  }
  (shapes, texts)
}, 6.6cm, icon-size: icon-size)

// ---------------------------------------------------------------------------
/// White cards with a coloured tab on top, a U-shaped coloured backing at the
/// bottom and a round icon.
#let u-backed-cards(
  steps: (), width: auto, height: 8.6cm, gap: 0.8cm, direction: auto,
  colours: (rgb("#6CBFB0"), rgb("#F5A04A"), rgb("#6D5A99")),
  icon-size: 15pt, title-size: 11pt, body-size: 6.8pt,
) = _row(steps, width, height, gap, direction, colours, (i, s, x, cw, H, k, print) => {
  let c = pc(s.colour, print)
  let shapes = {
    (k.rr)(x - 0.55, H * 0.62, cw + 1.1, H * 0.38 - 0.3, br: 1.1, bl: 1.1, r: 0, fill: c)
    (k.rr)(x + cw * 0.18, 0, cw * 0.64, 0.8, br: 0.35, bl: 0.35, r: 0, fill: c)
    (k.rr)(x, 0.4, cw, H - 1.0, r: 0.55, fill: white, stroke: 1pt + c.lighten(10%), shadow: true)
    (k.circ)(x + cw / 2, H - 2.0, 1.0, fill: c)
  }
  let texts = {
    (k.tx)(x + 0.4, 1.35, cw - 0.8, 0.9, _t(s, title-size, c.darken(5%)))
    (k.tx)(x + 0.5, 2.4, cw - 1.0, H - 5.4, _b(s, body-size, luma(110)), al: top + center)
    (k.tx)(x + cw / 2 - 0.7, H - 2.7, 1.4, 1.4, s.icon)
  }
  (shapes, texts)
}, 8.6cm, icon-size: icon-size)

// ---------------------------------------------------------------------------
/// Outline cards whose top edge carries two round badges: a numbered disc and
/// an icon ring.
#let circle-head-outline-cards(
  steps: (), width: auto, height: 8.0cm, gap: 0.8cm, direction: auto,
  colours: (rgb("#E8A200"), rgb("#E0405A"), rgb("#6CBB3C")),
  icon-size: 15pt, title-size: 11pt, body-size: 6.6pt, stroke-weight: 1.3pt,
) = _row(steps, width, height, gap, direction, colours, (i, s, x, cw, H, k, print) => {
  let c = pc(s.colour, print)
  let top-y = 2.0
  let st = stroke-weight + c
  let shapes = {
    (k.rr)(x, top-y, cw, H - top-y, br: 1.0, bl: 1.0, r: 0, fill: white, stroke: st, shadow: true)
    (k.circ)(x + cw * 0.27, top-y - 0.1, 1.15, fill: white, stroke: st)
    (k.circ)(x + cw * 0.27, top-y - 0.1, 0.85, fill: white, stroke: st)
    (k.circ)(x + cw * 0.27, top-y - 0.1, 0.62, fill: c)
    (k.circ)(x + cw * 0.74, top-y + 0.3, 1.0, fill: white, stroke: st)
    (k.rect)(x + cw * 0.74 + 0.7, top-y - 0.15, cw * 0.26, 0.2, fill: white)
    (k.open)(((x + cw * 0.74 + 0.7, top-y), (x + cw, top-y)), stroke: st)
  }
  let texts = {
    (k.tx)(x + cw * 0.27 - 0.6, top-y - 0.7, 1.2, 1.2, text(size: 11pt, weight: "bold", fill: white, two-digits(i)))
    (k.tx)(x + cw * 0.74 - 0.7, top-y - 0.4, 1.4, 1.4, s.icon)
    (k.tx)(x + 0.4, top-y + 1.6, cw - 0.8, 0.8, _t(s, title-size, c))
    (k.tx)(x + 0.5, top-y + 2.5, cw - 1.0, H - top-y - 3.2, _b(s, body-size, luma(110)), al: top + center)
  }
  (shapes, texts)
}, 8.0cm, icon-size: icon-size)

// ---------------------------------------------------------------------------
/// Dashed outline cards (two opposite corners rounded) under a pill that holds
/// a numbered ring and an icon.
#let dashed-pill-cards(
  steps: (), width: auto, height: 5.6cm, gap: 0.5cm, direction: auto,
  colours: (rgb("#E8A200"), rgb("#E0405A"), rgb("#6CBB3C"), rgb("#17B3B3")),
  icon-size: 15pt, title-size: 10pt, body-size: 6.2pt,
) = _row(steps, width, height, gap, direction, colours, (i, s, x, cw, H, k, print) => {
  let c = pc(s.colour, print)
  let shapes = {
    (k.rr)(x, 0.1, cw, H - 0.2, tr: 1.7, bl: 1.7, r: 0, fill: none,
      stroke: (paint: c, thickness: 1.2pt, dash: (3.5pt, 2.5pt)))
    (k.rr)(x + cw * 0.14, 0.9, cw * 0.72, 1.35, r: 0.22, stroke: 1.1pt + c)
    (k.open)(((x + cw / 2, 0.9), (x + cw / 2, 2.25)), stroke: 1.1pt + c)
    (k.circ)(x + cw * 0.14 + cw * 0.18, 1.575, 0.5, stroke: 0.9pt + c)
  }
  let texts = {
    (k.tx)(x + cw * 0.14 + cw * 0.18 - 0.5, 1.075, 1.0, 1.0, text(size: 9pt, weight: "bold", fill: c, two-digits(i)))
    (k.tx)(x + cw / 2, 0.9, cw * 0.36, 1.35, s.icon)
    (k.tx)(x + 0.3, 2.65, cw - 0.6, 0.7, _t(s, title-size, c))
    (k.tx)(x + 0.4, 3.4, cw - 0.8, H - 3.7, _b(s, body-size, luma(115)), al: top + center)
  }
  (shapes, texts)
}, 6.6cm, icon-size: icon-size)

// ---------------------------------------------------------------------------
/// Slanted outline cards: a numbered disc at the upper left, an icon ring at
/// the lower right and a dashed echo of the lower-left corner.
#let skewed-badge-cards(
  steps: (), width: auto, height: 6.6cm, gap: 0.55cm, direction: auto,
  colours: (rgb("#E8A200"), rgb("#E0405A"), rgb("#6CBB3C"), rgb("#17B3B3")),
  icon-size: 15pt, title-size: 10pt, body-size: 6.2pt,
) = _row(steps, width, height, gap, direction, colours, (i, s, x, cw, H, k, print) => {
  let c = pc(s.colour, print)
  let a = (x + cw * 0.17, 0.75)
  let b = (x + cw * 0.78, 0.75)
  let cc = (x + cw * 0.84, H - 1.0)
  let d = (x + cw * 0.23, H - 1.0)
  let shapes = {
    (k.open)(((x + cw * 0.04, 3.2), (x + cw * 0.04 + 0.28, H - 0.4), (x + cw * 0.78, H - 0.4)),
      stroke: (paint: c, thickness: 1pt, dash: (3pt, 2.5pt)))
    (k.poly)((a, b, cc, d), fill: white, stroke: 1.3pt + c, shadow: true)
    (k.circ)(a.at(0), a.at(1) + 0.15, 0.9, fill: c, stroke: 2pt + white)
    (k.circ)(x + cw * 0.9, H - 0.75, 1.0, fill: white, stroke: 1.3pt + c)
  }
  let texts = {
    (k.tx)(a.at(0) - 0.6, a.at(1) - 0.45, 1.2, 1.2, text(size: 11pt, weight: "bold", fill: white, two-digits(i)))
    (k.tx)(x + cw * 0.9 - 0.7, H - 1.45, 1.4, 1.4, s.icon)
    (k.tx)(x + cw * 0.27, 1.9, cw * 0.5, 0.7, _t(s, title-size, c))
    (k.tx)(x + cw * 0.27, 2.6, cw * 0.5, H - 4.3, _b(s, body-size, luma(115)), al: top + center)
  }
  (shapes, texts)
}, 6.6cm, icon-size: icon-size)

// ---------------------------------------------------------------------------
/// Outline cards with a header badge (a year, a step), a coloured title band,
/// a text, an icon and a small tab at the foot.
#let badge-timeline-cards(
  steps: (), width: auto, height: 6.6cm, gap: 0.55cm, direction: auto,
  colours: (rgb("#8059A6"), rgb("#EA9527"), rgb("#27AEEA"), rgb("#E8431C")),
  icon-size: 15pt, title-size: 9pt, body-size: 6.4pt, badge-size: 13pt,
) = _row(steps, width, height, gap, direction, colours, (i, s, x, cw, H, k, print) => {
  let c = pc(s.colour, print)
  let shapes = {
    (k.rr)(x, 0.05, cw, H - 0.1, r: 0.55, fill: white, stroke: 1pt + c, shadow: true)
    (k.rr)(x + cw * 0.2, 0.05, cw * 0.6, 1.35, br: 0.4, bl: 0.4, r: 0, fill: c)
      (k.rect)(x, 2.0, cw, 0.95, fill: c)
    (k.rr)(x + cw * 0.2, H - 0.45, cw * 0.6, 0.4, tl: 0.25, tr: 0.25, r: 0, fill: c)
  }
  let texts = {
    (k.tx)(x + cw * 0.2, 0.2, cw * 0.6, 1.0, text(size: badge-size, weight: "bold", fill: white,
      if s.label != none { s.label } else { two-digits(i) }))
    (k.tx)(x, 2.0, cw, 0.95, _t(s, title-size, white))
    (k.tx)(x + 0.45, 3.2, cw - 0.9, H - 5.6, _b(s, body-size, luma(110)), al: top + center)
    (k.tx)(x + cw / 2 - 0.7, H - 2.0, 1.4, 1.4, s.icon)
  }
  (shapes, texts)
}, 8.0cm, icon-size: icon-size)
