#import "utility.typ"
#import "operations.typ"
#import "units.typ"
#import "@preview/zero:0.7.1"

#let method-prec-table = (add: 1, sub: 1, neg: 2, mul: 2.5, div: 2.5)
#let method-prec(value) = {
  let op = value.at("source", default: none)
  if op == none { return 1000 }
  method-prec-table.at(op.head, default: 1000)
}

#let select-part(value, part, state) = {
  if part == "both" or (part == "value" and value.info.at("pm", default: none) in (none, ())) { return value }
  let info = value.info
  let round = (
    state.round
      + {
        let r = utility.as-round(value)
        if r == none { (:) } else { r }
      }
  )
  let pm = info.at("pm", default: none)
  if pm == none or pm == () {
    pm = ("0", "")
  } else if type(pm.first()) == array {
    pm = pm.first()
  }
  let (int, frac) = (info.int, info.frac)
  if info.at("pm", default: none) not in (none, ()) and round.follow-uncertainty {
    (int, frac, pm) = zero.impl.rounding.round-to-uncertainty(
      int,
      frac,
      pm,
      sign: info.sign,
      ..round,
      precision: round.uncertainty-precision,
    )
  } else if round.precision not in (auto, none) {
    (int, frac) = zero.impl.rounding.round(int, frac, sign: info.sign, ..round)
  }
  value.info = if part == "value" {
    info + (int: int, frac: frac, pm: none)
  } else {
    (int: pm.at(0), frac: pm.at(1), sign: "+", pm: none, e: info.at("e", default: none))
  }
  value.round = (precision: none)
  let named = value.at("args", default: arguments()).named()
  let _ = named.remove("round", default: none)
  value.args = arguments(..value.at("args", default: arguments()).pos(), ..named)
  value
}

#let part-metadata(value, part) = {
  if part == "both" { return value }
  let info = value.info
  let pm = info.at("pm", default: none)
  if part == "value" {
    let x = value.remove("source", default: none)
    value.info.pm = none
    value.uncertainty = none
    value
  } else {
    let pm = if pm in (none, ()) { ("0", "") } else if type(pm.first()) == array { pm.first() } else { pm }
    let round = utility.as-round(value)
    let precision = if round != none { round.at("uncertainty-precision", default: none) }
    (
      info: (int: pm.at(0), frac: pm.at(1), sign: "+", pm: none, e: info.at("e", default: none)),
      unit: value.at("unit", default: none),
      round: if precision == none {
        none
      } else if type(precision) == dictionary {
        (mode: "places", precision: precision.places)
      } else {
        (mode: "figures", precision: precision)
      },
      args: value.at("args", default: arguments()),
    )
  }
}

#let display-info(value, part: "both", call-args: none) = {
  if call-args != none { value = utility.with-call-args(value, call-args) }
  assert(part in ("both", "value", "error"), message: "display: part must be \"both\", \"value\" or \"error\".")
  if utility.is-undefined(value) {
    return utility.create-result-metadata(value) + text("undefined")
  }
  if not utility.is-finite(utility.as-float(value)) {
    value.round = none
    let named = value.at("args", default: arguments()).named()
    let _ = named.remove("round", default: none)
    value.args = arguments(..named)
  }
  let apply-preferred-units(value, preferred-units) = {
    if preferred-units == () {
      return value
    }

    let use-unit(value, unit, rule) = {
      value.unit = unit
      let named = value.at("args", default: arguments()).named()
      named.insert("alt", rule.preferred.at("alt", default: auto))
      value.args = arguments(..value.at("args", default: arguments()).pos(), ..named)
      value
    }

    for rule in preferred-units {
      if rule.match.unit == value.unit {
        value = use-unit(value, rule.preferred.unit, rule)
        if rule.factor != none {
          value = operations.mul((value, operations.const(rule.factor)))
        }
      } else if not rule.exact-match {
        let units-dict = units.unit-to-dict(value.unit)
        let rule-units-dict = units.unit-to-dict(rule.match.unit)
        if units.contains-unit(units-dict, rule-units-dict) {
          if rule.factor != none {
            value = operations.mul((value, operations.const(rule.factor)))
          }
          value = use-unit(
            value,
            units.multiply-unit((value.unit, units.invert-unit(rule.match.unit), rule.preferred.unit)),
            rule,
          )
        } else if units.contains-unit(units-dict, rule-units-dict.map(x => -x)) {
          value.unit = units.multiply-unit((value.unit, rule.match.unit, units.invert-unit(rule.preferred.unit)))
          if rule.factor != none {
            value = operations.div(value, operations.const(rule.factor))
          }
        }
      }
    }
    return value
  }
  let result = context {
    let value = value
    if value.at("unit", default: none) != none {
      value = apply-preferred-units(value, utility.zcalc-state.get().preferred-units)
    }
    let empty = value.info.int == "" and value.info.frac == ""
    if not empty { value = select-part(value, part, zero.impl.num-state.get()) }
    let args = value.at("args", default: ())
    let displayed-value = if value.at("unit", default: none) == none {
      if empty {
        zero.num(round: utility.as-round(value), ..args)
      } else {
        zero.num(value.info, round: utility.as-round(value), ..args)
      }
    } else if empty {
      zero.zi.units.unit(value.unit, ..args)
    } else {
      zero.zi.units.qty(value.info, value.unit, round: utility.as-round(value), ..args)
    }

    displayed-value.children.slice(1).join()
  }

  utility.create-result-metadata(part-metadata(value, part))
  result
}

#let variable(value, show-error: true) = {
  value = utility.normalise-quantity(value, allow-special: true)
  let x = value.remove("source", default: none)
  display-info(value, part: if show-error { "both" } else { "value" })
}

#let error(value) = {
  value = utility.normalise-quantity(value, allow-special: true)
  display-info(value, part: "error")
}

#let expands(value, depth, frozen) = {
  let free = frozen and not value.at("boundary", default: false)
  value.at("source", default: none) != none and (free or depth == none or depth > 0)
}

#let method-options(show-error, depth, frozen, product, fraction, show-units, exponential) = {
  assert(fraction in ("fraction", "inline"), message: "display: fraction must be \"fraction\" or \"inline\".")
  assert(exponential in ("power", "function"), message: "display: exponential must be \"power\" or \"function\".")
  (
    show-error: show-error,
    depth: depth,
    frozen: frozen,
    product: product,
    fraction: fraction,
    show-units: show-units,
    exponential: exponential,
  )
}

#let product-symbol(o) = {
  let product = if o.product == auto { zero.impl.num-state.get().product } else { o.product }
  if product == none { h(0.15em) } else { product }
}

#let operand(value, o) = {
  if not o.show-units { value.unit = none }
  variable(value, show-error: o.show-error)
}

#let child(o, value) = {
  let is-boundary = value.at("boundary", default: false)
  let free = o.frozen and not is-boundary
  (
    o
      + (
        depth: if o.depth == none { none } else if free { o.depth } else { o.depth - 1 },
        frozen: o.frozen or is-boundary,
      )
  )
}

#let method-tree(value, o) = {
  value = utility.normalise-quantity(value, allow-special: true)
  if not expands(value, o.depth, o.frozen) { return operand(value, o) }

  let c = child(o, value)
  let m(x) = method-tree(x, c)
  let wrap(x, min-prec) = {
    let rendered = m(x)
    if expands(x, c.depth, c.frozen) and method-prec(x) < min-prec { $(#rendered)$ } else { rendered }
  }

  let (operation, data) = (value.source.head, value.source.data)
  if operation == "add" {
    $#data.map(x => wrap(x, 1)).join($+$)$
  } else if operation == "sub" {
    let (a, terms) = data
    let rest = terms.map(t => $- #wrap(t, 2)$).join()
    $#wrap(a, 1) #rest$
  } else if operation == "neg" {
    $- #wrap(data, 2)$
  } else if operation == "abs" {
    $abs(#m(data))$
  } else if operation == "mul" {
    context { $#data.map(x => wrap(x, 2.5)).join(product-symbol(o))$ }
  } else if operation == "div" {
    if o.fraction == "inline" {
      $#wrap(data.at(0), 2.5) \/ #wrap(data.at(1), 2.6)$
    } else {
      $#m(data.at(0))/#m(data.at(1))$
    }
  } else if operation == "pow" {
    let (base, exponent) = data
    if utility.as-float(base) == calc.e {
      if o.exponential == "function" { $exp(#m(exponent))$ } else { $e^(#m(exponent))$ }
    } else {
      $#wrap(base, 3)^(#m(exponent))$
    }
  } else if operation == "root" {
    let (radicand, index) = data
    if utility.as-float(index) == 2 { $sqrt(#m(radicand))$ } else { $root(#m(index), #m(radicand))$ }
  } else if operation == "log" {
    let (val, base) = data
    if utility.as-float(base) == calc.e { $ln(#m(val))$ } else { $log_(#m(base))(#m(val))$ }
  } else if operation == "sin" {
    $sin(#m(data))$
  } else if operation == "cos" {
    $cos(#m(data))$
  } else if operation == "tan" {
    $tan(#m(data))$
  } else if operation == "asin" {
    $arcsin(#m(data))$
  } else if operation == "acos" {
    $arccos(#m(data))$
  } else if operation == "atan" {
    $arctan(#m(data))$
  }
}

#let rss-of(errors, product: auto) = {
  context {
    let product = product-symbol((product: product))
    $sqrt(#errors.map(t => $#if t.count != 1 { $#t.count product$ } (#t.error)^2$).join($+$))$
  }
}

#let deduplicate-errors(errors, consider-value: true) = {
  let errors = errors.filter(x => (
    not x.at("constant", default: false) and utility.as-uncertainty(x) not in (none, 0)
  ))
  let dedup-errors = errors.dedup(key: x => if consider-value {
    (utility.as-uncertainty(x), utility.as-float(x))
  } else { utility.as-uncertainty(x) })
  dedup-errors = if dedup-errors.len() != errors.len() {
    dedup-errors.map(x => (
      count: errors.filter(y => utility.as-uncertainty(y) == utility.as-uncertainty(x)).len(),
      error: x,
    ))
  } else {
    dedup-errors.map(x => (count: 1, error: x))
  }
  dedup-errors
}

#let has-error(x) = not x.at("constant", default: false) and utility.as-uncertainty(x) not in (none, 0)

#let error-method-tree(value, o) = {
  value = utility.normalise-quantity(value, allow-special: true)

  if not expands(value, o.depth, o.frozen) { return error(if o.show-units { value } else { value + (unit: none) }) }

  let c = child(o, value)
  let e(x) = error-method-tree(x, c)
  let v(x) = operand(x, o + (show-error: false))
  let rss(terms) = rss-of(terms, product: o.product)

  let (operation, data) = (value.source.head, value.source.data)
  if operation == "add" or operation == "sub" {
    let terms = if operation == "sub" { (data.first(),) + data.last() } else { data }
    let errors = deduplicate-errors(terms, consider-value: false)
    if errors.len() == 0 { return $0$ }
    rss(errors.map(x => (count: x.count, error: e(x.error))))
  } else if operation == "abs" or operation == "neg" {
    e(data)
  } else if operation == "mul" or operation == "div" {
    let errors = deduplicate-errors(data)
    if errors.len() == 0 { return $0$ }
    context {
      let product = product-symbol(o)
      $#v(value) product #rss(errors.map(x => (count: x.count, error: $#e(x.error) / #v(x.error)$)))$
    }
  } else if operation == "pow" {
    let (base, exponent) = data
    let terms = ()
    if has-error(base) {
      terms.push((
        count: 1,
        error: context {
          let product = product-symbol(o)
          $#v(exponent) product #v(value) product #e(base)/#v(base)$
        },
      ))
    }
    if has-error(exponent) {
      terms.push((count: 1, error: $#v(value) dot ln(#v(base)) dot #e(exponent)$))
    }
    if terms.len() == 0 { return $0$ }
    rss(terms)
  } else if operation == "root" {
    let (radicand, index) = data
    let terms = ()
    if has-error(radicand) {
      terms.push((
        count: 1,
        error: context {
          let product = product-symbol(o)
          $#v(value) product #e(radicand)/(#v(index) product #v(radicand))$
        },
      ))
    }
    if has-error(index) {
      terms.push((count: 1, error: $#v(value) dot ln(#v(radicand)) dot #e(index) / #v(index)^2$))
    }
    if terms.len() == 0 { return $0$ }
    rss(terms)
  } else if operation == "log" {
    let (val, base) = data
    let terms = ()
    if has-error(val) {
      terms.push((count: 1, error: $#e(val) / (#v(val) dot ln(#v(base)))$))
    }
    if has-error(base) {
      terms.push((count: 1, error: $#v(value) dot #e(base) / (#v(base) dot ln(#v(base)))$))
    }
    if terms.len() == 0 { return $0$ }
    rss(terms)
  } else if operation == "sin" {
    if not has-error(data) { return $0$ }
    $abs(cos(#v(data))) dot #e(data)$
  } else if operation == "cos" {
    if not has-error(data) { return $0$ }
    $abs(sin(#v(data))) dot #e(data)$
  } else if operation == "tan" {
    if not has-error(data) { return $0$ }
    $#e(data) / cos^2(#v(data))$
  } else if operation == "asin" or operation == "acos" {
    if not has-error(data) { return $0$ }
    $#e(data) / sqrt(1 - #v(data)^2)$
  } else if operation == "atan" {
    if not has-error(data) { return $0$ }
    $#e(data) / (1 + #v(data)^2)$
  }
}

