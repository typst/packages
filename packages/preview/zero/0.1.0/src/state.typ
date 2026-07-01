
#let num-state = state("num-state", (
  digits: auto,
  fixed: none,
  product: sym.times,
  decimal-separator: ".",
  tight: false,
  omit-unity-mantissa: false,
  positive-sign: false,
  positive-sign-exponent: false,
  base: 10,
  uncertainty-mode: "separate"
))

#let group-state = state("group-state", (
  size: 3, 
  separator: sym.space.thin,
  threshold: 5
))

#let round-state = state("round-state", (
  mode: none,
  precision: 2,
  pad: true,
  direction: "nearest",
))

