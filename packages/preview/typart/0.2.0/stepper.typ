// Stepper: numbered milestones on a line, with done / current / upcoming states.
// Import with:  #import "stepper.typ": stepper
//
//   #stepper(([Proposal], [Data], [Model], [Paper]), current: 2)
#import "common.typ": _dot, _put, _txt, _u

#let stepper(
  items,
  current: 0,
  step: 4.5,
  node: 0.55,
  accent: rgb("#73c25a"),
  todo: luma(205),
  text-fill: rgb("#1f1f3a"),
  size: 14pt,
) = {
  let (step, node) = (_u(step), _u(node))
  let n = items.len()
  let y = node + 4pt
  let x = i => step * (i + 0.5)
  // index < current: done, == current: in progress, > current: upcoming
  let state(i) = if i < current { "done" } else if i == current { "now" } else { "todo" }
  stack(dir: ttb, spacing: 8pt,
    box(width: n * step, height: 2 * y, {
      place(top + left, line(start: (x(0), y), end: (x(n - 1), y), stroke: todo + 4pt))
      if current > 0 {
        place(top + left, line(start: (x(0), y), end: (x(calc.min(current, n - 1)), y), stroke: accent + 4pt))
      }
      for i in range(n) {
        let s = state(i)
        _dot(x(i), y, node, fill: if s == "todo" { white } else if s == "done" { accent } else { white },
          stroke: (if s == "todo" { todo } else { accent }) + (if s == "now" { 4pt } else { 2.5pt }))
        _put(x(i), y, _txt(if s == "done" { sym.checkmark } else { str(i + 1) },
          if s == "done" { white } else if s == "now" { accent } else { todo }, node * 1.1))
      }
    }),
    grid(columns: (step,) * n, align: center,
      ..items.enumerate().map(((i, it)) => box(width: step - 0.3cm, _txt(it,
        if state(i) == "todo" { text-fill.lighten(40%) } else { text-fill }, size,
        weight: if state(i) == "now" { "bold" } else { auto })))))
}
