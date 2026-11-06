#import "init.typ": *

#let _re-num = regex("^(-?\d+(\.|,)?\d*)?(((\+(\d+(\.|,)?\d*)-(\d+(\.|,)?\d*)))|((((\+-)|(-\+))(\d+(\.|,)?\d*))))?((e|E)([-\+]?\d+))?$")
#let _unicode-exponents = (
  ("\u2070", "0"),
  ("\u00B9", "1"),
  ("\u00B2", "2"),
  ("\u00B3", "3"),
  ("\u2074", "4"),
  ("\u2075", "5"),
  ("\u2076", "6"),
  ("\u2077", "7"),
  ("\u2078", "8"),
  ("\u2079", "9"),
  ("\u207A", "+"),
  ("\u207B", "-"),
)

#let _format-float(f, decsep: "auto", thousandsep: "#h(0.166667em)") = {
  /// Formats a float with thousands separator.
  /// - `f`: Float to format.
  /// - `decsep`: Which decimal separator to use. This must be the same as the one used in `f`. Set it to `auto` to automatically choose it. Falls back to `.`.
  /// - `thousandsep`: The separator between the thousands.
  let string = ""
  if decsep == "auto" {
    if "," in f {
      decsep = ","
    } else {
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

  string += str(int-list.remove(0))
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

#let _format-num(
  value,
  exponent: none,
  upper: none,
  lower: none,
  multiplier: "dot",
  thousandsep: "#h(0.166667em)",
) = {
  /// Format a number.
  /// - `value`: Value of the number.
  /// - `exponent`: Exponent in the exponential notation.
  /// - `upper`: Upper uncertainty.
  /// - `lower`: Lower uncertainty.
  /// - `multiplier`: The symbol used to indicate multiplication
  /// - `thousandsep`: The separator between the thousands of the float.

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
      formatted-value += " " + multiplier + " "
    }
    formatted-value += "10^(" + str(exponent) + ")"
  }
  formatted-value
}

#let _unicode-exponent-list = for (unicode, ascii) in _unicode-exponents {
  (unicode,)
}

#let _exponent-pattern = regex("[" + _unicode-exponent-list.join("|") + "]+")

#let _replace-unicode-exponents(unit-str) = {
  let exponent-matches = unit-str.matches(_exponent-pattern)
  let exponent = ""
  for match in exponent-matches {

    exponent = "^" + match.text
    for (unicode, ascii) in _unicode-exponents {
      exponent = exponent.replace(regex(unicode), ascii)
    }
    unit-str = unit-str.replace(match.text, exponent)
  }
  unit-str
}

#let _chunk(string, cond) = (string: string, cond: cond)

#let _format-unit-short(
  string,
  space: "#h(0.166667em)",
  per: "symbol",
  units-short,
  units-short-space,
  prefixes-short,
) = {
  /// Format a unit using the shorthand notation.
  /// - `string`: String containing the unit.
  /// - `space`: Space between units.
  /// - `per`: Whether to format the units after `/` with a fraction or exponent.

  assert(("symbol", "fraction", "/", "fraction-short", "short-fraction", "\\/").contains(per))

  let formatted = ""

  string = _replace-unicode-exponents(string)

  let split = string.replace(regex(" */ *"), "/").replace(regex(" +"), " ").split(regex(" "))
  let chunks = ()
  for s in split {
    let per-split = s.split("/")
    chunks.push(_chunk(per-split.at(0), false))
    if per-split.len() > 1 {
      for p in per-split.slice(1) {
        chunks.push(_chunk(p, true))
      }
    }
  }

  // needed for fraction formatting
  let normal-list = ()
  let per-list = ()

  let prefixes = ()
  for (string: string, cond: per-set) in chunks {
    let u-space = true
    let prefix = none
    let unit = ""
    let exponent = none

    let qty-exp = string.split("^")
    let quantity = qty-exp.at(0)
    exponent = qty-exp.at(1, default: none)

    if quantity in units-short {
      // Match units without prefixes
      unit = units-short.at(quantity)
      u-space = units-short-space.at(quantity)
    } else {
      // Match prefix + unit
      let pre = ""
      for char in quantity.clusters() {
        pre += char
        // Divide `quantity` into `pre`+`u` and check validity
        if pre in prefixes-short {
          let u = quantity.trim(pre, at: start, repeat: false)
          if u in units-short {
            prefix = prefixes-short.at(pre)
            unit = units-short.at(u)
            u-space = units-short-space.at(u)

            pre = none
            break
          }
        }
      }
      // if pre != none {
      //   panic("invalid unit: " + quantity)
      // }
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
        per-list.push(_chunk(final-unit, u-space))
      } else {
        normal-list.push(_chunk(final-unit, u-space))
      }
    }
  }

  if per == "fraction" or per == "/" {
    if normal-list.at(0).at("cond") {
      formatted += space
    }

    if per-list.len() > 0 {
      formatted += " ("
    }

    for (i, chunk) in normal-list.enumerate() {
      let (string: n, cond: space-set) = chunk
      if i != 0 and space-set {
        formatted += space
      }
      formatted += n
    }

    if per-list.len() == 0 {
      return formatted
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
  } else if per == "fraction-short" or per == "\\/" {
    if normal-list.at(0).at("cond") {
      formatted += space
    }

    for (i, chunk) in normal-list.enumerate() {
      let (string: n, cond: space-set) = chunk
      formatted += n
    }

    for (i, chunk) in per-list.enumerate() {
      let (string: p, cond: space-set) = chunk
      formatted += "\\/" + p
    }
  }

  formatted
}

#let _format-unit(string, space: "#h(0.166667em)", per: "symbol") = {
  /// Format a unit using written-out words.
  /// - `string`: String containing the unit.
  /// - `space`: Space between units.
  /// - `per`: Whether to format the units after `per` with a fraction or exponent.

  assert(("symbol", "fraction", "/", "fraction-short", "short-fraction", "\\/").contains(per))

  // load data
  let (units, units-short, units-space, units-short-space) = _units()

  let (prefixes, prefixes-short) = _prefixes()

  let formatted = ""

  // needed for fraction formatting
  let normal-list = ()
  let per-list = ()

  // whether per was used
  let per-set = false
  // whether waiting for a postfix
  let post = false
  // one unit
  let unit = _chunk("", true)

  let split = lower(string).split(" ")
  split.push("")

  for u in split {
    // expecting postfix
    if post {
      if per == "symbol" {
        // add postfix
        if u in _postfixes {
          if per-set {
            unit.at("string") += "^(-"
          } else {
            unit.at("string") += "^("
          }
          unit.at("string") += _postfixes.at(u)
          unit.at("string") += ")"

          if unit.at("cond") {
            unit.at("string") = space + unit.at("string")
          }

          per-set = false
          post = false

          formatted += unit.at("string")
          unit = _chunk("", true)
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
          unit = _chunk("", true)
          // finish unit
        } else {
          post = false

          if unit.at("cond") {
            unit.at("string") = space + unit.at("string")
          }

          formatted += unit.at("string")
          unit = _chunk("", true)
        }
      } else {
        if u in _postfixes {
          unit.at("string") += "^("
          unit.at("string") += _postfixes.at(u)
          unit.at("string") += ")"

          if per-set {
            per-list.push(unit)
          } else {
            normal-list.push(unit)
          }

          per-set = false
          post = false

          unit = _chunk("", true)
          continue
        } else {
          if per-set {
            per-list.push(unit)
          } else {
            normal-list.push(unit)
          }

          per-set = false
          post = false

          unit = _chunk("", true)
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
      return _format-unit-short(string, space: space, per: per, units-short, units-short-space, prefixes-short)
    }
  }

  if per == "fraction" or per == "/" {
    if normal-list.at(0).at("cond") {
      formatted += space
    }

    if per-list.len() > 0 {
      formatted += " ("
    }

    for (i, chunk) in normal-list.enumerate() {
      let (string: n, cond: space-set) = chunk
      if i != 0 and space-set {
        formatted += space
      }
      formatted += n
    }

    if per-list.len() == 0 {
      return formatted
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
  } else if per == "fraction-short" or per == "\\/" {
    if normal-list.at(0).at("cond") {
      formatted += space
    }

    for (i, chunk) in normal-list.enumerate() {
      let (string: n, cond: space-set) = chunk
      formatted += n
    }

    for (i, chunk) in per-list.enumerate() {
      let (string: p, cond: space-set) = chunk
      formatted += "\\/" + p
    }
  }

  formatted
}

#let _format-range(
  lower,
  upper,
  exponent-lower: none,
  exponent-upper: none,
  multiplier: "dot",
  delimiter: "-",
  space: "#h(0.16667em)",
  thousandsep: "#h(0.166667em)",
  force-parentheses: false,
) = {
  /// Format a range.
  /// - `(lower, upper)`: Strings containing the numbers.
  /// - `(exponent-lower, exponent-upper)`: Strings containing the exponentials in exponential notation.
  /// - `multiplier`: The symbol used to indicate multiplication
  /// - `delimiter`: Symbol between the numbers.
  /// - `space`: Space between the numbers and the delimiter.
  /// - `thousandsep`: The separator between the thousands of the float.
  /// - `force-parentheses`: Whether to force parentheses around the range.

  let formatted-value = ""

  formatted-value += _format-num(lower, thousandsep: thousandsep).replace(",", ",#h(0pt)")
  if exponent-lower != exponent-upper and exponent-lower != none {
    if lower != none {
      formatted-value += multiplier + " "
    }
    formatted-value += "10^(" + str(exponent-lower) + ")"
  }
  formatted-value += space + " " + delimiter + " " + space + _format-num(upper, thousandsep: thousandsep).replace(
    ",",
    ",#h(0pt)",
  )
  if exponent-lower != exponent-upper and exponent-upper != none {
    if upper != none {
      formatted-value += multiplier + " "
    }
    formatted-value += "10^(" + str(exponent-upper) + ")"
  }
  if exponent-lower == exponent-upper and (exponent-lower != none and exponent-upper != none) {
    formatted-value = "lr((" + formatted-value
    formatted-value += ")) " + multiplier + " 10^(" + str(exponent-lower) + ")"
  } else if force-parentheses {
    formatted-value = "lr((" + formatted-value
    formatted-value += "))"
  }
  formatted-value
}
