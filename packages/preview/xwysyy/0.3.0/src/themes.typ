// Theme color palettes, shared theme state, and inline highlight macros.

#let themes = (
  sky: (
    sea: rgb("#3b60a0"),
    sky: rgb("#bdd0f1"),
    skyl: rgb("#eff3ff"),
    skyll: rgb("#f4f9ff"),
    paper: rgb("#f5f6f8"),
    header-fill: none,
    header-text: none,
    page-fill: white,
  ),
  sunset: (
    sea: rgb("#970014"),
    sky: rgb("#D8A6A2"),
    skyl: rgb("#fdf0f0"),
    skyll: rgb("#FFF8F6"),
    paper: rgb("#f5f6f8"),
    header-fill: rgb("#F7EEE7"),
    header-text: rgb("#970014"),
    page-fill: rgb("#fffefd"),
  ),
  forest: (
    sea: rgb("#1f5d45"),
    sky: rgb("#a8d5ba"),
    skyl: rgb("#e9f5ee"),
    skyll: rgb("#f5fbf7"),
    paper: rgb("#f7faf8"),
    header-fill: none,
    header-text: none,
    page-fill: white,
  ),
  midnight: (
    sea: rgb("#1f2a44"),
    sky: rgb("#8fa8d8"),
    skyl: rgb("#edf2fb"),
    skyll: rgb("#f7faff"),
    paper: rgb("#f7f8fb"),
    header-fill: none,
    header-text: none,
    page-fill: white,
  ),
  violet: (
    sea: rgb("#5a3e85"),
    sky: rgb("#c7b7e8"),
    skyl: rgb("#f2ecfb"),
    skyll: rgb("#faf7ff"),
    paper: rgb("#f8f6fb"),
    header-fill: rgb("#f1ebf7"),
    header-text: rgb("#4c3473"),
    page-fill: white,
  ),
  graphite: (
    sea: rgb("#31343a"),
    sky: rgb("#b9c0c9"),
    skyl: rgb("#f0f2f4"),
    skyll: rgb("#f8f9fa"),
    paper: rgb("#f7f7f5"),
    header-fill: none,
    header-text: none,
    page-fill: white,
  ),
)

#let _theme-required-fields = (
  "sea",
  "sky",
  "skyl",
  "skyll",
  "paper",
  "header-fill",
  "header-text",
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

#let red(body) = text(fill: rgb("#9c1d11"), body)
#let bred(body) = text(size: 1.1em, stroke: 0.02em + rgb("#9c1d11"), fill: rgb("#9c1d11"), body)
#let yellow(body) = text(fill: rgb("#d9ad20"), body)
#let byellow(body) = text(size: 1.1em, stroke: 0.02em + rgb("#d9ad20"), fill: rgb("#d9ad20"), body)
