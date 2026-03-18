#let default-state = (
  // Mantissa and uncertainty:
  digits: auto,
  decimal-separator: ".",
  omit-unity-mantissa: false,
  uncertainty-mode: "separate",
  positive-sign: false,
  tight: false,
  math: true,
  // Power:
  product: sym.times,
  positive-sign-exponent: false,
  base: 10,
  fixed: none,
  exponent: auto,
  group: (
    size: 3,
    separator: sym.space.thin,
    threshold: 5,
  ),
  round: (
    mode: "places",
    precision: none,
    pad: true,
    direction: "nearest",
    ties: "away-from-zero",
  ),
  unit: (
    unit-separator: sym.space.thin,
    fraction: "power",
    breakable: false,
    use-sqrt: true,
    prefix: auto,
    lowercase-liter: false,
  ),
)

#let num-state = state("num-state", default-state)


#let update-num-state(state, args) = {
  if "round" in args {
    state.round += args.round
    args.remove("round")
  }
  if "group" in args {
    state.group += args.group
    args.remove("group")
  }
  if "unit" in args {
    state.unit += args.unit
    args.remove("unit")
  }
  return state + args
}
