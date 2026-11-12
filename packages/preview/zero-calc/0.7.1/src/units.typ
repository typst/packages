#let base-si-units = (
  "A",
  "cd",
  "K",
  "kg",
  "m",
  "mol",
  "s",
)

#let si-conversions = (
  "min": (unit: (numerator: (("s", "1"),), denominator: ()), factor: "60"),
  "h": (unit: (numerator: (("s", "1"),), denominator: ()), factor: "3600"),
  "d": (unit: (numerator: (("s", "1"),), denominator: ()), factor: "86400"),
  "Bq": (unit: (numerator: (), denominator: (("s", "1"),))),
  "Hz": (unit: (numerator: (), denominator: (("s", "1"),))),
  "H": (unit: (numerator: (("kg", "1"), ("m", "2")), denominator: (("s", "2"), ("A", "2")))),
  "J": (unit: (numerator: (("kg", "1"), ("m", "2")), denominator: (("s", "2"),))),
  "N": (unit: (numerator: (("kg", "1"), ("m", "1")), denominator: (("s", "2"),))),
  "Pa": (unit: (numerator: (("kg", "1"),), denominator: (("m", "1"), ("s", "2")))),
  sym.Omega: (unit: (numerator: (("kg", "1"), ("m", "2")), denominator: (("s", "3"), ("A", "2")))),
  "S": (unit: (numerator: (("s", "3"), ("A", "2")), denominator: (("kg", "1"), ("m", "2")))),
  "kat": (unit: (numerator: (("mol", "1"),), denominator: (("s", "1"),))),
  sym.degree + "C": (unit: (numerator: (("K", "1"),), denominator: ()), offset: "273.15"),
  "C": (unit: (numerator: (("A", "1"), ("s", "1")), denominator: ())),
  "Gy": (unit: (numerator: (("m", "2"),), denominator: (("s", "2"),))),
  "F": (unit: (numerator: (("A", "2"), ("s", "4")), denominator: (("kg", "1"), ("m", "2")))),
  "T": (unit: (numerator: (("kg", "1"),), denominator: (("s", "2"), ("A", "1")))),
  "V": (unit: (numerator: (("kg", "1"), ("m", "2")), denominator: (("s", "3"), ("A", "1")))),
  "W": (unit: (numerator: (("kg", "1"), ("m", "2")), denominator: (("s", "3"),))),
  "au": (unit: (numerator: (("m", "1"),), denominator: ()), factor: "149597870700"),
  "Da": (unit: (numerator: (("kg", "1"),), denominator: ()), factor: "1.66053906892e-27"),
  "eV": (unit: (numerator: (("kg", "1"), ("m", "2")), denominator: (("s", "2"),)), factor: "1.602176634e-19"),
  "ha": (unit: (numerator: (("m", "2"),), denominator: ()), factor: "1e4"),
  "L": (unit: (numerator: (("m", "3"),), denominator: ()), factor: "1e-3"),
  "t": (unit: (numerator: (("kg", "1"),), denominator: ()), factor: "1e3"),
  "g": (unit: (numerator: (("kg", "1"),), denominator: ()), factor: "1e-3"),
)

#let is-unitless(value) = {
  if value.at("unit", default: none) == none or (value.unit.numerator == () and value.unit.denominator == ()) {
    return true
  }
  return false
}

#let units-to-signed-pairs(units) = {
  units = units.filter(x => x != none)
  return (
    units.filter(x => x.numerator != ()).map(x => x.numerator.map(y => (y.at(0), float(y.at(1)))))
      + units.filter(x => x.denominator != ()).map(x => x.denominator.map(y => (y.at(0), float("-" + y.at(1)))))
  ).join(default: ())
}

#let dict-to-unit(pairs) = if pairs.values().all(x => x == 0) { none } else {
  (
    numerator: pairs.filter(x => x > 0).map(x => str(x)).pairs(),
    denominator: pairs.filter(x => x < 0).map(x => str(-x)).pairs(),
  )
}

#let unit-to-dict(unit) = if unit == none { (:) } else {
  unit.numerator.to-dict().map(x => float(x)) + unit.denominator.to-dict().map(x => -float(x))
}

#let equal(a, b) = {
  let normalise(unit) = unit-to-dict(unit).pairs().filter(x => x.at(1) != 0).sorted()
  normalise(a) == normalise(b)
}

#let signed-pairs-to-unit(pairs) = if pairs.all(x => x.at(1) == 0) { none } else {
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

#let contains-unit(unit, rule) = {
  for (rule-unit, rule-exponent) in rule {
    let matched-unit = unit.at(rule-unit, default: none)
    if matched-unit == none {
      return false
    }
    if matched-unit * rule-exponent > 0 and calc.abs(matched-unit) >= calc.abs(rule-exponent) {
      continue
    } else {
      return false
    }
  }
  return true
}
