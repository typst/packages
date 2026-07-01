#import "quantity.typ": _make-quantity, quantity, set-quantity
#import "converter.typ" as conv: _get, invert-unit, multiply-unit, operate-unit, power-unit, root-unit
#import "utils.typ"

#let neg(
  q,
  method: q => {
    $-$ + if q.source == "add" { $(#q.method)$ } else { q.method }
  },
  ..formatting,
) = {
  let value = q.value

  _make-quantity(
    ..q,
    value: -value,
    round-mode: "figures",
    method: method(q),
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
) = {
  let formatting = qnts.named()
  let qnts = qnts.pos()
  let units = _get("unit", ..qnts)
  let values = _get("value", ..qnts)
  let places = _get("places", ..qnts)

  assert(
    units.all(i => i.sorted() == units.first().sorted()),
    message: "Adding quantities only allow for the same units.",
  )
  let new-places = conv.add-signify(..qnts)
  let result = values.sum()

  _make-quantity(
    value: result,
    unit: units.at(0),
    places: new-places,
    method: method(qnts),
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
  ..formatting,
) = {
  let (v1, v2) = _get("value", q1, q2)
  let (u1, u2) = _get("unit", q1, q2)
  assert(
    u1.sorted() == u2.sorted(),
    message: "Subtraction requires quantities in the same unit.",
  )

  let result = v1 - v2

  _make-quantity(
    value: result,
    unit: u1,
    places: conv.add-signify(q1, q2),
    round-mode: "places",
    method: method(q1, q2),
    source: "sub",
    ..formatting,
  )
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
  let new-units = multiply-unit(..units)

  _make-quantity(
    value: values.product(),
    unit: new-units,
    figures: conv.mul-signify(..qnts),
    round-mode: "figures",
    method: method(qnts),
    source: "mul",
    ..formatting,
  )
}

#let inv(q, method: q => $1/#q.method$, ..formatting) = {
  let (value, unit, figures) = q
  let new-unit = invert-unit(..unit)

  _make-quantity(
    value: 1 / value,
    unit: new-unit,
    figures: figures,
    round-mode: "figures",
    method: method(q),
    ..formatting,
  )
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

  _make-quantity(
    value: v1 / v2,
    unit: new-unit,
    figures: conv.mul-signify(q1, q2),
    round-mode: "figures",
    method: method(q1, q2),
    ..formatting,
  )
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
    new-figures = conv.exp-signify(q2)
  }

  _make-quantity(
    value: new-value,
    unit: new-unit,
    figures: new-figures,
    round-mode: "figures",
    method: method(q1, q2),
    ..formatting,
  )
}

#let root(
  q,
  n,
  method: (q, n) => {
    $(#q.method)^(1/#n)$
  },
  ..formatting,
) = {
  let new-unit = root-unit(..q.unit, n)

  _make-quantity(
    value: calc.root(q.value, n),
    unit: new-unit,
    figures: q.figures,
    round-mode: "figures",
    method: method(q, n),
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
  ..formatting,
) = {
  let value = q.value
  let unit = q.unit
  assert(unit == (), message: "Logarithms only accept dimensionless quantity.")

  let new-places = q.figures
  if type(base) in (int, float) {
    value = calc.log(base: base, value)
  } else {
    assert(base.unit == (), message: "Logarithm's base must be a dimensionless quantity.")
    value = calc.log(base: base.value, value)
  }

  _make-quantity(
    value: value,
    places: new-places,
    round-mode: "places",
    method: method(base, q),
    ..formatting,
  )
}

#let ln(
  qnt,
  method: q => {
    $ln (#q.method)$
  },
  ..formatting,
) = {
  assert(qnt.unit == (), message: "Natural logarithm only accepts dimensionless quantity")
  _make-quantity(
    value: calc.ln(qnt.value),
    places: qnt.figures,
    round-mode: "places",
    method: method(qnt),
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


