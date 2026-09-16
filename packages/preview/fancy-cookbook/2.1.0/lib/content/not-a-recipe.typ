// =============== Not a Recipe =====================

// a simple part for what is not a recipe
#let not-a-recipe(
  name: none,
  change-palette: none,
  body) = {

  set par(first-line-indent: (amount: 2em, all: true))
  set list(indent: 2em, body-indent: 0.5em)
  
  if name != none {
    heading(level: 2, name)
  }

  if change-palette != none {
    set-palette(change-palette)
  }
  
  v(4em)
  body
}