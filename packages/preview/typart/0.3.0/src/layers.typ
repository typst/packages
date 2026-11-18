// Layers: a layered architecture or protocol stack, one labelled band of blocks per layer.
// Import with:  #import "layers.typ": layers
//
//   #layers((([Application], ([HTTP], [gRPC])), ([Transport], ([TCP], [UDP])), ([Network], ([IP],))))
#import "common.typ": _card, _fluid, _items, _lens, _on, _tallest, _theme, _txt

#let layers(
  items,
  gap: 0.5em,
  inset: 0.6em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("layers", theme, style)
  let items = _items("layers", items, t.palette, fields: ("label", "blocks"))
  for (i, it) in items.enumerate() {
    if not (type(it.blocks) == array and it.blocks.len() > 0) { assert(false, message: "layers: item " + str(i + 1)
      + " needs an array of blocks (a single block takes a trailing comma: ([A],)), got " + repr(it.blocks)) }
  }
  let (gap, inset, size, em) = _lens("layers", gap: gap, inset: inset, text-size: text-size, em: 1em).values()
  let total = _fluid("layers", width, area)
  let band(it) = color.mix((it.fill, 30%), (t.surface, 70%))
  let names = items.map(it => _txt(it.label, _on(t, band(it)), size))
  // one label column for every layer, at most 30% of the width
  let name-w = calc.min(0.3 * total, calc.max(..names.map(name => measure(name).width)))
  let row-w = total - 2 * inset - name-w - gap
  stack(dir: ttb, spacing: gap, ..items.zip(names).map(((it, name)) => {
    let w = (row-w - gap * (it.blocks.len() - 1)) / it.blocks.len()
    let blocks = it.blocks.map(b => _txt(b, _on(t, it.fill), size * t.small, weight: auto))
    // blocks of one layer share the height of the tallest (or of a wrapped layer label)
    let h = calc.max(2 * em, _tallest(blocks, w - 0.8 * em) + 0.9 * em, measure(name, width: name-w).height)
    box(width: total, fill: band(it), radius: t.corner-radius, inset: inset, stack(dir: ltr, spacing: gap,
      box(width: name-w, height: h, align(left + horizon, name)),
      ..blocks.map(b => _card(t, width: w, height: h, fill: it.fill, radius: t.corner-radius, inset: (x: 0.4 * em),
        align(center + horizon, b)))))
  }))
})
