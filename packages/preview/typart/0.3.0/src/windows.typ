// Windows: a signal cut into sliding windows, each drawn under the stretch it covers.
// Import with:  #import "windows.typ": windows
//
//   #windows(signal("ecg", cycles: 6, width: 18em), count: 4, overlap: 50%)
#import "common.typ": _canvas, _card, _fit, _lens, _on, _put, _theme, _txt

#let windows(
  body,
  count: 4,
  overlap: 50%,
  prefix: [Window],
  item-height: 1.7em,
  gap: 0.3em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("windows", theme, style)
  if not (type(count) == int and count > 0) { assert(false, message: "windows: `count` must be a positive integer, got " + repr(count)) }
  if not (type(overlap) == ratio and overlap >= 0% and overlap < 100%) { assert(false, message: "windows: `overlap` must be a ratio from 0% "
    + "up to (not including) 100%, got " + repr(overlap)) }
  let (h, gap, size, em) = _lens("windows", item-height: item-height, gap: gap, text-size: text-size, em: 1em).values()
  let (width: bw, height: bh) = measure(body)
  // the windows cover the body exactly: count lengths less the overlaps
  let stride = 1 - overlap / 100%
  let len = bw / (1 + (count - 1) * stride)
  // overlapping windows take turns on as many rows as overlap at once
  let rows = calc.min(count, calc.ceil(1 / stride - 0.0001))
  let labels = range(count).map(i => [#prefix #(i + 1)])
  let s = _fit(labels, t.ink, size * t.small, len - 0.5 * em, h - 0.3 * em)
  let base = bh + 0.6 * em
  _canvas("windows", t, width, area, bw, base + rows * (h + gap) - gap, {
    for i in range(count) {
      let (x, fill) = (i * stride * len, t.palette.at(calc.rem(i, t.palette.len())))
      let y = base + calc.rem(i, rows) * (h + gap)
      // a faint band shows the stretch of the body the window covers
      place(top + left, dx: x, box(width: len, height: bh, fill: fill.transparentize(82%)))
      place(top + left, dx: x, dy: y, _card(t, width: len, height: h, fill: fill, radius: t.corner-radius))
      _put(x + len / 2, y + h / 2, _txt(labels.at(i), _on(t, fill), s), w: len)
    }
    place(top + left, body)
  })
})
