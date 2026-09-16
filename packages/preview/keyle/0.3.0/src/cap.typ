// Layered keycap factories.
//
// keyle has exactly two orthogonal axes: a *theme* (how a key is drawn) and a
// *sym* (what glyph is drawn). A theme is nothing more than one of the factory
// functions below with its styling pre-bound via Typst's native `.with(...)`,
// taking the key symbol as its last positional argument. Users extend any
// preset the very same way, e.g. `keyle.themes.flat.with(fill: red)`.
//
// Two layers are kept strictly separate:
//   - the *text layer*  -> `text-args` (spread into `text`) and `wrap`
//   - the *cap layer*   -> geometry and colors of the key shell

/// Coerce a number (treated as points) or a length into a length.
/// -> length
#let _len(v) = if type(v) == length { v } else { float(v) * 1pt }

/// Text layer: turn a key symbol into styled content.
///
/// `wrap` may be any `content -> content` function, so builtin transforms can
/// be passed directly, e.g. `wrap: smallcaps` or `wrap: upper`.
/// -> content
#let style-text(
  /// The key symbol. -> any
  sym,
  /// Arguments spread into `text`. -> dictionary
  args: (:),
  /// Content transform applied after styling. -> function
  wrap: it => it,
) = wrap(text(..args, sym))

/// Keycap factory using vector rectangles (the rect backend).
///
/// Bind styling with `.with(...)` to obtain a theme renderer `sym => content`.
/// -> content
#let keycap(
  /// Face fill color. -> color
  fill: rgb("#eeeeee"),
  /// Face border. -> stroke
  stroke: rgb("#555555") + 0.6pt,
  /// Corner radius. -> length | ratio
  radius: 2pt,
  /// Inner padding around the symbol. -> length | dictionary
  inset: (x: 3pt, y: 2.5pt),
  /// Diagonal drop-shadow extent; `0pt` renders a flat cap. -> length
  raise: 1.2pt,
  /// Shadow color, or `none` to disable. -> color | none
  shadow: rgb("#555555"),
  /// Baseline shift of the cap relative to surrounding text. -> length | ratio
  baseline: 0.1em,
  /// Text layer arguments spread into `text`. -> dictionary
  text-args: (fill: black),
  /// Text layer content transform. -> function
  wrap: it => it,
  /// The key symbol. -> any
  sym,
) = {
  let body = style-text(sym, args: text-args, wrap: wrap)
  let face = rect(inset: inset, radius: radius, stroke: stroke, fill: fill, body)
  let r = _len(raise)
  box(
    baseline: baseline,
    inset: (right: r, bottom: r),
    if r == 0pt or shadow == none {
      face
    } else {
      // Same-size block offset diagonally -> a solid bottom-right drop shadow.
      let lip = rect(inset: inset, radius: radius, fill: shadow, stroke: shadow + 0.6pt, hide(body))
      place(dx: r, dy: r, lip)
      face
    },
  )
}

/// Build a parameterized keycap SVG (pure vector, no `<foreignObject>`).
/// All sizes are in points; colors are CSS hex strings or `none`.
/// -> bytes
#let _rect(x, y, w, h, r, fill, stroke: none, sw: 0) = {
  let s = "<rect x='" + str(x) + "' y='" + str(y) + "' width='" + str(w) + "' height='" + str(h) + "' rx='" + str(r) + "' fill='" + fill + "'"
  if stroke != none {
    s = s + " stroke='" + stroke + "' stroke-width='" + str(sw) + "'"
  }
  s + "/>"
}

#let _keycap-svg(w, h, fill, stroke, stroke-width, radius, lip, shadow) = {
  let x = stroke-width / 2
  let iw = w - stroke-width
  let head = "<svg xmlns='http://www.w3.org/2000/svg' width='" + str(w) + "' height='" + str(h) + "' viewBox='0 0 " + str(w) + " " + str(h) + "'>"
  let back = if shadow != none and lip > 0 {
    _rect(x, x, iw, h - stroke-width, radius, shadow)
  } else { "" }
  let face = _rect(x, x, iw, h - stroke-width - lip, radius, fill, stroke: stroke, sw: stroke-width)
  bytes(head + back + face + "</svg>")
}

/// Keycap factory using a generated SVG shell (the svg backend).
///
/// The SVG is stretched to the measured symbol size so corners never distort.
/// Bind styling with `.with(...)` to obtain a theme renderer `sym => content`.
/// -> content
#let svg-keycap(
  /// Face fill color. -> color
  fill: rgb("#f3f4f6"),
  /// Face border color. -> color
  stroke: rgb("#d1d5db"),
  /// Border width in points. -> float
  stroke-width: 1.2,
  /// Corner radius in points. -> float
  radius: 6,
  /// Bottom shadow lip height in points. -> float
  lip: 3,
  /// Shadow color, `auto` to derive from `stroke`, or `none`. -> color | auto | none
  shadow: auto,
  /// Inner padding around the symbol. -> dictionary
  pad: (x: 6pt, y: 3.5pt),
  /// Baseline shift of the cap relative to surrounding text. -> length | ratio
  baseline: 0.3em,
  /// Text layer arguments spread into `text`. -> dictionary
  text-args: (fill: rgb("#1f2937"), weight: "semibold"),
  /// Text layer content transform. -> function
  wrap: it => it,
  /// The key symbol. -> any
  sym,
) = {
  let body = style-text(sym, args: text-args, wrap: wrap)
  let shadow-c = if shadow == auto { stroke } else { shadow }
  let shadow-hex = if shadow == none { none } else { shadow-c.to-hex() }
  context {
    let m = measure(body)
    let lip-len = lip * 1pt
    let w = (m.width + 2 * pad.x) / 1pt
    let h = (m.height + 2 * pad.y + lip-len) / 1pt
    let svg = _keycap-svg(w, h, fill.to-hex(), stroke.to-hex(), stroke-width, radius, lip, shadow-hex)
    box(baseline: baseline, width: w * 1pt, height: h * 1pt, {
      place(image(svg, format: "svg", width: w * 1pt, height: h * 1pt))
      place(center + horizon, dy: -lip-len / 2, body)
    })
  }
}
