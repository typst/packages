// theme.typ - Theme system for chartypst

// Default theme — flat keys, no nesting
#let default-theme = (
  palette: (
    rgb("#4e79a7"),
    rgb("#f28e2b"),
    rgb("#e15759"),
    rgb("#76b7b2"),
    rgb("#59a14f"),
    rgb("#edc948"),
    rgb("#b07aa1"),
    rgb("#ff9da7"),
    rgb("#9c755f"),
    rgb("#bab0ac"),
  ),
  title-size: 11pt,
  title-weight: "bold",
  axis-label-size: 7pt,
  axis-title-size: 8pt,
  legend-size: 8pt,
  value-label-size: 8pt,
  axis-stroke: 0.5pt + black,
  axis-padding-left: 40pt,
  axis-padding-bottom: 20pt,
  axis-padding-top: 10pt,
  axis-padding-right: 10pt,
  tick-count: 5,
  number-format: "auto",
  grid-stroke: 0.5pt + luma(230),
  show-grid: false,
  legend-position: "bottom",
  legend-swatch-size: 10pt,
  legend-gap: 10pt,
  title-gap: 5pt,
  text-color: black,
  text-color-light: gray,
  text-color-inverse: white,
  background: none,
  border: none,
)

/// Merges a user's partial theme dictionary onto the default theme.
///
/// - user-theme (none, dictionary): Partial theme overrides; `none` returns the default theme
/// -> dictionary
#let resolve-theme(user-theme) = {
  if user-theme == none {
    return default-theme
  }
  let result = (:)
  for (key, val) in default-theme {
    if key in user-theme {
      result.insert(key, user-theme.at(key))
    } else {
      result.insert(key, val)
    }
  }
  result
}

/// Returns a color from the theme palette, cycling if the index exceeds palette length.
///
/// - theme (dictionary): Resolved theme dictionary
/// - index (int): Color index (wraps around via modulo)
/// -> color
#let get-color(theme, index) = {
  let pal = theme.palette
  pal.at(calc.rem(index, pal.len()))
}

// --- Named preset themes ---

#let minimal-theme = {
  let t = (:)
  for (key, val) in default-theme {
    t.insert(key, val)
  }
  t.insert("axis-stroke", 0.3pt + luma(150))
  t.insert("grid-stroke", 0.3pt + luma(240))
  t.insert("show-grid", true)
  t.insert("title-size", 10pt)
  t.insert("title-weight", "regular")
  t.insert("border", none)
  t
}

#let dark-theme = {
  let t = (:)
  for (key, val) in default-theme {
    t.insert(key, val)
  }
  t.insert("background", rgb("#1a1a2e"))
  t.insert("palette", (
    rgb("#00d2ff"),
    rgb("#ff6b6b"),
    rgb("#c56cf0"),
    rgb("#ffdd59"),
    rgb("#0be881"),
    rgb("#ff9f43"),
    rgb("#48dbfb"),
    rgb("#ff6348"),
    rgb("#1dd1a1"),
    rgb("#f368e0"),
  ))
  t.insert("axis-stroke", 0.5pt + rgb("#cccccc"))
  t.insert("grid-stroke", 0.5pt + rgb("#333355"))
  t.insert("text-color", rgb("#e0e0e0"))
  t.insert("text-color-light", rgb("#888899"))
  t.insert("text-color-inverse", rgb("#1a1a2e"))
  t
}

#let presentation-theme = {
  let t = (:)
  for (key, val) in default-theme {
    t.insert(key, val)
  }
  t.insert("title-size", 14pt)
  t.insert("axis-label-size", 9pt)
  t.insert("axis-title-size", 10pt)
  t.insert("legend-size", 10pt)
  t.insert("value-label-size", 10pt)
  t.insert("legend-swatch-size", 12pt)
  t
}

#let print-theme = {
  let t = (:)
  for (key, val) in default-theme {
    t.insert(key, val)
  }
  t.insert("palette", (
    luma(40),
    luma(90),
    luma(140),
    luma(180),
    luma(60),
    luma(110),
    luma(160),
    luma(200),
    luma(80),
    luma(130),
  ))
  t.insert("show-grid", true)
  t.insert("grid-stroke", 0.4pt + luma(200))
  t
}

#let accessible-theme = {
  let t = (:)
  for (key, val) in default-theme {
    t.insert(key, val)
  }
  t.insert("palette", (
    rgb("#E69F00"),
    rgb("#56B4E9"),
    rgb("#009E73"),
    rgb("#F0E442"),
    rgb("#0072B2"),
    rgb("#D55E00"),
    rgb("#CC79A7"),
    rgb("#000000"),
  ))
  t
}

#let themes = (
  default: default-theme,
  minimal: minimal-theme,
  dark: dark-theme,
  presentation: presentation-theme,
  print: print-theme,
  accessible: accessible-theme,
)
