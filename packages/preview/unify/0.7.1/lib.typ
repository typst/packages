#import "format.typ": *

#let num(value, multiplier: "dot", thousandsep: "#h(0.166667em)") = {
  /// Format a number.
  /// - `value`: String with the number.
  /// - `multiplier`: The symbol used to indicate multiplication
  /// - `thousandsep`: The separator between the thousands of the float.

  // str() converts minus "-" of a number to unicode "\u2212"
  value = str(value).replace("−", "-").replace(" ", "") //.replace(",", ".")

  let match-value = value.match(_re-num)
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
    exponent: captures-value.at(18),
    upper: upper,
    lower: lower,
    multiplier: multiplier,
    thousandsep: thousandsep,
  )

  formatted = "$" + formatted + "$"
  eval(formatted)
}

#let add-unit(unit, shorthand, symbol, space: true) = {
  /// Add a new unit.
  /// - `unit`: Full name of the unit.
  /// - `shorthand`: Shorthand of the unit, usually only 1-2 letters.
  /// - `symbol`: String that will be inserted as the unit symbol.
  /// - `space`: Whether to put a space before the unit.
  context {
    let lang = _get-language()

    _lang-db.update(db => {
      db.at(lang).at("units").at(0).insert(unit, symbol)
      db.at(lang).at("units").at(1).insert(shorthand, symbol)
      db.at(lang).at("units").at(2).insert(unit, space)
      db.at(lang).at("units").at(3).insert(shorthand, space)
      db
    })
  }
}

#let add-prefix(prefix, shorthand, symbol) = {
  /// Add a new prefix.
  /// - `prefix`: Full name of the prefix.
  /// - `shorthand`: Shorthand of the prefix, usually only 1-2 letters.
  /// - `symbol`: String that will be inserted as the prefix symbol.
  context {
    let lang = _get-language()

    _lang-db.update(db => {
      db.at(lang).at("prefixes").at(0).insert(prefix, symbol)
      db.at(lang).at("prefixes").at(1).insert(shorthand, symbol)
      db
    })
  }
}


#let unit(unit, space: "#h(0.166667em)", per: "symbol") = {
  /// Format a unit.
  /// - `unit`: String containing the unit.
  /// - `space`: Space between units.
  /// - `per`: Whether to format the units after `per` or `/` with a fraction or exponent.

  context {
    let formatted-unit = ""
    formatted-unit = _format-unit(unit, space: space, per: per)

    let formatted = "$" + formatted-unit + "$"
    eval(formatted)
  }
}

#let qty(
  value,
  unit,
  rawunit: false,
  space: "#h(0.166667em)",
  multiplier: "dot",
  thousandsep: "#h(0.166667em)",
  per: "symbol",
) = {
  /// Format a quantity (i.e. number with a unit).
  /// - `value`: String containing the number.
  /// - `unit`: String containing the unit.
  /// - `multiplier`: The symbol used to indicate multiplication
  /// - `rawunit`: Whether to transform the unit or keep the raw string.
  /// - `space`: Space between units.
  /// - `thousandsep`: The separator between the thousands of the float.
  /// - `per`: Whether to format the units after `per` or `/` with a fraction or exponent.

  value = str(value).replace("−", "-").replace(" ", "")
  let match-value = value.match(_re-num)
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
    exponent: captures-value.at(18),
    upper: upper,
    lower: lower,
    multiplier: multiplier,
    thousandsep: thousandsep,
  )

  context {
    let formatted-unit = ""
    if rawunit {
      formatted-unit = space + unit
    } else {
      formatted-unit = _format-unit(unit, space: space, per: per)
    }

    let formatted = "$" + formatted-value + formatted-unit + "$"
    eval(formatted)
  }
}

#let numrange(
  lower,
  upper,
  multiplier: "dot",
  delimiter: "-",
  space: "#h(0.16667em)",
  thousandsep: "#h(0.166667em)",
) = {
  /// Format a range.
  /// - `(lower, upper)`: Strings containing the numbers.
  /// - `multiplier`: The symbol used to indicate multiplication
  /// - `delimiter`: Symbol between the numbers.
  /// - `space`: Space between the numbers and the delimiter.
  /// - `thousandsep`: The separator between the thousands of the float.
  lower = str(lower).replace("−", "-").replace(" ", "")
  let match-lower = lower.match(_re-num)
  assert.ne(match-lower, none, message: "invalid lower number: " + lower)
  let captures-lower = match-lower.captures

  upper = str(upper).replace("−", "-").replace(" ", "")
  let match-upper = upper.match(_re-num)
  assert.ne(match-upper, none, message: "invalid upper number: " + upper)
  let captures-upper = match-upper.captures

  let formatted = _format-range(
    captures-lower.at(0),
    captures-upper.at(0),
    exponent-lower: captures-lower.at(18),
    exponent-upper: captures-upper.at(18),
    multiplier: multiplier,
    delimiter: delimiter,
    thousandsep: thousandsep,
    space: space,
  )
  formatted = "$" + formatted + "$"

  eval(formatted)
}

#let qtyrange(
  lower,
  upper,
  unit,
  rawunit: false,
  multiplier: "dot",
  delimiter: "-",
  space: "",
  unitspace: "#h(0.16667em)",
  thousandsep: "#h(0.166667em)",
  per: "symbol",
) = {
  /// Format a range with a unit.
  /// - `(lower, upper)`: Strings containing the numbers.
  /// - `unit`: String containing the unit.
  /// - `rawunit`: Whether to transform the unit or keep the raw string.
  /// - `multiplier`: The symbol used to indicate multiplication
  /// - `delimiter`: Symbol between the numbers.
  /// - `space`: Space between the numbers and the delimiter.
  /// - `unitspace`: Space between units.
  /// - `thousandsep`: The separator between the thousands of the float.
  /// - `per`: Whether to format the units after `per` or `/` with a fraction or exponent.

  lower = str(lower).replace("−", "-").replace(" ", "")
  let match-lower = lower.match(_re-num)
  assert.ne(match-lower, none, message: "invalid lower number: " + lower)
  let captures-lower = match-lower.captures

  upper = str(upper).replace("−", "-").replace(" ", "")
  let match-upper = upper.match(_re-num)
  assert.ne(match-upper, none, message: "invalid upper number: " + upper)
  let captures-upper = match-upper.captures

  let formatted-value = _format-range(
    captures-lower.at(0),
    captures-upper.at(0),
    exponent-lower: captures-lower.at(18),
    exponent-upper: captures-upper.at(18),
    multiplier: multiplier,
    delimiter: delimiter,
    space: space,
    thousandsep: thousandsep,
    force-parentheses: true,
  )

  context {
    let formatted-unit = ""
    if rawunit {
      formatted-unit = space + unit
    } else {
      formatted-unit = _format-unit(unit, space: unitspace, per: per)
    }

    let formatted = "$" + formatted-value + formatted-unit + "$"
    eval(formatted)
  }
}
