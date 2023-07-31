#let re-num = regex("^(-?\d+\.?\d*)(((\+(\d+\.?\d*)-(\d+\.?\d*)))|((((\+-)|(-\+))(\d+\.?\d*))))?(e(-?\d+))?$")

#let _format-num(value, exponent: none, upper: none, lower: none) = {
  /// Format a number.
  /// - `value`: Value of the number.
  /// - `exponent`: Exponent in the exponential notation.
  /// - `upper`: Upper uncertainty.
  /// - `lower`: Lower uncertainty.

  let formatted-value = ""
  formatted-value += str(value)
  if upper != none and lower != none {
    if upper != lower {
      formatted-value += "^(+" + str(upper) + ")"
      formatted-value += "_(-" + str(lower) + ")"
    } else {
      formatted-value += " plus.minus " + str(upper)
    }
  } else if upper != none {
    formatted-value += " plus.minus " + str(upper)
  } else if lower != none {
    formatted-value += " plus.minus " + str(lower)
  }
  if not (upper == none and lower == none) {
    formatted-value = "lr((" + formatted-value
    formatted-value += "))"
  }
  if exponent != none {
    formatted-value += " dot 10^(" + str(exponent) + ")"
  }
  formatted-value
}

#let num(value) = {
  /// Format a number.
  /// - `value`: String with the number.

  value = str(value).replace(" ", "")
  let match-value = value.match(re-num)
  assert.ne(match-value, none, message: "invalid string")
  let captures-value = match-value.captures

  let upper = none
  let lower = none
  if captures-value.at(11) != none {
    upper = captures-value.at(11)
    lower = none
  } else {
    upper = captures-value.at(4)
    lower = captures-value.at(5)
  }

  let formatted = _format-num(
    captures-value.at(0),
    exponent: captures-value.at(13),
    upper: upper,
    lower: lower
  )

  formatted = "$" + formatted + "$"
  eval(formatted)
}

#let _fix-csv(path, delimiter: ",") = {
  /// Load a CSV file with pre- or postfixes.
  /// - `path`: Path of the CSV file.
  /// - `delimiter`: Passed to the `csv` function.

  let array = csv(path, delimiter: delimiter)
  let dict = (:)

  for line in array {
    dict.insert(line.at(0), line.at(1))
  }
  dict
}

#let _unit-csv(path, delimiter: ",") = {
  /// Load a CSV file with units.
  /// - `path`: Path of the CSV file.
  /// - `delimiter`: Passed to the `csv` function.

  let array = csv(path, delimiter: delimiter)
  let units = (:)
  let units-space = (:)

  for line in array {
    units.insert(line.at(0), line.at(1))
    if line.at(2) == "false" or line.at(2) == "0" {
      units-space.insert(line.at(0), false)
    } else {
      units-space.insert(line.at(0), true)
    }
  }
  (units, units-space)
}

#let prefixes = _fix-csv("prefixes.csv")
#let (units, units-space) = _unit-csv("units.csv")
#let postfixes = _fix-csv("postfixes.csv")

#let _format-unit(string, space: "#h(0.166667em)") = {
  /// Format a unit.
  /// - `string`: String containing the unit.
  /// - `space`: Space between units.

  let formatted = ""

  // whether per was used
  let per = false
  // whether waiting for a postfix
  let post = false
  // whether a unit is finished
  let unit-finished = false
  // one unit
  let unit = ""

  let split = string.split(" ")
  split.push("")

  for u in split {
    // expecting postfix
    if post {
      // add postfix
      if u in postfixes {
        if per {
          unit += "^(-"
        } else {
          unit += "^("
        }
        unit += postfixes.at(u)
        unit += ") \" \""
        per = false
        post = false

        formatted += unit
        unit = ""
        unit-finished = false
        continue
      // add per
      } else if per {
        unit += "^(-1) \" \""
        per = false
        post = false

        formatted += unit
        unit = ""
        unit-finished = false
      // finish unit
      } else {
        post = false

        formatted += unit
        unit = ""
        unit-finished = false
      }
    }

    // detected per
    if u == "per" {
      per = true
    // add prefix
    } else if u in prefixes {
      unit += prefixes.at(u)
    // add unit
    } else if u in units {
      unit += units.at(u)
      if units-space.at(u) {
        unit = space + unit
      }
      post = true
    }
  }
  formatted
}

#let unit(value, unit, raw-unit: false, space: "#h(0.166667em)") = {
  /// Format a unit.
  /// - `value`: String containing the number.
  /// - `unit`: String containing the unit.
  /// - `raw-unit`: Whether to transform the unit or keep the raw string.
  /// - `space`: Space between units.

  value = str(value).replace(" ", "")
  let match-num = value.match(re-num)
  assert.ne(match-num, none, message: "invalid string")
  let captures-num = match-num.captures

  let upper = none
  let lower = none
  if captures-num.at(11) != none {
    upper = captures-num.at(11)
    lower = none
  } else {
    upper = captures-num.at(4)
    lower = captures-num.at(5)
  }

  let formatted-value = _format-num(
    captures-num.at(0),
    exponent: captures-num.at(13),
    upper: upper,
    lower: lower
  )

  let formatted-unit = ""
  if raw-unit {
    formatted-unit = space + unit
  } else {
    formatted-unit = _format-unit(unit, space: space)
  }

  let formatted = "$" + formatted-value + formatted-unit + "$"
  eval(formatted)
}

#let _format-range(
  lower, upper, exponent-lower: none, exponent-upper: none,
  delimiter: "-", space: "#h(0.16667em)", force-parentheses: false
) = {
  /// Format a range.
  /// - `(lower, upper)`: Strings containing the numbers.
  /// - `(exponent-lower, exponent-upper)`: Strings containing the exponentials in exponential notation.
  /// - `delimiter`: Symbol between the numbers.
  /// - `space`: Space between the numbers and the delimiter.
  /// - `force-parentheses`: Whether to force parentheses around the range.

  let formatted-value = ""

  formatted-value += lower
  if exponent-lower != exponent-upper and exponent-lower != none {
    formatted-value += "dot 10^(" + str(exponent-lower) + ")"
  }
  formatted-value += space + delimiter + space + upper
  if exponent-lower != exponent-upper and exponent-upper != none {
    formatted-value += "dot 10^(" + str(exponent-upper) + ")"
  }
  if exponent-lower == exponent-upper and (exponent-lower != none and exponent-upper != none) {
    formatted-value = "lr((" + formatted-value
    formatted-value += ")) dot 10^(" + str(exponent-lower) + ")"
  } else if force-parentheses {
    formatted-value = "lr((" + formatted-value
    formatted-value += "))"
  }
  formatted-value
}

#let range(lower, upper, delimiter: "-", space: "#h(0.16667em)") = {
  lower = str(lower).replace(" ", "")
  let match-lower = lower.match(re-num)
  assert.ne(match-lower, none, message: "invalid string")
  let captures-lower = match-lower.captures

  upper = str(upper).replace(" ", "")
  let match-upper = upper.match(re-num)
  assert.ne(match-upper, none, message: "invalid string")
  let captures-upper = match-upper.captures

  let formatted = _format-range(
    captures-lower.at(0),
    captures-upper.at(0),
    exponent-lower: captures-lower.at(13),
    exponent-upper: captures-upper.at(13),
    delimiter: delimiter,
    space: space,
  )
  formatted = "$" + formatted + "$"

  eval(formatted)
}

#let unitrange(
  lower, upper, unit, raw-unit: false, delimiter: "-",
  space: "", unit-space: "#h(0.16667em)"
) = {
  /// Format a range with a unit.
  /// - `(lower, upper)`: Strings containing the numbers.
  /// - `unit`: String containing the unit.
  /// - `raw-unit`: Whether to transform the unit or keep the raw string.
  /// - `delimiter`: Symbol between the numbers.
  /// - `space`: Space between the numbers and the delimiter.
  /// - `unit-space`: Space between units.

  lower = str(lower).replace(" ", "")
  let match-lower = lower.match(re-num)
  assert.ne(match-lower, none, message: "invalid string")
  let captures-lower = match-lower.captures

  upper = str(upper).replace(" ", "")
  let match-upper = upper.match(re-num)
  assert.ne(match-upper, none, message: "invalid string")
  let captures-upper = match-upper.captures

  let formatted-value = _format-range(
    captures-lower.at(0),
    captures-upper.at(0),
    exponent-lower: captures-lower.at(13),
    exponent-upper: captures-upper.at(13),
    delimiter: delimiter,
    space: space,
    force-parentheses: true
  )

  let formatted-unit = ""
  if raw-unit {
    formatted-unit = space + unit
  } else {
    formatted-unit = _format-unit(unit, space: unit-space)
  }

  let formatted = "$" + formatted-value + formatted-unit + "$"
  eval(formatted)
}
