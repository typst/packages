#import "parse.typ": parse

#let group-digits(options, input, rev: true) = {
  let (first, other) = if options.digit-group-size != 3 {
    (options.digit-group-size,) * 2
  } else {
    (options.digit-group-first-size, options.digit-group-other-size)
  }

  let input = if rev {
    input.split("").slice(1, -1).rev()
  } else {
    input
  }

  let len = input.len()
  let start = calc.rem(first, input.len())
  let result = (
    input.slice(0, start),
    ..for i in range(start, len, step: other) {
      (input.slice(i, calc.min(i + other, len)),)
    }
  )

  return if rev {
    result.map(x => x.rev().join()).rev()
  } else {
    result
  }.join(options.group-separator)
}

#let check-exponent-thresholds(options, exp) = (options.exponent-mode == "scientific" or exp - 1 < options.exponent-thresholds.first() or exp+1 > options.exponent-thresholds.last())


#let process-exponent(options, exp) = {
    let exponent = parse(options, exp)
    if exponent.all(x => x == auto) {
      exponent = (
        none, // sign
        exp, // The not parsed exponent
        none // Decimal
      )
    }

    if exponent.at(2) != none {
      exponent.insert(2, options.output-decimal-marker)
    }
    let sign = exponent.first()
    exponent = exponent.slice(1).join()
    if exponent != "0" or options.print-zero-exponent {
      if sign == "-" or options.print-implicit-plus or options.print-exponent-implicit-plus {
        exponent = if sign == "-" { sym.minus } else {sym.plus} + exponent
      }
      exponent = if options.output-exponent-marker != none {
        options.output-exponent-marker + exponent
      } else {
        math.attach(if options.print-mantissa {options.spacing + options.exponent-product + options.spacing } + options.exponent-base, t: exponent)
      }
    } else {
      exponent = none
    }
    return exponent
}

#let process-power(options, pwr) = {
  let power = parse(options, pwr)
  if power.all(x => x == auto) {
    return pwr
  }

  if power.at(2) != none {
    power.insert(2, options.output-decimal-marker)
  }
  return power.join()
}

#let process-uncertainty(options, pm) = {
  let uncertainty = parse(options, pm)
  if uncertainty.all(x => x == auto) {
    uncertainty = (
      none,
      pm,
      none
    )
  }
  if uncertainty.at(2) != none {
    uncertainty.insert(2, options.output-decimal-marker)
  }
  uncertainty = options.spacing + if uncertainty.first() == "-" { sym.minus.plus } else { sym.plus.minus } + options.spacing + uncertainty.slice(1).join()
  return uncertainty
}

#let non-zero-integer-regex = regex("[^0]")

#let exponent-mode(options, integer, decimal, exponent) = {
  exponent = if exponent == none { 0 } else { int(exponent) }
  if options.exponent-mode in ("scientific", "threshold") {
    let i = integer.position(non-zero-integer-regex)
    if i != none and i < integer.len() {
      let exp = integer.len() - i - 1 + exponent
      if check-exponent-thresholds(options, exp) {
        exponent = exp
        decimal = integer.slice(i+1) + decimal
        integer = integer.slice(i, i+1)
      }
    } else if integer.len() > 1 or integer == "0" {
      let i = decimal.position(non-zero-integer-regex)
      let exp = exponent - i - 1
      if check-exponent-thresholds(options, exp) {
        integer = decimal.slice(i, i+1)
        decimal = decimal.slice(i+1)
        exponent = exp
      }
    }
  } else if options.exponent-mode == "engineering" {
    if integer.len() > 1 {
      let l = calc.rem(integer.len(), 3)
      if l == 0 { l = 3 }
      exponent += integer.slice(l).len()
      decimal = integer.slice(l) + decimal
      integer = integer.slice(0, l)
    } else if integer == "0" {
      let i = decimal.position(non-zero-integer-regex)
      let l = 3 - calc.rem(i, 3)
      integer = decimal.slice(i, i+l)
      decimal = decimal.slice(i+l)
      exponent -= i+l
    }
  } else if options.exponent-mode == "fixed" {
    let n = options.fixed-exponent
    let i = exponent - n
    exponent = n
    if i < 0 {
      if integer.len() < -i {
        integer = "0" * -(i - integer.len()) + integer
      }
      decimal = integer.slice(i) + decimal
      integer = integer.slice(0, i)
    } else if i > 0 {
      if decimal.len() < i {
        decimal += "0" * (i - decimal.len())
      }
      integer += decimal.slice(0, i)
      decimal = decimal.slice(i)
    }
  }
  return (integer, decimal, exponent)
}

// Rounds the digits of a number based on the last digit sliced off of it.
// `decimal` should be `""` if there is no decimal
#let round-digits(options, integer, decimal, index) = {
  let digit
  if integer.len() > index {
    decimal = ""
    digit = integer.at(index)
    integer = integer.slice(0, index) + "0" * (integer.len() - index)
  } else if integer.len() == index {
    digit = decimal.first()
    decimal = ""
  } else if integer.len() + decimal.len() > index {
    index -= integer.len()
    digit = decimal.at(index)
    decimal = decimal.slice(0, index)
  }

  if digit != none and (options.round-direction == "up" or (
    options.round-direction == "nearest" and (
        options.round-half == "even" and calc.odd(int((integer + decimal).last()))
        or options.round-half == "up" and int(digit) >= 5
      )
    )) {
    if decimal != "" {
      let len = decimal.len()
      decimal = str(int(decimal) + 1)
      if len < decimal.len() {
        decimal = if options.round-pad { decimal.slice(1) } else { "" }
        integer = str(int(integer) + 1)
      } else {
        decimal = "0" * (len - decimal.len()) + decimal
      }
    } else {
      let i = integer.len() - index
      integer = str(int(integer) + calc.pow(10, i))
    }
  }
  return (integer, decimal)
}

#let round-mode(options, sign, integer, decimal) = {
  let round-digits = round-digits.with(options)
  if options.round-mode == "places"  {
    if decimal.len() > options.round-precision {
      (integer, decimal) = round-digits(integer, decimal, options.round-precision + integer.len())
      if float(integer + "." + decimal) < options.round-minimum {
        (integer, decimal) = str(options.round-minimum).split(".")
        sign = "<" + sign
      } else if int(integer) + int(decimal) == 0 and options.round-zero-positive {
        sign = "+"
      }
    } else if decimal.len() < options.round-precision and options.round-pad {
      decimal += "0" * (options.round-precision - decimal.len())
    }
  } else if options.round-mode == "figures" {
    if int(integer) == 0 {
      integer = ""
    }
    
    let len = integer.len() + decimal.len()
    if options.round-precision < len {
      (integer, decimal) = round-digits(integer, decimal, options.round-precision + if integer.len() < options.round-precision { decimal.position(non-zero-integer-regex) })
    } else if len < options.round-precision and options.round-pad {
      decimal += "0" * (options.round-precision - len)
    }
  }
  //  else if options.round-mode == "uncertainty" {

  // }

  return (sign, integer, decimal)
}

#let process(options, sign, integer, decimal, exponent, power, uncertainty) = {
  
  let parse-numbers = not (integer == auto and decimal == auto)
  if not parse-numbers {
    (sign, integer, decimal, exponent, power) = (sign, integer, decimal, exponent, power).map(x => if x != auto { x })
  }
  if integer == none {
    integer = ""
  }
  if decimal == none {
    decimal = ""
  }

  // Exponent options
  if options.exponent-mode != "input" {
    (integer, decimal, exponent) = exponent-mode(options, integer, decimal, exponent)
  }

  // Rounding options
  if options.round-mode != none and (options.round-mode != "uncertainty" and uncertainty == none) { // or (options.round-mode == "uncertainty" and uncertainty != none)) {
    (sign, integer, decimal) = round-mode(options, sign, integer, decimal)
  }

  if options.drop-zero-decimal and decimal.match(non-zero-integer-regex) == none {
    decimal = ""
  }

  // Minimum digits
  if integer.len() < options.minimum-integer-digits {
    integer = "0" * (options.minimum-integer-digits - integer.len()) + integer
  }
  if decimal.len() < options.minimum-decimal-digits {
    decimal += "0" * (options.minimum-decimal-digits - decimal.len())
  }

  if options.group-digits in ("all", "decimal", "integer") {
    let group-digits = group-digits.with(options)
    if options.group-digits in ("all", "integer") and integer.len() >= options.group-minimum-digits {
      integer = group-digits(integer)
    }
    if options.group-digits in ("all", "decimal") and decimal.len() >= options.group-minimum-digits {
      decimal = group-digits(decimal, rev: false)
    }
  }

  
  let mantissa = if parse-numbers {
    ""
    if (integer.len() == 0 or integer != "0") or options.print-zero-integer {
      if integer.len() == 0 {
        "0"
      } else {
        integer
      }
    }
    if decimal != "" or options.retain-explicit-decimal-marker {
      options.output-decimal-marker
      if options.zero-decimal-as-symbol and int(decimal) == 0 {
        options.zero-symbol
      } else {
        decimal
      }
    }
  } else {
    options.number
  }

  options.print-mantissa = options.print-unity-mantissa or mantissa not in ("1", "")
  
  options.spacing = if not options.tight-spacing {
    sym.space.thin
  }

  if options.drop-uncertainty {
    uncertainty = none 
  } else if uncertainty != none {
    uncertainty = process-uncertainty(options, uncertainty)
  }

  if options.drop-exponent {
    exponent = none
  } else if exponent != none {
    exponent = process-exponent(options, exponent)
  }

  if power != none {
    power = process-power(options, power)
  }

  return (options, sign, mantissa, exponent, power, uncertainty)
}