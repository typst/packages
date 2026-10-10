// A single node: its fill, ink and box, its hand-drawn outline, and how it
// is measured.

#import "@preview/cetz:0.5.2"
#import "util.typ": _pt, _luma
#import "input.typ": branch
#import "hand.typ": _rounded-rect, _ellipse-pts, _hand-line, _seed

// Fill of a box after the theme field `fill`. Tinted fills are lightened
// by `tint` and then further until they are at least `tint-min` light:
// otherwise an almost black ink only yields a medium grey on which text
// reads poorly.
#let _fill(mode, color, opts) = {
  if mode == "solid" { color }
  else if mode == "white" { white }
  else if mode == "tint" {
    let f = color.lighten(opts.tint)
    let n = 0
    while _luma(f) < opts.tint-min and n < 4 { f = f.lighten(30%); n += 1 }
    f
  } else { none }
}

// Text colour for a fill: `ink` applies when set; with `auto` the luminance
// of the fill decides whether dark or light text reads better. Without a
// fill it is the dark one.
#let _ink(fill, opts) = {
  if opts.ink != auto { opts.ink }
  else if fill == none { opts.ink-dark }
  else if _luma(fill) < opts.ink-threshold { opts.ink-light }
  else { opts.ink-dark }
}

// The words of a label, provided it consists of text only; otherwise
// `none`. Needed to know the width of the longest word: a box must not
// shrink below it, or the word sticks out.
#let _words(c) = {
  if type(c) == str { return c.split() }
  if type(c) != content { return none }
  if c.func() == text { return c.text.split() }
  if c.func() == [ ].func() { return () }
  if c.func() == [].func() {
    let out = ()
    for p in c.children {
      let w = _words(p)
      if w == none { return none }
      out += w
    }
    return out
  }
  if c.has("body") { return _words(c.body) }
  none
}

// Everything the theme and the node decide about a box: fill, border,
// radius, shape, fixed size, text colour and weight. Shared by the box
// itself and by the hand-drawn outline, so both agree.
#let _spec(depth, th) = if depth == 0 { th + th.root } else if depth == 1 { th + th.branches } else { th }

#let _paint(node, depth, color, opts) = {
  let th = opts.theme
  let root = depth == 0
  let spec = _spec(depth, th)
  let color = if root { opts.root-fill } else { color }
  let fill = if node.fill == auto { _fill(spec.fill, color, opts) } else { node.fill }
  let stroke = if spec.underline and not root { none }
    else if spec.stroke == 0pt { none } else { spec.stroke + color }
  // A ring: no fill asks for a visible border.
  if node.fill == none and stroke == none { stroke = calc.max(spec.stroke, 0.08em) + color }
  if node.mark { stroke = 0.15em + color.darken(35%) }
  let ink = if node.ink != auto { node.ink } else { _ink(fill, opts) }
  let weight = if depth < opts.bold-depth or node.mark { "bold" } else { "regular" }
  let size = if spec.size == none { none } else { spec.size.at(calc.min(depth, spec.size.len() - 1)) }
  (
    fill: fill, stroke: stroke, ink: ink, weight: weight,
    shape: spec.shape, size: size,
    radius: if spec.underline and not root { 0pt } else { spec.radius },
  )
}

// Is this node a gap to fill in? Its own `blank`, or the map-wide rule.
#let _is-gap(node, depth, opts) = {
  (node.blank
    or (opts.blanks == "all" and depth > 0)
    or (opts.blanks == "leaves" and depth > 0 and node.kids.len() == 0)
    or (opts.blanks == "branches" and depth == 1))
}

#let _nodebox(node, depth, color, opts, width: auto, height: auto) = {
  let th = opts.theme
  let p = _paint(node, depth, color, opts)
  let scale = opts.scale.at(calc.min(depth, opts.scale.len() - 1))
  // Hand-drawn: the box itself stays invisible, `_hand-shape` draws its
  // outline as a wobbly path underneath. Size and padding stay the same so
  // the layout holds.
  let drawn = th.hand == none
  let blank = _is-gap(node, depth, opts)
  let ink = if blank and opts.solution and opts.solution-ink != auto { opts.solution-ink } else { p.ink }
  let label = text(weight: p.weight, size: 1em * scale, fill: ink, node.label)
  let label = if th.font != none { text(font: th.font, label) } else { label }
  // A gap keeps its size: `hide` measures like the text it hides.
  let label = if blank and not opts.solution { hide(label) } else { label }
  let body = if node.icon == none { label }
    else if node.icon-at == "top" { align(center, stack(dir: ttb, spacing: 0.3em, node.icon, label)) }
    else { box(node.icon) + h(0.35em) + label }
  let fill = if drawn { p.fill } else { none }
  let stroke = if drawn { p.stroke } else { none }
  if p.shape == "rect" {
    // A box with a set size centres its text; a natural one lays it out
    // from the top left, which is the same thing for a single line.
    let body = if width == auto and height == auto { body } else { align(center + horizon, body) }
    box(width: width, height: height, fill: fill, stroke: stroke, radius: p.radius, inset: opts.inset, body)
  } else if height != auto {
    // Equal sizes among shaped siblings: the shape takes the size as given.
    let inner = align(center + horizon, box(width: width, align(center, body)))
    if p.shape == "circle" { circle(radius: calc.max(width, height) / 2, fill: fill, stroke: stroke, inset: 0pt, inner) }
    else { ellipse(width: width, height: height, fill: fill, stroke: stroke, inset: 0pt, inner) }
  } else if p.size != none {
    // Fixed diameter: the text wraps inside and is centred. If it does not
    // fit, the font shrinks step by step to 60%; if that is still not
    // enough, the shape grows rather than letting the text spill out.
    let d = p.size
    let words = _words(node.label)
    context {
      let d = d.to-absolute()
      let inner-w = if p.shape == "circle" { d * 0.72 } else { d * 0.8 }
      let inner-h = if p.shape == "circle" { d * 0.72 } else { d * 0.62 * 0.8 }
      let s = 1.0
      let fits(s) = {
        let m = measure(box(width: inner-w, align(center, text(size: s * 1em, body))))
        let widest = if words == none { 0pt } else {
          words.map(w => measure(text(weight: p.weight, size: s * 1em * scale, w)).width).fold(0pt, calc.max)
        }
        m.height <= inner-h and widest <= inner-w
      }
      while s > 0.6 and not fits(s) { s -= 0.1 }
      let m = measure(box(width: inner-w, align(center, text(size: s * 1em, body))))
      let grow = calc.max(1.0, m.height / inner-h)
      let inner = box(width: inner-w, align(center, text(size: s * 1em, body)))
      if p.shape == "circle" { circle(radius: d * grow / 2, fill: fill, stroke: stroke, inset: 0pt, align(center + horizon, inner)) }
      else { ellipse(width: d * grow, height: d * 0.62 * grow, fill: fill, stroke: stroke, inset: 0pt, align(center + horizon, inner)) }
    }
  } else {
    let inner = align(center + horizon, box(width: width, align(center, body)))
    if p.shape == "circle" { circle(fill: fill, stroke: stroke, inset: opts.inset, inner) }
    else { ellipse(fill: fill, stroke: stroke, inset: opts.inset, inner) }
  }
}

// CeTZ measures `content` with its own text edges (cap-height, baseline)
// and therefore places the box a few points too high. A block with the
// fixed size measured here takes that decision away from CeTZ: it is
// centred exactly where the edges and the hand-drawn shape expect it.
#let _framed(t, body) = block(width: t.w, height: t.h, body)

#let _hand-shape(cx, cy, t, depth, color, opts) = {
  let paint = _paint(t.node, depth, color, opts)
  let (w, h) = (_pt(t.w), _pt(t.h))
  let r = if type(paint.radius) == ratio { calc.min(w, h) * paint.radius / 100% } else { _pt(paint.radius) }
  let pts = if paint.shape == "rect" { _rounded-rect(_pt(cx), _pt(cy), w, h, r) }
    else { _ellipse-pts(_pt(cx), _pt(cy), w / 2, h / 2) }
  let st = if paint.stroke == none { none } else { paint.stroke }
  if st == none and paint.fill == none { return }
  _hand-line(pts, st, opts.theme.hand, _seed(_pt(cx), _pt(cy), w, h), closed: true, fill: paint.fill)
}

// Measures a node. If the label is wider than `max-width` it wraps; a
// bisection then finds the smallest width at which the wrapping does not
// grow further, so the box is no wider than its longest line. The lower
// bound is the longest word; if it cannot be determined the box stays at
// `max-width`. If even the longest word is wider than `max-width`, the
// natural width stays: a cut-off word would be worse than a wide box.
// Must be called inside `context`.
#let _measure-node(node, depth, color, opts) = {
  let th = opts.theme
  let spec = _spec(depth, th)
  let natural = measure(_nodebox(node, depth, color, opts))
  let words = _words(node.label)
  let floor = if words == none { none } else {
    words.map(w => measure(_nodebox(branch(w), depth, color, opts)).width).fold(0pt, calc.max)
  }
  // Circles and ellipses grow with the diagonal of the text, so a long
  // single line makes a huge disc. Try a few narrower wraps and keep the
  // one that gives the smallest shape.
  if spec.shape != "rect" and spec.size == none and floor != none {
    let best = (w: natural.width, h: natural.height, width: auto)
    for f in (0.8, 0.65, 0.5, 0.4, 0.3) {
      let cand = natural.width * f
      if cand < floor { break }
      let m = measure(_nodebox(node, depth, color, opts, width: cand))
      if m.width < best.w { best = (w: m.width, h: m.height, width: cand) }
    }
    return best
  }
  if opts.max-width == none or natural.width <= opts.max-width {
    return (w: natural.width, h: natural.height, width: auto)
  }
  let floor = if floor == none { opts.max-width } else { floor }
  if floor > opts.max-width {
    return (w: natural.width, h: natural.height, width: auto)
  }
  let wrapped = measure(_nodebox(node, depth, color, opts, width: opts.max-width))
  let lo = floor
  let hi = opts.max-width
  for _ in range(7) {
    let mid = (lo + hi) / 2
    let m = measure(_nodebox(node, depth, color, opts, width: mid))
    if m.height <= wrapped.height { hi = mid } else { lo = mid }
  }
  // Measure the box once more at the chosen width: for a shaped node the
  // outer size is not the inner width.
  let m = measure(_nodebox(node, depth, color, opts, width: hi))
  (w: m.width, h: m.height, width: hi)
}
