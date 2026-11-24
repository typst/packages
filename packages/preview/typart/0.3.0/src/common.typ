// Shared layer: theme, item validation, sizing and native drawing helpers.
// Coordinates are absolute lengths with y pointing down.  Everything below a widget's
// signature works in absolute lengths: `_lens` resolves the em of its parameters once.

// Categorical fills, each at least 0.1 apart in relative luminance (they stay distinct in
// greyscale) and light enough for dark text at 4.5:1.
#let palette = (
  rgb("#9aa5f5"),   // lavender
  rgb("#a7dd9b"),   // green
  rgb("#ffe07a"),   // amber
  rgb("#ea6470"),   // red
  rgb("#74c7ec"),   // sky
)

// Every look decision shared by the widgets.  `auto` values follow the document.
#let default-theme = (
  palette: palette,
  ink: auto,              // text and dark shapes; auto: the document's text colour
  surface: auto,          // what lies behind the diagram; auto: the page fill, else white
  accent: rgb("#73c25a"), // arrows, connectors and highlights
  line: auto,             // outlines and flowchart edges; auto: ink softened towards surface
  panel: auto,            // neutral boxes; auto: surface tinted with ink
  muted: auto,            // tracks and inactive parts; auto: between panel and line
  stroke: 0.08em,         // outline thickness
  thick: 0.2em,           // connector and ring thickness
  corner-radius: 0.35em,
  small: 80%,             // secondary text, relative to a widget's text-size
  large: 150%,            // headline values
  min-scale: 70%,         // a drawing wider than its container fails instead of shrinking below this
  shadow: true,           // a soft shadow under boxes and circles; false draws them flat
)

#let _document-theme = state("typart-theme", (:))
/// Sets theme keys for every diagram that follows, like a set rule:
/// `#typart-theme(accent: gray, corner-radius: 0pt)`.  It adds a short second layout
/// pass; `themed` gives the same result without it.
///
/// - overrides (arguments): Keys of `default-theme` with their new values.
#let typart-theme(..overrides) = {
  assert(overrides.pos().len() == 0, message: "typart-theme: takes named theme keys, e.g. typart-theme(accent: gray)")
  _document-theme.update(current => current + overrides.named())
}

// The theme the widget `who` draws with: defaults, then the document's `typart-theme`, then
// the widget's `theme` dictionary, then the theme keys passed to it directly (`style`,
// the arguments left over after its own parameters), with every auto resolved and every
// length absolute.  Needs context.
#let _theme(who, theme, style) = {
  if not (style.pos().len() == 0) { assert(false, message: who + ": unexpected argument " + repr(style.pos().at(0, default: none))) }
  for key in style.named().keys() {
    if not (key in default-theme) { assert(false, message: who + ": unexpected argument `" + key + "`; besides its own parameters it "
      + "takes the theme keys " + default-theme.keys().join(", ")) }
  }
  let overrides = _document-theme.get() + theme + style.named()
  for key in overrides.keys() {
    if not (key in default-theme) { assert(false, message: "typart: unknown theme key `" + key + "`; expected one of "
      + default-theme.keys().join(", ")) }
  }
  let t = default-theme + overrides
  let ink = if t.ink != auto { t.ink } else if type(text.fill) == color { text.fill } else { black }
  let surface = if t.surface != auto { t.surface } else if type(page.fill) == color { page.fill } else { white }
  let tint(key, share) = if t.at(key) == auto { color.mix((ink, share), (surface, 100% - share), space: rgb) } else {
    t.at(key)
  }
  t + (ink: ink, surface: surface, line: tint("line", 70%), panel: tint("panel", 8%), muted: tint("muted", 22%),
    stroke: t.stroke.to-absolute(), thick: t.thick.to-absolute(), corner-radius: t.corner-radius.to-absolute(),
    // none, or how far the shadow falls and its paint: a shadow is the absence of light, so
    // it is black whatever the theme, and faint
    shadow: if t.shadow == true { (dx: (0.07em).to-absolute(), dy: (0.13em).to-absolute(), paint: black.transparentize(84%)) })
}

// A parameter's value, or `default` when it was left at auto.
#let _or(value, default) = if value == auto { default } else { value }

// WCAG relative luminance and contrast ratio.
#let _luminance(c) = {
  let (r, g, b) = color.linear-rgb(c).components(alpha: false).map(v => v / 100%)
  0.2126 * r + 0.7152 * g + 0.0722 * b
}
#let _contrast(a, b) = {
  let (lo, hi) = (_luminance(a), _luminance(b)).sorted()
  (hi + 0.05) / (lo + 0.05)
}
// The text colour that reads best on `fill`: ink or surface.
#let _on(t, fill) = if _contrast(t.ink, fill) >= _contrast(t.surface, fill) { t.ink } else { t.surface }

/// Colours the item of a list it is written in: `- Face #fill(red)`.  Arrays and
/// dictionaries take the colour as their last value or their `color` key instead.
///
/// - color (color): The fill of that item.
#let fill(color) = metadata((typart-fill: color))

// The label of a list item and the colour of its `fill(..)` mark, or none.
#let _marked(body) = {
  let parts = if body.has("children") { body.children } else { (body,) }
  let marks = parts.filter(part => part.func() == metadata and type(part.value) == dictionary and "typart-fill" in part.value)
  if marks.len() == 0 { return (body, none) }
  // without the mark and the space written before it
  let rest = parts.filter(part => part not in marks)
  while rest.len() > 0 and rest.last() == [ ] { let _ = rest.pop() }
  (if rest.len() == 1 { rest.first() } else { rest.join() }, marks.last().value.typart-fill)
}

// The items of a list written as content: a bullet list gives its items, a term list
// (`/ term: description`) gives (term, description) pairs, each followed by the colour of
// its `fill(..)` mark if it has one; none when `body` holds neither kind of list.
#let _listed(body) = {
  let parts = if body.has("children") { body.children } else { (body,) }
  let found = parts.filter(part => part.func() in (list.item, terms.item))
  if found.len() > 0 {
    found.map(it => {
      let (label, color) = _marked(if it.func() == list.item { it.body } else { it.description })
      let values = if it.func() == list.item { (label,) } else { (it.term, label) }
      if color == none and values.len() == 1 { label } else { values + if color == none { () } else { (color,) } }
    })
  }
}

// Items as dictionaries, or an error naming the widget `who`.  `items` is an array or a
// list written as content.  `fields` name the leading values of each item (with one field
// the item may be the bare value), `optional` the ones that may follow; a trailing colour
// becomes `fill`, which otherwise cycles through `colors` (or stays on the first one with
// cycle: false).  An item may also be a dictionary of those names, plus `color`.  The
// fields in `numbers` become numbers when written as text, as they are in a list.
#let _items(who, items, colors, fields: ("label",), optional: (), min: 1, max: none, cycle: true, numbers: ()) = {
  let shape = "(" + (..fields, ..optional.map(f => "[" + f + "]"), "[color]").join(", ") + ")"
  let items = if type(items) == content { _listed(items) } else { items }
  if not (type(items) == array) { assert(false, message: who + ": expected an array of items or a list ([- A - B]), got " + repr(items)) }
  assert(fields.len() > 1 or items.len() != 2 or type(items.at(1)) != color,
    message: who + ": got one " + shape + " pair instead of an array of items; add a trailing comma: ((label, color),)")
  assert(items.len() >= min and (max == none or items.len() <= max),
    message: who + ": needs " + (if max == none { "at least " + str(min) } else if min == max { "exactly " + str(min) } else {
      str(min) + " to " + str(max)
    }) + " item(s), got " + str(items.len()))
  let names = fields + optional
  let number(v) = if type(v) == content and v.has("text") and v.text.match(regex("^-?\\d+(\\.\\d+)?$")) != none {
    if "." in v.text { float(v.text) } else { int(v.text) }
  } else { v }
  let parsed(item) = numbers.fold(item, (item, name) => item + ((name): number(item.at(name))))
  items.enumerate().map(((i, it)) => {
    let cycled = colors.at(if cycle { calc.rem(i, colors.len()) } else { 0 })
    if type(it) == dictionary {
      assert(it.keys().all(key => key in names + ("color",)) and fields.all(name => name in it),
        message: who + ": item " + str(i + 1) + " takes the keys " + (names + ("color",)).join(", ") + " ("
          + fields.join(", ") + " required), got " + repr(it))
      return parsed(names.fold((fill: it.at("color", default: cycled)), (out, name) => out + ((name): it.at(name,
        default: none))))
    }
    let values = if type(it) == array { it } else { (it,) }
    let fill = if values.len() > fields.len() and type(values.last()) == color { values.pop() } else { cycled }
    assert(values.len() >= fields.len() and values.len() <= names.len(),
      message: who + ": item " + str(i + 1) + " must be " + shape + ", got " + repr(it)
        + (if type(it) != array and fields.len() > 1 { "; a single item needs a trailing comma: ((..),)" }))
    parsed(names.enumerate().fold((fill: fill), (out, (k, name)) => out + ((name): values.at(k, default: none))))
  })
}

// The named lengths, absolute (em is relative to the surrounding text), or an error
// naming the widget `who`.  Destructure the result by name.
#let _lens(who, ..lengths) = {
  let out = (:)
  for (name, v) in lengths.named() {
    if not (type(v) == length) { assert(false, message: who + ": `" + name + "` must be a length such as 2em or 1cm, got " + repr(v)) }
    out.insert(name, v.to-absolute())
  }
  out
}
// A parameter given as one length or an (x, y) pair, as absolute (x, y).
#let _pair(who, name, v) = {
  let (x, y) = if type(v) == array { v } else { (v, v) }
  _lens(who, ..((name): x, (name + " (y)"): y)).values()
}

// The width a widget gets inside `area`: its `width` when given (a ratio is relative to
// the container), else all the container has.
#let _span(who, width, area) = {
  if width == auto { return area.width }
  if not (type(width) in (length, ratio, relative)) { assert(false, message: who + ": `width` must be auto, a length or a ratio, got "
    + repr(width)) }
  let rel = 0% + 0pt + width
  rel.ratio * area.width + rel.length.to-absolute()
}
// The width a fluid widget (one that divides its width among its items) fills.
#let _fluid(who, width, area) = {
  let w = _span(who, width, area)
  if not (w < float.inf * 1pt) { assert(false, message: who + ": the container has no width to fill; pass `width:`") }
  w
}
// A drawing of natural size w x h shown at `width`: auto keeps the natural size unless
// the container is narrower; a length or ratio scales the whole drawing, text included.
// Shrinking on its own stops at the theme's min-scale: below it the text is too small to
// read, so the widget fails and says what to do.
#let _canvas(who, t, width, area, w, h, body) = {
  let avail = _span(who, width, area)
  let k = if width == auto { calc.min(1, avail / w) } else { avail / w }
  let cm(len) = str(calc.round(len.cm(), digits: 1)) + "cm"
  if not (width != auto or k * 100% >= t.min-scale) { assert(false, message: who + ": is " + cm(w) + " wide but its container only "
    + cm(avail) + ", which would shrink its text to " + str(calc.round(k * 100)) + "%; make it narrower (fewer or "
    + "shorter items, smaller sizes, another direction) or pass `width: 100%` to scale it anyway") }
  let drawing = box(width: w, height: h, body)
  if k == 1 { drawing } else { scale(k * 100%, reflow: true, drawing) }
}

#let _txt(body, fill, size, weight: "bold") = {
  set par(justify: false, leading: 0.5em)
  text(fill: fill, size: size, ..if weight != auto { (weight: weight) }, body)
}

// Measuring helpers; call them inside `context`.
#let _tallest(bodies, w) = calc.max(0pt, ..bodies.map(b => measure(b, width: w).height))

// Largest size <= `size` at which every label, wrapped at width w, fits its slot
// (one shared size, as in SmartArt).  w is a length or per-label array; h is a
// maximum height (length or array) or a test `(i, width, height) => bool` for
// shaped slots.  A label that fits at `size` fits at any smaller size, so only
// the overflowing ones are re-measured while bisecting on the size.
#let _fit(labels, fill, size, w, h) = {
  let n = labels.len()
  let ws = if type(w) == array { w } else { (w,) * n }
  let inside = if type(h) == function { h } else if type(h) == array { (i, lw, lh) => lh <= h.at(i) } else { (i, lw, lh) => lh <= h }
  let fits(i, s) = {
    let m = measure(_txt(labels.at(i), fill, s), width: ws.at(i))
    m.width <= ws.at(i) + 0.01pt and inside(i, m.width, m.height)
  }
  let over = range(n).filter(i => not fits(i, size))
  if over.len() == 0 { return size }
  let (lo, hi) = (size * 0.3, size)
  for _ in range(6) {
    let mid = (lo + hi) / 2
    if over.all(i => fits(i, mid)) { lo = mid } else { hi = mid }
  }
  lo
}

// Slot test for a label centred in a circle of radius r: its corners stay inside.
#let _in-circle(r) = (i, lw, lh) => calc.norm(lw / 2pt, lh / 2pt) * 1pt <= r

// Centre `body` on (x, y), wrapping at width `w`.  The tall slot gives `horizon`
// room to centre any number of lines; being placed, it takes no space.
#let _put(x, y, body, w: 40cm) = place(top + left, dx: x - w / 2, dy: y - 50cm,
  box(width: w, height: 100cm, align(center + horizon, body)))

// The faint copy of a shape that is its shadow: `ghost` builds the shape in a given paint;
// it is placed at dx, dy plus the shadow's reach.
#let _cast(shadow, dx, dy, ghost) = if shadow != none {
  place(top + left, dx: dx + shadow.dx, dy: dy + shadow.dy, ghost(shadow.paint))
}

// `shape` (a box, rect, circle or ellipse) over its shadow, taking the room of the shape
// alone.  A shape whose height follows its content is measured first.
#let _shade(shadow, shape) = {
  let fields = shape.fields()
  if shadow == none or fields.at("fill", default: none) == none { return shape }
  let body = fields.remove("body", default: none)
  let round = shape.func() == circle and "radius" in fields
  if not round and fields.at("height", default: auto) == auto {
    return layout(area => {
      let m = measure(shape, width: area.width)
      _shade(shadow, (shape.func())(..fields, width: m.width, height: m.height, body))
    })
  }
  let ghost(paint) = (shape.func())(..fields, fill: paint, stroke: none)
  let size = if round { (width: 2 * fields.radius, height: 2 * fields.radius) } else {
    (width: fields.at("width", default: auto), height: fields.height)
  }
  box(..size, _cast(shadow, 0pt, 0pt, ghost) + place(top + left, shape))
}
// A box, or a circle, that casts the theme's shadow.  A box of explicit size, the usual
// case, is built directly; any other goes through `_shade`.
#let _card(t, ..box-args) = {
  let named = box-args.named()
  let (w, h) = (named.at("width", default: auto), named.at("height", default: auto))
  if t.shadow == none or named.at("fill", default: none) == none { return box(..box-args) }
  if type(w) != length or type(h) != length { return _shade(t.shadow, box(..box-args)) }
  box(width: w, height: h, place(top + left, dx: t.shadow.dx, dy: t.shadow.dy, box(width: w, height: h,
    radius: named.at("radius", default: 0pt), fill: t.shadow.paint)) + place(top + left, box(..box-args)))
}
#let _disc(t, ..circle-args) = _shade(t.shadow, circle(..circle-args))

#let _poly(..pts, fill: none, stroke: none, shadow: none) = {
  _cast(if fill != none { shadow }, 0pt, 0pt, paint => polygon(fill: paint, ..pts))
  place(top + left, polygon(fill: fill, stroke: stroke, ..pts))
}

#let _dot(x, y, r, fill: none, stroke: none, shadow: none) = {
  _cast(if fill != none { shadow }, x - r, y - r, paint => circle(radius: r, fill: paint))
  place(top + left, dx: x - r, dy: y - r, circle(radius: r, fill: fill, stroke: stroke))
}

// Filled triangular arrowhead whose base centre is `from` and tip is `tip`.
#let _head(from, tip, paint, half) = {
  let (fx, fy) = from
  let (tx, ty) = tip
  let len = calc.norm((tx - fx) / 1pt, (ty - fy) / 1pt) * 1pt
  let (nx, ny) = (-(ty - fy) / len, (tx - fx) / len)
  _poly(tip, (fx + nx * half, fy + ny * half), (fx - nx * half, fy - ny * half), fill: paint)
}

// Polyline through `pts` with arrowheads at its ends; head size scales with the stroke.
#let _arrow(..pts, paint: black, thickness: 2pt, head: auto, start: false, end: true, dash: none) = {
  let pts = pts.pos()
  let hl = if head == auto { thickness * 3.6 } else { head }
  // the point d before `to` on the segment from `from`
  let back(from, to, d) = {
    let len = calc.norm((to.at(0) - from.at(0)) / 1pt, (to.at(1) - from.at(1)) / 1pt) * 1pt
    (to.at(0) - (to.at(0) - from.at(0)) * (d / len), to.at(1) - (to.at(1) - from.at(1)) * (d / len))
  }
  // a two-point arrow with a head at its end is nearly every arrow: one unit vector serves
  // the shaft and the head
  if pts.len() == 2 and end and not start {
    let ((ax, ay), (bx, by)) = pts
    let len = calc.norm((bx - ax) / 1pt, (by - ay) / 1pt) * 1pt
    let (ux, uy) = ((bx - ax) / len, (by - ay) / len)
    let (cx, cy, half) = (bx - ux * hl, by - uy * hl, hl * 0.5)
    place(top + left, line(start: (ax, ay), end: (bx - ux * hl * 0.8, by - uy * hl * 0.8),
      stroke: (paint: paint, thickness: thickness, dash: dash)))
    place(top + left, polygon(fill: paint, (bx, by), (cx - uy * half, cy + ux * half), (cx + uy * half, cy - ux * half)))
    return
  }
  let shaft = pts
  if end { shaft.at(-1) = back(pts.at(-2), pts.at(-1), hl * 0.8) }
  if start { shaft.at(0) = back(pts.at(1), pts.at(0), hl * 0.8) }
  place(top + left, curve(stroke: (paint: paint, thickness: thickness, join: "round", dash: dash),
    curve.move(shaft.first()), ..shaft.slice(1).map(curve.line)))
  if end { _head(back(pts.at(-2), pts.at(-1), hl), pts.at(-1), paint, hl * 0.5) }
  if start { _head(back(pts.at(1), pts.at(0), hl), pts.at(0), paint, hl * 0.5) }
}

// A thin arrow in the theme's line colour, as between the nodes of a flowchart.
#let _link(t, ..pts, dash: none) = _arrow(..pts, paint: t.line, thickness: 1.4 * t.stroke, head: 8.7 * t.stroke, dash: dash)

// Point on a circle; angles are counter-clockwise from +x as on paper.
#let _polar(cx, cy, r, a) = (cx + r * calc.cos(a), cy - r * calc.sin(a))

// Cubic Bézier segments of the arc from angle a0 to a1 (start point excluded);
// `ry` makes it an elliptical arc with vertical radius ry.
#let _arc(cx, cy, r, a0, a1, ry: auto) = {
  let sy = if ry == auto { 1 } else { ry / r }
  let n = calc.max(1, calc.ceil(calc.abs((a1 - a0) / 90deg)))
  let d = (a1 - a0) / n
  let k = 4 / 3 * calc.tan(d / 4) * r
  let pt(a) = (cx + r * calc.cos(a), cy - r * sy * calc.sin(a))
  range(n).map(i => {
    let s = a0 + i * d
    let e = s + d
    let (sx, sy0) = pt(s)
    let (ex, ey) = pt(e)
    curve.cubic(
      (sx - k * calc.sin(s), sy0 - k * sy * calc.cos(s)),
      (ex + k * calc.sin(e), ey + k * sy * calc.cos(e)),
      (ex, ey))
  })
}

// An open elliptical ring centred on (cx, cy), its arrowhead turning anticlockwise at the top.
#let _loop(cx, cy, rx, ry, paint, t) = {
  let hl = t * 3.8
  let pt(a) = (cx + rx * calc.cos(a), cy - ry * calc.sin(a))
  let a1 = 450deg - hl / rx * 1rad
  place(top + left, curve(stroke: (paint: paint, thickness: t, cap: "round"), curve.move(pt(125deg)),
    .._arc(cx, cy, rx, 125deg, a1 + hl * 0.2 / rx * 1rad, ry: ry)))
  _head(pt(a1), pt(450deg), paint, hl * 0.6)
}

// Box of size w x h centred on (x, y) with `body` centred inside.
#let _node(x, y, w, h, body, fill: none, stroke: none, radius: 0pt, inset: 0pt, shadow: none) = {
  _cast(if fill != none { shadow }, x - w / 2, y - h / 2, paint => box(width: w, height: h, fill: paint, radius: radius))
  place(top + left, dx: x - w / 2, dy: y - h / 2, box(width: w, height: h, fill: fill, stroke: stroke, radius: radius,
    inset: (x: inset), align(center + horizon, body)))
}
