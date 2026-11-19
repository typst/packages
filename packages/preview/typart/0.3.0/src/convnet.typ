// Convnet: a convolutional network as stacks of feature maps that shrink and multiply,
// ending in vectors.  Import with:  #import "convnet.typ": convnet
//
//   #convnet(((32, 1, [Input]), (28, 6, [Conv]), (14, 6, [Pool]), (1, 120, [Dense])))
#import "common.typ": _canvas, _items, _lens, _link, _tallest, _theme, _txt

#let convnet(
  layers,
  item-height: 6em,
  gap: 2.2em,
  max-planes: 5,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("convnet", theme, style)
  let layers = _items("convnet", layers, t.palette, fields: ("size", "channels", "label"))
  for (i, l) in layers.enumerate() {
    if not ((l.size, l.channels).all(v => type(v) == int and v > 0)) { assert(false, message: "convnet: layer " + str(i + 1)
      + " needs a positive map size and number of channels, got " + repr((l.size, l.channels))) }
  }
  let (tall, gap, size, em) = _lens("convnet", item-height: item-height, gap: gap, text-size: text-size, em: 1em).values()
  let (largest, widest) = (calc.max(..layers.map(l => l.size)), calc.max(..layers.map(l => l.channels)))
  let shift = 0.32 * em
  // a layer of maps is a stack of squares, one per channel up to max-planes; a layer of
  // size 1 is a vector: a bar as tall as its channels are many
  let shapes = layers.map(l => if l.size == 1 {
    (planes: 1, w: 0.9 * em, h: calc.max(1.4 * em, tall * calc.sqrt(l.channels / widest)))
  } else {
    let side = calc.max(1.2 * em, tall * calc.sqrt(l.size / largest))
    (planes: calc.min(l.channels, max-planes), w: side, h: side)
  }).map(s => s + (bw: s.w + (s.planes - 1) * shift, bh: s.h + (s.planes - 1) * shift))
  let captions = layers.map(l => stack(spacing: 0.3 * em, ..if l.label != none { (_txt(l.label, t.ink, size * t.small),) },
    _txt(if l.size == 1 { [#l.channels] } else { [#l.channels\@#l.size×#l.size] }, t.line, size * t.small * 0.9, weight: auto)))
  let slots = shapes.map(s => s.bw + gap - 0.4 * em)
  let caption-h = calc.max(..captions.zip(slots).map(((c, slot)) => measure(c, width: slot).height))
  let reach(k) = calc.max(0pt, measure(captions.at(k), width: slots.at(k)).width / 2 - shapes.at(k).bw / 2)
  let xs = shapes.enumerate().map(((i, _)) => reach(0) + shapes.slice(0, i).map(s => s.bw + gap).sum(default: 0pt))
  let body-h = calc.max(..shapes.map(s => s.bh))
  _canvas("convnet", t, width, area, xs.last() + shapes.last().bw + reach(-1), body-h + 0.6 * em + caption-h, {
    for (i, (l, s)) in layers.zip(shapes).enumerate() {
      let y = (body-h - s.bh) / 2
      // back to front, each plane a step right and down
      for k in range(s.planes) {
        place(top + left, dx: xs.at(i) + k * shift, dy: y + k * shift, box(width: s.w, height: s.h, fill: l.fill,
          stroke: 0.09 * em + t.surface, radius: 0.12 * em))
      }
      if i > 0 { _link(t, (xs.at(i) - gap + 0.35 * em, body-h / 2), (xs.at(i) - 0.35 * em, body-h / 2)) }
      place(top + left, dx: xs.at(i) + s.bw / 2 - slots.at(i) / 2, dy: body-h + 0.6 * em,
        box(width: slots.at(i), align(center, captions.at(i))))
    }
  })
})
