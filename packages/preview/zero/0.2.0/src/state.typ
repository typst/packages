#let default-state = (
  digits: auto,
  fixed: none,
  product: sym.times,
  decimal-separator: ".",
  tight: false,
  omit-unity-mantissa: false,
  positive-sign: false,
  positive-sign-exponent: false,
  base: 10,
  uncertainty-mode: "separate",
  math: true,
  group: (
    size: 3, 
    separator: sym.space.thin,
    threshold: 5
  ),
  round: (
    mode: none,
    precision: 2,
    pad: true,
    direction: "nearest",
  )
)
#let num-state = state("num-state", default-state)

#let group-state = state("group-state", default-state.group)

#let round-state = state("round-state", default-state.round)

