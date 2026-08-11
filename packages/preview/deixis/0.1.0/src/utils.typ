#let resolve-len(val) = {
  if val == auto or type(val) == fraction or val == none or type(val) == ratio {
    0pt
  } else {
    measure(line(length: val)).width
  }
}

#let resolve-signed-len(val) = measure(box(width: val + 1e10pt)).width - 1e10pt

#let to-length(val) = if type(val) == length { val } else { val * 1pt }

#let to-float(val) = if type(val) == length { val / 1pt } else { val }

#let get-page-margins(page-num) = {
  let m = page.margin
  let default-m = 2.5cm

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

  if "inside" in m or "outside" in m {
    let inside = r-auto(m.at("inside", default: x), x)
    let outside = r-auto(m.at("outside", default: x), x)

    if calc.odd(page-num) {
      l-margin = inside
      r-margin = outside
    } else {
      l-margin = outside
      r-margin = inside
    }
  }

  return (left: l-margin, right: r-margin, top: t-margin, bottom: b-margin)
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

#let get-radius(r) = {
  if type(r) == dictionary {
    return (
      top-left: r.at("top-left", default: 0pt),
      top-right: r.at("top-right", default: 0pt),
      bottom-left: r.at("bottom-left", default: 0pt),
      bottom-right: r.at("bottom-right", default: 0pt),
    )
  } else {
    let abs-r = if r == auto { 0pt } else { r }
    return (top-left: abs-r, top-right: abs-r, bottom-left: abs-r, bottom-right: abs-r)
  }
}

#let get-stroke(s) = {
  if s in (none, auto) { return none }
  if type(s) == dictionary and ("top" in s or "bottom" in s or "left" in s or "right" in s) {
    return (
      top: s.at("top", default: none),
      bottom: s.at("bottom", default: none),
      left: s.at("left", default: none),
      right: s.at("right", default: none),
    )
  }
  return (top: s, bottom: s, left: s, right: s)
}

#let _deixis-normalize-ports(val) = {
  if val in (auto, none) { return auto }

  let valid-ports = ("top", "bottom", "left", "right")

  let parse-port(p) = {
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
  } else if type(val) == dictionary {
    let res = (:)
    for (k, v) in val {
      if k not in ("mark", "body") {
        panic("deixis: Invalid key '" + k + "' in link-ports. Allowed keys are 'mark' and 'body'.")
      }
      res.insert(k, parse-port(v))
    }
    return res
  } else {
    panic("deixis: link-ports must be an alignment, string, or dictionary. Got: " + type(val))
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
