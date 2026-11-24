// Convnet3d: a convolutional network as blocks in perspective, the VGG-style figure: each
// stage is a row of slabs as tall as its feature maps and as thick as its channels.
// Import with:  #import "convnet3d.typ": convnet3d
//
//   #convnet3d(((224, 64, [Conv-1], 2), (112, 128, [Conv-2], 2), (1, 1000, [FC])))
#import "common.typ": _canvas, _items, _lens, _or, _poly, _theme, _txt

// How far a face of height 1 recedes: right and up.
#let _lean = (0.38, 0.48)

#let convnet3d(
  stages,
  input: none,
  legend: ([Convolution], [Pooling], [Fully connected]),
  pool: true,
  item-height: 11em,
  gap: 0.9em,
  fills: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("convnet3d", theme, style)
  let stages = _items("convnet3d", stages, (auto,), fields: ("size", "channels", "label"), optional: ("repeat",),
    cycle: false).map(s => s + (repeat: if s.repeat == none { 1 } else { s.repeat }))
  for (i, s) in stages.enumerate() {
    if not ((s.size, s.channels, s.repeat).all(v => type(v) == int and v > 0)) { assert(false, message: "convnet3d: stage " + str(i + 1)
      + " needs a positive size, number of channels and repeat count, got " + repr((s.size, s.channels, s.repeat))) }
  }
  if not (legend == none or type(legend) == array and legend.len() == 3) { assert(false, message: "convnet3d: `legend` is none or the three "
    + "labels for convolution, pooling and fully connected layers, got " + repr(legend)) }
  let (tall, gap, size, em) = _lens("convnet3d", item-height: item-height, gap: gap, text-size: text-size, em: 1em).values()
  let fills = _or(fills, (t.palette.at(0), t.palette.at(3), t.palette.at(1)))
  if not (type(fills) == array and fills.len() == 3) { assert(false, message: "convnet3d: `fills` is auto or the colours of the "
    + "convolution, pooling and fully connected layers, got " + repr(fills)) }
  let kinds = (conv: fills.at(0), pool: fills.at(1), dense: fills.at(2))
  let largest = calc.max(..stages.map(s => s.size))
  // heights follow the square root of the map size, thickness that of the channels
  // (a vector is a flat bar whatever the other sizes)
  let height(size) = if size == 1 { 0.55 * em } else { calc.max(0.9 * em, tall * calc.sqrt(size / largest)) }
  let caption(body, ink) = _txt(body, ink, size * t.small)
  let shape(s) = _txt(if s.size == 1 { [1 × 1 × #s.channels] } else { [#s.size × #s.size × #s.channels] }, t.line,
    size * t.small * 0.9, weight: auto)
  // every slab: (kind, x of its front face, thickness, height, fill); stages keep the
  // span of their slabs for the captions
  let (slabs, spans, x) = ((), (), 0pt)
  for (i, s) in stages.enumerate() {
    let dense = s.size == 1
    let fill = if s.fill == auto { kinds.at(if dense { "dense" } else { "conv" }) } else { s.fill }
    let label = if s.label != none { caption(s.label, t.ink) }
    let thick = if dense { calc.max(1.4 * em, calc.min(5 * em, em * calc.sqrt(s.channels / 256))) } else {
      calc.max(0.3 * em, calc.min(1.4 * em, 0.5 * em * calc.sqrt(s.channels / 64)))
    }
    let start = x
    for k in range(s.repeat) {
      slabs.push((kind: if dense { "dense" } else { "conv" }, x: x, w: thick, h: height(s.size), fill: fill))
      x += thick + 0.14 * em
    }
    // a stage is at least as wide as its captions, so neighbours never collide
    let wide = calc.max(x - 0.14 * em - start, ..(label, shape(s)).filter(b => b != none).map(b => measure(b).width + 0.3 * em))
    spans.push((x0: start, x1: start + wide, h: height(s.size), label: label, shape: shape(s)))
    x = start + wide + gap
    let next = stages.at(i + 1, default: none)
    if pool and not dense and next != none and next.size < s.size {
      let pooled = if next.size > 1 { next.size } else { calc.max(1, calc.quo(s.size, 2)) }
      slabs.push((kind: "pool", x: x, w: 0.3 * em, h: height(pooled), fill: kinds.pool))
      x += 0.3 * em + (if next.size > 1 { 0.14 * em } else { gap })
    }
  }
  let (lx, ly) = _lean
  let picture = if input != none {
    let m = measure(input)
    let k = height(largest) / m.height
    (w: m.width * k * lx, h: m.height * k + m.width * k * ly, k: k, m: m)
  }
  let x0 = if picture == none { 0pt } else { picture.w + 2 * gap }
  let rise = calc.max(..slabs.map(s => s.h * (0.5 + ly / 2)), if picture == none { 0pt } else { picture.h / 2 })
  // room above the tallest slab for a label that sits higher than it
  let label-h = calc.max(0pt, ..spans.filter(s => s.label != none).map(s =>
    measure(s.label).height + 0.35 * em + s.h * (0.5 + ly / 2) - rise))
  let mid = label-h + rise
  let drop = calc.max(..spans.map(s => s.h * (0.5 + ly / 2) + 0.35 * em + measure(s.shape).height),
    if picture == none { 0pt } else { picture.h / 2 })
  let present = ("conv", "pool", "dense").filter(kind => slabs.any(s => s.kind == kind))
  let key = if legend != none {
    present.map(kind => stack(dir: ltr, spacing: 0.35 * em, box(width: 0.75 * em, height: 0.75 * em, fill: kinds.at(kind),
      radius: 0.12 * em), _txt(legend.at(("conv", "pool", "dense").position(k => k == kind)), t.ink, size * t.small,
      weight: auto)))
  } else { () }
  let key-h = if key.len() > 0 { 0.8 * em + measure(key.first()).height } else { 0pt }
  let key-w = key.map(entry => measure(entry).width).sum(default: 0pt) + 1.2 * em * calc.max(0, key.len() - 1)
  let total = calc.max(key-w, x0 + calc.max(..slabs.map(s => s.x + s.w + s.h * lx), ..spans.map(s => s.x1 + s.h * lx)))
  _canvas("convnet3d", t, width, area, total, mid + drop + key-h, {
    if picture != none {
      // the input stands as the first face: narrowed and sheared like the slabs
      place(top + left, dy: mid - picture.h / 2 + picture.m.width * picture.k * ly, skew(ay: -calc.atan(ly / lx),
        origin: top + left, scale(x: picture.k * lx * 100%, y: picture.k * 100%, origin: top + left, input)))
    }
    for s in slabs {
      let (dx, dy) = (s.h * lx, s.h * ly)
      let (left, top) = (x0 + s.x, mid - s.h / 2 + dy / 2)
      let edge = t.stroke + color.mix((s.fill, 55%), (t.ink, 45%), space: rgb)
      let face(shade, ..pts) = _poly(..pts, fill: color.mix((s.fill, shade), (t.surface, 100% - shade), space: rgb), stroke: edge)
      face(55%, (left + s.w, top), (left + s.w + dx, top - dy), (left + s.w + dx, top + s.h - dy), (left + s.w, top + s.h))
      face(80%, (left, top), (left + dx, top - dy), (left + s.w + dx, top - dy), (left + s.w, top))
      face(100%, (left, top), (left + s.w, top), (left + s.w, top + s.h), (left, top + s.h))
    }
    for s in spans {
      let (dx, dy, w) = (s.h * lx, s.h * ly, s.x1 - s.x0)
      if s.label != none {
        place(top + left, dx: x0 + s.x0 + dx, dy: mid - s.h / 2 - dy / 2 - 0.35 * em - measure(s.label).height,
          box(width: w, align(center, s.label)))
      }
      place(top + left, dx: x0 + s.x0, dy: mid + s.h / 2 + dy / 2 + 0.35 * em, box(width: w, align(center, s.shape)))
    }
    if key.len() > 0 {
      place(bottom + right, stack(dir: ltr, spacing: 1.2 * em, ..key))
    }
  })
})
