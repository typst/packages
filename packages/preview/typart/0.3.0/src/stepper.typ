// Stepper: numbered milestones on a line, with done / current / upcoming states.
// Import with:  #import "stepper.typ": stepper
//
//   #stepper(([Proposal], [Data], [Model], [Paper]), current: 2)
#import "common.typ": _canvas, _dot, _items, _lens, _on, _put, _tallest, _theme, _txt

#let stepper(
  items,
  current: 0,
  step: 6em,
  node-radius: 0.9em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("stepper", theme, style)
  let items = _items("stepper", items, (t.accent,))
  let (step, node, size, em) = _lens("stepper", step: step, node-radius: node-radius, text-size: text-size,
    em: 1em).values()
  let n = items.len()
  let y = node + 0.25 * em
  let x = i => step * (i + 0.5)
  let faded = color.mix((t.ink, 50%), (t.surface, 50%))
  // index < current: done, == current: in progress, > current: upcoming
  let state(i) = if i < current { "done" } else if i == current { "now" } else { "todo" }
  let labels = items.enumerate().map(((i, it)) => _txt(it.label, if state(i) == "todo" { faded } else { t.ink }, size,
    weight: if state(i) == "now" { "bold" } else { auto }))
  let body = stack(dir: ttb, spacing: 0.5 * em,
    box(width: n * step, height: 2 * y, {
      place(top + left, line(start: (x(0), y), end: (x(n - 1), y), stroke: t.muted + t.thick))
      if current > 0 {
        place(top + left, line(start: (x(0), y), end: (x(calc.min(current, n - 1)), y), stroke: t.accent + t.thick))
      }
      for i in range(n) {
        let s = state(i)
        _dot(x(i), y, node, fill: if s == "done" { t.accent } else { t.surface },
          stroke: (if s == "todo" { t.muted } else { t.accent }) + (if s == "now" { 0.25 } else { 0.15 }) * em)
        _put(x(i), y, _txt(if s == "done" { sym.checkmark } else { str(i + 1) },
          if s == "done" { _on(t, t.accent) } else if s == "now" { t.ink } else { faded }, node * 1.1))
      }
    }),
    grid(columns: (step,) * n, align: center, ..labels.map(label => box(width: step - 0.5 * em, label))))
  // measuring a grid that is also laid out costs a second layout iteration, so the
  // height is added up from the labels
  _canvas("stepper", t, width, area, n * step, 2 * y + 0.5 * em + _tallest(labels, step - 0.5 * em), body)
})
