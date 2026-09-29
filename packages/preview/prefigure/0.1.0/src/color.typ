// Interpreting the colour strings PreFigure writes into the SVG.
//
// A label's `color` reaches the baked SVG verbatim as a `fill`, where resvg
// reads it as a CSS colour. Native labels are drawn by Typst instead, so this
// file reproduces that same reading — otherwise the two label modes would not
// agree on colour. Accepted, as in CSS Color 4:
//
//   * the 148 CSS/SVG colour names (case-insensitive)
//   * `#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa` hex
//   * `rgb()`/`rgba()`/`hsl()`/`hsla()`, in either the legacy comma syntax or
//     the space + `/`-alpha syntax. PreFigure emits `rgb(r,g,b)` itself for a
//     computed colour (see user_namespace.valid_eval), so this form is not
//     hypothetical.
//   * `none`/`transparent`
//
// Anything else panics rather than falling back to black: a colour PreFigure
// accepted but we cannot read is a bug worth surfacing, not a label silently
// drawn in the wrong colour.
//
// These are deliberately *CSS* readings. PreFigure's own `gray`/`lightgray`/
// `darkgray` overrides (utilities.get_color) apply to shape fills and strokes,
// never to label colours, so a label's `gray` is CSS #808080 here — exactly what
// resvg draws for the baked `<text>`.

// The CSS/SVG named colours, as resvg resolves them.
#let _named = (
  aliceblue: "f0f8ff",
  antiquewhite: "faebd7",
  aqua: "00ffff",
  aquamarine: "7fffd4",
  azure: "f0ffff",
  beige: "f5f5dc",
  bisque: "ffe4c4",
  black: "000000",
  blanchedalmond: "ffebcd",
  blue: "0000ff",
  blueviolet: "8a2be2",
  brown: "a52a2a",
  burlywood: "deb887",
  cadetblue: "5f9ea0",
  chartreuse: "7fff00",
  chocolate: "d2691e",
  coral: "ff7f50",
  cornflowerblue: "6495ed",
  cornsilk: "fff8dc",
  crimson: "dc143c",
  cyan: "00ffff",
  darkblue: "00008b",
  darkcyan: "008b8b",
  darkgoldenrod: "b8860b",
  darkgray: "a9a9a9",
  darkgreen: "006400",
  darkgrey: "a9a9a9",
  darkkhaki: "bdb76b",
  darkmagenta: "8b008b",
  darkolivegreen: "556b2f",
  darkorange: "ff8c00",
  darkorchid: "9932cc",
  darkred: "8b0000",
  darksalmon: "e9967a",
  darkseagreen: "8fbc8f",
  darkslateblue: "483d8b",
  darkslategray: "2f4f4f",
  darkslategrey: "2f4f4f",
  darkturquoise: "00ced1",
  darkviolet: "9400d3",
  deeppink: "ff1493",
  deepskyblue: "00bfff",
  dimgray: "696969",
  dimgrey: "696969",
  dodgerblue: "1e90ff",
  firebrick: "b22222",
  floralwhite: "fffaf0",
  forestgreen: "228b22",
  fuchsia: "ff00ff",
  gainsboro: "dcdcdc",
  ghostwhite: "f8f8ff",
  gold: "ffd700",
  goldenrod: "daa520",
  gray: "808080",
  green: "008000",
  greenyellow: "adff2f",
  grey: "808080",
  honeydew: "f0fff0",
  hotpink: "ff69b4",
  indianred: "cd5c5c",
  indigo: "4b0082",
  ivory: "fffff0",
  khaki: "f0e68c",
  lavender: "e6e6fa",
  lavenderblush: "fff0f5",
  lawngreen: "7cfc00",
  lemonchiffon: "fffacd",
  lightblue: "add8e6",
  lightcoral: "f08080",
  lightcyan: "e0ffff",
  lightgoldenrodyellow: "fafad2",
  lightgray: "d3d3d3",
  lightgreen: "90ee90",
  lightgrey: "d3d3d3",
  lightpink: "ffb6c1",
  lightsalmon: "ffa07a",
  lightseagreen: "20b2aa",
  lightskyblue: "87cefa",
  lightslategray: "778899",
  lightslategrey: "778899",
  lightsteelblue: "b0c4de",
  lightyellow: "ffffe0",
  lime: "00ff00",
  limegreen: "32cd32",
  linen: "faf0e6",
  magenta: "ff00ff",
  maroon: "800000",
  mediumaquamarine: "66cdaa",
  mediumblue: "0000cd",
  mediumorchid: "ba55d3",
  mediumpurple: "9370db",
  mediumseagreen: "3cb371",
  mediumslateblue: "7b68ee",
  mediumspringgreen: "00fa9a",
  mediumturquoise: "48d1cc",
  mediumvioletred: "c71585",
  midnightblue: "191970",
  mintcream: "f5fffa",
  mistyrose: "ffe4e1",
  moccasin: "ffe4b5",
  navajowhite: "ffdead",
  navy: "000080",
  oldlace: "fdf5e6",
  olive: "808000",
  olivedrab: "6b8e23",
  orange: "ffa500",
  orangered: "ff4500",
  orchid: "da70d6",
  palegoldenrod: "eee8aa",
  palegreen: "98fb98",
  paleturquoise: "afeeee",
  palevioletred: "db7093",
  papayawhip: "ffefd5",
  peachpuff: "ffdab9",
  peru: "cd853f",
  pink: "ffc0cb",
  plum: "dda0dd",
  powderblue: "b0e0e6",
  purple: "800080",
  rebeccapurple: "663399",
  red: "ff0000",
  rosybrown: "bc8f8f",
  royalblue: "4169e1",
  saddlebrown: "8b4513",
  salmon: "fa8072",
  sandybrown: "f4a460",
  seagreen: "2e8b57",
  seashell: "fff5ee",
  sienna: "a0522d",
  silver: "c0c0c0",
  skyblue: "87ceeb",
  slateblue: "6a5acd",
  slategray: "708090",
  slategrey: "708090",
  snow: "fffafa",
  springgreen: "00ff7f",
  steelblue: "4682b4",
  tan: "d2b48c",
  teal: "008080",
  thistle: "d8bfd8",
  tomato: "ff6347",
  turquoise: "40e0d0",
  violet: "ee82ee",
  wheat: "f5deb3",
  white: "ffffff",
  whitesmoke: "f5f5f5",
  yellow: "ffff00",
  yellowgreen: "9acd32",
)

// A CSS <number> (no unit, no exponent — CSS colours never use one).
#let _number = regex("^[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)$")

// Split a functional colour's argument list. Commas, whitespace and the CSS 4
// alpha slash all separate, so `255,0,0` and `255 0 0 / 50%` tokenize alike.
// (Kept on one line: Typst ends an expression at a newline, so a method chain
// broken across lines silently drops everything after the first line.)
#let _args(inner) = {
  let flat = inner.replace(",", " ").replace("/", " ")
  flat.split(" ").map(t => t.trim()).filter(t => t != "")
}

// One channel as a fraction of its range: `50%` and — with `full: 255` — `127.5`
// both give 0.5. `src` is the whole colour string, for the error message.
#let _frac(tok, full, src) = {
  let pct = tok.ends-with("%")
  let digits = if pct { tok.slice(0, -1) } else { tok }
  assert(
    digits.match(_number) != none,
    message: "prefigure: cannot read colour \""
      + src
      + "\": \""
      + tok
      + "\" is not a number",
  )
  float(digits) / (if pct { 100.0 } else { full })
}

// `hsl()`'s hue. Bare numbers are degrees; `grad` is tested before `rad`, which
// it ends with.
#let _hue(tok, src) = {
  let units = (
    (suffix: "turn", unit: 360deg),
    (suffix: "grad", unit: 0.9deg),
    (suffix: "deg", unit: 1deg),
    (suffix: "rad", unit: 1rad),
  )
  for u in units {
    if tok.ends-with(u.suffix) {
      return _frac(tok.slice(0, -u.suffix.len()), 1.0, src) * u.unit
    }
  }
  _frac(tok, 1.0, src) * 1deg
}

// Read a PreFigure/SVG colour string as a Typst colour.
#let css-color(s) = {
  if s == none { return black }
  let src = s.trim()
  if src == "" { return black }
  let key = lower(src)

  if key in _named { return rgb(_named.at(key)) }
  if src.starts-with("#") { return rgb(src) }
  // A fill of `none` draws nothing; the equivalent for text is full transparency.
  if key == "none" or key == "transparent" { return rgb(0, 0, 0, 0) }

  let parts = src.split("(")
  if parts.len() == 2 and src.ends-with(")") {
    let func = lower(parts.at(0).trim())
    let args = _args(parts.at(1).slice(0, -1))
    let named = (rgb: 3, rgba: 4, hsl: 3, hsla: 4)
    if func in named {
      // The legacy `rgba`/`hsla` spellings differ from `rgb`/`hsl` only in that
      // CSS required the alpha; both accept 3 or 4 arguments here.
      assert(
        args.len() == 3 or args.len() == 4,
        message: "prefigure: cannot read colour \""
          + src
          + "\": "
          + func
          + "() takes 3 or 4 "
          + "arguments, got "
          + str(args.len()),
      )
      let alpha = if args.len() == 4 { _frac(args.at(3), 1.0, src) } else {
        1.0
      }
      if func == "rgb" or func == "rgba" {
        let c = args.slice(0, 3).map(t => _frac(t, 255.0, src) * 100%)
        return rgb(..c, alpha * 100%)
      }
      return color.hsl(
        _hue(args.at(0), src),
        _frac(args.at(1), 100.0, src) * 100%,
        _frac(args.at(2), 100.0, src) * 100%,
        alpha * 100%,
      )
    }
  }

  panic(
    "prefigure: unrecognised colour \""
      + s
      + "\" — expected a CSS colour name, "
      + "#hex, or rgb()/rgba()/hsl()/hsla()",
  )
}
