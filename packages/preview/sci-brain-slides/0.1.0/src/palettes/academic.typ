// Academic palette . restrained navy on white.
// The conference-talk default: serious, projector-safe, prints well in greyscale.
#let palette = (
  primary: rgb("#2f2f7f"),
  primary_light: rgb("#e8e2f4"),
  secondary: rgb("#4d4da3"),
  on_primary: rgb("#ffffff"),
  accent: rgb("#9b83ec"),
  accent_deep: rgb("#7c5fdc"),
  ink: rgb("#2f2f7f"),
  text: rgb("#1c1c2e"),
  text_soft: rgb("#56566e"),
  paper: rgb("#ffffff"),
  paper_bg: rgb("#f7f7fb"),
  hairline: rgb("#d4d4de"),
  success: rgb("#2e7d32"),
  warning: rgb("#c62828"),
  neutral_lightest: rgb("#ffffff"),
  neutral_dark: rgb("#56566e"),
  neutral_darkest: rgb("#1c1c2e"),
)

// DejaVu Sans is available in the Typst web app and most Linux installs.
// Override the theme's `font:` argument to use another installed family.
#let fonts = (
  sans: "DejaVu Sans",
  serif: "New Computer Modern",
  math: "New Computer Modern Math",
  mono: "DejaVu Sans Mono",
)
