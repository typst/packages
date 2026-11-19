// RNN: a recurrent network unrolled in time: at each step an input feeds a hidden state,
// which emits an output and passes on to the next step.  Import with:  #import "rnn.typ": rnn
//
//   #rnn((($x_1$, $h_1$, $y_1$), ($x_2$, $h_2$, $y_2$)), weights: ($U$, $V$, $W$))
#import "common.typ": _arrow, _canvas, _dot, _fit, _in-circle, _items, _lens, _link, _node, _on, _or, _pair, _put, _theme, _txt

#let rnn(
  steps,
  cell: [RNN],
  weights: none,
  folded: none,
  unfold: [Unfold],
  ellipsis: true,
  item-width: 4.4em,
  item-height: 2.4em,
  node-radius: 1.3em,
  gap: (2.6em, 1.7em),
  state-fill: auto,
  input-fill: auto,
  output-fill: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("rnn", theme, style)
  let steps = _items("rnn", steps, (_or(state-fill, t.palette.first()),), fields: ("input",), optional: ("state", "output"), cycle: false)
  if not (weights == none or type(weights) == array and weights.len() == 3) { assert(false, message: "rnn: `weights` is none or the three "
    + "labels of the input, recurrent and output arrows, got " + repr(weights)) }
  if not (folded == none or type(folded) == array and folded.len() in (2, 3)) { assert(false, message: "rnn: `folded` is none or the "
    + "(input, state, output) of the folded network, got " + repr(folded)) }
  let (w, h, r, size, em) = _lens("rnn", item-width: item-width, item-height: item-height, node-radius: node-radius,
    text-size: text-size, em: 1em).values()
  let (gx, gy) = _pair("rnn", "gap", gap)
  // the folded network is one more column in front, drawn the same way
  let columns = (..if folded != none { ((input: folded.at(0), state: folded.at(1), output: folded.at(2, default: none),
    fill: _or(state-fill, t.palette.first())),) }, ..steps)
  let outputs = columns.any(c => c.output != none)
  let (in-fill, out-fill) = (_or(input-fill, t.palette.at(1)), _or(output-fill, t.palette.at(4)))
  let s = _fit(columns.map(c => (c.input, c.output)).flatten().filter(b => b != none), t.ink, size, 2 * r - 0.3 * em,
    _in-circle(r - 0.15 * em))
  let (y-out, y-state) = (r, (if outputs { 2 * r + gy } else { 0pt }) + h / 2)
  let y-in = y-state + h / 2 + gy + r
  let tag(body) = _txt(body, t.ink, size * t.small, weight: auto)
  let (u, v, o) = if weights == none { (none, none, none) } else { weights.map(tag) }
  let lead = if ellipsis { 2.2 * em } else { gx }
  // the folded column, its loop and the unfold arrow take their room before the steps
  let loop = 1.3 * em
  let turn = if folded == none { 0pt } else {
    loop + (if v != none { measure(v).width + 0.3 * em } else { 0pt }) + w + 1.2 * em + calc.max(4 * em,
      measure(tag(unfold)).width + 1.6 * em) + 0.6 * em
  }
  let x0 = if folded == none { 0pt } else { loop + (if v != none { measure(v).width + 0.3 * em } else { 0pt }) + w / 2 }
  let x(i) = if folded != none and i == 0 { x0 } else {
    turn + lead + w / 2 + (i - (if folded == none { 0 } else { 1 })) * (w + gx)
  }
  let n = columns.len()
  let beside(body, x, y) = if body != none {
    place(top + left, dx: x + 0.3 * em, dy: y - measure(body).height / 2, body)
  }
  let above(body, x, y) = if body != none { _put(x, y - 0.35 * em - measure(body).height / 2, body) }
  _canvas("rnn", t, width, area, x(n - 1) + w / 2 + lead + 0.1 * em, y-in + r, {
    for (i, c) in columns.enumerate() {
      let (cx, state) = (x(i), _txt(if c.state == none { cell } else { c.state }, _on(t, c.fill), size))
      _link(t, (cx, y-in - r - 0.15 * em), (cx, y-state + h / 2 + 0.15 * em))
      beside(u, cx, (y-in - r + y-state + h / 2) / 2)
      _dot(cx, y-in, r, fill: in-fill, shadow: t.shadow)
      _put(cx, y-in, _txt(c.input, _on(t, in-fill), s), w: 2 * r)
      if c.output != none {
        _link(t, (cx, y-state - h / 2 - 0.15 * em), (cx, y-out + r + 0.15 * em))
        beside(o, cx, (y-state - h / 2 + y-out + r) / 2)
        _dot(cx, y-out, r, fill: out-fill, shadow: t.shadow)
        _put(cx, y-out, _txt(c.output, _on(t, out-fill), s), w: 2 * r)
      }
      _node(shadow: t.shadow, cx, y-state, w, h, state, fill: c.fill, radius: t.corner-radius, inset: 0.3 * em)
    }
    let first = if folded == none { 0 } else { 1 }
    if folded != none {
      // the state of the folded network feeds itself, then the thick arrow unfolds it
      let (a, b) = (x0 - w / 2, x0 - w / 2 - loop)
      _link(t, (a, y-state - h / 4), (b, y-state - h / 4), (b, y-state + h / 4), (a - 0.1 * em, y-state + h / 4))
      if v != none { place(top + left, dx: b - 0.3 * em - measure(v).width, dy: y-state - measure(v).height / 2, v) }
      let (from, to) = (x0 + w / 2 + 0.9 * em, turn - 0.3 * em)
      _arrow((from, y-state), (to, y-state), paint: t.ink, thickness: t.thick * 1.3)
      above(tag(unfold), (from + to) / 2, y-state - t.thick)
    }
    // the state passes from step to step; dots mark that the sequence goes on
    for i in range(first, n + 1) {
      let (a, b) = (if i == first { x(first) - w / 2 - lead } else { x(i - 1) + w / 2 }, if i == n { x(n - 1) + w / 2 + lead } else {
        x(i) - w / 2
      })
      let dots = if ellipsis and i in (first, n) { 0.9 * em } else { 0pt }
      let (a, b) = if i == first { (a + dots, b) } else if i == n { (a, b - dots) } else { (a, b) }
      if dots > 0pt {
        let at = if i == first { a - dots } else { b + 0.25 * em }
        for k in range(3) { _dot(at + 0.1 * em + k * 0.27 * em, y-state, 0.07 * em, fill: t.line) }
      }
      if i == n and dots > 0pt {
        place(top + left, line(start: (a + 0.15 * em, y-state), end: (b, y-state), stroke: 1.4 * t.stroke + t.line))
      } else { _link(t, (a + 0.15 * em, y-state), (b - 0.15 * em, y-state)) }
      above(v, (a + b) / 2, y-state)
    }
  })
})
