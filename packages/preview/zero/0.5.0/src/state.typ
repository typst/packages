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
    mode: "places",
    precision: none,
    pad: true,
    direction: "nearest",
  ),
  unit: (
    unit-separator: sym.space.thin,
    fraction: "power",
    breakable: false,
    use-sqrt: true
  )
)
#let num-state = state("num-state", default-state)




#let update-num-state(state, args) = {
  if "round" in args { state.round += args.round; args.remove("round") }
  if "group" in args { state.group += args.group; args.remove("group") }
  if "unit" in args { state.unit += args.unit; args.remove("unit") }
  return state + args
}