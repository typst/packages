// Theme color palettes, shared theme state, and inline highlight macros.

#let themes = (
  sky: (
    sea: rgb("#3b60a0"),
    sky: rgb("#bdd0f1"),
    skyl: rgb("#eff3ff"),
    skyll: rgb("#f4f9ff"),
    paper: rgb("#f5f6f8"),
    header-text: none,
    page-fill: white,
  ),
  sunset: (
    sea: rgb("#970014"),
    sky: rgb("#D8A6A2"),
    skyl: rgb("#fdf0f0"),
    skyll: rgb("#FFF8F6"),
    paper: rgb("#f5f6f8"),
    header-text: none,
    page-fill: rgb("#fffefd"),
  ),
  forest: (
    sea: rgb("#1f5d45"),
    sky: rgb("#a8d5ba"),
    skyl: rgb("#e9f5ee"),
    skyll: rgb("#f5fbf7"),
    paper: rgb("#f7faf8"),
    header-text: none,
    page-fill: white,
  ),
  midnight: (
    sea: rgb("#1f2a44"),
    sky: rgb("#8fa8d8"),
    skyl: rgb("#edf2fb"),
    skyll: rgb("#f7faff"),
    paper: rgb("#f7f8fb"),
    header-text: none,
    page-fill: white,
  ),
  violet: (
    sea: rgb("#5a3e85"),
    sky: rgb("#c7b7e8"),
    skyl: rgb("#f2ecfb"),
    skyll: rgb("#faf7ff"),
    paper: rgb("#f8f6fb"),
    header-text: none,
    page-fill: white,
  ),
  graphite: (
    sea: rgb("#31343a"),
    sky: rgb("#b9c0c9"),
    skyl: rgb("#f0f2f4"),
    skyll: rgb("#f8f9fa"),
    paper: rgb("#f7f7f5"),
    header-text: none,
    page-fill: white,
  ),
)

// `header-text` is optional: it overrides the open-header title color (default sea).
#let _theme-required-fields = (
  "sea",
  "sky",
  "skyl",
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
#let skyl = themes.sky.skyl
#let skyll = themes.sky.skyll
#let paper = themes.sky.paper

// Theme state for dynamic components
#let _theme-state = state("xwysyy-theme", themes.sky)

// Bold color macros share the strong recipe: 1.1em + true bold weight +
// 0.03em internal tracking + 0.05em hair side spacing (non-weak) + 0.035em
// baseline drop for CJK optical centering, no stroke.
#let _bold-run(c, body) = {
  h(0.05em)
  text(size: 1.1em, weight: 700, tracking: 0.03em, baseline: 0.035em, fill: c, body)
  h(0.05em)
}
#let red(body) = text(fill: rgb("#9c1d11"), body)
#let bred(body) = _bold-run(rgb("#9c1d11"), body)
#let yellow(body) = text(fill: rgb("#d9ad20"), body)
#let byellow(body) = _bold-run(rgb("#d9ad20"), body)
