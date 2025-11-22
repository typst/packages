#import "/src/utils.typ": content-to-string

// full: (sign, integer, decimal, exponent, power)
// (sign, integer, decimal)
#let parse(options, number, full: false) = {
  let typ = type(number)
  let result = if typ == content {
    content-to-string(number)
  } else if typ in (int, float) {
    str(number)
  } else if typ == str {
    number
  }

  if result == none {
    if options.parse-numbers == true {
      panic("Unknown number format: ", number)
    }
    return (auto,) * if full { 5 } else { 3 }
  }

  let input-decimal-markers = str(options.input-decimal-markers.join("|")).replace(sym.minus, "-").replace(sym.plus, "+")
  let basic-float = "([-+]?\d*(?:(?:" + input-decimal-markers + ")\d*)?)"
  result = result.replace(sym.minus, "-").replace(sym.plus, "+").replace(" ", "").match(regex({
    "^"
    // Sign
    "([-+])?"
    // Integer
    "(\d+)?"
    // Decimal
    "(?:"
      "(?:"
        input-decimal-markers
      ")"
      "(\d*)"
    ")?" 
    if full {
      // Exponent
      "(?:[eE](.*?))?"
      // Power
      "(?:\^(.*?))?"
    }
    "$"
  }))

  return if result == none {
    if options.parse-numbers == true {
      panic("Cannot match number: " + repr(number))
    }
    (auto,) * if full { 5 } else { 3 }
  } else {
   result.captures
  }
}

#let to-float(options, number) = {
  let (sign, integer, decimal) = parse(options, number)
  if auto in (sign, integer, decimal) {
    panic("Cannot create a float from ", number, " as parsing failed.")
  }
  return float(sign + integer + "." + decimal)
}