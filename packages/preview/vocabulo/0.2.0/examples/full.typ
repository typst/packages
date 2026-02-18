#import "@preview/vocabulo:0.2.0": *

#let words = csv("words.csv")

#let my-theme = (
  text: luma(10),
  background: luma(255),
  background-alt: cmyk(0%, 5%, 10%, 5%),
  accent: cmyk(3%, 5%, 40%, 5%),
  separator: luma(150),
)

#show: vocabulo(
  words,
  ("English", "Deutsch"),
  format: ("remarkable", "paper-pro"),
  flipped: true,
  num-writing-lines: 6,
  bar-pos: "left",
  seed: 42,
  theme: my-theme,
)
