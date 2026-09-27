#import "quantity.typ": _make-quantity, quantity, set-quantity
#import "converter.typ" as conv: _get, invert-unit, multiply-unit, operate-unit, power-unit, root-unit, rss, rss-method
#import "utils.typ"

#let neg(
  q,
  method: q => {
    $-$ + if q.source == "add" { $(#q.method)$ } else { q.method }
  },
  error-method: q => q.error-method,
  ..formatting,
) = {
  let value = q.value

  _make-quantity(
    ..q,
    value: -value,
    round-mode: "figures",
    method: method(q),
    error: q.error,
    error-method: error-method(q),
    ..formatting,
  )
}

#let add(
  ..qnts,
  method: qnts => {
    qnts
      .map(q => {
        if q.value < 0 { $(#q.method)$ } else { q.method }
      })
      .join($+$)
  },
  error-method: qnts => conv.rss-method(..qnts.map(q => q.error-method)),
) = {
  let formatting = qnts.named()
  let qnts = qnts.pos()
  let units = _get("unit", ..qnts)
  let values = _get("value", ..qnts)
  let places = _get("places", ..qnts)
  let errors = _get("error", ..qnts)

  assert(
    units.all(i => i.sorted() == units.first().sorted()),
    message: "Adding quantities only allow for the same units.",
  )
  let new-places = conv.add-signify(..qnts)
  let result = values.sum()
  let new-error = conv.rss(..errors)

  _make-quantity(
    value: result,
    unit: units.at(0),
    places: new-places,
    round-mode: "places",
    method: method(qnts),
    error: new-error,
    error-method: error-method(qnts),
    source: "add",
    ..formatting,
  )
}

#let sub(
  q1,
  q2,
  method: (q1, q2) => {
    if q1.source in ("sub", "add") { q1.method = $(#q1.method)$ }
    if q2.source in ("sub", "add") { q2.method = $(#q2.method)$ }
    $#q1.method - #q2.method$
  },
  error-method: (q1, q2) => conv.rss-method(q1.error-method, q2.error-method),
  ..formatting,
) = {
  let (v1, v2) = _get("value", q1, q2)
  let (u1, u2) = _get("unit", q1, q2)
  assert(
    u1.sorted() == u2.sorted(),
    message: "Subtraction requires quantities in the same unit.",
  )

  let result = v1 - v2
  let new-error = conv.rss(q1.error, q2.error)

  _make-quantity(
    value: result,
    unit: u1,
    places: conv.add-signify(q1, q2),
    round-mode: "places",
    method: method(q1, q2),
    error: new-error,
    error-method: error-method(q1, q2),
    source: "sub",
    ..formatting,
  )
}

#let mul(
  ..qnts,
  method: qnts => {
    qnts.map(q => if q.source in ("add", "sub") { $(#q.method)$ } else { q.method }).join($times$)
  },
  error-method: (qnts, value-method) => {
    let terms = qnts.map(q => $(#q.error-method)/(#q.method)$)
    $#value-method times #conv.rss-method(..terms)$
  },
) = {
  let formatting = qnts.named()
  let qnts = qnts.pos()
  let values = _get("value", ..qnts)
  let errors = _get("error", ..qnts)
  let units = _get("unit", ..qnts).sum()
  let new-units = multiply-unit(..units)
  let result = values.product()
  let value-method = method(qnts)

  // relative errors add in quadrature: σf = |f| · sqrt(Σ(σi/xi)²)
  let rel-terms = qnts.map(q => if q.value != 0 { q.error / q.value } else { 0 })
  let new-error = calc.abs(result) * conv.rss(..rel-terms)

  _make-quantity(
    value: result,
    unit: new-units,
    figures: conv.mul-signify(..qnts),
    round-mode: "figures",
    method: value-method,
    error: new-error,
    error-method: error-method(qnts, value-method),
    source: "mul",
    ..formatting,
  )
}

#let inv(
  q,
  method: q => $1/#q.method$,
  error-method: (q, value-method) => $#value-method times (#q.error-method)/(#q.method)$,
  ..formatting,
) = {
  let (value, unit, figures) = q
  let new-unit = invert-unit(..unit)
  let value-method = method(q)
  let new-error = calc.abs(1 / value) * (q.error / value)

  _make-quantity(
    value: 1 / value,
    unit: new-unit,
    figures: figures,
    round-mode: "figures",
    method: value-method,
    error: new-error,
    error-method: error-method(q, value-method),
    ..formatting,
  )
}

#let div(
  q1,
  q2,
  method: (q1, q2) => {
    $#q1.method/#q2.method$
  },
  error-method: (q1, q2, value-method) => {
    let terms = ($(#q1.error-method)/(#q1.method)$, $(#q2.error-method)/(#q2.method)$)
    $#value-method times #conv.rss-method(..terms)$
  },
  ..formatting,
) = {
  let (v1, v2) = _get("value", q1, q2)
  let (u1, u2) = _get("unit", q1, q2)
  let new-unit = multiply-unit(..u1, ..invert-unit(..u2))
  let result = v1 / v2
  let value-method = method(q1, q2)
  let new-error = calc.abs(result) * conv.rss(q1.error / v1, q2.error / v2)

  _make-quantity(
    value: result,
    unit: new-unit,
    figures: conv.mul-signify(q1, q2),
    round-mode: "figures",
    method: value-method,
    error: new-error,
    error-method: error-method(q1, q2, value-method),
    ..formatting,
  )
}

#let pow(
  q1,
  q2,
  method: (q1, q2) => {
    $(#q1.method)^#q2.method$
  },
  error-method: (q1, q2, value-method, new-value) => {
    let terms = ($(#q2.method times #value-method)/(#q1.method) times (#q1.error-method)$,)
    if q2.error != 0 {
      terms += ($#value-method times ln(#q1.method) times (#q2.error-method)$,)
    }
    conv.rss-method(..terms)
  },
  ..formatting,
) = {
  let (v1, v2) = _get("value", q1, q2)
  let (u1, u2) = _get("unit", q1, q2)
  let new-value
  let new-unit
  let new-figures = q1.figures
  assert(u2 == (), message: "The exponent must be dimensionless.")
if type(v2) == int or int(v2) == v2{
    new-value = calc.pow(v1, v2)
    new-unit = power-unit(..u1, v2)
  } else {
    assert(u1 == (), message: "Fractional exponentiation is only allowed for dimensionless quantity.")
    new-value = calc.pow(v1, v2)
    new-unit = ()
    new-figures = conv.exp-signify(q2)
  }
  let value-method = method(q1, q2)

  // f = v1^v2. ∂f/∂v1 = v2·f/v1, ∂f/∂v2 = f·ln(v1) (only if the
  // exponent itself carries an error and v1 > 0).
  let terms = (v2 * new-value / v1 * q1.error,)
  if q2.error != 0 and v1 > 0 {
    terms += (new-value * calc.ln(v1) * q2.error,)
  }
  let new-error = conv.rss(..terms)

  _make-quantity(
    value: new-value,
    unit: new-unit,
    figures: new-figures,
    round-mode: "figures",
    method: value-method,
    error: new-error,
    error-method: error-method(q1, q2, value-method, new-value),
    ..formatting,
  )
}

#let root(
  q,
  n,
  method: (q, n) => {
    $(#q.method)^(1/#n)$
  },
  error-method: (q, n, value-method) => {
    $(#value-method)/(#n times #q.method) times (#q.error-method)$
  },
  ..formatting,
) = {
  let new-unit = root-unit(..q.unit, n)
  let new-value = calc.root(q.value, n)
  let value-method = method(q, n)
  let new-error = calc.abs(new-value / (n * q.value)) * q.error

  _make-quantity(
    value: new-value,
    unit: new-unit,
    figures: q.figures,
    round-mode: "figures",
    method: value-method,
    error: new-error,
    error-method: error-method(q, n, value-method),
    ..formatting,
  )
}

#let log(
  base: 10,
  q,
  method: (base, q) => {
    if base == 10 {
      $log (#q.method)$
    } else if base in (int, float) {
      $log_#base (#q.method)$
    } else {
      $log_#base.method (#q.method)$
    }
  },
  error-method: (base, q, value-method, b-value, b-error, b-method) => {
    let terms = ($(#q.error-method)/(#q.method times ln(#b-method))$,)
    if b-error != 0 {
      terms += ($(ln(#q.method) times (#base.error-method))/(#b-method times (ln(#b-method))^2)$,)
    }
    conv.rss-method(..terms)
  },
  ..formatting,
) = {
  let value = q.value
  let unit = q.unit
  assert(unit == (), message: "Logarithms only accept dimensionless quantity.")

  let new-places = q.figures
  let b-value
  let b-error = 0
  let b-method
  if type(base) in (int, float) {
    b-value = base
    b-method = base
    value = calc.log(base: base, value)
  } else {
    assert(base.unit == (), message: "Logarithm's base must be a dimensionless quantity.")
    b-value = base.value
    b-error = base.error
    b-method = base.method
    value = calc.log(base: base.value, value)
  }

  let value-method = method(base, q)

  let terms = (q.error / (q.value * calc.ln(b-value)),)
  if b-error != 0 {
    terms += (calc.ln(q.value) / (b-value * calc.pow(calc.ln(b-value), 2)) * b-error,)
  }
  let new-error = conv.rss(..terms)

  _make-quantity(
    value: value,
    places: new-places,
    round-mode: "places",
    method: value-method,
    error: new-error,
    error-method: error-method(base, q, value-method, b-value, b-error, b-method),
    ..formatting,
  )
}

#let ln(
  qnt,
  method: q => {
    $ln (#q.method)$
  },
  error-method: (q, value-method) => $(#q.error-method)/(#q.method)$,
  ..formatting,
) = {
  assert(qnt.unit == (), message: "Natural logarithm only accepts dimensionless quantity")
  let new-value = calc.ln(qnt.value)
  let value-method = method(qnt)
  let new-error = calc.abs(qnt.error / qnt.value)

  _make-quantity(
    value: new-value,
    places: qnt.figures,
    round-mode: "places",
    method: value-method,
    error: new-error,
    error-method: error-method(qnt, value-method),
    ..formatting,
  )
}

#let exp(
  q,
  method: q => {
    $exp(#q.method)$
  },
  ..formatting,
) = {
  assert(q.unit == (), message: "Exponentiation only accepts dimensionless quantity.")

  _make-quantity(
    value: calc.exp(q.value),
    figures: conv.exp-signify(q),
    round-mode: "figures",
    method: method(q),
    ..formatting,
  )
}

#let solver(
  func,
  init: none,
  tolerance: 1e-6,
  max-iterations: 20,
  ..formatting,
) = {
  assert(
    init != none and type(init) == dictionary,
    message: "Initial value of the target variable must be specified in terms of quantity",
  )

  let reset(x, origin: init, ..formatting) = {
    set-quantity(init, value: x, ..formatting)
  }

  let new-func(x) = func(reset(x, origin: init)).value

  reset(
    utils.newton-solver(
      init: init.value,
      tolerance: tolerance,
      max-iterations: max-iterations,
      new-func,
    ),
    origin: init,
    ..formatting
  )
}

#let new-factor(from, to, ..formatting) = {
  let (from, to) = (from, to).map(n => if type(n) != dictionary { exact(..n) } else { n })
  let inverted = div(from, to, figures: 10, ..formatting)
  div(to, from, figures: 10, ..formatting) + (inv: inverted)
}


