// Vibrant palette . saturated teal + magenta on white.
// For teaching, outreach, and any room where energy beats gravitas. Projector-loud.
#let palette = (
  primary: rgb("#0d9488"),
  primary_light: rgb("#ccfbf1"),
  secondary: rgb("#0f766e"),
  on_primary: rgb("#ffffff"),
  accent: rgb("#db2777"),
  accent_deep: rgb("#be185d"),
  ink: rgb("#134e4a"),
  text: rgb("#1c2b2a"),
  text_soft: rgb("#5b6b6a"),
  paper: rgb("#ffffff"),
  paper_bg: rgb("#f0fdfa"),
  hairline: rgb("#99f6e4"),
  success: rgb("#15803d"),
  warning: rgb("#dc2626"),
  neutral_lightest: rgb("#ffffff"),
  neutral_dark: rgb("#5b6b6a"),
  neutral_darkest: rgb("#1c2b2a"),
)

// DejaVu Sans is available in the Typst web app and most Linux installs.
// Override the theme's `font:` argument to use another installed family.
#let fonts = (
  sans: "DejaVu Sans",
  serif: "New Computer Modern",
  math: "New Computer Modern Math",
  mono: "DejaVu Sans Mono",
)
