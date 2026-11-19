// PRISMA flow diagram: the records of a systematic review going down a column of steps,
// with what each step leaves out branching to the right.
// Import with:  #import "prisma.typ": prisma
//
//   #prisma(
//     (([Records identified (n = 1240)], [Duplicates removed (n = 310)]), [Studies included (n = 42)]),
//     stages: (([Identification], 1), ([Included], 1)),
//   )
#import "common.typ": _arrow, _canvas, _items, _lens, _node, _on, _pair, _theme, _txt

#let prisma(
  steps,
  stages: (),
  item-width: 13em,
  gap: (2.4em, 1.6em),
  inset: 0.6em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("prisma", theme, style)
  let steps = _items("prisma", steps, (t.panel,), fields: ("main",), optional: ("side",))
  let stages = _items("prisma: stages", stages, t.palette, fields: ("label", "count"), numbers: ("count",), min: 0)
  assert(stages.len() == 0 or stages.map(st => st.count).sum() == steps.len(),
    message: "prisma: the stage counts must add up to the " + str(steps.len()) + " steps")
  let (w, inset, size, em) = _lens("prisma", item-width: item-width, inset: inset, text-size: text-size, em: 1em).values()
  let (gx, gy) = _pair("prisma", "gap", gap)
  let label(body) = if body != none { _txt(body, t.ink, size, weight: auto) }
  let rows = steps.map(st => (main: label(st.main), side: label(st.side)))
  let heights = rows.map(r => calc.max(..r.values().filter(b => b != none).map(b => measure(b, width: w - 2 * inset).height))
    + 2 * inset)
  // a stage is at least as tall as its label, set sideways: its steps share what is missing
  let first = 0
  for st in stages {
    let span = heights.slice(first, first + st.count).sum() + (st.count - 1) * gy
    let lack = calc.max(0pt, measure(_txt(st.label, t.ink, size * t.small)).width + em - span)
    for i in range(first, first + st.count) { heights.at(i) += lack / st.count }
    first += st.count
  }
  let tops = range(rows.len()).map(i => heights.slice(0, i).sum(default: 0pt) + i * gy)
  let bar = if stages.len() > 0 { 1.7 * em } else { 0pt }
  let x0 = if stages.len() > 0 { bar + 0.7 * em } else { 0pt }
  let thickness = 1.4 * t.stroke
  let arrow(..pts) = _arrow(..pts, paint: t.line, thickness: thickness, head: thickness * 3 + 0.36 * em)
  let card(x, i, body) = _node(shadow: t.shadow, x, tops.at(i) + heights.at(i) / 2, w, heights.at(i), body, fill: t.panel,
    stroke: t.stroke + t.line, radius: t.corner-radius, inset: inset)
  let sided = rows.any(r => r.side != none)
  _canvas("prisma", t, width, area, x0 + w + (if sided { gx + w } else { 0pt }), tops.last() + heights.last(), {
    let first = 0
    for st in stages {
      let (y0, y1) = (tops.at(first), tops.at(first + st.count - 1) + heights.at(first + st.count - 1))
      _node(shadow: t.shadow, bar / 2, (y0 + y1) / 2, bar, y1 - y0, rotate(-90deg, reflow: true, _txt(st.label, _on(t, st.fill), size * t.small)),
        fill: st.fill, radius: t.corner-radius)
      first += st.count
    }
    for (i, r) in rows.enumerate() {
      let y = tops.at(i) + heights.at(i) / 2
      if i > 0 { arrow((x0 + w / 2, tops.at(i) - gy), (x0 + w / 2, tops.at(i))) }
      card(x0 + w / 2, i, r.main)
      if r.side != none {
        arrow((x0 + w, y), (x0 + w + gx, y))
        card(x0 + w + gx + w / 2, i, r.side)
      }
    }
  })
})
