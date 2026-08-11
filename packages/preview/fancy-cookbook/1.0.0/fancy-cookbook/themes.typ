// =============== Colors ===================
// -------------- Themes --------------------
#let theme-grey = (
  dark: rgb("#757575"),
  medium: rgb("#bdbdbd"),
  light: rgb("#F9F9F9")
)

#let theme-blue = (
  dark: rgb("#2171b5"),
  medium: rgb("#6baed6"),
  light: rgb("#deebf7")
)

#let theme-green = (
  dark: rgb("#238b45"),
  medium: rgb("#74c476"),
  light: rgb("#e5f5e0")
)

#let theme-purple = (
  dark: rgb("#756bb1"),
  medium: rgb("#9e9ac8"),
  light: rgb("#efedf5")
)

#let theme-orange = (
  dark: rgb("#e6550d"),
  medium: rgb("#fd8d3c"),
  light: rgb("#feedde")
)

#let theme-teal = (
  dark: rgb("#1c9099"),
  medium: rgb("#67c2c4"),
  light: rgb("#e5f5f9"),
)

#let theme-pink = (
  dark: rgb("#c51b8a"),
  medium: rgb("#fa9fb5"),
  light: rgb("#fde0dd")
)

#let theme-brown = (
  dark: rgb("#8c510a"),
  medium: rgb("#bf812d"),
  light: rgb("#f6e8c3")
)

#let theme-indigo = (
  dark: rgb("#3f007d"),
  medium: rgb("#807dba"),
  light: rgb("#efedf5")
)

#let theme-lime = (
  dark: rgb("#4d9221"),
  medium: rgb("#a6d96a"),
  light: rgb("#f7fcb9")
)

#let themes = (
  grey : theme-grey,
  blue: theme-blue,
  green: theme-green,
  purple: theme-purple,
  orange: theme-orange,
  teal: theme-teal,
  pink: theme-pink,
  brown: theme-brown,
  indigo: theme-indigo,
  lime: theme-lime
)

// ------------------------ Gears of colors --------------------------

// this state will get the current color theme
#let theme-state = state("theme", theme-grey)

#let set-theme(theme) = {
  theme-state.update(theme)
}

#let style = (
  flat: "flat",
  gradient: "gradient"
)

// this state will get the style of the ingredients block "flat" or "gradient"
#let style-state = state("style", style.flat)

#let set-style(style) = {
  style-state.update(style)
}

// color to fill the ingredients block
#let fill-ingredients(style, theme) = {
  if style == "gradient" {
    gradient.linear(theme.medium,theme.light, angle: 90deg)
  } else {
    theme.light
  }
}


// color for the group text of the ingredients block
#let ingredient-group-color(style, theme) = {
  if style == "gradient" {
    theme.dark.darken(30%)
  } else {
    theme.dark
  }
}