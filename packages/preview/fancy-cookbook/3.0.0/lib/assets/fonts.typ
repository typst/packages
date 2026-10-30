#let fonts = (
  body: ("PT Serif", "New Computer Modern"),
  header: ("PT Sans", "Libertinus Serif", "Harano Aji Mincho"),
  mono: ("JetBrainsMono NF", "Courier New"),
)

#let fonts-state = state("fonts", fonts)

#let set-fonts-state(fonts) = {
  fonts-state.update(fonts)
}