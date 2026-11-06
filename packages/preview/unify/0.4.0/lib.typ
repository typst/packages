#let re-num = regex("^(-?\d+(\.|,)?\d*)?(((\+(\d+(\.|,)?\d*)-(\d+(\.|,)?\d*)))|((((\+-)|(-\+))(\d+(\.|,)?\d*))))?(e([-\+]?\d+))?$")


#let _format-float(f, decsep: "auto", thousandsep: "#h(0.166667em)") = {
  /// Formats a float with thousands separator.
  /// - `f`: Float to format.
  /// - `decsep`: Which decimal separator to use. This must be the same as the one used in `f`. Set it to `auto` to automatically choose it. Falls back to `.`.
  /// - `thousandsep`: The seperator between the thousands.
  let string = ""
  if decsep == "auto" {
    if "," in f {
      decsep = ","
    } else{
      decsep = "."
    }
  }

  if thousandsep.trim() == "." {
    thousandsep = ".#h(0mm)"
  }

  let split = str(f).split(decsep)
  let int-part = split.at(0)
  let dec-part = split.at(1, default: none)
  let int-list = int-part.clusters()

  for (i, n) in int-list.enumerate() {
    let mod = (i - int-list.len()) / 3
    if int(mod) == mod {
      string += " " + thousandsep + " "
    }
    string += str(n)
  }

  if dec-part != none {
    let dec-list = dec-part.clusters()
    string += decsep
    for (i, n) in dec-list.enumerate() {
      let mod = i / 3
      if int(mod) == mod and i != 0 {
        string += " " + thousandsep + " "
      }
      string += str(n)
    }
  }

  string
}

#let _format-num(value, exponent: none, upper: none, lower: none, thousandsep: "#h(0.166667em)") = {
  /// Format a number.
  /// - `value`: Value of the number.
  /// - `exponent`: Exponent in the exponential notation.
  /// - `upper`: Upper uncertainty.
  /// - `lower`: Lower uncertainty.
  /// - `thousandsep`: The seperator between the thousands of the float.

  let formatted-value = ""
  if value != none {
    formatted-value += _format-float(value, thousandsep: thousandsep).replace(",", ",#h(0pt)")
  }
  if upper != none and lower != none {
    if upper != lower {
      formatted-value += "^(+" + _format-float(upper, thousandsep: thousandsep) + ")"
      formatted-value += "_(-" + _format-float(lower, thousandsep: thousandsep) + ")"
    } else {
      formatted-value += " plus.minus " + _format-float(upper, thousandsep: thousandsep).replace(",", ",#h(0pt)")
    }
  } else if upper != none {
    formatted-value += " plus.minus " + _format-float(upper, thousandsep: thousandsep).replace(",", ",#h(0pt)")
  } else if lower != none {
    formatted-value += " plus.minus " + _format-float(lower, thousandsep: thousandsep).replace(",", ",#h(0pt)")
  }
  if not (upper == none and lower == none) {
    formatted-value = "lr((" + formatted-value
    formatted-value += "))"
  }
  if exponent != none {
    if value != none {
      formatted-value += " dot "
    }
    formatted-value += "10^(" + str(exponent) + ")"
  }
  formatted-value
}

#let num(value, thousandsep: "#h(0.166667em)") = {
  /// Format a number.
  /// - `value`: String with the number.
  /// - `thousandsep`: The seperator between the thousands of the float.

  value = str(value).replace(" ", "")//.replace(",", ".")
  let match-value = value.match(re-num)
  assert.ne(match-value, none, message: "invalid number: " + value)
  let captures-value = match-value.captures

  let upper = none
  let lower = none
  if captures-value.at(14) != none {
    upper = captures-value.at(14)
    lower = none
  } else {
    upper = captures-value.at(5)
    lower = captures-value.at(7)
  }

  let formatted = _format-num(
    captures-value.at(0),
    exponent: captures-value.at(17),
    upper: upper,
    lower: lower,
    thousandsep: thousandsep
  )

  formatted = "$" + formatted + "$"
  eval(formatted)
}

#let _prefix-csv(path, delimiter: ",") = {
  /// Load a CSV file with pre- or postfixes.
  /// - `path`: Path of the CSV file.
  /// - `delimiter`: Passed to the `csv` function.

  let array = csv(path, delimiter: delimiter)
  let symbols = (:)
  let symbols-short = (:)

  for line in array {
    symbols.insert(lower(line.at(0)), line.at(2))
    symbols-short.insert(line.at(1), line.at(2))
  }
  (symbols, symbols-short)
}

#let _postfix-csv(path, delimiter: ",") = {
  /// Load a CSV file with pre- or postfixes.
  /// - `path`: Path of the CSV file.
  /// - `delimiter`: Passed to the `csv` function.

  let array = csv(path, delimiter: delimiter)
  let dict = (:)

  for line in array {
    dict.insert(lower(line.at(0)), line.at(1))
  }
  dict
}

#let _unit-csv(path, delimiter: ",") = {
  /// Load a CSV file with units.
  /// - `path`: Path of the CSV file.
  /// - `delimiter`: Passed to the `csv` function.

  let array = csv(path, delimiter: delimiter)
  let units = (:)
  let units-short = (:)
  let units-space = (:)
  let units-short-space = (:)

  for line in array {
    units.insert(lower(line.at(0)), line.at(2))
    units-short.insert(line.at(1), line.at(2))
    if line.at(3) == "false" or line.at(3) == "0" {
      units-space.insert(lower(line.at(0)), false)
      units-short-space.insert(line.at(1), false)
    } else {
      units-space.insert(lower(line.at(0)), true)
      units-short-space.insert(line.at(1), true)
    }
  }
  (units, units-short, units-space, units-short-space)
}

#let (prefixes, prefixes-short) = _prefix-csv("prefixes.csv")
#let (units, units-short, units-space, units-short-space) = _unit-csv("units.csv")
#let postfixes = _postfix-csv("postfixes.csv")

#let chunk(string, cond) = (string: string, cond: cond)

#let _format-unit-short(string, space: "#h(0.166667em)", per: "symbol") = {
  /// Format a unit using the shorthand notation.
  /// - `string`: String containing the unit.
  /// - `space`: Space between units.
  /// - `per`: Whether to format the units after `/` with a fraction or exponent.

  assert(per == "symbol" or per == "fraction" or per == "/")

  let formatted = ""

  let split = string
    .replace(regex(" */ *"), "/")
    .replace(regex(" +"), " ")
    .split(regex(" "))
  let chunks = ()
  for s in split {
    let per-split = s.split("/")
    chunks.push(chunk(per-split.at(0), false))
    if per-split.len() > 1 {
      for p in per-split.slice(1) {
        chunks.push(chunk(p, true))
      }
    }
  }

  // needed for fraction formatting
  let normal-list = ()
  let per-list = ()

  let prefixes = ()
  for (string: string, cond: per-set) in chunks {
    let acc = ""
    let u-space = true
    let prefix = none
    let unit = ""
    let exponent = none

    let qty-exp = string.split("^")
    let quantity = qty-exp.at(0)
    exponent = qty-exp.at(1, default: none)

    for char in quantity.clusters() {
      acc += char
      if acc in prefixes-short and prefix == none {
        prefix = prefixes-short.at(acc)
        acc = ""
      } else if acc in units-short {
        unit = units-short.at(acc)
        u-space = units-short-space.at(acc)
        acc = ""
      } else if acc.len() == quantity.len() {
        panic("invalid unit: " + quantity)
      }
    }

    if per == "symbol" {
      if u-space {
        formatted += space
      }
      formatted += prefix + unit
      if exponent != none {
        if per-set {
          formatted += "^(-" + exponent + ")"
        } else {
          formatted += "^(" + exponent + ")"
        }
      } else if per-set {
        formatted += "^(-1)"
      }
    } else {
      let final-unit = ""
      // if u-space {
      //   final-unit += space
      // }
      final-unit += prefix + unit
      if exponent != none {
          final-unit += "^(" + exponent + ")"
      }

      if per-set {
        per-list.push(chunk(final-unit, u-space))
      } else {
        normal-list.push(chunk(final-unit, u-space))
      }
    }
  }

  // return((normal-list, per-list))

  if per != "symbol" {
    if normal-list.at(0).at("cond") {
      formatted += space
    }
    formatted += " ("
    for (i, chunk) in normal-list.enumerate() {
      let (string: n, cond: space-set) = chunk
      if i != 0 and space-set {
        formatted += space
      }
      formatted += n
    }
    formatted += ")/("
    for (i, chunk) in per-list.enumerate() {
      let (string: p, cond: space-set) = chunk
      if i != 0 and space-set {
        formatted += space
      }
      formatted += p
    }
    formatted += ")"
  }

  formatted
}

#let _format-unit(string, space: "#h(0.166667em)", per: "symbol") = {
  /// Format a unit using written-out words.
  /// - `string`: String containing the unit.
  /// - `space`: Space between units.
  /// - `per`: Whether to format the units after `per` with a fraction or exponent.

  assert(per == "symbol" or per == "fraction" or per == "/")

  let formatted = ""

  // needed for fraction formatting
  let normal-list = ()
  let per-list = ()

  // whether per was used
  let per-set = false
  // whether waiting for a postfix
  let post = false
  // one unit
  let unit = chunk("", true)

  let split = lower(string).split(" ")
  split.push("")

  for u in split {
    // expecting postfix
    if post {
      if per == "symbol" {
        // add postfix
        if u in postfixes {
          if per-set {
            unit.at("string") += "^(-"
          } else {
            unit.at("string") += "^("
          }
          unit.at("string") += postfixes.at(u)
          unit.at("string") += ")"

          if unit.at("cond") {
            unit.at("string") = space + unit.at("string")
          }

          per-set = false
          post = false

          formatted += unit.at("string")
          unit = chunk("", true)
          continue
        // add per
        } else if per-set {
          unit.at("string") += "^(-1)"

          if unit.at("cond") {
            unit.at("string") = space + unit.at("string")
          }

          per-set = false
          post = false

          formatted += unit.at("string")
          unit = chunk("", true)
        // finish unit
        } else {
          post = false

          if unit.at("cond") {
            unit.at("string") = space + unit.at("string")
          }

          formatted += unit.at("string")
          unit = chunk("", true)
        }
      } else {
        if u in postfixes {
          unit.at("string") += "^("
          unit.at("string") += postfixes.at(u)
          unit.at("string") += ")"

          if per-set {
            per-list.push(unit)
          } else {
            normal-list.push(unit)
          }

          per-set = false
          post = false

          unit = chunk("", true)
          continue
        } else {
          if per-set {
            per-list.push(unit)
          } else {
            normal-list.push(unit)
          }

          per-set = false
          post = false

          unit = chunk("", true)
        }
      }
    }

    // detected per
    if u == "per" {
      per-set = true
    // add prefix
    } else if u in prefixes {
      unit.at("string") += prefixes.at(u)
    // add unit
    } else if u in units {
      unit.at("string") += units.at(u)
      unit.at("cond") = units-space.at(u)
      post = true
    } else if u != "" {
      return _format-unit-short(string, space: space, per: per)
    }
  }

  if per != "symbol" {
    if normal-list.at(0).at("cond") {
      formatted += space
    }
      formatted += " ("
    for (i, chunk) in normal-list.enumerate() {
      let (string: n, cond: space-set) = chunk
      if i != 0 and space-set {
        formatted += space
      }
      formatted += n
    }
    formatted += ")/("
    for (i, chunk) in per-list.enumerate() {
      let (string: p, cond: space-set) = chunk
      if i != 0 and space-set {
        formatted += space
      }
      formatted += p
    }
    formatted += ")"
  }

  formatted
}

#let unit(unit, space: "#h(0.166667em)", per: "symbol") = {
  /// Format a unit.
  /// - `unit`: String containing the unit.
  /// - `space`: Space between units.
  /// - `per`: Whether to format the units after `per` or `/` with a fraction or exponent.

  let formatted-unit = ""
  formatted-unit = _format-unit(unit, space: space, per: per)

  let formatted = "$" + formatted-unit + "$"
  eval(formatted)
}

#let qty(value, unit, rawunit: false, space: "#h(0.166667em)", thousandsep: "#h(0.166667em)", per: "symbol") = {
  /// Format a quantity (i.e. number with a unit).
  /// - `value`: String containing the number.
  /// - `unit`: String containing the unit.
  /// - `rawunit`: Whether to transform the unit or keep the raw string.
  /// - `space`: Space between units.
  /// - `thousandsep`: The seperator between the thousands of the float.
  /// - `per`: Whether to format the units after `per` or `/` with a fraction or exponent.

  value = str(value).replace(" ", "")
  let match-value = value.match(re-num)
  assert.ne(match-value, none, message: "invalid number: " + value)
  let captures-value = match-value.captures

  let upper = none
  let lower = none
  if captures-value.at(14) != none {
    upper = captures-value.at(14)
    lower = none
  } else {
    upper = captures-value.at(5)
    lower = captures-value.at(7)
  }

  let formatted-value = _format-num(
    captures-value.at(0),
    exponent: captures-value.at(17),
    upper: upper,
    lower: lower,
    thousandsep: thousandsep
  )

  let formatted-unit = ""
  if rawunit {
    formatted-unit = space + unit
  } else {
    formatted-unit = _format-unit(unit, space: space, per: per)
  }

  let formatted = "$" + formatted-value + formatted-unit + "$"
  eval(formatted)
}

#let _format-range(
  lower, upper, exponent-lower: none, exponent-upper: none,
  delimiter: "-", space: "#h(0.16667em)", thousandsep: "#h(0.166667em)", force-parentheses: false
) = {
  /// Format a range.
  /// - `(lower, upper)`: Strings containing the numbers.
  /// - `(exponent-lower, exponent-upper)`: Strings containing the exponentials in exponential notation.
  /// - `delimiter`: Symbol between the numbers.
  /// - `space`: Space between the numbers and the delimiter.
  /// - `thousandsep`: The seperator between the thousands of the float.
  /// - `force-parentheses`: Whether to force parentheses around the range.

  let formatted-value = ""

  formatted-value += _format-float(lower, thousandsep: thousandsep).replace(",", ",#h(0pt)")
  if exponent-lower != exponent-upper and exponent-lower != none {
    if lower != none {
      formatted-value += "dot "
    }
    formatted-value += "10^(" + str(exponent-lower) + ")"
  }
  formatted-value += space + " " + delimiter + " " + space + _format-float(upper, thousandsep: thousandsep).replace(",", ",#h(0pt)")
  if exponent-lower != exponent-upper and exponent-upper != none {
    if upper != none {
      formatted-value += "dot "
    }
    formatted-value += "10^(" + str(exponent-upper) + ")"
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

#let numrange(lower, upper, delimiter: "-", space: "#h(0.16667em)", thousandsep: "#h(0.166667em)") = {
  /// Format a range.
  /// - `(lower, upper)`: Strings containing the numbers.
  /// - `delimiter`: Symbol between the numbers.
  /// - `space`: Space between the numbers and the delimiter.
  /// - `thousandsep`: The seperator between the thousands of the float.
  lower = str(lower).replace(" ", "")
  let match-lower = lower.match(re-num)
  assert.ne(match-lower, none, message: "invalid lower number: " + lower)
  let captures-lower = match-lower.captures

  upper = str(upper).replace(" ", "")
  let match-upper = upper.match(re-num)
  assert.ne(match-upper, none, message: "invalid upper number: " + upper)
  let captures-upper = match-upper.captures

  let formatted = _format-range(
    captures-lower.at(0),
    captures-upper.at(0),
    exponent-lower: captures-lower.at(17),
    exponent-upper: captures-upper.at(17),
    delimiter: delimiter,
    thousandsep: thousandsep,
    space: space,
  )
  formatted = "$" + formatted + "$"

  eval(formatted)
}

#let qtyrange(
  lower, upper, unit, rawunit: false, delimiter: "-", space: "",
  unitspace: "#h(0.16667em)", thousandsep: "#h(0.166667em)", per: "symbol"
) = {
  /// Format a range with a unit.
  /// - `(lower, upper)`: Strings containing the numbers.
  /// - `unit`: String containing the unit.
  /// - `rawunit`: Whether to transform the unit or keep the raw string.
  /// - `delimiter`: Symbol between the numbers.
  /// - `space`: Space between the numbers and the delimiter.
  /// - `unitspace`: Space between units.
  /// - `thousandsep`: The seperator between the thousands of the float.
  /// - `per`: Whether to format the units after `per` or `/` with a fraction or exponent.

  lower = str(lower).replace(" ", "")
  let match-lower = lower.match(re-num)
  assert.ne(match-lower, none, message: "invalid lower number: " + lower)
  let captures-lower = match-lower.captures

  upper = str(upper).replace(" ", "")
  let match-upper = upper.match(re-num)
  assert.ne(match-upper, none, message: "invalid upper number: " + upper)
  let captures-upper = match-upper.captures

  let formatted-value = _format-range(
    captures-lower.at(0),
    captures-upper.at(0),
    exponent-lower: captures-lower.at(17),
    exponent-upper: captures-upper.at(17),
    delimiter: delimiter,
    space: space,
    thousandsep: thousandsep,
    force-parentheses: true
  )

  let formatted-unit = ""
  if rawunit {
    formatted-unit = space + unit
  } else {
    formatted-unit = _format-unit(unit, space: unitspace, per: per)
  }

  let formatted = "$" + formatted-value + formatted-unit + "$"
  eval(formatted)
}
