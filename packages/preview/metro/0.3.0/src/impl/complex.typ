#import "/src/utils.typ": combine-dict
#import "num/num.typ"
#import "angle.typ": is-angle, parse as parse-angle, to-number as angle-to-number
#import "unit.typ" as unit_
#import "qty.typ"

#let default-options = (
  complex-angle-unit: "degrees",
  complex-mode: "input",
  complex-root-position: "after-number",
  complex-symbol-angle: sym.angle,
  complex-symbol-degree: sym.degree,
  output-complex-root: math.upright("i"),
  print-complex-unity: false
)

// I've kind of given up with the combine-dict rules, I need to sort this out another time.
#let get-options(options) = combine-dict(options, default-options + num.default-options + unit_.default-options + qty.default-options, only-update: true)


#let parse(options, real, imag) = {
  if options.parse-numbers == false {
    if options.complex-mode == "input" {
      panic("Cannot identify the complex mode without parsing the number!")
    }
    return (options.complex-mode, real, imag)
  }

  let imag-type = type(imag)

  let input-mode = if is-angle(imag) {
    "polar"
  } else {
    "cartesian"
  }

  if options.complex-mode != "input" and  input-mode != options.complex-mode {
    real = num.to-float(options, real)
    (real, imag) = if input-mode == "cartesian" {
      // output mode is polar
      imag = num.to-float(options, imag)
      (
        calc.sqrt(
          calc.pow(real, 2) + calc.pow(imag, 2)
        ),
        calc.atan2(real, imag)
      )
    } else {
      imag = angle-to-number(imag)
      // output mode is cartesian
      (
        real * calc.cos(imag),
        real * calc.sin(imag)
      )
    }
  }

  let mode = if options.complex-mode == "input" { input-mode } else { options.complex-mode }

  return (
      mode,
      num.parse(options, real),
      if options.complex-mode == "input" and input-mode == "cartesian" or options.complex-mode == "cartesian" {
        num.parse(options, imag)
      } else {
        parse-angle(options, imag)
      }
    )
}

#let complex(real, imag, unit, options) = {
  options = get-options(options)
  let (mode, real, imag) = parse(options, real, imag)
  let is-polar = mode == "polar"

  let real-mantissa = {
    let (options, sign, mantissa, ..rest) = num.process(options, ..real, none, none, none)
    mantissa
    real = num.build(options, sign, mantissa, ..rest)
  }

  return math.equation({
    if is-polar or real-mantissa != "0" {
      real
    }

    if is-polar {
      options.complex-symbol-angle
      num.build(..num.process(options, ..imag, none, none, none))
      if options.complex-angle-unit == "degrees" {
        options.complex-symbol-degree
      }
    } else {
      let (options, sign, mantissa, ..rest) = num.process(options, ..imag, none, none, none)

      options.print-implicit-plus = real-mantissa != "0"

      mantissa = if not options.print-complex-unity and mantissa in ("1", "") {
        options.output-complex-root  
      } else if options.complex-root-position == "after-number" {
        mantissa + options.output-complex-root
      } else {
        options.output-complex-root + mantissa
      }

      num.build(options, sign, mantissa, ..rest)
    }

    if unit != none {
      unit_.unit(unit, options)
    }
  })
}
