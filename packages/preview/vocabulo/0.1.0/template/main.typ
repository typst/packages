#import "@preview/vocabulo:0.1.0": *

#let words = (
  ("hello", "hallo"),
  ("goodbye", "auf Wiedersehen"),
)

#show: vocabulo(words, ("English", "German"))
