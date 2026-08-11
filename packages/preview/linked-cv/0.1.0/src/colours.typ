#let colours = (
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

  accent: rgb("#6694A5"),
)

#let get-colour(name) = colours.at(name)

#let accent-colour-state = state("accent-colour", colours.accent)
#let get-accent-colour() = accent-colour-state.get()
#let set-accent-colour(colour) = {
  accent-colour-state.update(s => colour)
}
