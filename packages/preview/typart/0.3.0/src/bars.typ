// Bars: labelled horizontal bars with values (results, benchmarks), filling the width.
// Import with:  #import "bars.typ": bars
//
//   #bars((([Ours], 94.2, red), ([Baseline A], 88.7), ([Baseline B], 81.3)), unit: "%")
#import "common.typ": _fluid, _items, _lens, _on, _theme, _txt

#let bars(
  items,
  max: auto,
  unit: "",
  item-height: 1.5em,
  gap: 0.5em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("bars", theme, style)
  let items = _items("bars", items, t.palette, fields: ("label", "value"), numbers: ("value",), cycle: false)
  for (i, it) in items.enumerate() {
    if not (type(it.value) in (int, float)) { assert(false, message: "bars: the value of item " + str(i + 1) + " must be a number, got "
      + repr(it.value)) }
  }
  let (bar-h, gap, size, em) = _lens("bars", item-height: item-height, gap: gap, text-size: text-size, em: 1em).values()
  let top = if max == auto { calc.max(..items.map(it => it.value)) } else { max }
  let names = items.map(it => _txt(it.label, t.ink, size, weight: auto))
  let gutter = 0.7 * em
  let total = _fluid("bars", width, area)
  // names wrap once they would take more than 40% of the width
  let name-w = calc.min(calc.max(..names.map(b => measure(b).width)), total * 0.4)
  let bar-w = total - name-w - gutter
  let pad = bar-h / 3
  grid(columns: (name-w, bar-w), column-gutter: gutter, row-gutter: gap, align: (right + horizon, left + horizon),
    ..items.zip(names).map(((it, name)) => {
      let fill-w = bar-w * it.value / top
      let value(fill) = _txt([#it.value#unit], fill, size * t.small)
      let inside = value(_on(t, it.fill))
      // a value that does not fit in its bar goes just after it, in the text colour
      let fits = measure(inside).width + 2 * pad <= fill-w
      (
        name,
        box(width: bar-w, height: bar-h, fill: t.panel, radius: bar-h / 2, {
          place(box(width: fill-w, height: bar-h, fill: it.fill, radius: bar-h / 2))
          if fits {
            place(left + horizon, dx: fill-w - pad - measure(inside).width, inside)
          } else {
            place(left + horizon, dx: fill-w + pad, value(t.ink))
          }
        }),
      )
    }).flatten())
})
