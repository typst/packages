#import "operations.typ"
#import "utility.typ"
#import "utility-display.typ"

#let const(value) = {
  let result = utility.normalise-constant(value)
  utility-display.display-info(result)
}

#let pi = const(calc.pi)
#let e = const(calc.e)
#let tau = const(calc.tau)
#let inf = const(calc.inf)

#let add(convert-si: false, ..summands) = {
  if summands.pos().any(x => x == none) { return none }
  let datas = utility.normalise-quantities(summands.pos())
  if convert-si { datas = datas.map(operations.convert-units-to-si) }
  let result = operations.add(datas)
  return utility-display.display-info(result, call-args: summands)
}

#let sub(minuend, convert-si: false, ..subtrahends) = {
  if ((minuend,) + subtrahends.pos()).any(x => x == none) { return none }
  let datas = utility.normalise-quantities((minuend,) + subtrahends.pos())
  if convert-si { datas = datas.map(operations.convert-units-to-si) }
  let result = operations.sub(datas.first(), datas.slice(1))
  return utility-display.display-info(result, call-args: subtrahends)
}

#let abs(value, convert-si: false, ..args) = {
  if (value,).any(x => x == none) { return none }
  let value = utility.normalise-quantity(value)
  if convert-si { value = operations.convert-units-to-si(value) }
  let result = operations.abs(value)
  return utility-display.display-info(result, call-args: args)
}
#let neg(value, convert-si: false, ..args) = {
  if (value,).any(x => x == none) { return none }
  let value = utility.normalise-quantity(value)
  if convert-si { value = operations.convert-units-to-si(value) }
  let result = operations.neg(value)
  return utility-display.display-info(result, call-args: args)
}

#let mul(convert-si: false, ..factors) = {
  if factors.pos().any(x => x == none) { return none }
  let datas = utility.normalise-quantities(factors.pos())
  if convert-si { datas = datas.map(operations.convert-units-to-si) }
  let result = operations.mul(datas)
  return utility-display.display-info(result, call-args: factors)
}

#let div(dividend, divisor, convert-si: false, ..args) = {
  if (dividend, divisor).any(x => x == none) { return none }
  let (dividend, divisor) = utility.normalise-quantities((dividend, divisor))
  if convert-si {
    (dividend, divisor) = (operations.convert-units-to-si(dividend), operations.convert-units-to-si(divisor))
  }
  let result = operations.div(dividend, divisor)
  return utility-display.display-info(result, call-args: args)
}

#let pow(base, exponent, convert-si: false, ..args) = {
  if (base, exponent).any(x => x == none) { return none }
  let (base, exponent) = utility.normalise-quantities((base, exponent))
  if convert-si { base = operations.convert-units-to-si(base) }
  let result = operations.pow(base, exponent)
  return utility-display.display-info(result, call-args: args)
}

#let exp(exponent, convert-si: false, ..args) = {
  if (exponent,).any(x => x == none) { return none }
  let exponent = utility.normalise-quantity(exponent)
  let result = operations.exp(exponent)
  return utility-display.display-info(result, call-args: args)
}

#let root(radicand, index, convert-si: false, ..args) = {
  if (radicand, index).any(x => x == none) { return none }
  let (radicand, index) = utility.normalise-quantities((radicand, index))
  if convert-si {
    (radicand, index) = (operations.convert-units-to-si(radicand), operations.convert-units-to-si(index))
  }
  let result = operations.root(radicand, index)
  return utility-display.display-info(result, call-args: args)
}

#let sqrt(radicand, convert-si: false, ..args) = {
  if (radicand,).any(x => x == none) { return none }
  let radicand = utility.normalise-quantity(radicand)
  if convert-si { radicand = operations.convert-units-to-si(radicand) }
  let result = operations.sqrt(radicand)
  return utility-display.display-info(result, call-args: args)
}

#let log(value, base, ..args) = {
  if (value, base).any(x => x == none) { return none }
  let (value, base) = utility.normalise-quantities((value, base))
  let result = operations.log(value, base)
  return utility-display.display-info(result, call-args: args)
}

#let ln(value, ..args) = {
  if (value,).any(x => x == none) { return none }
  let value = utility.normalise-quantity(value)
  let result = operations.ln(value)
  return utility-display.display-info(result, call-args: args)
}

#let sin(angle, ..args) = {
  if (angle,).any(x => x == none) { return none }
  let angle = utility.normalise-quantity(angle)
  let result = operations.sin(angle)
  return utility-display.display-info(result, call-args: args)
}
#let cos(angle, ..args) = {
  if (angle,).any(x => x == none) { return none }
  let angle = utility.normalise-quantity(angle)
  let result = operations.cos(angle)
  return utility-display.display-info(result, call-args: args)
}
#let tan(angle, ..args) = {
  if (angle,).any(x => x == none) { return none }
  let angle = utility.normalise-quantity(angle)
  let result = operations.tan(angle)
  return utility-display.display-info(result, call-args: args)
}

#let asin(value, unit: sym.degree, ..args) = {
  if (value,).any(x => x == none) { return none }
  let value = utility.normalise-quantity(value)
  let result = operations.asin(value, unit: unit)
  return utility-display.display-info(result, call-args: args)
}
#let acos(value, unit: sym.degree, ..args) = {
  if (value,).any(x => x == none) { return none }
  let value = utility.normalise-quantity(value)
  let result = operations.acos(value, unit: unit)
  return utility-display.display-info(result, call-args: args)
}
#let atan(value, unit: sym.degree, ..args) = {
  if (value,).any(x => x == none) { return none }
  let value = utility.normalise-quantity(value)
  let result = operations.atan(value, unit: unit)
  return utility-display.display-info(result, call-args: args)
}

#let convert-units-to-si(quantity, save-operations: true) = {
  if (quantity,).any(x => x == none) { return none }
  let value = utility.normalise-quantity(quantity)
  value = operations.convert-units-to-si(value, save-operations: save-operations)
  return utility-display.display-info(value)
}

#let set-preferred-units(rules) = context {
  let state = utility.zcalc-state.get()
  let normalise-unit(unit) = {
    let type = type(unit)
    return if type == function {
      let metadata = utility.impl.utility.retrieve-metadata(unit())
      (unit: metadata.unit, alt: metadata.args.named().at("alt", default: auto))
    } else if type == dictionary {
      if unit.at("denominator", default: none) != none and unit.at("numerator", default: none) != none {
        (unit: unit, alt: none)
      } else {
        unit
      }
    } else if type(unit) == content {
      let metadata = utility.impl.utility.retrieve-metadata(unit)
      (unit: metadata.unit, alt: metadata.args.named().at("alt", default: auto))
    }
  }
  let new-state = (
    preferred-units: rules.map(rule => (
      match: normalise-unit(rule.match),
      preferred: normalise-unit(rule.preferred),
      exact-match: rule.at("exact-match", default: true),
      factor: rule.at("factor", default: none),
    )),
  )

  state += new-state

  utility.zcalc-state.update(state)
}

#let convert-units(value, unit, ..args) = {
  if value == none { return none }
  let value = utility.normalise-quantity(value)
  let target = utility.normalise-quantity(if type(unit) == function { unit() } else { unit })
  let result = operations.convert-units(value, target.unit, args: arguments(..(target.args.named() + args.named())))
  return utility-display.display-info(result)
}

#let to-float(value, unit: none) = {
  if type(value) == array { return value.map(x => to-float(x, unit: unit)) }
  if value == none { return none }

  let t = type(value)
  if t == content {
    value = utility.retrieve-metadata(value)
    if unit != none {
      let target = utility.normalise-quantity(if type(unit) == function { unit() } else { unit })
      value = operations.convert-units(value, target.unit)
    }
    return utility.as-float(value)
  } else if t in (int, float, str) {
    return float(value)
  }
}

#let to-uncertainty(value, unit: none) = {
  if type(value) == array { return value.map(x => to-uncertainty(x, unit: unit)) }
  if value == none { return none }

  let t = type(value)
  if t == content {
    value = utility.retrieve-metadata(value)
    if unit != none {
      let target = utility.normalise-quantity(if type(unit) == function { unit() } else { unit })
      value = operations.convert-units(value, target.unit)
    }
    return utility.as-uncertainty(value)
  } else if t in (int, float, str) {
    return utility.as-uncertainty(utility.normalise-quantity(value))
  }
}
