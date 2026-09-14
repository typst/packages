// Pill-steps: central hub + connected rounded pill rows (freepik style).
// Import with:  #import "pill-steps.typ": pill-steps
//
//   item = (title, body) | (title, body, icon) | (title, body, icon, color)
//   icon is ANY content already styled by you.
//
//   #pill-steps((
//     ([Research], [Gather requirements], text(font: "Font Awesome 7 Free", size: 26pt)[\u{f0eb}]),
//     ([Develop], [Build the solution], , rgb("#74c7ec")),
//   ))
#import "common.typ": palette, _lab, _col

#let pill-steps(
  items,
  title: [INFOGRAPHIC \ STEPS],
  hub-body: none,
  hub-r: 3.6cm, step-r: 1.1cm,
  pill-w: 15cm, pill-h: 2.4cm, vgap: 0.6cm, gap-hub: 1.8cm,
  text-fill: white, body-fill: white.transparentize(12%),
  hub-fill: white, hub-text: rgb("#1f1f3a"),
  step-circle-fill: white, step-text-fill: auto,
  connector: luma(170), connector-dot-fill: white, dot-stroke: luma(150),
  icon-color: auto,
  icon-font: "Font Awesome 7 Free", icon-size: 26pt,
  title-size: 20pt, body-size: 12pt, step-size: 28pt, steplbl-size: 11pt,
) = {
  set par(justify: false, leading: 0.5em)
  let n = items.len()
  let totalH = n * pill-h + (n - 1) * vgap
  let H = calc.max(totalH, 2 * hub-r)
  let pillX = 2 * hub-r + gap-hub
  let W = pillX + pill-w
  let rowTop = i => (H - totalH) / 2 + i * (pill-h + vgap)
  let cyf = i => rowTop(i) + pill-h / 2
  let hubCY = H / 2
  let lab = it => if type(it) == array { it.at(0) } else { it }
  let bod = it => if type(it) == array { it.at(1, default: []) } else { [] }
  let ico = it => if type(it) == array { it.at(2, default: none) } else { none }
  let colf = (it, i) => if type(it) == array and it.len() > 3 { it.at(3) } else { palette.at(calc.rem(i, palette.len())) }
  let stf = (col, i) => if step-text-fill == auto { col } else { step-text-fill }
  box(width: W, height: H, {
    for i in range(n) {
      let ax = hub-r * 1.35
      let ay = hubCY + (cyf(i) - hubCY) * 0.35
      let bx = pillX - step-r
      let by = cyf(i)
      let mx = (ax + bx) / 2
      place(top + left, curve(stroke: connector + 1.5pt,
        curve.move((ax, ay)), curve.cubic((mx, ay), (mx, by), (bx, by))))
      place(top + left, dx: ax - 3pt, dy: ay - 3pt,
        circle(radius: 3pt, fill: connector-dot-fill, stroke: dot-stroke + 1.2pt))
    }
    for (i, it) in items.enumerate() {
      let col = colf(it, i)
      let icon = ico(it)
      place(top + left, dx: pillX, dy: rowTop(i),
        box(width: pill-w, height: pill-h, fill: col, radius: pill-h / 2,
          inset: (left: step-r + 1cm, right: if icon != none { 2.4cm } else { 0.8cm }, y: 0.3cm),
          align(horizon, stack(dir: ttb, spacing: 4pt,
            text(fill: text-fill, weight: "bold", size: title-size)[#lab(it)],
            text(fill: body-fill, size: body-size)[#bod(it)]))))
      if icon != none {
        let ico-display = if type(icon) == "string" {
          text(fill: icon-color, font: icon-font, size: icon-size)[#icon]
        } else if icon-color != auto {
          { set text(fill: icon-color); icon }
        } else { icon }
        place(top + left, dx: pillX + pill-w - 1.8cm, dy: cyf(i) - 0.7cm,
          box(width: 1.4cm, height: 1.4cm, align(center + horizon, ico-display)))
      }
      place(top + left, dx: pillX - step-r, dy: cyf(i) - step-r,
        box(width: 2 * step-r, height: 2 * step-r, fill: step-circle-fill, radius: step-r,
          align(center + horizon, stack(dir: ttb, spacing: 0pt,
            text(fill: stf(col, i), weight: "bold", size: step-size)[#(if i + 1 < 10 { "0" })#(i + 1)]))))
    }
    place(top + left, dx: 0pt, dy: hubCY - hub-r,
      box(width: 2 * hub-r, height: 2 * hub-r, fill: hub-fill, radius: hub-r, inset: hub-r * 0.35,
        align(center + horizon, stack(dir: ttb, spacing: 6pt,
          text(fill: hub-text, weight: "bold", size: title-size + 4pt)[#title],
          if hub-body != none { box(width: 100%, text(fill: hub-text.lighten(15%), size: body-size)[#hub-body]) }))))
  })
}
