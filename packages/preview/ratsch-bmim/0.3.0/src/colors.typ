#let color = (
  link: rgb(118, 50, 55),
  blue: rgb(0, 53, 103),
  gray: rgb(156, 156, 156),
  grey: rgb("717788"),
  green: rgb("006e43"),
  purple: rgb("55488e"),
  red: rgb("961842"),
  yellow: rgb("b98900"),
)

#let color-theme = (
  blue:
  (
    primary: color.blue,
    highlight: color.blue.lighten(20%),
    lolight: color.blue.lighten(80%),
    secondary: color.red,
    background: white,
    neutral-lightest: white,
  )
)

