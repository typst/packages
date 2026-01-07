#import "@preview/phonokit:0.3.0": *

#autoseg(
  ("e", "b", "e"),
  features: ("L", "", "H"),
  spacing: 0.5,
  tone: true,
  baseline: 50%,
  gloss: [èbě],
)
#a-r
#autoseg(
  ("e", "b", "e"),
  features: ("L", "", "H"),
  links: ((0, 2),),
  spacing: 0.5,
  baseline: 50%,
  tone: true,
  gloss: [ _pumpkin_],
)

