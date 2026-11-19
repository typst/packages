// Annotate: callouts on any content (an image, a plot), with leader lines to labels beside it.
// Import with:  #import "annotate.typ": annotate
//
//   #annotate(image("ecg.svg", width: 6cm), (((30%, 20%), [R peak]), ((70%, 60%), [T wave])))
#import "common.typ": _canvas, _dot, _items, _lens, _theme, _txt

#let annotate(
  body,
  notes,
  gap: 2em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("annotate", theme, style)
  let notes = _items("annotate", notes, (t.accent,), fields: ("point", "label"), cycle: false)
  for (i, nt) in notes.enumerate() {
    assert(type(nt.point) == array and nt.point.len() == 2 and nt.point.all(v => type(v) == ratio),
      message: "annotate: note " + str(i + 1) + " needs an (x, y) point in ratios of the body such as (30%, 50%), got "
        + repr(nt.point))
  }
  let (gap, size, em) = _lens("annotate", gap: gap, text-size: text-size, em: 1em).values()
  let (width: bw, height: bh) = measure(body)
  let label-w = 9 * em
  // one side's notes from top to bottom: each label at its point's height, or just below
  // the previous label when they would overlap
  let side(left) = {
    let (out, bottom) = ((), -float.inf * 1pt)
    for nt in notes.filter(nt => (nt.point.at(0) < 50%) == left).sorted(key: nt => nt.point.at(1)) {
      let label = _txt(nt.label, t.ink, size * t.small, weight: auto)
      let (width: w, height: h) = measure(label, width: label-w)
      let y = calc.max(nt.point.at(1) * bh - h / 2, bottom + 0.5 * em)
      out.push((..nt, label: label, w: w, h: h, y: y))
      bottom = y + h
    }
    out
  }
  let (lefts, rights) = (side(true), side(false))
  let room(side) = if side.len() == 0 { 0pt } else { gap + calc.max(..side.map(nt => nt.w)) }
  let (x0, y0) = (room(lefts), calc.max(0pt, ..(lefts + rights).map(nt => -nt.y)))
  _canvas("annotate", t, width, area, x0 + bw + room(rights), y0 + calc.max(bh, ..(lefts + rights).map(nt => nt.y + nt.h)), {
    place(top + left, dx: x0, dy: y0, body)
    for (side, k) in ((lefts, -1), (rights, 1)) {
      // the label's inner edge, then the knee where the leader turns towards the point
      let edge = if k < 0 { x0 - gap } else { x0 + bw + gap }
      for nt in side {
        let (px, py, ly) = (x0 + nt.point.at(0) * bw, y0 + nt.point.at(1) * bh, y0 + nt.y + nt.h / 2)
        place(top + left, curve(stroke: (paint: nt.fill, thickness: t.stroke * 1.2, join: "round"),
          curve.move((edge - k * 0.3 * em, ly)), curve.line((edge - k * 0.75 * gap, ly)), curve.line((px, py))))
        _dot(px, py, 0.22 * em, fill: nt.fill, stroke: 0.08 * em + t.surface)
        place(top + left, dx: if k < 0 { edge - label-w } else { edge }, dy: y0 + nt.y,
          box(width: label-w, align(if k < 0 { right } else { left }, nt.label)))
      }
    }
  })
})
