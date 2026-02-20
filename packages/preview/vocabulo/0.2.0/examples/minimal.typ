#import "@preview/vocabulo:0.2.0": *

#let words = (
  ("hello", "hallo"),
  ("goodbye", "auf Wiedersehen"),
  ("thank you", "danke"),
  ("please", "bitte"),
)

#show: vocabulo(words, ("English", "Deutsch"))
