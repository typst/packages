#let thesis_font_size = (
  tiny: 11.3pt,
  small: 12pt,
  normal: 14pt,
  large: 16pt,
  llarge: 18pt,
  lllarge: 24.88pt,
)

#let thesis_font = (
  times: ("Times New Roman"),
  // minglu: ("mingliu"),
  minglu: ("PMingLiU"),
)

#let engfont(s) = {
  set text(font: thesis_font.times)
  s
}

#let chnfont(s) = {
  set text(font: thesis_font.minglu)
  s
}
