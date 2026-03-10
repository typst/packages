// Colors
#let voc-grey = luma(240)
#let voc-grey-light = luma(140)
#let voc-grey-dark = luma(30)
#let voc-blue = color.hsl(210deg, 100%, 90%)
#let voc-blue-light = color.hsl(210deg, 90%, 93%)
#let voc-blue-dark = rgb("223344")
#let voc-green = color.hsl(120deg, 40%, 80%)
#let voc-green-alt = color.hsl(110deg, 35%, 80%)

// Themes
#let themes = (
  light: (
    text: black,
    background: white,
    background-alt: voc-grey,
    accent: voc-grey,
    separator: voc-grey-light,
  ),
  dark: (
    text: white,
    background: black,
    background-alt: luma(20),
    accent: voc-blue-dark,
    separator: voc-grey-dark,
  ),
  blue: (
    text: black,
    background: white,
    background-alt: voc-blue-light,
    accent: voc-blue,
    separator: voc-grey-light,
  ),
  green: (
    text: black,
    background: white,
    background-alt: voc-green,
    accent: voc-green-alt,
    separator: voc-grey-light,
  ),
)


