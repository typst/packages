#import "@preview/t4t:0.3.2": is
#import "/src/utils.typ": combine-dict

#let number-to-string(number) = {
  number = if is.content(number) {
    if is.sequence(number) {
      number.children.map(c => c.text).join()
    } else {
      number.text
    }
  } else {
    str(number)
  }.replace("-", sym.minus)

  let sign = if number.starts-with(sym.minus) {
    sym.minus
    // For some reason strings get indexed by byte? minus is unicode
    number = number.slice(3)
  } else if number.starts-with(sym.plus) {
    sym.plus
    // Plus is ascii
    number = number.slice(1)
  }

  return (sign, number)
}

#let _num(
  number,
  exponent: none, 
  uncertainty: none,
  options
) = {

  let spacing = if not options.tight-spacing {
    sym.space.thin
  }

  let (sign, number) = number-to-string(number)

  let (integer, decimal) = {
    let a = number.split(regex(options.input-decimal-markers.join("|")))
    assert(a.len() <= 2, message: repr(a))
    (a.first(), a.at(1, default: none))
  }

  let group-digits(input, rev: true) = {
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

  if integer.len() < options.minimum-integer-digits {
    integer = "0" * (options.minimum-integer-digits - integer.len()) + integer
  }
  if decimal != none and decimal.len() < options.minimum-decimal-digits {
    decimal += "0" * (options.minimum-decimal-digits - decimal.len())
  }

  if options.group-digits in ("all", "decimal", "integer") {
    if options.group-digits in ("all", "integer") and integer.len() >= options.group-minimum-digits {
      integer = group-digits(integer)
    }
    if decimal != none and options.group-digits in ("all", "decimal") and decimal.len() >= options.group-minimum-digits {
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
    if decimal != none and (decimal != "" or options.retain-explicit-decimal-marker) {
      options.output-decimal-marker
      if options.zero-decimal-as-symbol and int(decimal) == 0 {
        options.zero-symbol
      } else {
        decimal
      }
    }
  }

  let print-mantissa = options.print-unity-mantissa or mantissa not in ("1", "")

  if uncertainty != none {
    uncertainty = spacing + sym.plus.minus + spacing + number-to-string(uncertainty).last()
  }

  if exponent != none {
    exponent = number-to-string(exponent)
    if exponent.last() != "0" or options.print-zero-exponent {
      exponent = if exponent.first() == sym.minus or options.print-implicit-plus or options.print-exponent-implicit-plus {
        exponent.join()
      } else {
        exponent.last()
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

  let is-negative = sign == sym.minus and (mantissa != "0" or options.retain-negative-zero)

  let bracket-ambiguous-numbers = options.bracket-ambiguous-numbers and exponent != none and uncertainty != none
  let bracket-negative-numbers = options.bracket-negative-numbers and is-negative

  // Return
  return math.equation({
    if bracket-ambiguous-numbers or (options.separate-uncertainty == "bracket" and uncertainty != none) {
      "("
    }
    if bracket-negative-numbers {
      "("
    } else if is-negative {
      sym.minus
    } else if options.print-implicit-plus or options.print-mantissa-implicit-plus or (sign == sym.plus and options.retain-explicit-plus) {
      sym.plus
    }

    if print-mantissa {
      mantissa
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

#let num(
    number,
    e: none,
    pm: none,
    ..options
  ) = {
  
  return _num(
    number,
    exponent: e,
    uncertainty: pm,
    combine-dict(options.named(), (
      // parsing
      input-decimal-markers: ("\.", ","),
      retain-explicit-decimal-marker: false,
      retain-explicit-plus: false,
      retain-negative-zero: false,
      retain-zero-uncertainty: false,

      // post-processing
      // drop-exponent: false,
      // drop-uncertainty: false,
      // drop-zero-decimal: false,
      // exponent-mode: "input",
      // exponent-thresholds: (-3, 3),
      // fixed-exponent: 0,
      minimum-integer-digits: 0,
      minimum-decimal-digits: 0,
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
      separate-uncertainty: "bracket",
      separate-uncertainty-unit: none,
    ), only-update: true)
  )
}