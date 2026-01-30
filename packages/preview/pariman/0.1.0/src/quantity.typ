#import "utils.typ"

/// Parser for unit input
/// The possible patterns:
/// - " " is used for separating units
/// - "/" is used as a prefix for inverting unit exponent
/// - "^" is used for unit exponent
/// - "^-1" is possible
/// - "1/s" is possible
/// Output: a tuples of length two for which the first element is the unit and the second element is the exponent.
#let _parse-a-unit(u, is-denom: false) = {
  let splitted = u.split("^")
  assert(splitted.len() <= 2, message: "Each unit must have one, integer exponent.")
  let name = splitted.first()
  let exponent

  if splitted.len() == 2 {
    exponent = eval(splitted.last())
  } else {
    exponent = 1
  }

  if is-denom {
    exponent = -exponent
  }
  (name, exponent)
}

#let _parse-string-unit(string, sep: " ") = {
  let splitted = string.split("/")
  let noms = ""
  let denoms = ""
  assert(splitted.len() <= 2, message: "Slash as prefix for denominator must not be used more than once.")
  if splitted.len() == 2 {
    (noms, denoms) = splitted
  } else {
    (noms,) = splitted
  }
  let arr-noms = noms.split(sep).map(_parse-a-unit)
  let arr-denoms = denoms.split(sep).map(_parse-a-unit.with(is-denom: true))

  arr-noms + arr-denoms
}

#let parse-unit(string, sep: " ") = {
  let results = (:)
  let short-hands = ("oC": $degree C$, "oF": $degree F$, "oR": $degree R$)
  for (name, exp) in _parse-string-unit(string, sep: sep) {
    if name not in ("1", "") and exp != 0 {
      if name not in results {
        results.insert(name, exp)
      } else {
        results.at(name) += exp
      }
    }
  }
  results
    .pairs()
    .map(((n, e)) => {
      if n in short-hands {
        (short-hands.at(n), e)
      } else {
        (n, e)
      }
    })
}

/// The formatting functionality is provided by zero package.
#import "@preview/zero:0.5.0" as zero: zi

#let scientify(num, figures: 4, magnitude-limit: none) = {
  // num is given as a number
  let N = if num == 0 { 0 } else {
    calc.floor(calc.log(calc.abs(num)))
  }
  if calc.abs(N) < magnitude-limit {
    return str(num)
  }
  let mantissa = calc.round(num / calc.pow(10, N), digits: figures)
  let formatted = str(mantissa) + if N != 0 { "e" + str(N) }
  formatted.replace(sym.minus, "-")
}

#let info-num(value, figures: auto, places: auto) = {
  let (mantissa, exp) = (value, "")
  let (integer, dec) = (value, "")
  if value.contains("e") {
    (mantissa, exp) = value.split("e")
  }
  if mantissa.contains(".") {
    (integer, dec) = mantissa.split(".")
  }

  if figures == auto {
    figures = integer.len() + dec.len()
    if integer.contains("-") {
      figures -= 1
    }
  }
  if places == auto {
    places = dec.len()
  }
  return (
    places: places,
    figures: figures,
    integer: integer,
    decimal: dec,
    mantissa: mantissa,
    exponent: exp,
  )
}

#let quantity(
  value,
  rounder: it => it,
  ..args,
  unit-sep: " ",
  places: auto,
  figures: auto,
  magnitude-limit: 4,
  round-mode: "places",
  method: auto,
  display: auto,
  source: none,
) = {
  let formatting = args.named()
  let arr-units = args.pos()

  value = str(value)
  // Extract information about rounding
  let (figures, places) = info-num(value, figures: figures, places: places)

  let digits = if round-mode == "places" { places } else { figures }

  value = scientify(eval(value), figures: figures, magnitude-limit: magnitude-limit)


  let qty = zero.num
  let value = rounder(value)

  let units = ()
  if arr-units.len() >= 1 {
    for u in arr-units {
      if type(u) == str {
        units += parse-unit(u, sep: unit-sep)
      } else if type(u) == array {
        assert(u.len() == 2, message: "The custom unit in an array must be in the form `(unit, exponent)`.")
        units.push(u)
      } else {
        units.push((u, 1))
      }
    }
    qty = zi.declare(..units)
  }

  let default-format = (
    round: (mode: round-mode, precision: digits),
  )

  if display == auto {
    display = qty(value, ..default-format, ..formatting)
  }

  if method == auto {
    method = display
  }

  (
    value: eval(value),
    unit: units,
    // deciman places
    places: places,
    // significant figures
    figures: figures,
    // formatted value
    "show": zero.num(value, ..default-format, ..formatting),
    // verbatim value
    "text": str(value),
    // display with unit
    display: display,
    // the calculation
    method: method,
    source: source, // for formatting methods
  )
}

#let _get(prop, ..qnts) = {
  qnts.pos().map(q => q.at(prop))
}

#let set-quantity(q, ..formatting) = {
  let value = q.remove("value")
  let unit = q.remove("unit")
  let formatting = formatting.named()
  if "value" in formatting {
    value = formatting.remove("value")
    q.display = auto
  }
  quantity(value, ..unit, ..q, ..formatting)
}

#let exact = quantity.with(figures: 99)
