#import "@preview/zero:0.7.0"
#import "units.typ"
#import "utility.typ": (
  as-float, as-round, as-uncertainty, create-info, get-e, get-places, get-sig-figs, normalise-constant,
  normalise-quantity, rss,
)

#let const = normalise-constant
#let pi = normalise-constant(calc.pi)
#let e = normalise-constant(calc.e)
#let tau = normalise-constant(calc.tau)
#let inf = normalise-constant(calc.inf)

#let add(terms) = {
  let unit = terms.first().at("unit", default: none)
  assert(terms.all(x => x.at("unit", default: none) == unit), message: "All parameters must have the same unit.")
  let sum = terms.map(as-float).sum()
  let error = rss(terms.map(as-uncertainty))
  let target-e = get-e(terms, sum, "highest")
  return (
    float: sum,
    uncertainty: error,
    info: create-info(sum, error, target-e),
    round: get-places(
      terms.filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))),
      target-e,
    ),
    unit: unit,
    constant: terms.all(x => x.at("constant", default: false)),
    source: (head: "add", data: terms),
  )
}

#let sub(a, terms) = {
  let unit = a.at("unit", default: none)
  if type(terms) != array { terms = (terms,) }
  assert(terms.all(x => x.at("unit", default: none) == unit), message: "All parameters must have the same unit.")
  let negative-terms = terms.map(x => {
    if x.at("float", default: none) != none { x.float = -x.float }
    x.info.sign = if x.info.sign == "-" { "+" } else { "-" }
    x
  })
  let result = add((a,) + negative-terms)
  result.source = (head: "sub", data: (a, terms))
  return result
}

#let neg(term) = {
  term.info.sign = if term.info.sign == "-" { "+" } else { "-" }
  return (
    float: -as-float(term),
    uncertainty: as-uncertainty(term),
    info: term.info,
    round: as-round(term),
    unit: term.at("unit", default: none),
    constant: term.at("constant", default: false),
    source: (head: "neg", data: term),
  )
}

#let abs(term) = {
  term.info.sign = "+"
  return (
    float: calc.abs(as-float(term)),
    uncertainty: as-uncertainty(term),
    info: term.info,
    round: as-round(term),
    unit: term.at("unit", default: none),
    constant: term.at("constant", default: false),
    source: (head: "abs", data: term),
  )
}

#let mul(terms) = {
  let unit = units.multiply-unit(terms.map(x => x.at("unit", default: none)))
  let product = terms.map(as-float).product(default: 0)
  let error = if terms.any(x => as-uncertainty(x) != none) {
    (
      calc.abs(product)
        * rss(terms.map(x => {
          let uncertainty = as-uncertainty(x)
          if uncertainty != none {
            uncertainty / as-float(x)
          }
        }))
    )
  }
  let target-e = get-e(terms, product, "value")
  return (
    float: product,
    uncertainty: error,
    info: create-info(product, error, target-e),
    round: get-sig-figs(terms.filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x)))),
    unit: unit,
    constant: terms.all(x => x.at("constant", default: false)),
    source: (head: "mul", data: terms),
  )
}

#let div(dividend, divisor) = {
  let unit = units.multiply-unit((
    dividend.at("unit", default: none),
    units.invert-unit(divisor.at("unit", default: none)),
  ))
  let terms = (dividend, divisor)
  let quotient = as-float(dividend) / as-float(divisor)

  let error = if terms.any(x => as-uncertainty(x) != none) {
    (
      calc.abs(quotient)
        * rss(terms.map(x => {
          let uncertainty = as-uncertainty(x)
          if uncertainty != none {
            uncertainty / as-float(x)
          }
        }))
    )
  }
  let target-e = get-e(terms, quotient, "value")
  return (
    float: quotient,
    uncertainty: error,
    info: create-info(quotient, error, target-e),
    round: get-sig-figs(terms.filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x)))),
    unit: unit,
    constant: terms.all(x => x.at("constant", default: false)),
    source: (head: "div", data: terms),
  )
}

#let pow(base, exponent) = {
  let exponent-uncertainty = as-uncertainty(exponent)
  assert(
    units.is-unitless(exponent),
    message: "pow: exponent must not carry a unit: " + repr(exponent.at("unit", default: none)),
  )
  assert(
    units.is-unitless(base) or exponent-uncertainty == none,
    message: "pow: exponent must be exact (no uncertainty) when base carries a unit.",
  )

  let exponent-float = as-float(exponent)
  let base-float = as-float(base)
  let base-uncertainty = as-uncertainty(base)

  let unit = units.pow-unit(base.at("unit", default: none), exponent-float)
  let result = calc.pow(base-float, exponent-float)

  let error-terms = (
    if base-uncertainty != none and base-float != 0 {
      exponent-float * calc.abs(result) * (base-uncertainty / calc.abs(base-float))
    },
    if exponent-uncertainty != none {
      calc.abs(result) * calc.abs(calc.ln(base-float)) * exponent-uncertainty
    },
  )
  let error = if error-terms.any(x => x != none) { rss(error-terms) }

  if exponent.info.frac.len() == 0 and exponent.info.pm == none {
    exponent.constant = true
  }
  let target-e = get-e(none, result, "value")
  return (
    float: result,
    uncertainty: error,
    info: create-info(result, error, target-e),
    round: get-sig-figs(
      (base, exponent).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))),
    ),
    unit: unit,
    constant: (base, exponent).all(x => x.at("constant", default: false)),
    source: (head: "pow", data: (base, exponent)),
  )
}

#let exp(exponent) = pow(e, exponent)

#let root(radicand, index) = {
  let index-float = as-float(index)
  let index-uncertainty = as-uncertainty(index)
  let radicand-float = as-float(radicand)
  let radicand-uncertainty = as-uncertainty(radicand)
  assert(int(index-float) == index-float, message: "only integer index is allowed. index: " + str(index-float))
  assert(
    radicand.at("unit", default: none) == none or index-uncertainty == none,
    message: "root: index must be exact (no uncertainty) when radicand carries a unit.",
  )

  let unit = units.root-unit(radicand.at("unit", default: none), index-float)
  let result = calc.root(radicand-float, int(index-float))

  let error-terms = (
    if radicand-uncertainty != none and radicand-float != 0 {
      index-float * calc.abs(result) * (radicand-uncertainty / calc.abs(radicand-float))
    },
    if index-uncertainty != none {
      calc.abs(result) * calc.abs(calc.ln(radicand-float)) * index-uncertainty
    },
  )
  let error = if error-terms.any(x => x != none) { rss(error-terms) }

  if index.info.pm == none {
    index.constant = true
  }
  let target-e = get-e(none, result, "value")
  return (
    float: result,
    uncertainty: error,
    info: create-info(result, error, target-e),
    round: get-sig-figs(
      (radicand, index).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))),
    ),
    unit: unit,
    constant: (radicand, index).all(x => x.at("constant", default: false)),
    source: (head: "root", data: (radicand, index)),
  )
}

#let sqrt(radicand) = root(radicand, normalise-constant(2))

#let log(value, base) = {
  let value-float = as-float(value)
  let value-uncertainty = as-uncertainty(value)
  let base-float = as-float(base)
  let base-uncertainty = as-uncertainty(base)

  assert(units.is-unitless(value), message: "log: value must not carry a unit.")
  assert(units.is-unitless(base), message: "log: base must not carry a unit.")
  assert(value-float > 0, message: "log: value must be positive.")
  assert(base-float > 0 and base-float != 1, message: "log: base must be positive and != 1.")

  let result = calc.log(value-float, base: base-float)
  let ln-base = calc.ln(base-float)

  let error-terms = (
    if value-uncertainty != none {
      value-uncertainty / (calc.abs(value-float) * calc.abs(ln-base))
    },
    if base-uncertainty != none {
      calc.abs(result) * base-uncertainty / (calc.abs(base-float) * calc.abs(ln-base))
    },
  )
  let error = if error-terms.any(x => x != none) { rss(error-terms) }
  let target-e = get-e(none, result, "value")

  return (
    float: result,
    uncertainty: error,
    info: create-info(result, error, target-e),
    round: get-sig-figs(
      (value, base).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))),
    ),
    constant: (value, base).all(x => x.at("constant", default: false)),
    source: (head: "log", data: (value, base)),
  )
}

#let ln(value) = log(value, e)

#let sin(angle) = {
  let angle-float = as-float(angle)
  let angle-uncertainty = as-uncertainty(angle)
  assert(
    units.is-unitless(angle)
      or (
        angle.unit.numerator.at(0).at(0) in (sym.degree, "rad", sym.prime.double, sym.prime)
          and angle.unit.denominator.len() == 0
      ),
    message: "sin: angle must not carry a unit (radians assumed).",
  )
  if angle.at("unit", default: none) != none {
    let unit = angle.unit.numerator.at(0).at(0)
    if unit == sym.degree {
      angle-float *= 1deg
    } else if unit == sym.prime {
      angle-float = (angle-float / 60) * 1deg
    } else if unit == sym.prime.double {
      angle-float = angle-float / 3600 * 1deg
    } else if unit == "rad" {
      angle-float = angle-float * 1rad
    }
  }

  let result = calc.sin(angle-float)
  let error = if angle-uncertainty != none { calc.abs(calc.cos(angle-float)) * angle-uncertainty }
  let target-e = 0

  return (
    float: result,
    uncertainty: error,
    info: create-info(result, error, target-e),
    round: get-sig-figs((angle,).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x)))),
    constant: angle.at("constant", default: false),
    source: (head: "sin", data: angle),
  )
}

#let cos(angle) = {
  let angle-float = as-float(angle)
  let angle-uncertainty = as-uncertainty(angle)
  assert(
    units.is-unitless(angle)
      or (
        angle.unit.numerator.at(0).at(0) in (sym.degree, "rad", sym.prime.double, sym.prime)
          and angle.unit.denominator.len() == 0
      ),
    message: "sin: angle must not carry a unit (radians assumed).",
  )
  if angle.at("unit", default: none) != none {
    let unit = angle.unit.numerator.at(0).at(0)
    if unit == sym.degree {
      angle-float *= 1deg
    } else if unit == sym.prime {
      angle-float = (angle-float / 60) * 1deg
    } else if unit == sym.prime.double {
      angle-float = angle-float / 3600 * 1deg
    } else if unit == "rad" {
      angle-float = angle-float * 1rad
    }
  }

  let result = calc.cos(angle-float)
  let error = if angle-uncertainty != none { calc.abs(calc.sin(angle-float)) * angle-uncertainty }
  let target-e = 0

  return (
    float: result,
    uncertainty: error,
    info: create-info(result, error, target-e),
    round: get-sig-figs((angle,).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x)))),
    constant: angle.at("constant", default: false),
    source: (head: "cos", data: angle),
  )
}

#let tan(angle) = {
  let angle-float = as-float(angle)
  let angle-uncertainty = as-uncertainty(angle)
  assert(
    units.is-unitless(angle)
      or (
        angle.unit.numerator.at(0).at(0) in (sym.degree, "rad", sym.prime.double, sym.prime)
          and angle.unit.denominator.len() == 0
      ),
    message: "sin: angle must not carry a unit (radians assumed).",
  )
  if angle.at("unit", default: none) != none {
    let unit = angle.unit.numerator.at(0).at(0)
    if unit == sym.degree {
      angle-float *= 1deg
    } else if unit == sym.prime {
      angle-float = (angle-float / 60) * 1deg
    } else if unit == sym.prime.double {
      angle-float = angle-float / 3600 * 1deg
    } else if unit == "rad" {
      angle-float = angle-float * 1rad
    }
  }

  let result = calc.tan(angle-float)
  let error = if angle-uncertainty != none {
    angle-uncertainty / calc.pow(calc.cos(angle-float), 2)
  }
  let target-e = get-e(none, result, "value")

  return (
    float: result,
    uncertainty: error,
    info: create-info(result, error, target-e),
    round: get-sig-figs((angle,).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x)))),
    constant: angle.at("constant", default: false),
    source: (head: "tan", data: angle),
  )
}

#let asin(value, unit: sym.degree) = {
  let value-float = as-float(value)
  let value-uncertainty = as-uncertainty(value)
  assert(units.is-unitless(value), message: "asin: value must not carry a unit.")
  assert(value-float >= -1 and value-float <= 1, message: "asin: value must be in [-1, 1].")

  let unit-divider = if unit == sym.degree {
    1deg
  } else if unit == "rad" {
    1rad
  } else if unit == sym.prime {
    1deg / 60
  } else if unit == sym.prime.double {
    1deg / 360
  } else {
    1deg
  }
  let result = calc.asin(value-float) / unit-divider
  let error = if value-uncertainty != none {
    value-uncertainty / calc.sqrt(1 - calc.pow(value-float, 2))
  }
  let target-e = get-e(none, result, "value")

  return (
    float: result,
    uncertainty: error,
    info: create-info(result, error, target-e),
    round: get-sig-figs((value,).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x)))),
    unit: (numerator: ((unit, "1"),), denominator: ()),
    constant: value.at("constant", default: false),
    source: (head: "asin", data: value),
  )
}

#let acos(value, unit: sym.degree) = {
  let value-float = as-float(value)
  let value-uncertainty = as-uncertainty(value)
  assert(units.is-unitless(value), message: "acos: value must not carry a unit.")
  assert(value-float >= -1 and value-float <= 1, message: "acos: value must be in [-1, 1].")
  let unit-divider = if unit == sym.degree {
    1deg
  } else if unit == "rad" {
    1rad
  } else if unit == sym.prime {
    1deg / 60
  } else if unit == sym.prime.double {
    1deg / 360
  } else {
    1deg
  }
  let result = calc.acos(value-float) / unit-divider
  let error = if value-uncertainty != none {
    value-uncertainty / calc.sqrt(1 - calc.pow(value-float, 2))
  }
  let target-e = get-e(none, result, "value")

  return (
    float: result,
    uncertainty: error,
    info: create-info(result, error, target-e),
    round: get-sig-figs((value,).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x)))),
    unit: (numerator: ((unit, "1"),), denominator: ()),
    constant: value.at("constant", default: false),
    source: (head: "acos", data: value),
  )
}

#let atan(value, unit: sym.degree) = {
  let value-float = as-float(value)
  let value-uncertainty = as-uncertainty(value)
  assert(units.is-unitless(value), message: "atan: value must not carry a unit.")

  let unit-divider = if unit == sym.degree {
    1deg
  } else if unit == "rad" {
    1rad
  } else if unit == sym.prime {
    1deg / 60
  } else if unit == sym.prime.double {
    1deg / 360
  } else {
    1deg
  }
  let result = calc.atan(value-float) / unit-divider
  let error = if value-uncertainty != none {
    value-uncertainty / (1 + calc.pow(value-float, 2))
  }
  let target-e = get-e(none, result, "value")

  return (
    float: result,
    uncertainty: error,
    info: create-info(result, error, target-e),
    round: get-sig-figs((value,).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x)))),
    unit: (numerator: ((unit, "1"),), denominator: ()),
    constant: value.at("constant", default: false),
    source: (head: "atan", data: value),
  )
}
