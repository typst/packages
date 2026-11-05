// Minimal palette . pure black ink on white, single grey rule.
// For handouts, lecture notes printed as slides, and venues that punish decoration.
#let palette = (
  primary: rgb("#111111"),
  primary_light: rgb("#ececec"),
  secondary: rgb("#444444"),
  on_primary: rgb("#ffffff"),
  accent: rgb("#555555"),
  accent_deep: rgb("#222222"),
  ink: rgb("#111111"),
  text: rgb("#111111"),
  text_soft: rgb("#555555"),
  paper: rgb("#ffffff"),
  paper_bg: rgb("#fafafa"),
  hairline: rgb("#cccccc"),
  success: rgb("#1a7a32"),
  warning: rgb("#9a2222"),
  neutral_lightest: rgb("#ffffff"),
  neutral_dark: rgb("#555555"),
  neutral_darkest: rgb("#111111"),
)

// DejaVu Sans is available in the Typst web app and most Linux installs.
// Override the theme's `font:` argument to use another installed family.
#let fonts = (
  sans: "DejaVu Sans",
  serif: "New Computer Modern",
  math: "New Computer Modern Math",
  mono: "DejaVu Sans Mono",
)
