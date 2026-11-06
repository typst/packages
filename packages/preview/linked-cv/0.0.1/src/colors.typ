#let colors = (
  white: rgb("#FFFFFF"),
  black: rgb("#000000"),
  darkgray: rgb("#333333"),
  gray: rgb("#5D5D5D"),
  lightgray: rgb("#999999"),

  darktext: rgb("#111111"),
  text: rgb("#555555"),
  graytext: rgb("#999999"),
  lighttext: rgb("#BBBBBB"),

  lightbackground: rgb("#EEEEEE"),
  darkbackground: rgb("#CCCCCC"),

  awesome: rgb("#6694A5"),
  awesome-subsection: rgb("#6694A5").darken(30%),

  monokai-pink: rgb("#ff6188"),
  monokai-orange: rgb("#fc9867"),
  monokai-yellow: rgb("#ffd866"),
  monokai-green: rgb("#a9dc76"),
  monokai-blue: rgb("#78dce8"),
  monokai-purple: rgb("#ab9df2"),
)

#let get-color(name) = colors.at(name)
