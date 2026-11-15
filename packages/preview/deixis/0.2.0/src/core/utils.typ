#import "pins.typ": _deixis-routing-pin-spec
#import "styles.typ": _deixis-radius-corners, _deixis-stroke-edges

#let text-direction(dir, lang) = if dir == auto {
  if (
    lang
      in (
        "ar",
        "dv",
        "fa",
        "he",
        "ks",
        "pa",
        "ps",
        "sd",
        "ug",
        "ur",
        "yi",
      )
  ) { rtl } else { ltr }
} else {
  dir
}

// A4 paper size
#let default-page-size = (
  width: 21.0cm,
  height: 29.7cm,
)

// Page layers expose their final numeric dimensions, including an auto axis.
// Fixed pages need no query dependency; early passes retain the old fallback.
#let get-page-size(page-num) = {
  if type(page.width) == length and type(page.height) == length {
    return (width: page.width, height: page.height)
  }
  let frame = query(<deixis-page-frame>).find(f => f.value.page == page-num)
  (width: if frame != none { frame.value.width } else if type(page.width) == length { page.width } else { default-page-size.width },
    height: if frame != none { frame.value.height } else if type(page.height) == length { page.height } else { default-page-size.height })
}

#let resolve-len(val) = {
  if val == auto or type(val) == fraction or val == none or type(val) == ratio {
    0pt
  } else {
    measure(line(length: val)).width
  }
}

#let resolve-signed-len(val) = if type(val) == length {
  val.to-absolute()
} else { measure(box(width: val + 1e10pt)).width - 1e10pt }

#let to-length(val) = if type(val) == length { val } else { val * 1pt }

#let to-float(val) = if type(val) == length { val / 1pt } else { val }

#let get-page-binding() = if page.binding == auto {
  if text-direction(text.dir, text.lang) == rtl { right } else { left }
} else { page.binding }

// Logical sides share one duplex rule across prediction and every painter.
#let resolve-margin-side(side, target-id, page-num, pref-dir, binding) = {
  if side in ("inside", "outside") {
    let inside-left = if target-id == "page" { calc.odd(page-num) == (binding == left) } else { pref-dir != rtl }
    return if inside-left == (side == "inside") { left } else { right }
  }
  if side == "left" { left } else if side == "right" { right } else { side }
}

#let get-page-margins(page-num) = {
  let m = page.margin

  // Native automatic margins are 2.5/21 of the shorter finite configured axis.
  // Percentage margins on an auto axis resolve against zero, not its final size.
  let p-w = if type(page.width) == length { page.width } else { 0pt }
  let p-h = if type(page.height) == length { page.height } else { 0pt }
  let finite = (p-w, p-h).filter(size => size > 0pt)
  let basis = if finite.len() > 0 { calc.min(..finite) } else { 0pt }
  let auto-x = basis * (2.5 / 21)
  let auto-y = auto-x

  if m == auto { return (left: auto-x, right: auto-x, top: auto-y, bottom: auto-y) }

  if type(m) != dictionary { m = (rest: m) }

  let get(key, def) = if key in m and m.at(key) != auto { m.at(key) } else { def }

  let rest-x = get("rest", auto-x)
  let rest-y = get("rest", auto-y)

  let x = get("x", rest-x)
  let y = get("y", rest-y)

  let l-margin = get("left", x)
  let r-margin = get("right", x)
  let t-margin = get("top", y)
  let b-margin = get("bottom", y)

  if "inside" in m or "outside" in m {
    let inside = get("inside", x)
    let outside = get("outside", x)

    let binding = get-page-binding()
    if calc.odd(page-num) == (binding == left) {
      l-margin = inside
      r-margin = outside
    } else {
      l-margin = outside
      r-margin = inside
    }
  }

  let edge(value, basis) = {
    if type(value) == ratio { value * basis }
    else if type(value) == relative { resolve-signed-len(value.length) + value.ratio * basis }
    else { value }
  }
  return (left: edge(l-margin, p-w), right: edge(r-margin, p-w),
    top: edge(t-margin, p-h), bottom: edge(b-margin, p-h))
}

#let get-margins(m, default: 0pt) = {
  let default-m = default

  if m == auto { return (left: default-m, right: default-m, top: default-m, bottom: default-m) }
  if type(m) != dictionary { return (left: m, right: m, top: m, bottom: m) }

  let r-auto(val, def) = if val == auto { def } else { val }

  let rest = r-auto(m.at("rest", default: default-m), default-m)
  let x = r-auto(m.at("x", default: rest), rest)
  let y = r-auto(m.at("y", default: rest), rest)

  let l-margin = r-auto(m.at("left", default: x), x)
  let r-margin = r-auto(m.at("right", default: x), x)
  let t-margin = r-auto(m.at("top", default: y), y)
  let b-margin = r-auto(m.at("bottom", default: y), y)

  return (left: l-margin, right: r-margin, top: t-margin, bottom: b-margin)
}

// Query-free validation/normalization for callers that have no font context yet.
#let _deixis-padding-spec(value) = {
  let keys = ("left", "right", "top", "bottom", "x", "y", "rest")
  assert(value in (auto, none) or type(value) in (length, dictionary),
    message: "deixis: Annotation padding must be a signed length, edge dictionary, auto, or none; percentages have no pin-size basis.")
  if value == none { value = 0pt }
  if type(value) == dictionary {
    assert(value.keys().all(k => k in keys), message: "deixis: Unknown annotation padding edge; expected " + repr(keys))
    assert(value.values().all(v => v in (auto, none) or type(v) == length),
      message: "deixis: Annotation padding edges must be signed lengths, auto, or none.")
    value = value.pairs().fold((:), (result, pair) => {
      result.insert(pair.first(), if pair.last() == none { 0pt } else { pair.last() })
      result
    })
  }
  get-margins(value)
}

// Resolve in the declaration's font context, preserving negative insets.
// Painting may happen under another page's text settings.
#let resolve-padding(value) = {
  let pad = _deixis-padding-spec(value)
  (left: resolve-signed-len(pad.left), right: resolve-signed-len(pad.right),
    top: resolve-signed-len(pad.top), bottom: resolve-signed-len(pad.bottom))
}

#let get-radius = _deixis-radius-corners

#let get-stroke = _deixis-stroke-edges

#let _deixis-normalize-ports(val) = {
  if val in (auto, none) { return auto }

  let valid-ports = ("top", "bottom", "left", "right")

  let parse-port(p) = {
    if p == auto { return auto }
    if type(p) == dictionary {
      if "pin" in p { return _deixis-routing-pin-spec(p) }
      assert(p.keys().all(k => k in ("side", "at", "gap")) and "side" in p,
        message: "deixis: A port record needs side and accepts at/gap.")
      let side = if type(p.side) == alignment { repr(p.side) } else { p.side }
      assert(side in valid-ports, message: "deixis: Invalid port side " + repr(side))
      let at = p.at("at", default: auto)
      assert(at == auto or (type(at) == ratio and at >= 0% and at <= 100%),
        message: "deixis: Port at must be auto or a percentage from 0% to 100%.")
      return (side: side, at: at, gap: p.at("gap", default: 0pt))
    }
    let s = if type(p) == alignment { repr(p) } else if type(p) == str { p } else { none }
    if s not in valid-ports {
      panic(
        "deixis: Invalid port '"
          + repr(p)
          + "'. Allowed ports are: top, bottom, left, right (or their string equivalents).",
      )
    }
    return s
  }

  if type(val) in (str, alignment) {
    let s = parse-port(val)
    return (mark: s, body: s)
  } else if type(val) == array {
    assert(val.len() == 2, message: "deixis: A port pair needs (mark, body).")
    return (mark: parse-port(val.at(0)), body: parse-port(val.at(1)))
  } else if type(val) == dictionary {
    let res = (:)
    for (k, v) in val {
      if k not in ("mark", "body") {
        panic("deixis: Invalid key '" + k + "' in connector.ports. Allowed keys are 'mark' and 'body'.")
      }
      res.insert(k, parse-port(v))
    }
    return res
  } else {
    panic("deixis: connector.ports must be an alignment, string, pair, or dictionary. Got: " + repr(type(val)))
  }
}

#let _deixis-trim-content(c) = {
  if type(c) != content { return c }
  if c.func() != [].func() { return c } // Ensure it is a sequence

  let space-func = [ ].func()
  let children = c.children

  // strip leading spaces
  let start-idx = 0
  while start-idx < children.len() {
    if children.at(start-idx).func() == space-func {
      start-idx += 1
    } else {
      break
    }
  }

  // strip trailing spaces
  let end-idx = children.len()
  while end-idx > start-idx {
    let func = children.at(end-idx - 1).func()
    if func == space-func or func == parbreak {
      end-idx -= 1
    } else {
      break
    }
  }

  if start-idx >= end-idx { return [] }
  return children.slice(start-idx, end-idx).join()
}
