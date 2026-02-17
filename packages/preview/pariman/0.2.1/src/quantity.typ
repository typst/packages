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
#let _parse-a-unit(single-unit, is-denom: false) = {
  let splitted = single-unit.split("^")

  assert(splitted.len() <= 2, message: "Each unit must have one, integer exponent.")

  let name = splitted.first()
  let exponent = if splitted.len() == 2 { eval(splitted.last()) } else { 1 }
  if is-denom { exponent = -exponent }

  return (name, exponent)
}

#let _parse-string-unit(unit-string, sep: " ") = {
  let splitted = unit-string.split("/")
  let noms = ""
  let denoms = ""
  assert(
    splitted.len() <= 2,
    message: "Slash as prefix for denominator must not be used more than once.",
  )
  if splitted.len() == 2 {
    (noms, denoms) = splitted
  } else {
    (noms,) = splitted
  }
  let arr-noms = noms.split(sep).map(_parse-a-unit)
  let arr-denoms = denoms.split(sep).map(_parse-a-unit.with(is-denom: true))

  return arr-noms + arr-denoms
}

#let parse-unit(string, sep: " ") = {
  let results = (:)
  let short-hands = ("oC": $degree C$, "oF": $degree F$, "oR": $degree R$)
  for (name, exp) in _parse-string-unit(string, sep: sep) {
    // clear the case of s^-1 and 1/s
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

// Rules for significant figures
// 1. For decimals:
//    - zero before "." does not count.
//    - zero after "." before number that is not 0 does not count.
//    - zero after "." after number that is not 0 count.
// 2. For whole numbers:
//    - zero after a number that is not a zero is always count.
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

// rounding the number based on significant rounding mode.
#let _prepare(
  raw-number,
  figures: auto,
  places: auto,
  round-mode: auto,
  precision: 1,
) = {
  if round-mode == auto {
    if figures == auto and places == auto {
      return raw-number
    } else if type(figures) == int and places == auto {
      return utils.figures-rounder(raw-number, digits: precision + figures)
    } else if type(places) == int and figures == auto {
      return utils.places-rounder(raw-number, digits: precision + places)
    } else if type(places) == int and type(figures) == int {
      panic("Please choose a rounding method: `figures` or `places`.")
    }
  } else if round-mode == "figures" {
    if figures == auto { figures = 3 }
    return utils.figures-rounder(raw-number, digits: precision + figures)
  } else if round-mode == "places" {
    if places == auto {
      if figures == auto { figures = 3 }
      return utils.figures-rounder(raw-number, digits: precision + figures)
    } else {
      return utils.places-rounder(raw-number, digits: precision + places)
    }
  } else {
    panic("Unknown round-mode: " + rerp(round-mode))
  }
}

/// Constructor for quantities.
/// -> dictionary
#let quantity(
  /// The numerical value of the quantity.
  /// It is recommended to specify by `str` representation of the value
  /// to retain most of the information, like significant figures, number of decimal places
  /// or scientific notations.
  /// -> str | float
  raw-value,
  /// The units (positional arguments) or format options (named arguments) to the units.
  /// The unit must be a string, like `"km/s^2 N"`, or an array of the
  /// unit representation and its exponent, like `($angstrom$, 1)`.
  ///
  /// The format options will be passed to `zero` package directly.
  /// -> any
  ..args,
  /// The separator between units for string of unit input
  /// -> str
  unit-separator: " ",
  /// Number of decimal places to display.
  /// If this is `auto`, it will determine from the input value.
  /// -> auto | int
  places: auto,
  /// Number of significant figures to display.
  /// If this is `auto`, it will determine from the input value.
  /// -> auto | int
  figures: auto,
  /// For very large or small value whose magnitude are exceeded the absolute value of this option,
  /// `pariman` will automatically convert it to be in a scientific notation.
  /// -> int
  magnitude-limit: 4,
  /// Specify which way to round the numerical value.
  /// The possible options are `"figures"` for significant figures,
  /// `"places"` for number of decimal places,
  /// `auto` for a smart default.
  ///
  /// If this is set to `auto`, it will determine whether `figures` or `places` are specified.
  /// - If `figures` is an integer, this will resolve to `"figures"`.
  /// - If `places` is an integer, this will resolve to `"places"`.
  /// - If both `figures` and `places` are specified, the default behavior is `"places"`.
  ///
  /// -> str
  round-mode: auto,
  /// Way to display this value when using `quantity.method` or `qt.metod(..)`.
  ///
  /// -> any
  method: auto,
  /// Way to display this value when using `quantity.display` or `qt.display(..)`.
  ///
  /// -> any
  display: auto,
  /// The additional number of significant figures or decimal places to keep on for
  /// more precise calculation. This number will be added to `figures` or `places` when rounding the input value.
  ///
  /// -> int
  precision: 3,
  /// Whether to show the unit when accessing the `method` property. This will effect only when setting BEFORE the calculation.
  /// -> bool
  explicit-method: true,
  source: none,
  is-exact: false,
) = {
  // the main quantity
  let q = (
    value: raw-value,
    unit: (),
    // deciman places
    places: places,
    // significant figures
    figures: figures,
    // formatted value
    "show": auto,
    // verbatim value
    "text": auto,
    // display with unit
    display: display,
    // the calculation
    method: method,
    source: source, // for formatting methods
    round-mode: round-mode,
    is-exact: is-exact,
  )

  let formatting = args.named()
  let arr-units = args.pos()
  // keep the numerical value separately.
  if type(raw-value) != str {
    q.value = _prepare(
      raw-value,
      round-mode: round-mode,
      figures: figures,
      places: places,
      precision: precision,
    )
    // enable information extraction.
    q.text = str(q.value)
  } else {
    // if it is already a string, by-pass the rounding process.
    q.text = raw-value
    q.value = eval(raw-value)
  }

  // Extract information about rounding
  // the `figures` and `places` can by-pass the function if specified as integers.
  let info = number-info(q.text, figures: figures, places: places)
  q.figures = info.figures
  q.places = info.places
  // format the value if it is very big or very small.
  q.text = scientify(q.value, figures: q.figures, magnitude-limit: magnitude-limit)
  // choose a way to format the number.
  if round-mode == auto {
    if type(figures) == int and places == auto {
      q.round-mode = "figures"
    } else if type(places) == int and figures == auto {
      q.round-mode = "places"
    } else if places == auto and figures == auto {
      if q.text.contains("e") {
        q.round-mode = "figures"
      } else {
        q.round-mode = "places"
      }
    } else if value.contains("e") {
      // if it was in scientific form, use `figures` rounding mode.
      q.round-mode = "figures"
    } else {
      q.round-mode = "places"
    }
  }

  let digits = if q.round-mode == "figures" { q.figures } else { q.places }

  let formatter = zero.num
  // parsing units
  q.unit = ()
  if arr-units.len() >= 1 {
    // process the units
    for unit in arr-units {
      if type(unit) == str {
        q.unit += parse-unit(unit, sep: unit-separator)
      } else if type(unit) == array {
        assert(
          unit.len() == 2,
          message: "The custom unit in an array must be in the form `(unit, exponent)`.",
        )
        q.unit.push(unit)
      } else {
        q.unit.push((unit, 1))
      }
    }
    // if there is at least a unit, then switch to `zi`.
    formatter = zi.declare(..q.unit)
  }

  let default-format = (
    round: (mode: q.round-mode, precision: digits),
  )
  q.show = zero.num(q.text, ..default-format, ..formatting)

  if display == auto { q.display = formatter(q.text, ..default-format, ..formatting) }
  if method == auto { q.method = if explicit-method { q.display } else { q.show } }
  if type(method) == function { q.method = method(q) }

  return q
}

#let _get(prop, ..qnts) = {
  qnts.pos().map(q => q.at(prop))
}

/// Exact value quantities
#let exact(
  /// The value passed to the `quantity` function.
  /// -> float | str
  value,
  /// The units and format options for displaying the quantity. Same as `quantity`'s parameters.
  /// -> any
  ..args,
  /// Default significant figures.
  /// -> int
  figures: 99,
  /// Default decimal places
  /// -> int
  places: 99,
  /// The displaying significant figures.
  /// -> auto | int
  display-figures: auto,
  /// The displaying decimal places.
  /// -> auto | int
  display-places: auto,
) = {
  let formatting = args.named()
  let units = args.pos()
  (
    quantity(
      value,
      ..units,
      figures: display-figures,
      places: display-places,
      is-exact: true,
      ..formatting,
    )
      + (figures: figures, places: places)
  )
}

/// Reset or modify the behavior of `exact` or `quantity` functions.
/// -> dictionary
#let set-quantity(
  /// The quantity.
  /// -> dictionary
  qty,
  /// New units.
  /// -> str | array
  unit: auto,
  /// New value
  /// -> str | float
  value: auto,
  /// Format options. Same as `quantity`'s or `exact`'s.
  ..formatting,
) = {
  let old-value = qty.remove("value")
  let old-units = qty.remove("unit")
  let is-new-format = false
  // set-quantity can change the unit and the value.
  let formatting = formatting.named()
  if value == auto { value = old-value } else { is-new-format = true }
  if unit == auto { unit = old-units } else { is-new-format = true }
  // whether to reset the displaying methods and display value.
  if is-new-format {
    qty.display = auto
  }
  // capture the unit
  if unit != auto {
    assert(
      type(unit) in (array, str),
      message: "The units must be specified as a string of units or an array of units.",
    )
    if (
      type(unit) == str
        or (
          unit.len() == 2 and type(unit.last()) == int
        )
    ) { unit = (unit,) }
  }
  // retain the original function
  let func = if qty.is-exact { exact } else { quantity }
  func(value, ..unit, ..qty, ..formatting, display: auto)
}
