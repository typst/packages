// Shapes and styled boxes in HTML: `rect`, `square`, `circle`, `ellipse`, and
// the fill, stroke, inset, outset, radius, size, and clip of `box` and `block`.
// The content stays selectable HTML. Fill and stroke are paint layers behind
// it, so, as in Typst, the stroke and outset never change the layout.
// Each function returns `none` for what CSS cannot draw; the caller then keeps
// Typst's native HTML output.
#import "css.typ": num, size, paint, sides, stroke-value
#import "stroke.typ": svg-stroke-attrs, mask-url

// CSS can draw colors and most gradients; tilings and some gradients it cannot.
#let paintable(value) = {
  if value == none or type(value) == color { return true }
  if type(value) != gradient or value.relative() == "parent" { return false }
  value.kind() != gradient.radial or (value.focal-center() == value.center() and value.focal-radius() == 0%)
}

#let neg(value) = if value == 0pt or value == 0% + 0pt { "0" } else { "calc(-1 * " + size(value) + ")" }

#let rel(value) = {
  if type(value) == length { value + 0% }
  else if type(value) == ratio { 0pt + value }
  else { value }
}

// Per-corner radii from a radius value or dictionary. Named corners beat sides,
// which beat `rest`.
#let corners(value) = {
  if type(value) != dictionary {
    return (top-left: value, top-right: value, bottom-right: value, bottom-left: value)
  }
  let rest = value.at("rest", default: 0pt)
  let pick(corner, a, b) = value.at(corner, default: value.at(a, default: value.at(b, default: rest)))
  (
    top-left: pick("top-left", "top", "left"),
    top-right: pick("top-right", "top", "right"),
    bottom-right: pick("bottom-right", "bottom", "right"),
    bottom-left: pick("bottom-left", "bottom", "left"),
  )
}

// Typst resolves a ratio radius against half the shorter side. The paint layer
// is a size container, so `cqmin` is that side.
#let radius-css(value, grow: 0pt) = {
  let v = rel(value)
  if v.length == 0pt and v.ratio == 0% { return "0" }
  let parts = ()
  if v.length != 0pt { parts.push(size(v.length)) }
  if v.ratio != 0% { parts.push(num(v.ratio / 1% / 2) + "cqmin") }
  if grow != 0pt { parts.push(size(grow)) }
  if parts.len() == 1 { parts.first() } else { "calc(" + parts.join(" + ") + ")" }
}

#let radii-css(kind, radii, grow: 0pt) = {
  if kind == "ellipse" { return "50%" }
  ("top-left", "top-right", "bottom-right", "bottom-left").map(c => radius-css(radii.at(c), grow: grow)).join(" ")
}

#let border-style(s) = {
  if s.dash == none or s.dash == auto { "solid" }
  else if s.dash.array.at(0) in ("dot", 0pt) { "dotted" }
  else { "dashed" }
}

#let layer(styles) = html.elem("span", attrs: (style: ((
  "position: absolute", "display: block", "box-sizing: border-box",
) + styles).join("; ")))

// The stroke, centred on the shape's outline. Returns `none` if CSS cannot draw it.
#let stroke-layer(kind, strokes, radii) = {
  let present = strokes.values().filter(s => s != none)
  if present.len() == 0 { return [] }
  if not present.all(s => paintable(s.paint)) { return none }
  let t = (:)
  for (side, s) in strokes { t.insert(side, if s == none { 0pt } else { s.thickness.to-absolute() }) }
  let half = calc.max(..t.values()) / 2
  let outside = "inset: " + ("top", "right", "bottom", "left").map(side => neg(t.at(side) / 2)).join(" ")
  let first = present.first()
  // Gradients never compare equal, so values are compared by their repr.
  let uniform = present.len() == 4 and present.all(s => repr(s) == repr(first))
  let dashed = present.any(s => s.dash != none and s.dash != auto)
  let same-paint = present.all(s => repr(s.paint) == repr(first.paint))
  let even = kind == "ellipse" or radii.values().all(r => r == radii.top-left and rel(r).ratio == 0%)
  if uniform and dashed and even {
    // Exact dash patterns: an SVG outline masks the paint. The layer reaches
    // half a stroke beyond the shape, so a double-width stroke on the layer's
    // outline, clipped to its inside, is exactly the stroke centred on the shape.
    let tt = first.thickness.to-absolute()
    let outline = if kind == "ellipse" { "<ellipse cx='50%' cy='50%' rx='50%' ry='50%'" }
      else {
        let r = rel(radii.top-left).length.to-absolute()
        "<rect width='100%' height='100%' rx='" + size(if r == 0pt { 0pt } else { r + tt / 2 }) + "'"
      }
    let attrs = svg-stroke-attrs(first).replace("stroke-width='" + size(tt) + "'", "stroke-width='" + size(2 * tt) + "'")
    let source = ("<svg xmlns='http://www.w3.org/2000/svg' width='100%' height='100%'><clipPath id='c'>"
      + outline + "/></clipPath>" + outline + " clip-path='url(#c)' " + attrs + "/></svg>")
    return layer((outside, "background: " + paint(first.paint, role: "ink"),
      "mask-image: " + mask-url(source), "mask-size: 100% 100%", "mask-repeat: no-repeat"))
  }
  let radius = "border-radius: " + radii-css(kind, radii, grow: half)
  if same-paint and not dashed and type(first.paint) == gradient {
    // A gradient border: the paint shows only in the padding ring.
    let ring = "linear-gradient(#000 0 0)"
    return layer((outside, radius, "background: " + paint(first.paint, role: "ink"),
      "padding: " + ("top", "right", "bottom", "left").map(side => size(t.at(side))).join(" "),
      "mask: " + ring + " content-box, " + ring, "mask-composite: exclude"))
  }
  // Borders: one color per side, and dashes approximated by CSS dashed/dotted.
  if not present.all(s => type(s.paint) == color) { return none }
  let styles = (outside, radius)
  for (side, s) in strokes {
    styles.push("border-" + side + ": " + if s == none { "0" } else {
      size(t.at(side)) + " " + border-style(s) + " " + paint(s.paint, role: "ink")
    })
  }
  layer(styles)
}

// The shape element. `kind` is "rect" or "ellipse". Sizes and insets are
// native values; `strokes` and `outset` are side dictionaries.
#let shape-html(body, kind: "rect", tag: "div", display: "block", width: auto, height: auto,
  aspect: false, fill: none, strokes: (:), radius: (:), inset: (:), outset: (:), clip: false,
  class: "letmeout-shape", extra: ()) = {
  if not paintable(fill) { return none }
  let radii = corners(radius)
  let strokes = sides(strokes)
  let stroke = stroke-layer(kind, strokes, radii)
  if stroke == none { return none }
  let styles = ("display: " + display, "position: relative", "isolation: isolate", "box-sizing: border-box", "min-width: 0")
  if width != auto { styles.push("width: " + size(width)) }
  else if tag == "div" and display == "block" and kind != "block" { styles.push("width: fit-content"); styles.push("max-width: 100%") }
  if height != auto { styles.push("height: " + size(height)) }
  if aspect and (width == auto or height == auto) { styles.push("aspect-ratio: 1") }
  let pad = sides(inset, default: 0pt)
  for (side, value) in pad {
    if value == auto { value = 0pt }
    // Round shapes keep their content inside the inscribed rectangle.
    let extent = if side in ("left", "right") { width } else { height }
    let extra-pad = if kind == "ellipse" and body != none {
      if extent != auto and type(extent) != fraction { " + " + num(0.5 - calc.sqrt(2) / 4) + " * " + size(extent) }
      else { " + 0.25em" }
    } else { "" }
    if extra-pad != "" { styles.push("padding-" + side + ": calc(" + size(value) + extra-pad + ")") }
    else if rel(value) != 0% + 0pt { styles.push("padding-" + side + ": " + size(value)) }
  }
  if clip {
    styles.push("overflow: clip")
    if kind == "ellipse" { styles.push("border-radius: 50%") }
    else {
      // No size container here: a ratio becomes a CSS percentage of each side.
      styles.push("border-radius: " + ("top-left", "top-right", "bottom-right", "bottom-left").map(c => {
        let v = rel(radii.at(c))
        if v.ratio == 0% { size(v.length) } else { "calc(" + size(v.length) + " + " + num(v.ratio / 1% / 2) + "%)" }
      }).join(" "))
    }
  }
  styles += extra
  let paints = if fill != none or stroke != [] {
    html.elem("span", attrs: (class: "letmeout-shape-paint", "aria-hidden": "true", style: (
      "position: absolute", "display: block", "z-index: -1", "pointer-events: none", "container-type: size",
      "inset: " + ("top", "right", "bottom", "left").map(side => {
        let v = sides(outset, default: 0pt).at(side)
        neg(if v == auto { 0pt } else { v })
      }).join(" "),
    ).join("; ")), {
      if fill != none {
        layer(("inset: 0", "background: " + paint(fill), "border-radius: " + radii-css(kind, radii)))
      }
      stroke
    })
  }
  html.elem(tag, attrs: (class: class, style: styles.join("; ")), {
    paints
    if body != none { body }
  })
}

// Typst's sizes for shapes without content.
#let default-size = (rect: (45pt, 30pt), square: (30pt, 30pt), circle: (30pt, 30pt), ellipse: (45pt, 30pt))

#let shape-rule(name) = it => {
  let body = it.at("body", default: none)
  let (w, h) = (it.width, it.height)
  if body == none {
    let (dw, dh) = default-size.at(name)
    if name in ("square", "circle") {
      // One given side sets the other.
      if w == auto and h == auto { (w, h) = (dw, dh) }
      else if w == auto { w = h } else if h == auto { h = w }
    } else {
      if w == auto { w = dw }
      if h == auto { h = dh }
    }
  }
  if type(w) == fraction or type(h) == fraction { return none }
  let stroke = it.stroke
  if stroke == auto { stroke = if it.fill == none { 1pt + black } else { none } }
  let strokes = if name in ("circle", "ellipse") { stroke-value(stroke) } else {
    let s = sides(stroke)
    for (side, v) in s { s.insert(side, if v == auto { stroke-value(1pt + black) } else { stroke-value(v) }) }
    s
  }
  shape-html(body, kind: if name in ("circle", "ellipse") { "ellipse" } else { "rect" },
    width: w, height: h, aspect: name in ("square", "circle"), fill: it.fill, strokes: strokes,
    radius: it.at("radius", default: (:)), inset: it.inset, outset: it.outset,
    class: "letmeout-" + name)
}

#let has-sides(value) = sides(value, default: none).values().any(v => v != none and v != auto and rel(v) != 0% + 0pt)

// Box and block keep Typst's native HTML unless they have styling to carry over.
#let container-rule(name) = it => {
  let strokes = sides(it.stroke)
  for (side, v) in strokes { strokes.insert(side, stroke-value(v)) }
  let painted = it.fill != none or strokes.values().any(s => s != none)
  let width = if type(it.width) == fraction { auto } else { it.width }
  let height = if type(it.height) == fraction { auto } else { it.height }
  let extra = ()
  if name == "block" {
    if not it.breakable { extra.push("break-inside: avoid") }
    if it.above != auto and type(it.above) != fraction { extra.push("margin-top: " + size(it.above)) }
    if it.below != auto and type(it.below) != fraction { extra.push("margin-bottom: " + size(it.below)) }
  } else {
    let shift = rel(it.baseline.shift)
    if shift != 0% + 0pt {
      let amount = shift.length + if shift.ratio != 0% and type(height) == length { height * (shift.ratio / 100%) } else { 0pt }
      extra.push("vertical-align: " + neg(amount))
    }
  }
  if not (painted or has-sides(it.inset) or width != auto or height != auto or it.clip or extra.len() > 0) {
    return none
  }
  shape-html(it.body, kind: "block", tag: if name == "box" { "span" } else { "div" },
    display: if name == "box" { "inline-block" } else { "block" },
    width: width, height: height, fill: it.fill, strokes: strokes, radius: it.radius,
    inset: it.inset, outset: it.outset, clip: it.clip, class: "letmeout-" + name, extra: extra)
}
