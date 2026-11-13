#import "@preview/zero:0.7.1"
#import "units.typ"
#import "utility.typ": (
  as-float, as-round, as-uncertainty, create-add-result, create-info, flag-special, get-last-digits, get-sig-figs,
  get-value-e, is-undefined, merge-args, normalise-constant, normalise-quantity, prefixes, result-e, rss,
  undefined-result,
)

#let const = normalise-constant

#let any-undefined(..terms) = terms.pos().flatten().any(is-undefined)
#let pi = normalise-constant(calc.pi)
#let e = normalise-constant(calc.e)
#let tau = normalise-constant(calc.tau)
#let inf = normalise-constant(calc.inf)

#let add(terms) = {
  if any-undefined(terms) { return undefined-result("add", terms) }
  let unit = terms.filter(x => x.at("unit", default: none) != none).first(default: (unit: none)).unit
  assert(
    terms.all(x => x.at("unit", default: none) == none or units.equal(x.at("unit", default: none), unit)),
    message: "All parameters must have the same unit.",
  )
  let sum = terms.map(as-float).sum()
  let error = rss(terms.map(as-uncertainty))
  let digits = get-last-digits(terms.filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))))
  let plain = terms.all(x => x.info.e in (none, "0"))
  let shown = create-add-result(sum, error, digits, plain: plain)
  return flag-special((
    float: sum,
    uncertainty: error,
    info: shown.info,
    round: shown.round,
    unit: unit,
    constant: terms.all(x => x.at("constant", default: false)),
    source: (head: "add", data: terms),
    args: merge-args(terms, unit: unit),
  ))
}

#let sub(a, terms) = {
  if type(terms) != array { terms = (terms,) }
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
  if any-undefined(term) { return undefined-result("neg", term) }
  let original = term
  let value = as-float(term)
  let info = term.info
  if value != 0 { info.sign = if info.sign == "-" { "+" } else { "-" } }
  return (
    float: if value == 0 { value } else { -value },
    uncertainty: as-uncertainty(term),
    info: info,
    round: as-round(term),
    unit: term.at("unit", default: none),
    constant: term.at("constant", default: false),
    source: (head: "neg", data: original),
    args: term.at("args", default: none),
  )
}

#let abs(term) = {
  if any-undefined(term) { return undefined-result("abs", term) }
  let original = term
  let value = as-float(term)
  let info = term.info
  info.sign = "+"
  return (
    float: calc.abs(value),
    uncertainty: as-uncertainty(term),
    info: info,
    round: as-round(term),
    unit: term.at("unit", default: none),
    constant: term.at("constant", default: false),
    source: (head: "abs", data: original),
    args: term.at("args", default: none),
  )
}

#let mul(terms) = {
  if any-undefined(terms) { return undefined-result("mul", terms) }
  let unit = units.multiply-unit(terms.map(x => x.at("unit", default: none)))
  let product = terms.map(as-float).product(default: 0)
  let error = if terms.any(x => as-uncertainty(x) != none) {
    rss(terms
      .enumerate()
      .map(((i, x)) => {
        let uncertainty = as-uncertainty(x)
        if uncertainty != none {
          (
            uncertainty
              * calc.abs(
                terms.enumerate().filter(((j, _)) => j != i).map(((_, y)) => as-float(y)).product(default: 1),
              )
          )
        }
      }))
  }
  let round = get-sig-figs(terms.filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))))
  return flag-special((
    float: product,
    uncertainty: error,
    info: create-info(product, error, result-e(product, round: round)),
    round: round,
    unit: unit,
    constant: terms.all(x => x.at("constant", default: false)),
    source: (head: "mul", data: terms),
    args: merge-args(terms, unit: unit),
  ))
}

#let div(dividend, divisor) = {
  if any-undefined(dividend, divisor) { return undefined-result("div", (dividend, divisor)) }
  if as-float(divisor) == 0 { return undefined-result("div", (dividend, divisor)) }
  let unit = units.multiply-unit((
    dividend.at("unit", default: none),
    units.invert-unit(divisor.at("unit", default: none)),
  ))
  let terms = (dividend, divisor)
  let quotient = as-float(dividend) / as-float(divisor)

  let error = if terms.any(x => as-uncertainty(x) != none) {
    let (a, b) = (as-float(dividend), as-float(divisor))
    let (ua, ub) = (as-uncertainty(dividend), as-uncertainty(divisor))
    rss((
      if ua != none { ua / calc.abs(b) },
      if ub != none { ub * calc.abs(a) / (b * b) },
    ))
  }
  let round = get-sig-figs(terms.filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))))
  return flag-special((
    float: quotient,
    uncertainty: error,
    info: create-info(quotient, error, result-e(quotient, round: round)),
    round: round,
    unit: unit,
    constant: terms.all(x => x.at("constant", default: false)),
    source: (head: "div", data: terms),
    args: merge-args(terms, unit: unit),
  ))
}

#let pow(base, exponent) = {
  if any-undefined(base, exponent) { return undefined-result("pow", (base, exponent)) }
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

  if base-float == 0 and exponent-float <= 0 { return undefined-result("pow", (base, exponent)) }
  if base-float < 0 and int(exponent-float) != exponent-float { return undefined-result("pow", (base, exponent)) }

  let unit = units.pow-unit(base.at("unit", default: none), exponent-float)
  let result = calc.pow(base-float, exponent-float)

  let error-terms = (
    if base-uncertainty != none {
      if base-float != 0 {
        exponent-float * calc.abs(result) * (base-uncertainty / calc.abs(base-float))
      } else if exponent-float == 1 {
        base-uncertainty
      } else if exponent-float > 1 {
        0.0
      }
    },
    if exponent-uncertainty != none {
      calc.abs(result) * calc.abs(calc.ln(base-float)) * exponent-uncertainty
    },
  )
  let error = if error-terms.any(x => x != none) { rss(error-terms) }

  if exponent.info.frac.len() == 0 and exponent.info.pm == none {
    exponent.constant = true
  }
  let round = get-sig-figs(
    (base, exponent).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))),
  )
  return flag-special((
    float: result,
    uncertainty: error,
    info: create-info(result, error, result-e(result, round: round)),
    round: round,
    unit: unit,
    constant: (base, exponent).all(x => x.at("constant", default: false)),
    source: (head: "pow", data: (base, exponent)),
    args: merge-args((base, exponent), unit: unit),
  ))
}

#let exp(exponent) = pow(e, exponent)

#let root(radicand, index) = {
  if any-undefined(radicand, index) { return undefined-result("root", (radicand, index)) }
  let index-float = as-float(index)
  let index-uncertainty = as-uncertainty(index)
  let radicand-float = as-float(radicand)
  let radicand-uncertainty = as-uncertainty(radicand)
  assert(int(index-float) == index-float, message: "only integer index is allowed. index: " + str(index-float))
  assert(
    radicand.at("unit", default: none) == none or index-uncertainty == none,
    message: "root: index must be exact (no uncertainty) when radicand carries a unit.",
  )

  if index-float == 0 or (radicand-float < 0 and calc.rem(index-float, 2) == 0) {
    return undefined-result("root", (radicand, index))
  }

  let unit = units.root-unit(radicand.at("unit", default: none), index-float)
  let result = calc.root(radicand-float, int(index-float))

  let error-terms = (
    if radicand-uncertainty != none and radicand-float != 0 {
      calc.abs(result) * (radicand-uncertainty / calc.abs(radicand-float)) / calc.abs(index-float)
    },
    if index-uncertainty != none {
      calc.abs(result) * calc.abs(calc.ln(radicand-float)) * index-uncertainty / (index-float * index-float)
    },
  )
  let error = if error-terms.any(x => x != none) { rss(error-terms) }

  if index.info.pm == none {
    index.constant = true
  }
  let round = get-sig-figs(
    (radicand, index).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))),
  )
  return flag-special((
    float: result,
    uncertainty: error,
    info: create-info(result, error, result-e(result, round: round)),
    round: round,
    unit: unit,
    constant: (radicand, index).all(x => x.at("constant", default: false)),
    source: (head: "root", data: (radicand, index)),
    args: merge-args((radicand, index), unit: unit),
  ))
}

#let sqrt(radicand) = root(radicand, normalise-constant(2))

#let log(value, base) = {
  if any-undefined(value, base) { return undefined-result("log", (value, base)) }
  let value-float = as-float(value)
  let value-uncertainty = as-uncertainty(value)
  let base-float = as-float(base)
  let base-uncertainty = as-uncertainty(base)

  assert(units.is-unitless(value), message: "log: value must not carry a unit.")
  assert(units.is-unitless(base), message: "log: base must not carry a unit.")
  if value-float <= 0 or base-float <= 0 or base-float == 1 { return undefined-result("log", (value, base)) }

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
  let round = get-sig-figs(
    (value, base).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))),
  )

  return flag-special((
    float: result,
    uncertainty: error,
    info: create-info(result, error, result-e(result, round: round)),
    round: round,
    constant: (value, base).all(x => x.at("constant", default: false)),
    source: (head: "log", data: (value, base)),
    args: merge-args((value, base), unit: none),
  ))
}

#let ln(value) = log(value, e)

#let angle-units = (
  "°": 1deg,
  "rad": 1rad,
  "′": 1deg / 60,
  "″": 1deg / 3600,
)
#let angle-parts(angle, name) = {
  let unit = if units.is-unitless(angle) { "rad" } else { none }
  if unit == none and angle.unit.denominator.len() == 0 and angle.unit.numerator.len() == 1 {
    unit = str(angle.unit.numerator.at(0).at(0))
  }
  assert(
    unit in angle-units,
    message: name
      + ": angle must not carry a unit other than rad, "
      + sym.degree
      + ", "
      + sym.prime
      + " or "
      + sym.prime.double
      + " (radians assumed without unit).",
  )
  let uncertainty = as-uncertainty(angle)
  (
    value: as-float(angle) * angle-units.at(unit),
    uncertainty: if uncertainty != none { (uncertainty * angle-units.at(unit)).rad() },
  )
}

#let trig-result(name, result, error, angle, fixed-e: none) = {
  let round = get-sig-figs((angle,).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))))
  (
    float: result,
    uncertainty: error,
    info: create-info(result, error, if fixed-e != none { fixed-e } else { result-e(result, round: round) }),
    round: round,
    constant: angle.at("constant", default: false),
    source: (head: name, data: angle),
    args: merge-args((angle,), unit: none),
  )
}

#let snap-zero(result, angle) = if calc.abs(result) < 1e-15 and calc.abs(angle.rad()) > 1e-3 { 0.0 } else { result }

#let sin(angle) = {
  if any-undefined(angle) { return undefined-result("sin", angle) }
  let (value, uncertainty) = angle-parts(angle, "sin")
  let result = snap-zero(calc.sin(value), value)
  let error = if uncertainty != none { calc.abs(calc.cos(value)) * uncertainty }
  trig-result("sin", result, error, angle, fixed-e: 0)
}

#let cos(angle) = {
  if any-undefined(angle) { return undefined-result("cos", angle) }
  let (value, uncertainty) = angle-parts(angle, "cos")
  let result = snap-zero(calc.cos(value), value)
  let error = if uncertainty != none { calc.abs(calc.sin(value)) * uncertainty }
  trig-result("cos", result, error, angle, fixed-e: 0)
}

#let tan(angle) = {
  if any-undefined(angle) { return undefined-result("tan", angle) }
  let (value, uncertainty) = angle-parts(angle, "tan")
  if calc.abs(calc.cos(value)) < 1e-15 { return undefined-result("tan", angle) }
  let result = snap-zero(calc.tan(value), value)
  let error = if uncertainty != none { uncertainty / calc.pow(calc.cos(value), 2) }
  trig-result("tan", result, error, angle)
}

#let inverse-trig-result(name, function, derivative, value, unit) = {
  let value-float = as-float(value)
  let value-uncertainty = as-uncertainty(value)
  assert(units.is-unitless(value), message: name + ": value must not carry a unit.")
  let divider = angle-units.at(str(unit), default: 1deg)
  let result = function(value-float) / divider
  let error = if value-uncertainty != none { derivative(value-float) * value-uncertainty * 1rad / divider }
  let round = get-sig-figs((value,).filter(x => not x.at("constant", default: false)).map(x => (x.info, as-round(x))))
  (
    float: result,
    uncertainty: error,
    info: create-info(result, error, result-e(result, round: round)),
    round: round,
    unit: (numerator: ((unit, "1"),), denominator: ()),
    constant: value.at("constant", default: false),
    source: (head: name, data: value),
    args: value.at("args", default: none),
  )
}

#let asin(value, unit: sym.degree) = {
  if any-undefined(value) { return undefined-result("asin", value) }
  let value-float = as-float(value)
  assert(units.is-unitless(value), message: "asin: value must not carry a unit.")
  let value-uncertainty = as-uncertainty(value)
  if calc.abs(value-float) > 1 or (calc.abs(value-float) == 1 and value-uncertainty != none) {
    return undefined-result("asin", value)
  }
  inverse-trig-result("asin", calc.asin, x => 1 / calc.sqrt(1 - x * x), value, unit)
}

#let acos(value, unit: sym.degree) = {
  if any-undefined(value) { return undefined-result("acos", value) }
  let value-float = as-float(value)
  assert(units.is-unitless(value), message: "acos: value must not carry a unit.")
  let value-uncertainty = as-uncertainty(value)
  if calc.abs(value-float) > 1 or (calc.abs(value-float) == 1 and value-uncertainty != none) {
    return undefined-result("acos", value)
  }
  inverse-trig-result("acos", calc.acos, x => 1 / calc.sqrt(1 - x * x), value, unit)
}

#let atan(value, unit: sym.degree) = if any-undefined(value) { undefined-result("atan", value) } else {
  inverse-trig-result("atan", calc.atan, x => 1 / (1 + x * x), value, unit)
}

#let apply-prefix(value, unit, in-numerator) = {
  let prefix = if type(unit.at(0)) != symbol and unit.at(0).len() != 1 { unit.at(0).first() }
  let unit-name = unit.at(0)
  if prefix != none and prefix in prefixes.keys() and not unit-name in units.base-si-units {
    let actual-unit = unit-name.slice(prefix.len())
    if actual-unit in units.base-si-units or actual-unit in units.si-conversions.keys() or actual-unit == "g" {
      unit-name = actual-unit
    } else {
      prefix = none
    }
  } else {
    prefix = none
  }

  if prefix != none {
    let prefix-e = prefixes.at(prefix)
    let removal-unit = (
      numerator: ((if unit-name == "g" { "kg" } else { unit-name }, unit.at(1)),),
      denominator: ((unit.at(0), unit.at(1)),),
    )
    if not in-numerator {
      removal-unit = (numerator: removal-unit.denominator, denominator: removal-unit.numerator)
    }
    let sign = if in-numerator { 1 } else { -1 }
    // stupid kilograms
    let correction = if unit-name == "g" { -3 } else { 0 }
    let exponent = (prefix-e + correction) * int(unit.at(1)) * sign
    let multiplier = const(
      (
        float: calc.pow(10, exponent),
        info: (int: "1", frac: "", sign: "+", pm: none, e: str(exponent)),
        unit: removal-unit,
        args: arguments(omit-unity-mantissa: true),
      ),
    )
    value = mul((
      value,
      multiplier,
    ))
  }
  return (value, if prefix != none and unit-name == "g" { "kg" } else { unit-name })
}

#let apply-unit-conversion(value, unit, in-numerator, use-division: false) = {
  let unit-conversion = units.si-conversions.at(unit.at(0), default: none)

  if unit-conversion == none {
    return value
  }

  let factor = unit-conversion.at("factor", default: none)
  let offset = unit-conversion.at("offset", default: none)

  let removal-unit = unit-conversion.unit
  removal-unit.denominator.push(unit)

  let multiplier-value = if factor != none {
    unit-conversion.factor
  } else { "" }

  let multiplier

  if factor != none {
    multiplier = const(
      (
        float: if multiplier-value != "" { float(multiplier-value) } else { 1 },
        info: if multiplier-value != "" { zero.impl.parsing.parse-numeral(multiplier-value) } else {
          (int: "", frac: "", sign: "+", pm: none, e: none)
        },
        unit: (numerator: removal-unit.numerator, denominator: ()),
        args: arguments(omit-unity-mantissa: true),
      ),
    )
    if unit.at(1) != "1" {
      multiplier = pow(multiplier, const(unit.at(1)))
      multiplier.source = none
    }

    let x = const(
      (
        float: 1,
        info: (int: "1", frac: "", sign: "+", pm: none, e: none),
        unit: (numerator: removal-unit.denominator, denominator: ()),
        args: arguments(omit-unity-mantissa: true),
      ),
    )
    if in-numerator {
      multiplier = div(multiplier, x)
    } else {
      multiplier = div(x, multiplier)
    }
  } else {
    if not in-numerator {
      removal-unit = (numerator: removal-unit.denominator, denominator: removal-unit.numerator)
    }
    multiplier = const(
      (
        float: if multiplier-value != "" { float(multiplier-value) } else { 1 },
        info: if multiplier-value != "" { zero.impl.parsing.parse-numeral(multiplier-value) } else {
          (int: "", frac: "", sign: "+", pm: none, e: none)
        },
        unit: removal-unit,
        args: arguments(omit-unity-mantissa: true),
      ),
    )
  }

  value = mul((
    value,
    multiplier,
  ))

  if offset != none and (value.unit.numerator.len() == 1 and value.unit.denominator.len() == 0) {
    value = add((
      value,
      const((
        float: float(offset),
        info: zero.impl.parsing.parse-numeral(offset),
        unit: unit-conversion.unit,
        args: arguments(),
      )),
    ))
  }

  return value
}

#let convert-units-to-si(quantity, save-operations: false) = {
  if units.is-unitless(quantity) { return quantity }
  let result = quantity
  for unit in quantity.unit.numerator {
    (result, unit.at(0)) = apply-prefix(result, unit, true)
    result = apply-unit-conversion(result, unit, true)
  }
  for unit in quantity.unit.denominator {
    (result, unit.at(0)) = apply-prefix(result, unit, false)
    result = apply-unit-conversion(result, unit, false)
  }

  if (result.args.at("exponent", default: none) == "eng") {
    let named = result.args.named()
    named.remove("exponent")
    result.args = arguments(..result.args.pos(), ..named)
  }

  if not save-operations and result != quantity {
    result.source = quantity.at("source", default: none)
  }
  return result
}
#let convert-units(quantity, unit, args: arguments()) = {
  let one = (float: 1, info: (int: "1", frac: "", sign: "+", pm: none, e: none), unit: unit, args: arguments())
  let one-si = convert-units-to-si(one)
  assert(
    not unit.numerator.any(x => units.si-conversions.at(x.at(0), default: (:)).at("offset", default: none) != none),
    message: "convert-units: units with an offset (°C) are not supported as target",
  )
  let si = convert-units-to-si(quantity)
  assert(
    units.equal(si.at("unit", default: none), one-si.at("unit", default: none)),
    message: "convert-units: cannot convert " + repr(quantity.at("unit", default: none)) + " into " + repr(unit),
  )
  let factor = as-float(one-si)
  let result = mul((
    si,
    const((
      float: 1 / factor,
      info: create-info(1 / factor, none, result-e(1 / factor)),
      unit: units.multiply-unit((unit, units.invert-unit(one-si.unit))),
      args: arguments(),
    )),
  ))
  let named = quantity.at("args", default: none)
  named = if named == none { (:) } else { named.named() }
  let _ = named.remove("alt", default: none)
  let _ = named.remove("round", default: none)
  result.unit = unit
  result.args = arguments(..(named + args.named()))
  result.source = (head: "mul", data: (quantity,))
  return result
}
