// Autoencoder: layers as bars whose height follows their size, narrowing to the latent
// code and widening back.  Import with:  #import "autoencoder.typ": autoencoder
//
//   #autoencoder(((784, [Input]), (64, [Encoder]), (8, [Latent]), (64, [Decoder]), (784, [Output])))
#import "common.typ": _canvas, _card, _items, _lens, _poly, _tallest, _theme, _txt

#let autoencoder(
  layers,
  item-width: 1.4em,
  height: 9em,
  gap: 3.2em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("autoencoder", theme, style)
  let layers = _items("autoencoder", layers, t.palette, fields: ("count", "label"), numbers: ("count",), min: 2)
  for (i, l) in layers.enumerate() {
    if not (type(l.count) == int and l.count > 0) { assert(false, message: "autoencoder: layer " + str(i + 1)
      + " needs a positive number of units, got " + repr(l.count)) }
  }
  let (w, tall, gap, size, em) = _lens("autoencoder", item-width: item-width, height: height, gap: gap,
    text-size: text-size, em: 1em).values()
  // heights follow the square root of the sizes, so a small code stays visible
  let largest = calc.max(..layers.map(l => l.count))
  let heights = layers.map(l => calc.max(1.2 * em, tall * calc.sqrt(l.count / largest)))
  let counts = layers.map(l => _txt([#l.count], t.ink, size * t.small, weight: auto))
  let labels = layers.map(l => if l.label != none { _txt(l.label, t.ink, size * t.small) })
  let slot = w + gap - 0.5 * em
  let (count-h, label-h) = (_tallest(counts, slot), _tallest(labels.filter(l => l != none), slot))
  // the first and last captions may reach past the outer bars
  let reach = calc.max(0pt, ..(labels.first(), labels.last(), counts.first(), counts.last()).filter(b => b != none).map(b =>
    measure(b, width: slot).width / 2 - w / 2))
  let x(i) = reach + i * (w + gap)
  let mid = count-h + 0.4 * em + tall / 2
  _canvas("autoencoder", t, width, area, x(layers.len() - 1) + w + reach,
    mid + tall / 2 + (if label-h > 0pt { 0.5 * em + label-h } else { 0pt }), {
    for i in range(layers.len() - 1) {
      let (a, b) = (heights.at(i) / 2, heights.at(i + 1) / 2)
      _poly((x(i) + w, mid - a), (x(i + 1), mid - b), (x(i + 1), mid + b), (x(i) + w, mid + a), fill: t.panel)
    }
    for (i, l) in layers.enumerate() {
      let h = heights.at(i)
      place(top + left, dx: x(i), dy: mid - h / 2, _card(t, width: w, height: h, fill: l.fill, radius: t.corner-radius))
      let caption(body, dy) = place(top + left, dx: x(i) + w / 2 - slot / 2, dy: dy, box(width: slot, align(center, body)))
      caption(counts.at(i), mid - h / 2 - 0.4 * em - measure(counts.at(i), width: slot).height)
      if labels.at(i) != none { caption(labels.at(i), mid + tall / 2 + 0.5 * em) }
    }
  })
})
