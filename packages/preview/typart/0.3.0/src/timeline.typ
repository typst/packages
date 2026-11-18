// Timeline: milestones along a horizontal line.  Import with:  #import "timeline.typ": timeline
//
//   #timeline((("2024", [Start]), ("2025", [Pilot]), ("2026", [Launch])))
#import "common.typ": _arrow, _canvas, _dot, _items, _lens, _theme, _txt

#let timeline(
  items,
  step: 7.5em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("timeline", theme, style)
  let items = _items("timeline", items, t.palette, fields: ("date", "label"))
  let (step, size, em) = _lens("timeline", step: step, text-size: text-size, em: 1em).values()
  let n = items.len()
  let axis-h = em
  // date + label hanging off a stem; `up` stacks them above the axis
  let tag(it, up) = {
    let parts = (
      line(angle: 90deg, length: em, stroke: it.fill + 0.12 * em),
      _txt(it.date, t.line, size * t.small),
      box(width: step + 0.7 * em, _txt(it.label, t.ink, size)),
    )
    stack(dir: ttb, spacing: 0.4 * em, ..if up { parts.rev() } else { parts })
  }
  let axis(i) = box(width: step, height: axis-h, {
    let y = axis-h / 2
    // the whole axis is drawn once, from the first cell, so it has no seams
    if i == 0 { _arrow((0pt, y), (step * (n + 0.1), y), paint: t.accent, thickness: t.thick) }
    _dot(step / 2, y, 0.45 * em, fill: items.at(i).fill, stroke: t.surface + 0.12 * em)
  })
  let tags = items.enumerate().map(((i, it)) => tag(it, calc.even(i)))
  // measuring a grid that is also laid out costs a second layout iteration, so the
  // height is added up from the tags on each side of the axis
  let side(parity) = calc.max(0pt, ..tags.enumerate().filter(((i, _)) => calc.rem(i, 2) == parity).map(((_, tag)) =>
    measure(tag).height))
  _canvas("timeline", t, width, area, step * (n + 0.1), side(0) + axis-h + side(1), grid(
    columns: (step,) * n + (step * 0.1,),
    align: (_, y) => if y == 0 { center + bottom } else { center + top },
    ..tags.enumerate().map(((i, tag)) => if calc.even(i) { tag }), [],
    ..range(n).map(axis), [],
    ..tags.enumerate().map(((i, tag)) => if calc.odd(i) { tag }), [],
  ))
})
