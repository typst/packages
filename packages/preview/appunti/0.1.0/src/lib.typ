// Internal
#import "i18n.typ": current-language, translate
#import "notes.typ": notes
#import "utils.typ": recolor

// Algorithmic
#import "@preview/algorithmic:1.0.7"
#import algorithmic: *

#let algorithm = algorithm.with(line-numbers-format: x => [#x])
#let algorithm-figure(title, ..args) = context algorithmic.algorithm-figure(
  title,
  supplement: translate(current-language.get()).algorithm,
  line-numbers-format: x => [#x],
  ..args,
)

// Theorion
#import "@preview/theorion:0.6.0": *
