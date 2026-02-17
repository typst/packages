#import "quantity.typ": _get, exact, quantity, set-quantity
#import "converter.typ": invert-unit, multiply-unit, operate-unit, power-unit, root-unit
#import "utils.typ"

#let neg(
  qnt,
  method: qnt => {
    $-$ + if qnt.source == "add" { $(#qnt.method)$ } else { qnt.method }
  },
  ..formatting,
) = {
  let (value, unit, figures) = qnt
  let q-result = quantity(
    -value,
    ..unit,
    figures: figures,
    round-mode: "figures",
    method: method(qnt),
  )
  set-quantity(q-result, ..formatting.named())
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
) = {
  let formatting = qnts.named()
  let qnts = qnts.pos()
  let units = _get("unit", ..qnts)
  let values = _get("value", ..qnts)
  let places = _get("places", ..qnts)
  let figures = _get("places", ..qnts)

  assert(
    units.all(i => i.sorted() == units.first().sorted()),
    message: "Adding quantities only allow for the same units.",
  )
  let new-places = calc.min(..places)
  let new-figures = calc.min(..figures)
  let result = values.sum()
  let q-result = quantity(
    result,
    ..units.at(0),
    places: new-places,
    figures: new-figures,
    round-mode: "places",
    method: method(qnts),
    source: "add",
  )
  set-quantity(q-result, ..formatting)
}

#let sub(
  q1,
  q2,
  method: (q1, q2) => {
    if q1.source in ("sub", "add") { q1.method = $(#q1.method)$ }
    if q2.source in ("sub", "add") { q2.method = $(#q2.method)$ }
    $#q1.method - #q2.method$
  },
  ..formatting,
) = {
  let (v1, v2) = _get("value", q1, q2)
  let (u1, u2) = _get("unit", q1, q2)
  assert(
    u1.sorted() == u2.sorted(),
    message: "Subtraction requires quantities in the same unit.",
  )
  let places = _get("places", q1, q2)
  let figures = _get("figures", q1, q2)
  
  let new-places = calc.min(..places)
  let new-figures = calc.min(..figures)
  let result =v1 - v2
  let q-result = quantity(
    result,
    ..u1,
    places: new-places,
    figures: new-figures,
    round-mode: "places",
    method: method(q1, q2),
    source: "sub",
  )
  set-quantity(q-result, ..formatting)
}

#let mul(
  ..qnts,
  method: qnts => {
    qnts.map(q => if q.source in ("add", "sub") { $(#q.method)$ } else { q.method }).join($times$)
  },
) = {
  let formatting = qnts.named()
  let qnts = qnts.pos()
  let values = _get("value", ..qnts)
  let units = _get("unit", ..qnts).sum()
  let figures = _get("figures", ..qnts)
  let new-figures = calc.min(..figures)
  let new-units = multiply-unit(..units)
  let q-result = quantity(
    values.product(),
    ..new-units,
    figures: new-figures,
    round-mode: "figures",
    method: method(qnts),
    source: "mul",
  )
  set-quantity(q-result, ..formatting)
}

#let inv(qnt, method: qnt => $1/qnt.method$, ..formatting) = {
  let (value, unit, figures) = qnt
  let new-unit = invert-unit(..unit)
  let q-result = quantity(
    1 / value,
    ..new-unit,
    figures: figures,
    round-mode: "figures",
    method: method(qnt),
  )
  set-quantity(q-result, ..formatting)
}

#let div(
  q1,
  q2,
  method: (q1, q2) => {
    $#q1.method/#q2.method$
  },
  ..formatting,
) = {
  let (v1, v2) = _get("value", q1, q2)
  let (u1, u2) = _get("unit", q1, q2)
  let new-unit = multiply-unit(..u1, ..invert-unit(..u2))
  let figures = _get("figures", q1, q2)
  let new-figures = calc.min(..figures)
  let q-result = quantity(
    v1 / v2,
    ..new-unit,
    figures: new-figures,
    round-mode: "figures",
    method: method(q1, q2),
  )
  set-quantity(q-result, ..formatting)
}

#let pow(
  q1,
  q2,
  method: (q1, q2) => {
    $(#q1.method)^#q2.method$
  },
  ..formatting,
) = {
  let (v1, v2) = _get("value", q1, q2)
  let (u1, u2) = _get("unit", q1, q2)
  let new-value
  let new-unit
  let new-figures = q1.figures
  assert(u2 == (), message: "The exponent must be dimensionless.")
  if type(v2) == int {
    new-value = calc.pow(v1, v2)
    new-unit = power-unit(..u1, v2)
  } else {
    assert(u1 == (), message: "Fractional exponentiation is only allowed for dimensionless quantity.")
    new-value = calc.pow(v1, v2)
    new-unit = ()
    new-figures = q2.places
  }
  let q-result = quantity(
    new-value,
    ..new-unit,
    figures: new-figures,
    round-mode: "figures",
    method: method(q1, q2),
    ..formatting,
  )
  set-quantity(q-result, ..formatting)
}

#let root(
  qnt,
  n,
  method: (q, n) => {
    $(#q.method)^(1/#n)$
  },
  ..formatting,
) = {
  let new-unit = root-unit(..qnt.unit, n)
  let q-result = quantity(
    calc.root(qnt.value, n),
    ..new-unit,
    figures: qnt.figures,
    round-mode: "figures",
    method: method(qnt, n),
    ..formatting,
  )
  set-quantity(q-result, ..formatting)
}

#let log(
  base: 10,
  qnt,
  method: (base, q) => {
    if base == 10 {
      $log (#q.method)$
    } else if base in (int, float) {
      $log_#base (#q.method)$
    } else {
      $log_#base.method (#q.method)$
    }
  },
  ..formatting,
) = {
  let value = qnt.value
  let unit = qnt.unit
  assert(unit == (), message: "Logarithms only accept dimensionless quantity.")

  let new-places = qnt.figures
  if type(base) in (int, float) {
    value = calc.log(base: base, value)
  } else {
    assert(base.unit == (), message: "Logarithm's base must be a dimensionless quantity.")
    value = calc.log(base: base.value, value)
  }
  let q-result = quantity(
    value,
    places: new-places,
    rounder: calc.round.with(digits: new-places),
    round-mode: "places",
    method: method(base, qnt),
    ..formatting,
  )
  set-quantity(q-result, ..formatting)
}

#let ln(
  qnt,
  method: q => {
    $ln (#q.method)$
  },
  ..formatting,
) = {
  assert(qnt.unit == (), message: "Natural logarithm only accepts dimensionless quantity")
  let q-result = quantity(
    calc.ln(qnt.value),
    places: qnt.figures,
    round-mode: "places",
    method: method(qnt),
    ..formatting,
  )
  set-quantity(q-result, ..formatting)
}

#let exp(
  qnt,
  method: q => {
    $exp(#q.method)$
  },
  ..formatting,
) = {
  assert(qnt.unit == (), message: "Exponentiation only accepts dimensionless quantity.")
  let q-result = quantity(
    calc.exp(qnt.value),
    figures: qnt.places,
    round-mode: "figures",
    method: method(qnt),
    ..formatting,
  )
  set-quantity(q-result, ..formatting)
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

  let make-quantity(x, origin: init) = {
    set-quantity(init, value: x)
  }

  let new-func(x) = func(make-quantity(x, origin: init)).value

  let q-result = make-quantity(
    utils.newton-solver(
      init: init.value,
      tolerance: tolerance,
      max-iterations: max-iterations,
      new-func,
    ),
    origin: init,
  )
  set-quantity(q-result, ..formatting)
}

#let new-factor(from, to, ..formatting) = {
  let (from, to) = (from, to).map(n => if type(n) != dictionary { exact(..n) } else { n })
  let inverted = div(from, to, figures: 10, ..formatting)
  div(to, from, figures: 10, ..formatting) + (inv: inverted)
}


