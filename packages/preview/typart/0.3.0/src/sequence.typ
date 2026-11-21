// Sequence diagram: participants exchanging messages in time order (protocols, handshakes).
// Import with:  #import "sequence.typ": sequence
//
//   #sequence((("c", [Client]), ("s", [Server])), (("c", "s", [Request]), ("s", "c", [Response], "reply")))
#import "common.typ": _arrow, _canvas, _items, _lens, _node, _on, _pair, _put, _tallest, _theme, _txt

#let sequence(
  participants,
  messages,
  item-width: 6em,
  gap: (3em, 1.8em),
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("sequence", theme, style)
  let actors = _items("sequence: participants", participants, t.palette, fields: ("name", "label"))
  let messages = _items("sequence: messages", messages, t.palette, fields: ("from", "to", "label"),
    optional: ("kind",))
  let (w, size, em) = _lens("sequence", item-width: item-width, text-size: text-size, em: 1em).values()
  let (gx, gy) = _pair("sequence", "gap", gap)
  let column = (:)
  for (i, a) in actors.enumerate() {
    if not (type(a.name) == str) { assert(false, message: "sequence: a participant's name is a string, got " + repr(a.name)) }
    column.insert(a.name, i)
  }
  for m in messages {
    for name in (m.from, m.to) {
      if not (type(name) == str and name in column) { assert(false, message: "sequence: no participant named " + repr(name)) }
    }
    if not (m.kind in (none, "call", "reply")) { assert(false, message: "sequence: a message's kind is \"call\" or \"reply\", got "
      + repr(m.kind)) }
  }
  let x(i) = w / 2 + i * (w + gx)
  let heads = actors.map(a => _txt(a.label, _on(t, a.fill), size))
  let head-h = calc.max(2.2 * em, _tallest(heads, w - 0.8 * em) + 0.9 * em)
  // a self-call is a loop to the right of its lifeline with the label beside it
  let (loop-w, loop-h) = (1.6 * em, 1 * em)
  let rows = messages.map(m => {
    let (a, b) = (x(column.at(m.from)), x(column.at(m.to)))
    let label = _txt(m.label, t.ink, size * t.small, weight: auto)
    let slot = if a == b { 8 * em } else { calc.abs(b - a) - em }
    (a: a, b: b, label: label, slot: slot, dash: if m.kind == "reply" { "dashed" }, ..measure(label, width: slot))
  })
  // each arrow sits below its label, at least the row gap under the previous arrow
  let (ys, y) = ((), head-h + 0.3 * em)
  for r in rows {
    y += if r.a == r.b { calc.max(gy, loop-h + 0.7 * em, r.height + 0.5 * em) } else { calc.max(gy, r.height + 0.9 * em) }
    ys.push(y)
  }
  let n = actors.len()
  let total = calc.max(n * (w + gx) - gx, ..rows.filter(r => r.a == r.b).map(r => r.a + loop-w + 0.4 * em + r.width))
  let height = y + 0.9 * em
  let weight = t.stroke * 1.4
  _canvas("sequence", t, width, area, total, height, {
    for i in range(n) {
      place(top + left, line(start: (x(i), head-h), end: (x(i), height),
        stroke: (paint: t.muted, thickness: t.stroke, dash: "dashed")))
    }
    for (r, y) in rows.zip(ys) {
      let pts = if r.a == r.b { ((r.a, y - loop-h), (r.a + loop-w, y - loop-h), (r.a + loop-w, y), (r.a, y)) } else {
        ((r.a, y), (r.b, y))
      }
      _arrow(..pts, paint: t.line, thickness: weight, head: weight * 3 + 4 * t.stroke, dash: r.dash)
      if r.a == r.b {
        place(top + left, dx: r.a + loop-w + 0.4 * em, dy: y - loop-h / 2 - r.height / 2, box(width: r.slot, r.label))
      } else {
        // the backing hides the lifelines a long message crosses
        _put((r.a + r.b) / 2, y - 0.35 * em - r.height / 2, box(fill: t.surface, outset: (x: 0.25 * em), r.label),
          w: r.slot)
      }
    }
    for (i, a) in actors.enumerate() {
      _node(shadow: t.shadow, x(i), head-h / 2, w, head-h, heads.at(i), fill: a.fill, radius: t.corner-radius, inset: 0.4 * em)
    }
  })
})
