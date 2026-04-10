#import "num.typ": num
#import "state.typ": num-state, update-num-state
#import "assertions.typ": assert-settable-args
#import "parsing.typ": compute-eng-digits, parse-numeral
#import "utility.typ"

/// [internal function]
/// Parse a text-based unit specification.
/// - Consecutive units can be separated by a space.
///   (Why is this necessary? in "kg m" the "kg" needs to be close
///    but distinguishable from the "m")
/// - Exponents are allowed as in "m^2"
/// - A unit in the fraction can be specified either with a negative
///   exponent "s^-1" or by adding a slash before "/s"
/// - Prefixes are allowed and should be prepended to the base unit without
///   a space in between. Example: `"/mm^2"`. Occurrences of "mu" will be replaced
///   by the greek mu symbol.
/// Returns: a dictionary with the keys "numerator" and "denominator",
/// both containing a list where each entry is a tuple with the unit symbol
/// as the first element and the exponent as the second element. The exponent
/// is always positive.
#let parse-unit-str(str) = {
  str += " "
  str = str.replace("mu", "µ")

  let numerator = ()
  let denominator = ()
  let unit = ""
  let per = false

  let get-symbol-and-exponent(str, per) = {
    let pow-index = str.position("^")
    if pow-index == none { return (str, "1") }

    let exponent = str.slice(pow-index + 1)
    assert(
      exponent.len() > 0,
      message: "Invalid unit: missing exponent after \"^\"",
    )
    exponent = exponent.trim("(").trim(")")
    let symbol = str.slice(0, pow-index)
    assert(
      symbol.len() != 0,
      message: "Invalid unit: an exponent needs to be preceded by a unit",
    )
    return (symbol, exponent)
  }

  for c in str {
    if c in "/ " {
      // both "/" and " " terminate the current unit
      if unit.len() == 0 {
        if c == "/" { per = true }
        continue
      }

      let (symbol, exponent) = get-symbol-and-exponent(unit, per)
      if exponent.starts-with("-") {
        per = not per
        exponent = exponent.slice(1)
      }
      exponent = [#exponent]
      if unit != "1" {
        // make calls like "1/s" possible in addition to "/s"
        if per { denominator.push((symbol, exponent)) } else {
          numerator.push((symbol, exponent))
        }
      }
      per = false
      unit = ""

      if c == "/" { per = true }
    } else {
      unit += c
    }
  }

  (numerator: numerator, denominator: denominator)
}

#let parse-unit(..children) = {
  children = children.pos()
  if children.len() == 1 and type(children.first()) == str {
    return parse-unit-str(children.first())
  }

  let numerator = ()
  let denominator = ()

  for child in children {
    if type(child) in (str, content, symbol) {
      numerator.push((child, [1]))
    } else if type(child) == array {
      assert(
        child.len() == 2,
        message: "Unit entries need to be a tuple of a unit and an exponent, got "
          + repr(child),
      )
      let (unit, exponent) = child
      assert(
        type(exponent) in (int, float, str),
        message: "The exponent of a unit entry needs to be an int, float, or str, got "
          + repr(exponent),
      )
      if type(exponent) in (int, float) {
        exponent = str(exponent).replace("−", "-")
      }
      if exponent.starts-with("-") {
        exponent = exponent.slice(1)
        denominator.push((unit, [#exponent]))
      } else {
        numerator.push((unit, [#exponent]))
      }
    } else {
      assert(
        false,
        message: "Expected str, content, symbol or a unit-exponent pair, got "
          + repr(child),
      )
    }
  }

  (numerator: numerator, denominator: denominator)
}

#let format-unit-power(unit, exponent, math: true) = {
  if math {
    if type(exponent) in (int, float) {
      exponent = str(exponent)
    }
    if exponent in (1, [1]) { unit } else { std.math.attach(unit, t: exponent) }
  } else {
    if exponent in (1, [1]) { unit } else {
      unit + super(typographic: false, exponent)
    }
  }
}

#let fold-units(
  ..units,
  exp-multiplier,
  math: true,
  unit-separator: sym.space.thin,
  use-sqrt: true,
) = {
  let units = units
    .pos()
    .map(((unit, exponent)) => {
      if exp-multiplier == -1 {
        exponent = sym.minus + exponent
      }
      if use-sqrt and exponent == [0.5] and math {
        return std.math.sqrt(unit)
      }
      format-unit-power(unit, exponent, math: math)
    })

  let folded-units = units.join(unit-separator)
  if math {
    std.math.upright(folded-units)
  } else {
    folded-units
  }
}

/// Show a unit that has been parsed with @parse-unit-str.
#let show-unit(
  /// The unit elements in the numerator.
  /// -> array
  numerator,
  /// The unit elements in the denominator.
  /// -> array
  denominator,
  /// Mode for displaying fractions.
  /// -> "power" | "fraction" | "inline"
  fraction: "power",
  /// Whether to use an equation or plain text elements.
  math: true,
  /// Symbol to use between base units.
  /// -> content
  unit-separator: sym.space.thin,
  /// Whether to display a square root symbol when the exponent is 1/2.
  use-sqrt: true,
  /// Unprocessed arguments.
  ..args,
) = {
  let fold-units = fold-units.with(
    unit-separator: unit-separator,
    math: math,
    use-sqrt: use-sqrt,
  )


  let numerator-content = fold-units(..numerator, 1)
  if denominator.len() == 0 {
    return if math { $#numerator-content$ } else { numerator-content }
  }

  let denom-exp-multiplier = if fraction == "power" { -1 } else { 1 }
  let denominator-content = fold-units(..denominator, denom-exp-multiplier)

  if fraction == "power" {
    // Numerator may be empty!
    let result = denominator-content
    if numerator.len() != 0 {
      result = numerator-content + unit-separator + result
    }
    return if math { $result$ } else { result }
  }

  // For the two fractional modes, the numerator shall not be empty.
  if numerator.len() == 0 { numerator-content = $1$ }

  if fraction == "fraction" {
    if not math {
      assert(
        false,
        "`math: false` cannot be used together with `fraction: \"fraction\"`",
      )
    }
    return $#numerator-content/#denominator-content$
  } else if fraction == "inline" {
    if denominator.len() > 1 {
      denominator-content = "(" + denominator-content + ")"
    }

    if math {
      $#numerator-content#h(0pt)\/#h(0pt)#denominator-content$
    } else {
      numerator-content + "/" + denominator-content
    }
  } else {
    assert(
      false,
      message: "Invalid fraction: "
        + fraction
        + ". Expected \"power\", \"fraction\", or \"symbol\"",
    )
  }
}

#let unit(
  unit,
  ..args,
) = context {
  let num-state = update-num-state(num-state.get(), (unit: args.named()))

  let result = show-unit(
    unit.numerator,
    unit.denominator,
    ..num-state.unit,
    math: num-state.math,
  )
  if not num-state.unit.breakable {
    if num-state.math {
      result = $result$
    } else {
      result = box(result)
    }
  }
  result
}




#let qty(
  value,
  unit,
  ..args,
) = context {
  let unit = unit

  let num-state = update-num-state(
    num-state.get(),
    (unit: args.named()) + args.named(),
  )

  let separator = sym.space.thin
  if num-state.math {
    separator = $separator$
  }

  let angles = ("°", "′", "″", sym.degree, sym.prime, sym.prime.double)
  if unit.numerator.len() > 0 and unit.numerator.at(0).at(0) in angles {
    separator = none
  }

  if num-state.unit.prefix == auto and num-state.exponent == "eng" {
    num-state.prefixed-eng = true

    let info = parse-numeral(value)
    let e = if info.e == none { 0 } else { int(info.e) }
    let eng = compute-eng-digits(info)

    if eng != 0 {
      let prefixes = (
        "3": [k],
        "6": [M],
        "9": [G],
        "12": [T],
        "15": [P],
        "18": [E],
        "−3": [m],
        "−6": [#sym.mu],
        "−9": [n],
        "−12": [p],
        "−15": [f],
        "−18": [a],
      )


      let prefix = prefixes.at(str(eng))
      assert(unit.numerator.len() != 0)
      unit.numerator.first().first() = prefix + unit.numerator.first().first()
    }
  }

  let result = {
    num(value, state: num-state, force-parentheses-around-uncertainty: true)
    separator
    show-unit(
      unit.numerator,
      unit.denominator,
      fraction: num-state.unit.fraction,
      unit-separator: num-state.unit.unit-separator,
      math: num-state.math,
    )
  }

  if not num-state.unit.breakable {
    if num-state.math {
      result = $result$
    } else {
      result = box(result)
    }
  }
  result
}


#let set-unit(..args) = {
  num-state.update(s => {
    assert-settable-args(args, s.unit, name: "set-unit")
    s.unit += args.named()
    s
  })
}

#let liter-impl = context {
  if not num-state.get().unit.lowercase-liter {
    "L"
  } else {
    "l"
  }
}
