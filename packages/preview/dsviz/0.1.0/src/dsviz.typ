// dsviz: draw data-structure diagrams from a compact text DSL.
// The layout engine is a Rust/WASM plugin; all text is typeset by Typst.

#let _plugin = plugin("dsviz.wasm")

// Extract the DSL source from a string, a raw element, or content holding exactly one raw.
#let _source(body) = {
  if type(body) == str { return body }
  if body.func() == raw { return body.text }
  if body.has("children") {
    let raws = body.children.filter(c => c.func() == raw)
    if raws.len() == 1 { return raws.first().text }
  }
  if body.has("body") { return _source(body.body) }
  panic("dsviz: put the DSL in a raw block (```...```) or pass a string")
}

// Render at the given text size; returns (content, width).
#let _draw(src, sz, stroke, spacing, font) = {
  let txt = if font == auto {
    text.with(size: sz, top-edge: "cap-height", bottom-edge: "baseline")
  } else {
    text.with(font: font, size: sz, top-edge: "cap-height", bottom-edge: "baseline")
  }

  // Pass 1: collect every label and measure it with the real font.
  let segs = str(_plugin.labels(bytes(src))).split("\n").filter(s => s != "")
  let cfg = ("size=" + str(sz / 1pt), "spacing=" + str(spacing))
  if stroke != auto { cfg.push("stroke=" + str(stroke / 1pt)) }
  for s in segs {
    cfg.push(str(measure(txt(s)).width / 1pt) + "\t" + s)
  }

  // Pass 2: the plugin returns the shapes as SVG plus label positions.
  let (head, svg) = str(_plugin.render(bytes(src), bytes(cfg.join("\n")))).split("\u{1}")
  let lines = head.split("\n").filter(l => l != "")
  let (w, h) = lines.first().split(" ").map(float)
  let body = box(width: w * 1pt, height: h * 1pt, {
    place(image(bytes(svg), format: "svg", width: w * 1pt))
    for l in lines.slice(1) {
      let (x, y, anchor, scale, color, base, sub) = l.split("\t")
      let size = sz * float(scale)
      let t = txt(size: size, fill: rgb(color), base)
      if sub != "" {
        t += txt(size: size * 0.7, baseline: size * 0.22, fill: rgb(color), sub)
      }
      let m = measure(t)
      let k = (start: 0, middle: 0.5, end: 1).at(anchor)
      place(dx: float(x) * 1pt - k * m.width, dy: float(y) * 1pt - m.height / 2, t)
    }
  })
  (body, w * 1pt)
}

/// Render a data-structure diagram from the dsviz DSL.
///
/// Can be used directly, `#ds[```...```]`, or as a show rule:
/// `#show raw.where(lang: "ds"): ds`.
///
/// - width (auto, length, relative): Scale the whole diagram (text and strokes
///   included) to this width. `auto` keeps the natural size.
/// - font (auto, str, array): Font for labels. `auto` uses the current text font.
/// - size (auto, length): Label size. `auto` uses the current text size; at the
///   natural size, labels in the diagram have exactly this size.
/// - spacing (float): Node spacing factor; does not affect the text size.
/// - stroke (auto, length): Line width. `auto` is 8% of the text size.
/// - body (str, content): The DSL source, as a string or a raw block.
/// -> content
#let ds(
  width: auto,
  font: auto,
  size: auto,
  spacing: 1.0,
  stroke: auto,
  body,
) = context {
  let src = _source(body)
  let sz = if size == auto { text.size } else { size }.to-absolute()
  let st = if stroke == auto { auto } else { stroke.to-absolute() }
  let (img, w) = _draw(src, sz, st, spacing, font)
  // Redraw with proportionally larger text and strokes instead of scaling an image.
  let redraw(target) = {
    let r = target / w
    _draw(src, sz * r, if st == auto { auto } else { st * r }, spacing, font).first()
  }
  if width == auto {
    img
  } else if type(width) == length {
    redraw(width.to-absolute())
  } else {
    layout(region => {
      let target = if type(width) == ratio { width * region.width } else if type(width) == relative {
        width.ratio * region.width + width.length.to-absolute()
      } else { width.to-absolute() }
      redraw(target)
    })
  }
}
