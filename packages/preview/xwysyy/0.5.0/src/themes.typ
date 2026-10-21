// Theme color palettes, shared theme state, and inline highlight macros.

#let themes = (
  sky: (
    sea: rgb("#3b60a0"),
    sky: rgb("#bdd0f1"),
    skyll: rgb("#f4f9ff"),
    paper: rgb("#f5f6f8"),
    page-fill: white,
  ),
  sunset: (
    sea: rgb("#970014"),
    sky: rgb("#D8A6A2"),
    skyll: rgb("#FFF8F6"),
    paper: rgb("#f5f6f8"),
    page-fill: rgb("#fffefd"),
  ),
  forest: (
    sea: rgb("#1f5d45"),
    sky: rgb("#a8d5ba"),
    skyll: rgb("#f5fbf7"),
    paper: rgb("#f7faf8"),
    page-fill: white,
  ),
  midnight: (
    sea: rgb("#1f2a44"),
    sky: rgb("#8fa8d8"),
    skyll: rgb("#f7faff"),
    paper: rgb("#f7f8fb"),
    page-fill: white,
  ),
  violet: (
    sea: rgb("#5a3e85"),
    sky: rgb("#c7b7e8"),
    skyll: rgb("#faf7ff"),
    paper: rgb("#f8f6fb"),
    page-fill: white,
  ),
  graphite: (
    sea: rgb("#31343a"),
    sky: rgb("#b9c0c9"),
    skyll: rgb("#f8f9fa"),
    paper: rgb("#f7f7f5"),
    page-fill: white,
  ),
)

#let _theme-required-fields = (
  "sea",
  "sky",
  "skyll",
  "paper",
  "page-fill",
)

#let _resolve-theme(theme) = {
  if type(theme) == str {
    themes.at(theme)
  } else if type(theme) == dictionary {
    for field in _theme-required-fields {
      if theme.at(field, default: auto) == auto {
        panic("xwysyy-pre theme dictionary is missing field `" + field + "`")
      }
    }
    theme
  } else {
    panic("xwysyy-pre theme must be a string name or a dictionary")
  }
}

// Default theme colors (sky)
#let sea = themes.sky.sea
#let sky = themes.sky.sky
#let skyll = themes.sky.skyll
#let paper = themes.sky.paper

// Theme state for dynamic components
#let _theme-state = state("xwysyy-theme", themes.sky)

// Bold recipe shared by `strong` and the colored bold macros: 1.1em + true
// bold weight, no stroke (stroking fills the CJK glyph counters and looks
// muddy). 0.03em tracking opens the run internally; 0.05em hair spacing on
// both sides keeps it off the neighbors (non-weak: weak spacing would swallow
// adjacent Latin word spaces); the 0.035em baseline drop re-centers the
// enlarged CJK glyphs optically.
#let _bold-run(body, fill: none) = {
  set text(fill: fill) if fill != none
  h(0.05em)
  text(size: 1.1em, weight: 700, tracking: 0.03em, baseline: 0.035em, body)
  h(0.05em)
}
#let red(body) = text(fill: rgb("#9c1d11"), body)
#let bred(body) = _bold-run(body, fill: rgb("#9c1d11"))
#let yellow(body) = text(fill: rgb("#d9ad20"), body)
#let byellow(body) = _bold-run(body, fill: rgb("#d9ad20"))
