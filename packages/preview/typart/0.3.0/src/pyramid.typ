// Pyramid (or funnel) diagram.  Import with:  #import "pyramid.typ": pyramid
//
//   #pyramid(([Vision], [Strategy], ([Tactics], red)))
//   #pyramid(([Top], [Middle], [Bottom]), flip: true)   // funnel
#import "common.typ": _canvas, _fit, _items, _lens, _on, _poly, _put, _theme, _txt

#let pyramid(
  levels,
  base: 22em,
  height: 15em,
  gap: 0.3em,
  flip: false,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("pyramid", theme, style)
  let levels = _items("pyramid", levels, t.palette)
  let (base, height, gap, size, em) = _lens("pyramid", base: base, height: height, gap: gap, text-size: text-size,
    em: 1em).values()
  let n = levels.len()
  let cx = base / 2
  // half-width at depth y below the top edge
  let hw(y) = cx * (if flip { 1 - y / height } else { y / height })
  let band = height / n - gap
  let top(i) = height * i / n + (if i == 0 { 0pt } else { gap / 2 })
  // labels sit 32% of a band from its wide edge
  let label-y(i) = if flip { top(i) + band * 0.32 } else { top(i) + band * 0.68 }
  let ws = range(n).map(i => calc.max(2 * em, 2 * hw(label-y(i)) - em))
  // a label stays inside its trapezoid: checked at its narrow (pointed) side
  let in-band(i, lw, lh) = {
    let (yl, yt) = (label-y(i), top(i))
    let narrow = if flip { yl + lh / 2 } else { yl - lh / 2 }
    yl - lh / 2 >= yt + 0.08 * em and yl + lh / 2 <= yt + band - 0.08 * em and lw / 2 + 0.33 * em <= hw(narrow)
  }
  let s = _fit(levels.map(it => it.label), t.ink, size, ws, in-band)
  _canvas("pyramid", t, width, area, base, height, {
    for (i, it) in levels.enumerate() {
      let (yt, yb) = (top(i), height * (i + 1) / n - gap / 2)
      _poly((cx - hw(yt), yt), (cx + hw(yt), yt), (cx + hw(yb), yb), (cx - hw(yb), yb),
        fill: it.fill, stroke: t.surface + 0.12 * em)
      _put(cx, label-y(i), _txt(it.label, _on(t, it.fill), s), w: ws.at(i))
    }
  })
})
