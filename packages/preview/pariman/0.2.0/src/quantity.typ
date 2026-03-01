#import "utils.typ"
/// The formatting functionality is provided by zero package.
#import "@preview/zero:0.6.1" as zero: zi

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

  return formatted.replace(sym.minus, "-")
}

#let negative-pattern = regex("[" + ("-", sym.minus).join() + "]")

/// Rules for significant figures
/// 1. For decimals:
///   - zero before "." does not count.
///   - zero after "." before number that is not 0 does not count.
///   - zero after "." after number that is not 0 count.
/// 2. For whole numbers:
///   - zero after a number that is not a zero is always count.
#let decimal-info(number, separator: ".") = {
  let numbers = number.split(separator)
  assert(numbers.len() == 2, message: "decimals must contain a decimal separator")
  // counting the significant figures
  let is-significant = false
  let figures = 0
  let (before-sep, after-sep) = numbers
  for c in before-sep.clusters() {
    if c != "0" { is-significant = true }
    if is-significant { figures += 1 }
  }
  // counting the decimal places
  let places = 0
  for c in after-sep.clusters() {
    if c != "0" { is-significant = true }
    if is-significant { figures += 1 }
    places += 1
  }

  return (places: places, figures: figures)
}

#let integer-info(number) = {
  let is-significant = false
  let figures = 0
  for c in number.clusters() {
    if c != "0" { is-significant = true }
    figures += 1
  }

  return (figures: figures, places: 0)
}

#let e-notation-info(number, decimal-separator: ".") = {
  assert(number.contains("e"), message: "e-notation is only for numbers written in scientific notation.")

  let info = (:)
  let (preexponential, exponent) = number.split("e")
  if preexponential.contains(decimal-separator) {
    info = decimal-info(preexponential, separator: decimal-separator)
  } else {
    info = integer-info(preexponential)
  }
  // handling 1.0e1 case.
  info.places -= eval(exponent)
  if info.places < 0 { info.places = 0 }
  return info
}

#let count-significant(number, decimal-separator: ".") = {
  number = number.trim(negative-pattern)
  if number.contains("e") { return e-notation-info(number) }
  if number.contains(decimal-separator) { return decimal-info(number, separator: decimal-separator) }
  return integer-info(number)
}

#let number-info(value, figures: auto, places: auto, decimal-separator: ".") = {
  let info = count-significant(value, decimal-separator: decimal-separator)
  if type(figures) == int {
    info.figures = figures
  }
  if type(places) == int {
    info.places = places
  }
  return info
}

#let quantity(
  value,
  rounder: it => it,
  ..args,
  unit-separator: " ",
  places: auto,
  figures: auto,
  magnitude-limit: 4,
  round-mode: auto,
  method: auto,
  display: auto,
  source: none,
  is-exact: false,
) = {
  let formatting = args.named()
  let arr-units = args.pos()

  value = str(value)
  // Extract information about rounding
  // the `figures` and `places` can by-pass the function if specified as integers.
  let info = number-info(value, figures: figures, places: places)

  // choose a way to format the number.
  if round-mode == auto {
    if type(figures) == int and places == auto {
      round-mode = "figures"
    } else if type(places) == int and figures == auto {
      round-mode = "places"
    } else if places == auto and figures == auto {
      if value.contains("e") { 
        figures = info.figures
        round-mode = "figures" 
      } else { 
        places = info.places
        round-mode = "places" 
      }
    } else {
      round-mode = "places"
    }
  }

  let digits = if round-mode == "figures" { figures } else { places }

  value = scientify(eval(value), figures: info.figures, magnitude-limit: magnitude-limit)

  let formatter = zero.num
  let value = rounder(value)
  // parsing units
  let units = ()
  if arr-units.len() >= 1 {
    // process the units
    for unit in arr-units {
      if type(unit) == str {
        units += parse-unit(unit, sep: unit-separator)
      } else if type(unit) == array {
        assert(unit.len() == 2, message: "The custom unit in an array must be in the form `(unit, exponent)`.")
        units.push(unit)
      } else {
        units.push((unit, 1))
      }
    }
    // if there is at least a unit, then switch to `zi`.
    formatter = zi.declare(..units)
  }

  let default-format = (
    round: (mode: round-mode, precision: digits),
  )

  if display == auto { display = formatter(value, ..default-format, ..formatting) }
  if method == auto { method = display }

  (
    value: eval(value),
    unit: units,
    // deciman places
    places: info.places,
    // significant figures
    figures: info.figures,
    // formatted value
    "show": zero.num(value, ..default-format, ..formatting),
    // verbatim value
    "text": str(value),
    // display with unit
    display: display,
    // the calculation
    method: method,
    source: source, // for formatting methods
    round-mode: round-mode,
    is-exact: is-exact
  )
}

#let _get(prop, ..qnts) = {
  qnts.pos().map(q => q.at(prop))
}

#let exact(
  value, 
  ..args, 
  figures: 99, 
  places: 99,
  display-figures: auto, 
  display-places: auto,
) = {
  let formatting = args.named() 
  let units = args.pos() 
  quantity(
    value, 
    ..units, 
    figures: display-figures, 
    places: display-places, 
    is-exact: true,
  ) + (figures: figures, places: places)
}

#let set-quantity(q, ..formatting) = {
  let value = q.remove("value")
  let unit = q.remove("unit")
  let formatting = formatting.named()
  if "value" in formatting {
    value = formatting.remove("value")
    q.display = auto
    q.method = auto
  }
  let func = if q.is-exact { exact } else { quantity }
  func(value, ..unit, ..q, ..formatting, display: auto)
}
