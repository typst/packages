// A number for CSS. Typst writes negative numbers with a Unicode minus sign.
#let num(value) = str(value).replace("\u{2212}", "-")

#let weight-css(weight) = {
  if type(weight) == int { return str(weight) }
  (thin: "100", extralight: "200", light: "300", regular: "400", medium: "500",
    semibold: "600", bold: "700", extrabold: "800", black: "900").at(str(weight), default: "400")
}

// Preserve physical, font-relative, and percentage components as CSS lengths.
#let size(value, percent-unit: "%") = {
  if value == auto { return "auto" }
  if type(value) == fraction { return num(value / 1fr) + "fr" }
  if type(value) == ratio { return num(value / 1%) + percent-unit }
  if type(value) == relative {
    if value.ratio == 0% { return size(value.length) }
    if value.length == 0pt { return size(value.ratio, percent-unit: percent-unit) }
    return "calc(" + size(value.length) + " + " + size(value.ratio, percent-unit: percent-unit) + ")"
  }
  assert(type(value) == length, message: "letmeout: unsupported CSS size " + repr(value))
  let absolute = num(value.abs.pt()) + "pt"
  let em = num(value.em) + "em"
  if value.em == 0 { absolute }
  else if value.abs == 0pt { em }
  else { "calc(" + absolute + " + " + em + ")" }
}

#let repeated(values, index, default: auto) = {
  if values.len() == 0 { default }
  else { values.at(calc.min(index, values.len() - 1)) }
}
#let track(value) = {
  if type(value) == fraction { "minmax(0, " + size(value) + ")" }
  else { size(value) }
}
#let tracks(values) = values.map(track).join(" ")

#let hex(value) = rgb(value).to-hex()

// Shared by document and scoped themes. CSS inheritance merges nested maps.
#let dark-properties(pairs) = pairs.map(pair => {
  assert(type(pair) == array and pair.len() == 2,
    message: "letmeout: dark-colors takes (light, dark) color pairs")
  let (light, dark) = pair
  assert(type(light) == color and type(dark) == color,
    message: "letmeout: dark-colors takes (light, dark) color pairs")
  "--letmeout-dark-" + hex(light).slice(1) + ": " + hex(dark)
})

// Dark mode keeps the hue and mirrors the lightness around the middle: dark
// ink becomes light and light fills become dark; mid tones stay. White fills
// land on the browser's dark canvas, as they match the light one.
#let dark-variant(value, role) = {
  let (l, c, h, a) = oklch(value).components()
  let l = l / 100%
  let l = if role == "fill" { if l > 0.5 { 0.2357 + (1 - l) * 0.5286 } else { l } }
    else { if l < 0.5 { 0.92 - l * 0.84 } else { l } }
  rgb(oklch(l * 100%, c, h, a))
}

// A color for both schemes. `role` is "fill" for backgrounds, "ink" for text
// and strokes. A `--letmeout-dark-<hex>` property replaces the automatic dark
// variant; outside a dark color scheme `light-dark` picks the light color.
#let color-css(value, role: "fill") = {
  let light = hex(value)
  "light-dark(" + light + ", var(--letmeout-dark-" + light.slice(1) + ", " + hex(dark-variant(value, role)) + "))"
}

// Sample in Typst's chosen color space, then let CSS interpolate nearby stops.
// This also works for spaces (such as CMYK) that CSS cannot interpolate in.
#let gradient-stops(value, role) = {
  let stops = value.stops()
  let result = ()
  for (i, stop) in stops.enumerate() {
    result.push(color-css(stop.at(0), role: role) + " " + size(stop.at(1)))
    if i + 1 < stops.len() {
      let next = stops.at(i + 1).at(1)
      if next > stop.at(1) {
        for j in range(1, 17) {
          let offset = stop.at(1) + (next - stop.at(1)) * j / 17
          result.push(color-css(value.sample(offset), role: role) + " " + size(offset))
        }
      }
    }
  }
  result.join(", ")
}

#let paint(value, role: "fill") = {
  if value == none { return "transparent" }
  if type(value) == color { return color-css(value, role: role) }
  assert(type(value) == gradient,
    message: "letmeout: arbitrary Typst tiling content has no CSS paint equivalent; use an HTML background image")
  assert(value.relative() != "parent",
    message: "letmeout: parent-relative gradients need an explicit HTML background on the parent")
  let stops = gradient-stops(value, role)
  if value.kind() == gradient.linear {
    "linear-gradient(" + num(value.angle().deg() + 90) + "deg, " + stops + ")"
  } else if value.kind() == gradient.conic {
    let c = value.center()
    "conic-gradient(from " + num(value.angle().deg() + 90) + "deg at " + size(c.at(0)) + " " + size(c.at(1)) + ", " + stops + ")"
  } else {
    assert(value.focal-center() == value.center() and value.focal-radius() == 0%,
      message: "letmeout: off-center radial gradient focal circles have no CSS background equivalent")
    let c = value.center()
    "radial-gradient(ellipse " + size(value.radius()) + " " + size(value.radius()) + " at " + size(c.at(0)) + " " + size(c.at(1)) + ", " + stops + ")"
  }
}

#let alignment-styles(value) = {
  if value == auto { return () }
  let styles = ()
  if value.x != none {
    styles.push("text-align: " + repr(value.x))
    styles.push("justify-items: " + repr(value.x))
  }
  if value.y != none {
    styles.push("align-content: " + if value.y == horizon { "center" }
      else if value.y == bottom { "end" } else { "start" })
  }
  styles
}

#let sides(value, default: none) = {
  if type(value) != dictionary or value.keys().any(k => k in ("paint", "thickness", "dash", "cap", "join", "miter-limit")) {
    return (top: value, right: value, bottom: value, left: value)
  }
  let rest = value.at("rest", default: default)
  (
    top: value.at("top", default: value.at("y", default: rest)),
    bottom: value.at("bottom", default: value.at("y", default: rest)),
    left: value.at("left", default: value.at("x", default: rest)),
    right: value.at("right", default: value.at("x", default: rest)),
  )
}

#let stroke-fields(value) = {
  let own = if type(value) == dictionary { stroke(..value) } else { stroke(value) }
  (paint: own.paint, thickness: own.thickness, cap: own.cap,
    join: own.join, dash: own.dash, miter-limit: own.miter-limit)
}

#let stroke-value(value, base: none) = {
  if value == none { return none }
  let inherited = if base == none {
    (paint: black, thickness: 1pt, cap: "butt", join: "miter", dash: none, miter-limit: 4)
  } else { base }
  let fields = stroke-fields(value)
  for key in fields.keys() {
    if fields.at(key) == auto { fields.insert(key, inherited.at(key)) }
  }
  fields
}

#let fold-stroke(outer, inner) = {
  if inner == auto { return outer }
  if inner == none or outer == none or outer == auto { return inner }
  let a = stroke-fields(outer)
  let b = stroke-fields(inner)
  for key in b.keys() {
    if b.at(key) == auto { b.insert(key, a.at(key)) }
  }
  stroke(..b)
}

#let fold-sides(outer, inner, strokes: false) = {
  let a = sides(outer, default: auto)
  let b = sides(inner, default: auto)
  for key in b.keys() {
    let v = b.at(key)
    b.insert(key, if strokes { fold-stroke(a.at(key), v) }
      else if v == auto { a.at(key) } else { v })
  }
  for key in b.keys() {
    if b.at(key) == auto { let _ = b.remove(key) }
  }
  b
}

#let fold-alignment(outer, inner) = {
  if inner == auto { return outer }
  if outer == auto { return inner }
  let x = if inner.x == none { outer.x } else { inner.x }
  let y = if inner.y == none { outer.y } else { inner.y }
  if x == none { y } else if y == none { x } else { x + y }
}

#let direction() = {
  if text.dir != auto { return repr(text.dir) }
  // The browser can infer the same default from the language on the wrapper.
  if text.lang in ("ar", "ara", "he", "heb", "fa", "fas", "per", "ur", "urd", "ps", "pus", "yi", "yid", "syr", "dv", "div", "ug", "uig", "sd", "snd", "ckb") { "rtl" }
  else { "ltr" }
}

// Quote font family names consistently in text and block metrics.
#let font-css(fonts) = {
  let fonts = if type(fonts) == array { fonts } else { (fonts,) }
  fonts.map(f => {
    let name = if type(f) == dictionary { f.name } else { f }
    "\"" + name.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
  }).join(", ")
}
