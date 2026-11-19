// Target: concentric rings, outermost first.  Import with:  #import "target.typ": target
//
//   #target(([Vision], [Mission], ([Goal], red)))
#import "common.typ": _canvas, _dot, _fit, _items, _lens, _on, _put, _theme, _txt

#let target(
  items,
  radius: 8em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("target", theme, style)
  let items = _items("target", items, t.palette)
  let (r, size, em) = _lens("target", radius: radius, text-size: text-size, em: 1em).values()
  let n = items.len()
  let band = r / n
  // label centre (as a fraction of r above the centre) and its slot inside the ring
  let ys = range(n).map(i => if i == n - 1 { 0 } else { (2 * (n - i) - 1) / (2 * n) })
  let ws = range(n).map(i => {
    let ro = (n - i) / n
    calc.max(1.7 * em, 2 * r * calc.sqrt(calc.max(0.0004, ro * ro - ys.at(i) * ys.at(i))) - 0.65 * em)
  })
  // a ring label stays between its two circles; the centre label inside the disc
  let in-ring(i, lw, lh) = {
    let (yc, ro) = (r * ys.at(i), band * (n - i))
    if i == n - 1 { return calc.norm(lw / 2pt, lh / 2pt) * 1pt <= ro - 0.25 * em }
    calc.norm(lw / 2pt, (yc + lh / 2) / 1pt) * 1pt <= ro - 0.17 * em and yc - lh / 2 >= ro - band + 0.17 * em
  }
  let s = _fit(items.map(it => it.label), t.ink, size, ws, in-ring)
  _canvas("target", t, width, area, 2 * r, 2 * r, {
    for (i, it) in items.enumerate() {
      _dot(r, r, band * (n - i), fill: it.fill, stroke: t.surface + 0.12 * em)
    }
    for (i, it) in items.enumerate() {
      _put(r, r * (1 - ys.at(i)), _txt(it.label, _on(t, it.fill), s), w: ws.at(i))
    }
  })
})
