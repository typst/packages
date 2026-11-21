// Timing: a digital timing diagram, one row per signal, each written as a string of
// levels.  Import with:  #import "timing.typ": timing
//
//   #timing((([CLK], "01010101"), ([DATA], "x0110x00")))
#import "common.typ": _canvas, _items, _lens, _theme, _txt

#let timing(
  signals,
  step: 1.5em,
  item-height: 1.5em,
  gap: 0.8em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("timing", theme, style)
  let signals = _items("timing", signals, (t.line,), fields: ("label", "levels"), cycle: false).map(s => s
    + (levels: if type(s.levels) == content and s.levels.has("text") { s.levels.text } else { s.levels }))
  for (i, s) in signals.enumerate() {
    if not (type(s.levels) == str and s.levels.match(regex("^[01xX]+$")) != none) { assert(false, message: "timing: the levels of signal "
      + str(i + 1) + " are a string of 0, 1 and x (unknown), got " + repr(s.levels)) }
  }
  let (step, h, gap, size, em) = _lens("timing", step: step, item-height: item-height, gap: gap, text-size: text-size,
    em: 1em).values()
  let labels = signals.map(s => _txt(s.label, t.ink, size, weight: auto))
  let x0 = calc.max(..labels.map(l => measure(l).width)) + 0.8 * em
  let slots = calc.max(..signals.map(s => s.levels.len()))
  let weight = 1.4 * t.stroke
  _canvas("timing", t, width, area, x0 + slots * step, signals.len() * (h + gap) - gap, {
    for k in range(slots + 1) {
      place(top + left, line(start: (x0 + k * step, 0pt), end: (x0 + k * step, signals.len() * (h + gap) - gap),
        stroke: (paint: t.muted, thickness: t.stroke * 0.7, dash: "dotted")))
    }
    for (i, s) in signals.enumerate() {
      let top-y = i * (h + gap)
      let y(level) = top-y + (if level == "1" { weight / 2 } else { h - weight / 2 })
      place(top + left, dy: top-y, box(width: x0 - 0.8 * em, height: h, align(right + horizon, labels.at(i))))
      // runs of 0 and 1 are one stroke each; a stretch of unknown level is a filled band
      let (pts, previous) = ((), none)
      for (k, level) in s.levels.clusters().map(lower).enumerate() {
        let (a, b) = (x0 + k * step, x0 + (k + 1) * step)
        if level == "x" {
          place(top + left, dx: a, dy: top-y, box(width: step, height: h, fill: t.muted,
            stroke: (top: weight + s.fill, bottom: weight + s.fill)))
        } else {
          if previous in (none, "x") { pts.push(curve.move((a, y(level)))) } else if previous != level {
            pts.push(curve.line((a, y(level))))
          }
          pts.push(curve.line((b, y(level))))
        }
        previous = level
      }
      place(top + left, curve(stroke: (paint: s.fill, thickness: weight, join: "miter"), ..pts))
    }
  })
})
