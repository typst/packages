#let base-colours = (
  primary: rgb("#003C57"),
  secondary: rgb("#006931"),
  neutral-light: rgb("#fafafa"),
  neutral-dark: rgb("#23373b"),
)

#let colour = (
  ..base-colours,
  primary-light: base-colours.primary.lighten(50%),
  dev: rgb("#ec4899"),
)