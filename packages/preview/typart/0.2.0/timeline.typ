// Timeline: milestones along a horizontal line.  Import with:  #import "timeline.typ": timeline
//
//   #timeline((("2024", [Start]), ("2025", [Pilot]), ("2026", [Launch])))
#import "common.typ": _arrow, _col, _dot, _txt, _u

#let timeline(
  items,
  accent: rgb("#73c25a"),
  text-fill: rgb("#1f1f3a"),
  size: 16pt, date-size: 14pt, step: 5,
) = {
  let step = _u(step)
  let n = items.len()
  let axis-h = 0.56cm
  let col = i => _col(items.at(i), i, at: 2)
  // date + label hanging off a stem; `up` stacks them above the axis
  let tag(i, up) = {
    let parts = (
      line(angle: 90deg, length: 0.62cm, stroke: col(i) + 2pt),
      _txt(items.at(i).at(0), accent, date-size),
      box(width: step + 0.4cm, _txt(items.at(i).at(1), text-fill, size)),
    )
    stack(dir: ttb, spacing: 0.22cm, ..if up { parts.rev() } else { parts })
  }
  let axis(i) = box(width: step, height: axis-h, {
    let y = axis-h / 2
    // the whole axis is drawn once, from the first cell, so it has no seams
    if i == 0 { _arrow((0pt, y), (step * (n + 0.1), y), paint: accent, thickness: 4pt) }
    _dot(step / 2, y, 0.28cm, fill: col(i), stroke: white + 2pt)
  })
  grid(
    columns: (step,) * n + (step * 0.1,),
    align: (_, y) => if y == 0 { center + bottom } else { center + top },
    ..range(n).map(i => if calc.even(i) { tag(i, true) }), [],
    ..range(n).map(axis), [],
    ..range(n).map(i => if calc.odd(i) { tag(i, false) }), [],
  )
}
