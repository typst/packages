#let _light-gray = oklch(85%, 0.012, 264.5deg)
#let _medium-gray = oklch(68%, 0.012, 264.5deg)
#let _dark-gray = oklch(37.5%, 0.012, 264.5deg)
#let _yellow = oklch(87.5%, 0.165, 93.9deg)

#let _diverging-gradient = (
  gradient
    .linear(
      rgb("#e50d2e"),
      rgb("#ff553c"),
      rgb("#ff936d"),
      rgb("#fcc1a3"),
      rgb("#dedfe0"),
      rgb("#a4dcf0"),
      rgb("#69c4e5"),
      rgb("#4fa2d5"),
      rgb("#5477ce"),
    )
    .sharp(256)
    .stops()
)
