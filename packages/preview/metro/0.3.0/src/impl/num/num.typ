#import "/src/utils.typ": combine-dict, content-to-string

#import "process.typ": process
#import "parse.typ": parse, to-float

#let default-options = (
  // parsing
  input-decimal-markers: ("\.", ","),
  retain-explicit-decimal-marker: false,
  retain-explicit-plus: false,
  retain-negative-zero: false,
  retain-zero-uncertainty: false,
  parse-numbers: auto,

  // post-processing
  drop-exponent: false,
  drop-uncertainty: false,
  drop-zero-decimal: false,
  exponent-mode: "input",
  exponent-thresholds: (-3, 3),
  fixed-exponent: 0,
  minimum-integer-digits: 0,
  minimum-decimal-digits: 0,
  round-direction: "nearest",
  round-half: "up",
  round-minimum: 0,
  round-mode: "none",
  round-pad: true,
  round-precision: 2,
  round-zero-positive: true,
  // uncertainty-round-direction: "nearest",

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
  output-close-uncertainty: sym.paren.r,
  output-decimal-marker: ".",
  output-exponent-marker: none,
  output-open-uncertainty: sym.paren.l,
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






#let build(options, sign, mantissa, exponent, power, uncertainty) = {
  sign += ""
  let is-negative = "-" in sign and (mantissa != "0" or options.retain-negative-zero)

  let bracket-ambiguous-numbers = options.bracket-ambiguous-numbers and exponent != none and uncertainty != none
  let bracket-negative-numbers = options.bracket-negative-numbers and is-negative

  // Return
  return math.equation({
    let output = if options.print-mantissa {
      math.attach(mantissa, t: power)
    }

    if bracket-negative-numbers {
      output = math.lr("(" + output + ")")
    } else if is-negative {
      output = sym.minus + output
    } else if options.print-implicit-plus or options.print-mantissa-implicit-plus or ("+" in sign and options.retain-explicit-plus) {
      output = sym.plus + output
    }

    if "<" in sign {
      output = math.equation(sym.lt + output)
    }

    if options.separate-uncertainty == "repeat" and uncertainty != none {
      output += options.separate-uncertainty-unit
    }

    output += math.equation(uncertainty)

    if bracket-ambiguous-numbers {
      output = math.lr("(" + output + ")")
    }

    output += exponent

    if options.separate-uncertainty == "bracket" and uncertainty != none {
      output = math.lr("(" + output + ")")
    }

    return output
  })
}

#let get-options(options) = combine-dict(options, default-options, only-update: true)

#let num(
  number,
  exponent: none, 
  uncertainty: none,
  power: none,
  options
) = {

  options = get-options(options)

  let (sign, integer, decimal, exp, pwr) = if options.parse-numbers != false {
    parse(options, number, full: true)
  } else {
    (auto,) * 5
  }
  options.number = number
  
  if exp not in (none, auto) {
    exponent = exp
  }
  if pwr not in (none, auto) {
    power = pwr
  }

  let (options, sign, mantissa, exponent, power, uncertainty) = process(options, sign, integer, decimal, exponent, power, uncertainty)

  return build(options, sign, mantissa, exponent, power, uncertainty)

}
