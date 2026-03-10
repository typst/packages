#import "@preview/phonokit:0.3.7": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))

#autoseg(
  ("e", "b", "e"),
  features: ("L", "", "H"),
  spacing: 0.5,
  tone: true,
  baseline: 50%,
  gloss: [],
)
#a-r
#autoseg(
  ("e", "b", "e"),
  features: ("L", "", "H"),
  links: ((0, 2),),
  spacing: 0.5,
  baseline: 50%,
  tone: true,
  gloss: [èbě _pumpkin_],
)

