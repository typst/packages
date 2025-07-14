#import "num.typ": num
#import "state.typ": num-state, update-num-state
#import "assertations.typ": assert-settable-args


/// [internal function]
/// Parse a text-based unit specification. 
/// - Consecutive units can be separated by a space. 
///   (Why is this necessary? in "kg m" the "kg" needs to be close 
///    but distinguishable from the "m")
/// - Exponents are allowed as in "m^2"
/// - A unit in the fraction can be specified either with a negative
///   exponent "s^-1" or by adding a slash before "/s"
/// - Prefixes are allowed and should be preprended to the base unit without
///   a space in between. Example: `"/mm^2"`. Occurences of "mu" will be replaced
///   by the greek mu symbol. 
/// Returns: a dictionary with the keys "numerator" and "fraction",
/// both containing a list where each entry is a tuple with the unit symbol 
/// as the first element and the exponent as the second element. The exponent
/// is always positive. 
#let parse-unit-str(str) = {
  str += " "
  str = str.replace("mu", "µ")

  let numerator = ()
  let fraction = ()
  let unit = ""
  let per = false

  let get-symbol-and-exponent(str, per) = {
      let pow-index = str.position("^")
      if pow-index == none { return (str, "1") }
      
      let exponent = str.slice(pow-index + 1)
      assert(exponent.len() > 0, message: "Invalid unit: missing exponent after \"^\"")
      exponent = exponent.trim("(").trim(")")
      let symbol = str.slice(0, pow-index)
      assert(symbol.len() != 0, message: "Invalid unit: an exponent needs to be preceeded by a unit")
      return (symbol, exponent)
  }

  for c in str {
    if c in "/ " { // both "/" and " " terminate the current unit
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
      if unit != "1" { // make calls like "1/s" possible in addition to "/s"
        if per { fraction.push((symbol, exponent)) } 
        else { numerator.push((symbol, exponent)) }
      }
      per = false
      unit = ""
      
      if c == "/" { per = true } 
    } else {
      unit += c
    }
  }
  return (numerator: numerator, fraction: fraction)
}


/// Show a unit that has been parsed with @parse-unit-str.
/// - fraction (string): Mode for displaying the units in the fraction.
///         Options are "power", "fraction" and "inline" like in siunitx
/// - unit-separator (content): Symbol to use between base units. 
#let show-unit(
  unit-spec,
  fraction: "power",
  unit-separator: sym.space.thin,
  ..args
) = {
  let fold-units(arr, exp-multiplier) = {
    math.upright(arr.map(x => {
      let exponent = x.at(1)//
      if type(exponent) == int { exponent*= exp-multiplier }
      else if exp-multiplier == -1 { exponent = sym.minus + exponent }
      if exponent in (1, [1]) { $#x.at(0)$ }
      else { $#x.at(0)^#exponent$ }
    }).join(unit-separator))
  }

  let numerator = fold-units(unit-spec.numerator, 1)
  if unit-spec.fraction.len() == 0 { return numerator }
  
  let denom-exp-multiplier = if fraction == "power" { -1 } else { 1 }
  let result = fold-units(unit-spec.fraction, denom-exp-multiplier)
  
  if fraction == "power" {
    // numerator may be empty!
    if unit-spec.numerator.len() == 0 { return result }
    return numerator + unit-separator + result
  }
  // for the two fractional modes the numerator cannot be empty
  if unit-spec.numerator.len() == 0 { numerator = $1$ }
  if fraction == "fraction" {
    return $#numerator / #result$
  } else if fraction == "inline" {
    if unit-spec.fraction.len() > 1 {
      result = $(#result)$
    }
    return $#numerator#h(0pt)\/#h(0pt)#result$
  } else {
    assert(false, message: "Invalid fraction: " + fraction + ". Expected \"power\", \"fraction\", or \"symbol\"")
  }
}

#let unit(
  unit,
  ..args
) = context {
  
  let num-state = update-num-state(num-state.get(), (unit: args.named()))

  let result = show-unit(
    parse-unit-str(unit),
    ..num-state.unit
  )
  if not num-state.unit.breakable {
    result = box(result)
  }
  result
}




#let qty(
  value, 
  unit,
  ..args
) = context {
  
  let num-state = update-num-state(num-state.get(), (unit: args.named()) + args.named())

  let result = {
    num(value, state: num-state, force-parentheses-around-uncertainty: true) // force parens around numbers with uncertainty
    sym.space.thin
    show-unit(
      parse-unit-str(unit), 
      fraction: num-state.unit.fraction,
      unit-separator: num-state.unit.unit-separator
    )
  }
  
  if not num-state.unit.breakable {
    result = box(result)
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


#set-unit(fraction: "fraction", unit-separator: "~")

#qty("1232+-2", "m/s", fraction: "inline")
$ qty("1232+-2", "m/s") $

