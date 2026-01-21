#import "defs/units.typ"
#import "defs/prefixes.typ"
#import "impl/impl.typ"
#import "utils.typ": combine-dict

#let _state-default = (
  units: units._dict,
  prefixes: prefixes._dict,
  prefix-power-tens: prefixes._power-tens,
  powers: (
    square: impl.raiseto([2]),
    cubic: impl.raiseto([3]),
    squared: impl.tothe([2]),
    cubed: impl.tothe([3])
  ),
  qualifiers: (:),


  // quantites
  times: sym.dot,

  // Unit

  // Num

  allow-breaks: false,

  delimiter: " ",
)

#let _state = state("metro-setup", _state-default)

#let metro-reset() = _state.update(_ => return _state-default)

#let metro-setup(..options) = _state.update(s => {
  return combine-dict(options.named(), s)
})

#let declare-unit(unt, symbol) = _state.update(s => {
  s.units.insert(unt, symbol)
  return s
})

#let create-prefix = math.class.with("unary")

#let declare-prefix(prefix, symbol, power-tens) = _state.update(s => {
  s.prefixes.insert(prefix, symbol)
  s.prefix-power-tens.insert(prefix, power-tens)
  return s
})

#let declare-power(before, after, power) = _state.update(s => {
  s.powers.insert(before, impl.raiseto([#power]))
  s.powers.insert(after, impl.tothe([#power]))
  return s
})

#let declare-qualifier(quali, symbol) = _state.update(s => {
  s.qualifiers.insert(quali, impl.qualifier(symbol))
  return s
})


#let unit(input, ..options) = _state.display(s => {
  return impl.unit(input, ..combine-dict(options.named(), s))
})

#let num(number, e: none, pm: none, pw: none, ..options) = _state.display(s => {
  return (impl.num(number, exponent: e, uncertainty: pm, power: pw, ..combine-dict(options.named(), s)))
})


#let qty(
  number, 
  units, 
  e: none, 
  pm: none,
  pw: none,
  ..options
) = _state.display(s => {
  return impl.qty(
    number,
    units,
    e: e,
    pm: pm,
    pw: pw,
    ..combine-dict(options.named(), s)
  )
})