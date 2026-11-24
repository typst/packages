// A small expression tree: enough algebra to state a mechanics result in
// closed form, show it with the declared numbers substituted, and evaluate it.
//
// The load-bearing idea is `quantity`, which carries both the symbol it prints
// as and the number it stands for. One tree therefore renders three ways —
// `g sin theta`, `9.81 sin 30°`, `4.91` — without being built three times.

// ── Number formatting ────────────────────────────────────────────────────────

// Rounds to `digits` significant figures and keeps the trailing zeros, so
// results read like textbook answers: 34.0, 2.36, 0.289.
#let format-number(value, digits: 3) = {
  if value == none { return "?" }
  // A component that only differs from zero by the rounding of a sine reads as
  // zero, rather than as a string of zeros carried out to the last digit or as
  // a negative zero.
  let value = if calc.abs(value) < 1e-9 { 0 } else { value }
  let absolute-value = calc.abs(value)
  let decimal-places = if absolute-value == 0 {
    2
  } else {
    calc.clamp(
      digits - 1 - int(calc.floor(calc.log(absolute-value, base: 10))),
      0,
      6,
    )
  }
  let rounded-value = calc.round(value, digits: decimal-places)
  if decimal-places == 0 { return str(calc.round(rounded-value)) }

  let decimal-parts = str(rounded-value).split(".")
  let whole-number-part = decimal-parts.at(0)
  let fractional-part = if decimal-parts.len() > 1 {
    decimal-parts.at(1)
  } else {
    ""
  }
  while fractional-part.len() < decimal-places { fractional-part += "0" }
  whole-number-part + "." + fractional-part
}

#let format-angle(degrees) = {
  let rounded-degrees = calc.round(degrees, digits: 1)
  let displayed-degrees = if rounded-degrees == calc.round(rounded-degrees) {
    str(calc.round(rounded-degrees))
  } else {
    str(rounded-degrees)
  }
  displayed-degrees + "°"
}

// ── Leaves ───────────────────────────────────────────────────────────────────

#let number(value) = (kind: "number", value: float(value))

// `substituted` overrides what the numeric rendering prints, which is how an
// angle stored in radians still shows up as `30°`.
#let quantity(symbol, value: none, substituted: auto) = (
  kind: "quantity",
  symbol: symbol,
  value: if value == none { none } else { float(value) },
  substituted: substituted,
)

// Turns a declared property into a quantity. A number keeps the symbol the
// package would print for it; content the author wrote replaces that symbol,
// which is how `mass: $m$` stays symbolic all the way to the answer.
#let declared(value, symbol) = {
  if value == none { return none }
  if type(value) in (int, float) { return quantity(symbol, value: value) }
  quantity(value)
}

#let declared-angle(value, symbol) = quantity(
  symbol,
  value: value.rad(),
  substituted: [#format-angle(value.deg())],
)

#let is-number(term) = term.kind == "number"
#let is-zero(term) = is-number(term) and term.value == 0
#let is-one(term) = is-number(term) and term.value == 1

// ── Building terms ───────────────────────────────────────────────────────────
//
// The constructors fold plain numbers and drop identities as they build, so a
// caller can assemble the general form of an equation and let the terms that
// do not apply to this particular situation disappear on their own.

#let sum(..parts) = {
  let nonconstant-terms = ()
  let constant-sum = 0.0
  for part in parts.pos() {
    let additive-terms = if part.kind == "sum" { part.terms } else { (part,) }
    for additive-term in additive-terms {
      if is-number(additive-term) {
        constant-sum += additive-term.value
      } else {
        nonconstant-terms.push(additive-term)
      }
    }
  }
  // A constant leads the sum, so a partly evaluated expression reads the way it
  // would be written by hand: `4.90 - 8.50 mu_k`, not `-8.50 mu_k + 4.90`.
  if constant-sum != 0 { nonconstant-terms.insert(0, number(constant-sum)) }
  if nonconstant-terms.len() == 0 { return number(0) }
  if nonconstant-terms.len() == 1 { return nonconstant-terms.first() }

  // Something is added to before anything is taken away from it, so a term that
  // is not subtracted leads when there is one: `F - m g sin theta`, not
  // `-m g sin theta + F`.
  if nonconstant-terms.first().kind == "negated" {
    let leading-index = nonconstant-terms.position(
      additive-term => additive-term.kind != "negated",
    )
    if leading-index != none {
      nonconstant-terms = (
        (nonconstant-terms.at(leading-index),)
          + nonconstant-terms.slice(0, leading-index)
          + nonconstant-terms.slice(leading-index + 1)
      )
    }
  }
  (kind: "sum", terms: nonconstant-terms)
}

// Negating a sum negates its terms, so a balance that comes out as the negative
// of what was summed still reads as a difference: `F - m g`, not `-(m g - F)`.
#let negated(term) = {
  if is-number(term) { return number(-term.value) }
  if term.kind == "negated" { return term.term }
  if term.kind == "sum" { return sum(..term.terms.map(negated)) }
  (kind: "negated", term: term)
}

#let difference(left, right) = sum(left, negated(right))

#let product(..parts) = {
  let nonconstant-factors = ()
  let constant-product = 1.0
  for part in parts.pos() {
    let multiplicative-term = part
    if multiplicative-term.kind == "negated" {
      constant-product *= -1
      multiplicative-term = multiplicative-term.term
    }
    let multiplicative-factors = if multiplicative-term.kind == "product" {
      multiplicative-term.factors
    } else {
      (multiplicative-term,)
    }
    for factor in multiplicative-factors {
      if is-number(factor) {
        constant-product *= factor.value
      } else {
        nonconstant-factors.push(factor)
      }
    }
  }
  if constant-product == 0 { return number(0) }
  if nonconstant-factors.len() == 0 { return number(constant-product) }

  let product-is-negative = constant-product < 0
  if calc.abs(constant-product) != 1 {
    nonconstant-factors.insert(0, number(calc.abs(constant-product)))
  }
  let combined-product = if nonconstant-factors.len() == 1 {
    nonconstant-factors.first()
  } else {
    (kind: "product", factors: nonconstant-factors)
  }
  if product-is-negative { negated(combined-product) } else { combined-product }
}

// Divides `term` by `factor` when every one of its terms visibly contains that
// factor. Returning `none` when it does not is what keeps `ratio` from
// inventing a cancellation that is not there.
#let without-factor(term, factor) = {
  if term == factor { return number(1) }
  if term.kind == "negated" {
    let divided-inner-term = without-factor(term.term, factor)
    return if divided-inner-term == none {
      none
    } else {
      negated(divided-inner-term)
    }
  }
  if term.kind == "sum" {
    let divided-terms = ()
    for additive-term in term.terms {
      let divided-term = without-factor(additive-term, factor)
      if divided-term == none { return none }
      divided-terms.push(divided-term)
    }
    return sum(..divided-terms)
  }
  if term.kind == "product" and term.factors.contains(factor) {
    let remaining-factors = term.factors.filter(
      candidate-factor => candidate-factor != factor,
    )
    return product(..remaining-factors)
  }
  none
}

#let ratio(numerator, denominator) = {
  assert(
    not is-zero(denominator),
    message: "typed-physics: division by zero while building an expression",
  )
  if is-one(denominator) { return numerator }
  if is-number(numerator) and is-number(denominator) {
    return number(numerator.value / denominator.value)
  }
  let cancelled-numerator = without-factor(numerator, denominator)
  if cancelled-numerator != none { return cancelled-numerator }
  (kind: "ratio", numerator: numerator, denominator: denominator)
}

#let power(base, exponent) = {
  if is-one(exponent) { return base }
  (kind: "power", base: base, exponent: exponent)
}

#let trigonometric-function(name, argument) = {
  if is-number(argument) {
    let evaluated-value = if name == "sin" {
      calc.sin(argument.value)
    } else if name == "cos" {
      calc.cos(argument.value)
    } else {
      calc.tan(argument.value)
    }
    return number(evaluated-value)
  }
  (kind: "function", name: name, argument: argument)
}

#let sine(argument) = trigonometric-function("sin", argument)
#let cosine(argument) = trigonometric-function("cos", argument)
#let tangent(argument) = trigonometric-function("tan", argument)

// ── Evaluating ───────────────────────────────────────────────────────────────

// The value of a tree, or `none` as soon as any leaf in it is a symbol without
// a declared number. Callers use that `none` to decide whether a question is
// answerable at all rather than to print a wrong number.
#let value-of(term) = {
  let term-kind = term.kind
  if term-kind == "number" or term-kind == "quantity" { return term.value }

  if term-kind == "negated" {
    let inner-value = value-of(term.term)
    return if inner-value == none { none } else { -inner-value }
  }

  if term-kind == "sum" {
    let evaluated-sum = 0.0
    for additive-term in term.terms {
      let term-value = value-of(additive-term)
      if term-value == none { return none }
      evaluated-sum += term-value
    }
    return evaluated-sum
  }

  if term-kind == "product" {
    let evaluated-product = 1.0
    for factor in term.factors {
      let factor-value = value-of(factor)
      if factor-value == none { return none }
      evaluated-product *= factor-value
    }
    return evaluated-product
  }

  if term-kind == "ratio" {
    let numerator-value = value-of(term.numerator)
    let denominator-value = value-of(term.denominator)
    if numerator-value == none or denominator-value == none or denominator-value == 0 {
      return none
    }
    return numerator-value / denominator-value
  }

  if term-kind == "power" {
    let base-value = value-of(term.base)
    let exponent-value = value-of(term.exponent)
    if base-value == none or exponent-value == none { return none }
    return calc.pow(base-value, exponent-value)
  }

  if term-kind == "function" {
    let argument-value = value-of(term.argument)
    if argument-value == none { return none }
    if term.name == "sin" { return calc.sin(argument-value) }
    if term.name == "cos" { return calc.cos(argument-value) }
    return calc.tan(argument-value)
  }
  none
}

#let is-known(term) = value-of(term) != none

// Puts a number in place of every quantity that has one and leaves the rest
// standing. The constructors fold as they rebuild, so a mixed expression comes
// back part arithmetic and part algebra: `g sin θ - μ_k g cos θ` with a numeric
// gravity and angle but a symbolic coefficient becomes `4.91 - 8.50 μ_k`.
#let evaluated-where-known(term) = {
  let term-kind = term.kind

  if term-kind == "number" { return term }
  if term-kind == "quantity" {
    return if term.value == none { term } else { number(term.value) }
  }
  if term-kind == "negated" { return negated(evaluated-where-known(term.term)) }
  if term-kind == "sum" {
    return sum(..term.terms.map(evaluated-where-known))
  }
  if term-kind == "product" {
    return product(..term.factors.map(evaluated-where-known))
  }
  if term-kind == "ratio" {
    return ratio(
      evaluated-where-known(term.numerator),
      evaluated-where-known(term.denominator),
    )
  }
  if term-kind == "power" {
    return power(
      evaluated-where-known(term.base),
      evaluated-where-known(term.exponent),
    )
  }
  if term-kind == "function" {
    return trigonometric-function(
      term.name,
      evaluated-where-known(term.argument),
    )
  }
  term
}

// The magnitude of a term, kept in symbolic form: a negative expression comes
// back negated rather than wrapped in an absolute-value bar that no one would
// write by hand. A term whose value is not known yet is judged by its shape,
// which is enough whenever the sign was built in rather than computed.
#let magnitude-of(term) = {
  let evaluated-value = value-of(term)
  if evaluated-value != none {
    return if evaluated-value < 0 { negated(term) } else { term }
  }
  if term.kind == "negated" { return term.term }
  term
}

// ── Rendering ────────────────────────────────────────────────────────────────

#let _operator-precedence(term) = {
  let term-kind = term.kind
  if term-kind == "sum" {
    1
  } else if term-kind == "negated" {
    1
  } else if term-kind == "product" {
    2
  } else if term-kind == "function" {
    3
  } else { 4 }
}

// Renders as math content. `substitute: true` prints every quantity as the
// number it stands for, which is the middle line of a worked solution.
#let math-of(term, substitute: false) = {
  let render-term(part) = math-of(part, substitute: substitute)
  let render-with-grouping(part, required-precedence) = {
    let rendered-part = render-term(part)
    if _operator-precedence(part) < required-precedence {
      $(#rendered-part)$
    } else {
      rendered-part
    }
  }
  let term-kind = term.kind

  if term-kind == "number" { return $#format-number(term.value)$ }

  if term-kind == "quantity" {
    if not substitute { return term.symbol }
    if term.substituted != auto { return term.substituted }
    return $#format-number(term.value)$
  }

  if term-kind == "negated" {
    return $-#render-with-grouping(term.term, 2)$
  }

  if term-kind == "sum" {
    let rendered-terms = ()
    for additive-term in term.terms {
      if additive-term.kind == "negated" {
        rendered-terms.push($- #render-with-grouping(additive-term.term, 2)$)
      } else if rendered-terms.len() == 0 {
        rendered-terms.push(render-term(additive-term))
      } else {
        rendered-terms.push($+ #render-term(additive-term)$)
      }
    }
    return rendered-terms.join($ $)
  }

  // Symbols sit next to each other the way they are written by hand, but two
  // numbers next to each other need the dot to stay readable.
  if term-kind == "product" {
    let shows-a-number(factor) = {
      if factor.kind == "number" { return true }
      factor.kind == "quantity" and substitute and factor.substituted == auto
    }
    let rendered-factors = ()
    for (index, factor) in term.factors.enumerate() {
      let rendered-factor = render-with-grouping(factor, 2)
      if index == 0 {
        rendered-factors.push(rendered-factor)
      } else if (
        shows-a-number(term.factors.at(index - 1))
          and shows-a-number(factor)
      ) {
        rendered-factors.push($dot.op #rendered-factor$)
      } else {
        rendered-factors.push($thin #rendered-factor$)
      }
    }
    return rendered-factors.join()
  }

  if term-kind == "ratio" {
    return $(#render-term(term.numerator)) / (#render-term(term.denominator))$
  }

  if term-kind == "power" {
    return $#render-with-grouping(term.base, 4)^#render-term(term.exponent)$
  }

  if term-kind == "function" {
    let function-name = if term.name == "sin" {
      $sin$
    } else if term.name == "cos" {
      $cos$
    } else {
      $tan$
    }
    return $#function-name #render-with-grouping(term.argument, 3)$
  }

  panic("typed-physics: cannot render expression of kind " + repr(term-kind))
}

#let numeric-math-of(term, digits: 3) = {
  let evaluated-value = value-of(term)
  if evaluated-value == none { return none }
  $#format-number(evaluated-value, digits: digits)$
}

#let _with-unit(rendered-value, unit) = if unit == none {
  rendered-value
} else {
  $#rendered-value thin #unit$
}

// What is left of an expression once every quantity that has a number is
// replaced by it. A fully known term reaches a value, a fully symbolic one does
// not move, and a mixed one lands somewhere in between.
#let _partially-evaluated(term) = {
  let folded-term = evaluated-where-known(term)
  if folded-term == term { none } else { folded-term }
}

// A stated quantity is the value when every quantity behind it carries one, and
// otherwise the expression carried as far as the declared numbers reach. Both
// the mechanics and the electrical report state their results this way, because
// both are reading the same kind of tree.
#let stated-value(symbol, term, unit: none) = {
  let numeric-value = numeric-math-of(term)
  if numeric-value != none {
    return $#symbol = #_with-unit(numeric-value, unit)$
  }
  let folded-term = _partially-evaluated(term)
  if folded-term != none {
    return $#symbol = #_with-unit(math-of(folded-term), unit)$
  }
  $#symbol = #math-of(term)$
}
