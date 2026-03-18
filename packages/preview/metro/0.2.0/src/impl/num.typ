#import "@preview/t4t:0.3.2": is
#import "/src/utils.typ": combine-dict, content-to-string

#let default-options = (
  // parsing
  input-decimal-markers: ("\.", ","),
  retain-explicit-decimal-marker: false,
  retain-explicit-plus: false,
  retain-negative-zero: false,
  retain-zero-uncertainty: false,

  // post-processing
  drop-exponent: false,
  drop-uncertainty: false,
  drop-zero-decimal: false,
  exponent-mode: "input",
  exponent-thresholds: (-3, 3),
  fixed-exponent: 0,
  minimum-integer-digits: 0,
  minimum-decimal-digits: 0,

  // Printing
  bracket-negative-numbers: false,
  digit-group-size: 3,
  digit-group-first-size: 3,
  digit-group-other-size: 3,
  exponent-base: "10",
  exponent-product: sym.times,
  group-digits: "all",
  group-minimum-digits: 5,
  group-separator: sym.space.thin,
  output-close-uncertainty: ")",
  output-decimal-marker: ".",
  output-exponent-marker: none,
  output-open-uncertainty: "(",
  print-implicit-plus: false,
  print-exponent-implicit-plus: false,
  print-mantissa-implicit-plus: false,
  print-unity-mantissa: true,
  print-zero-exponent: false,
  print-zero-integer: true,
  tight-spacing: false,
  bracket-ambiguous-numbers: true,
  zero-decimal-as-symbol: false,
  zero-symbol: sym.bar.h,

  // qty
  separate-uncertainty: "",
  separate-uncertainty-unit: none,
)


#let analyse-number(options, number, full: false) = {
  let typ = type(number)
  if typ == content {
    number = content-to-string(number)
  } else if typ in (int, float) {
    number = str(number)
  } else if typ != str {
    panic("Unknown number format: ", number)
  }
  let input-decimal-markers = str(options.input-decimal-markers.join("|")).replace(sym.minus, "-").replace(sym.plus, "+")
  let basic-float = "([-+]?\d*(?:(?:" + input-decimal-markers + ")\d*)?)"
  let result = number.replace(sym.minus, "-").replace(sym.plus, "+").match(regex({
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
      "(?:[eE]" + basic-float + ")?"
      // Power
      "(?:\^" + basic-float + ")?"
    }
    "$"
  }))
  assert(result != none, message: "Cannot match number: " + number)
  return result.captures
}


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

#let non-zero-integer-regex = regex("[^0]")

#let post-process(options, integer, decimal, exponent) = {


  if options.exponent-mode != "input" {
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

  return (integer, decimal, exponent)
}

#let num(
  number,
  exponent: none, 
  uncertainty: none,
  power: none,
  ..options
) = {

  options = combine-dict(options.named(), default-options, only-update: true)

  let analyse-number = analyse-number.with(options)
  let group-digits = group-digits.with(options)

  let spacing = if not options.tight-spacing {
    sym.space.thin
  }

  let (sign, integer, decimal, exp, pwr) = analyse-number(number, full: true)
  if integer == none {
    integer = ""
  }
  if decimal == none {
    decimal = ""
  }
  if exp != none {
    exponent = exp
  }
  if pwr != none {
    power = pwr
  }

  (integer, decimal, exponent) = post-process(options, integer, decimal, exponent)

  if options.group-digits in ("all", "decimal", "integer") {
    if options.group-digits in ("all", "integer") and integer.len() >= options.group-minimum-digits {
      integer = group-digits(integer)
    }
    if options.group-digits in ("all", "decimal") and decimal.len() >= options.group-minimum-digits {
      decimal = group-digits(decimal, rev: false)
    }
  }

  let mantissa = {
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
  }

  let print-mantissa = options.print-unity-mantissa or mantissa not in ("1", "")

  if options.drop-uncertainty {
    uncertainty = none
  }
  if uncertainty != none {
    uncertainty = analyse-number(uncertainty)
    if uncertainty.at(2) != none {
      uncertainty.insert(2, options.output-decimal-marker)
    }
    uncertainty = spacing + if uncertainty.first() == "-" { sym.minus.plus } else { sym.plus.minus } + spacing + uncertainty.slice(1).join()
  }

  if options.drop-exponent {
    exponent = none
  }

  if exponent != none {
    exponent = analyse-number(exponent)
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
        math.attach(if print-mantissa {spacing + options.exponent-product + spacing } + options.exponent-base, t: exponent)
      }
    } else {
      exponent = none
    }
  }

  if power != none {
    power = analyse-number(power)
    if power.at(2) != none {
      power.insert(2, options.output-decimal-marker)
    }
    power = power.join()
  }

  let is-negative = sign == "-" and (mantissa != "0" or options.retain-negative-zero)

  let bracket-ambiguous-numbers = options.bracket-ambiguous-numbers and exponent != none and uncertainty != none
  let bracket-negative-numbers = options.bracket-negative-numbers and is-negative

  // Return
  return math.equation({
    if bracket-ambiguous-numbers {
      "("
    }
    if options.separate-uncertainty == "bracket" and uncertainty != none {
      "("
    }
    if bracket-negative-numbers {
      "("
    } else if is-negative {
      sym.minus
    } else if options.print-implicit-plus or options.print-mantissa-implicit-plus or (sign == "+" and options.retain-explicit-plus) {
      sym.plus
    }

    if print-mantissa {
      math.attach(mantissa, t: power)
    }

    if bracket-negative-numbers {
      ")"
    }
    if options.separate-uncertainty == "repeat" and uncertainty != none {
      options.separate-uncertainty-unit
    }
    uncertainty
    if bracket-ambiguous-numbers {
      ")"
    }
    exponent
    if options.separate-uncertainty == "bracket" and uncertainty != none {
      ")"
    }
  })
}
