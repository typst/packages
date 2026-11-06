/// Multi-line bi-colored "pills" (GitLab-style scoped labels) for Typst.
///
/// Renders compact, breakable two-part labels (key/value) with rounded
/// end-caps and a square-cornered, breakable middle that flows naturally
/// across line breaks.

// Private helper: luminance approximation (sRGB luma coefficients on gamma-encoded
// channels — close enough to pick legible ink, not true relative luminance).
#let _lum(c) = {
  let (r, g, b, ..) = rgb(c).components()
  0.2126 * (r / 100%) + 0.7152 * (g / 100%) + 0.0722 * (b / 100%)
}

// Private helper: picks black or white text for legibility on a given background.
#let _ink(bg) = if _lum(bg) > 0.55 { black } else { white }

/// Creates a bi-colored pill (key and value).
///
/// `key` and `value` are positional; everything else (`primary`, `secondary`,
/// `radius`, `outline`, `height`, `drop`) is a named argument. The
/// trailing-block syntax — `#pill("env")[prod]` — passes the block as the
/// `value`.
///
/// -> content
#let pill(
  /// Content for the left (dark) half of the pill. -> content | str
  key,

  /// Content for the right (light) half of the pill. -> content | str
  value,

  /// Background color for the left half. -> color
  primary: rgb("#1f7a8c"),

  /// The right half color, or a ratio to lighten `primary` by.
  ///
  /// ```example
  /// #pill("env", "prod", secondary: 40%) \
  /// #pill("env", "prod", secondary: rgb("#ffd166"))
  /// ```
  /// -> color | ratio
  secondary: 80%,

  /// Corner radius as a fraction of `height`: 100% = fully round ends,
  /// 0% = square ends.
  ///
  /// ```example
  /// #pill("env", "prod", radius: 0%) \
  /// #pill("env", "prod", radius: 30%) \
  /// #pill("env", "prod", radius: 100%)
  /// ```
  /// -> ratio
  radius: 30%,

  /// If `true`, draws a thin outline in the primary color around the pill.
  ///
  /// ```example
  /// #pill("priority", "high", outline: true) \
  /// #pill("priority", "high", outline: false)
  /// ```
  /// -> bool
  outline: true,

  /// Total pill height. You should not normally need to change this. -> length
  height: 1.15em,

  /// How far the fill sits below the baseline. You should not normally need
  /// to change this. -> length
  drop: 0.3em,
) = {
  let left-colour = primary
  let right-colour = if type(secondary) == color {
    secondary
  } else {
    primary.lighten(secondary)
  }

  let top = height - drop
  let r = height * radius
  let bite = r / 1.85
  let edges = (top-edge: top, bottom-edge: -drop)

  let cap(side) = box(
    baseline: drop,
    width: if side == "l" { r - bite } else { r },
    height: height,
    outset: if side == "l" { (right: bite) } else { (:) },
    fill: if side == "l" { left-colour } else { right-colour },
    radius: if side == "l" { (left: r) } else { (right: r) },
    stroke: if outline {
      if side == "l" {
        (left: left-colour, top: left-colour, bottom: left-colour)
      } else {
        (right: left-colour, top: left-colour, bottom: left-colour)
      }
    } else {
      none
    }
  )

  let stroke = if outline {
    (stroke: (top: left-colour, bottom: left-colour))
  } else {
    none
  }

  sym.zws
  cap("l")
  highlight(fill: left-colour, ..edges, ..stroke)[
    #text(_ink(left-colour), hyphenate: true)[#sym.wj#key#sym.wj]
  ]

  highlight(fill: right-colour, ..edges, ..stroke)[
    #text(_ink(right-colour), hyphenate: true)[#sym.wj~#value#sym.wj]
  ]
  cap("r")
  sym.zws
}
