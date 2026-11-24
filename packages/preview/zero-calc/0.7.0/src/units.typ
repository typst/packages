#let is-unitless(value) = {
  if value.at("unit", default: none) == none or (value.unit.numerator == () and value.unit.denominator == ()) {
    return true
  }
  return false
}

#let units-to-signed-pairs(units) = {
  units = units.filter(x => x != none)
  return (
    units.filter(x => x.numerator != ()).map(x => x.numerator.map(y => (y.at(0), int(y.at(1)))))
      + units.filter(x => x.denominator != ()).map(x => x.denominator.map(y => (y.at(0), int("-" + y.at(1)))))
  ).join(default: ())
}

#let dict-to-unit(pairs) = if pairs == (:) { none } else {
  (
    numerator: pairs.filter(x => x > 0).map(x => str(x)).pairs(),
    denominator: pairs.filter(x => x < 0).map(x => str(-x)).pairs(),
  )
}

#let signed-pairs-to-unit(pairs) = if pairs == (:) { none } else {
  (
    numerator: pairs.filter(x => x.at(1) > 0).map(x => (x.at(0), str(x.at(1)))),
    denominator: pairs.filter(x => x.at(1) < 0).map(x => (x.at(0), str(-x.at(1)))),
  )
}

#let multiply-unit(units) = {
  units = units-to-signed-pairs(units)
  let sum = (:)
  for (unit, exponent) in units {
    let found = sum.at(unit, default: none)
    if found == none {
      sum.insert(unit, exponent)
    } else {
      sum.at(unit) = sum.at(unit) + exponent
    }
  }
  dict-to-unit(sum)
}

#let invert-unit(units) = if units != none { (numerator: units.denominator, denominator: units.numerator) }

#let pow-unit(unit, exponent) = {
  if (unit == none) { return none }
  let pairs = units-to-signed-pairs((unit,)).map(x => (x.at(0), x.at(1) * exponent))
  signed-pairs-to-unit(pairs)
}

#let root-unit(unit, exponent) = {
  if (unit == none) { return none }
  let pairs = units-to-signed-pairs((unit,)).map(x => (x.at(0), x.at(1) / exponent))
  signed-pairs-to-unit(pairs)
}
