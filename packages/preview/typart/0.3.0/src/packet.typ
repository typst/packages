// Packet: the layout of a header, frame or register as fields of bits, wrapped in rows.
// Import with:  #import "packet.typ": packet
//
//   #packet((([Type], 8), ([Length], 8), ([Checksum], 16), ([Payload], 32)))
#import "common.typ": _fit, _fluid, _items, _lens, _on, _put, _theme, _txt

#let packet(
  fields,
  bits: 32,
  item-height: 2.4em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("packet", theme, style)
  let fields = _items("packet", fields, (t.panel,), fields: ("label", "bits"), numbers: ("bits",), cycle: false)
  for (i, f) in fields.enumerate() {
    if not (type(f.bits) == int and f.bits > 0) { assert(false, message: "packet: field " + str(i + 1) + " needs a positive number of bits, got "
      + repr(f.bits)) }
  }
  if not (type(bits) == int and bits > 0) { assert(false, message: "packet: `bits` (per row) must be a positive integer, got " + repr(bits)) }
  let (h, size, em) = _lens("packet", item-height: item-height, text-size: text-size, em: 1em).values()
  let total = _fluid("packet", width, area)
  let bit = total / bits
  // a field is drawn as one labelled box per row it touches; whole rows merge into one tall box
  let (boxes, at) = ((), 0)
  for f in fields {
    let (start, end) = (at, at + f.bits)
    let parts = if calc.rem(start, bits) == 0 and calc.rem(f.bits, bits) == 0 {
      ((calc.quo(start, bits), 0, bits, calc.quo(f.bits, bits)),)
    } else {
      range(calc.quo(start, bits), calc.quo(end - 1, bits) + 1).map(row => {
        let (a, b) = (calc.max(start, row * bits), calc.min(end, (row + 1) * bits))
        (row, a - row * bits, b - a, 1)
      })
    }
    boxes += parts.map(p => (f: f, row: p.at(0), col: p.at(1), span: p.at(2), rows: p.at(3)))
    at = end
  }
  let ruler = range(0, bits, step: 8).map(b => (b, left)) + ((bits - 1, right),)
  let ruler-h = measure(_txt([0], t.ink, size * t.small, weight: auto)).height + 0.35 * em
  box(width: total, height: ruler-h + calc.ceil(at / bits) * h, {
    for (b, side) in ruler {
      let x = if side == left { b * bit } else { (b + 1) * bit }
      place(top + left, dx: if side == left { x } else { x - 3 * em }, box(width: 3 * em, align(side,
        _txt([#b], t.line, size * t.small, weight: auto))))
    }
    for b in boxes {
      let (w, bh) = (b.span * bit, b.rows * h)
      place(top + left, dx: b.col * bit, dy: ruler-h + b.row * h, box(width: w, height: bh, fill: b.f.fill,
        stroke: t.stroke + t.line))
      // each label takes the size that fits its own box: fields differ too much to share one
      let s = _fit((b.f.label,), t.ink, size, w - 0.4 * em, bh - 0.4 * em)
      _put(b.col * bit + w / 2, ruler-h + b.row * h + bh / 2, _txt(b.f.label, _on(t, b.f.fill), s, weight: auto), w: w - 0.4 * em)
    }
  })
})
