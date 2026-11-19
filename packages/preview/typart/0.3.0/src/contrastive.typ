// Contrastive: the branches of a contrastive (Siamese, triplet) model: views of the data
// go through the same stages and meet in a loss.  Import with:  #import "contrastive.typ": contrastive
//
//   #contrastive([Sample], ([Augment], [Encoder], [Projection]))
#import "common.typ": _canvas, _items, _listed, _lens, _link, _node, _on, _pair, _put, _tallest, _theme, _txt

#let contrastive(
  inputs,
  stages,
  loss: [Contrastive loss],
  shared: [Shared weights],
  item-width: 7.5em,
  item-height: 2.6em,
  gap: (2.2em, 2.4em),
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("contrastive", theme, style)
  // one input feeds two branches (two views of a sample); several inputs feed one each
  let inputs = if type(inputs) == content and _listed(inputs) != none { _listed(inputs) } else { inputs }
  let single = type(inputs) != array
  let inputs = _items("contrastive: inputs", if single { (inputs,) } else { inputs }, (t.panel,), cycle: false,
    min: if single { 1 } else { 2 })
  let stages = _items("contrastive", stages, t.palette)
  let (w, h, size, em) = _lens("contrastive", item-width: item-width, item-height: item-height, text-size: text-size,
    em: 1em).values()
  let (gx, gy) = _pair("contrastive", "gap", gap)
  let rows = if single { 2 } else { inputs.len() }
  let label(it) = _txt(it.label, _on(t, it.fill), size)
  let h = calc.max(h, _tallest((..inputs, ..stages).map(label), w - 0.6 * em) + 0.9 * em)
  let (x, y) = (k => w / 2 + k * (w + gx), i => h / 2 + i * (h + gy))
  let m = stages.len()
  let height = rows * (h + gy) - gy
  let goal = if loss != none { _txt(loss, t.ink, size) }
  let goal-w = if goal == none { 0pt } else { calc.min(w, measure(goal).width + 1.2 * em) }
  // with one input the first stage makes the views, so the twins that share weights start after it
  let linked = if shared == none { () } else { range(if single { 1 } else { 0 }, m) }
  let note = if shared != none and linked.len() > 0 { _txt(shared, t.line, size * t.small, weight: auto) }
  _canvas("contrastive", t, width, area, x(m) + w / 2 + (if goal == none { 0pt } else { gx + goal-w }), height, {
    for k in linked {
      place(top + left, line(start: (x(k + 1), y(0) + h / 2), end: (x(k + 1), y(rows - 1) - h / 2),
        stroke: (paint: t.line, thickness: t.stroke, dash: "dashed")))
    }
    if note != none {
      _put(x(linked.first() + 1), (y(0) + y(1)) / 2, box(fill: t.surface, inset: 0.2 * em, note), w: w + gx - 0.4 * em)
    }
    for i in range(rows) {
      if single {
        // the sample fans out: an elbow to each branch
        let turn = x(0) + w / 2 + gx / 2
        _link(t, (x(0) + w / 2, height / 2), (turn, height / 2), (turn, y(i)), (x(1) - w / 2 - 0.15 * em, y(i)))
      } else {
        _link(t, (x(0) + w / 2 + 0.15 * em, y(i)), (x(1) - w / 2 - 0.15 * em, y(i)))
        _node(shadow: t.shadow, x(0), y(i), w, h, label(inputs.at(i)), fill: inputs.at(i).fill, stroke: t.stroke + t.line,
          radius: t.corner-radius, inset: 0.3 * em)
      }
      for (k, st) in stages.enumerate() {
        if k > 0 { _link(t, (x(k) + w / 2 + 0.15 * em, y(i)), (x(k + 1) - w / 2 - 0.15 * em, y(i))) }
        _node(shadow: t.shadow, x(k + 1), y(i), w, h, label(st), fill: st.fill, radius: t.corner-radius, inset: 0.3 * em)
      }
      if goal != none { _link(t, (x(m) + w / 2 + 0.15 * em, y(i)), (x(m) + w / 2 + gx - 0.15 * em, y(i))) }
    }
    if single {
      _node(shadow: t.shadow, x(0), height / 2, w, h, label(inputs.first()), fill: inputs.first().fill, stroke: t.stroke + t.line,
        radius: t.corner-radius, inset: 0.3 * em)
    }
    if goal != none {
      _node(shadow: t.shadow, x(m) + w / 2 + gx + goal-w / 2, height / 2, goal-w, height, goal, fill: t.panel, stroke: t.stroke + t.line,
        radius: t.corner-radius, inset: 0.3 * em)
    }
  })
})
