#import "state.typ": num-state, update-num-state
#import "formatting.typ": *
#import "rounding.typ": *
#import "assertions.typ": *
#import "parsing.typ" as parsing: nonum
#import "accessibility.typ": generate-num-alt-description
#let update-state(state, args, name: none) = {
  assert-no-fixed(args)
  state.update(s => {
    assert-settable-args(args, s, name: name)
    s + args.named()
  })
}


#let set-num(..args) = update-state(num-state, args, name: "set-num")

#let set-group(..args) = {
  num-state.update(s => {
    assert-settable-args(args, s.group, name: "set-group")
    s.group += args.named()
    s
  })
}

#let set-round(..args) = {
  num-state.update(s => {
    assert-settable-args(args, s.round, name: "set-round")
    s.round += args.named()
    s
  })
}


// Process the exponent with its various modes mode
#let process-exponent(info, exponent) = {
  if (info.int + info.frac).trim("0") == "" {
    // Add no exponent if number is 0
    return info
  }

  let new-exponent = if type(exponent) == dictionary {
    assert(
      "fixed" in exponent or "sci" in exponent,
      message: "Expected key \"fixed\" or \"sci\", got " + repr(exponent),
    )

    if "fixed" in exponent {
      exponent.fixed
    } else {
      let threshold = exponent.sci
      if type(threshold) == int {
        threshold = (-threshold, threshold)
      }
      let e = parsing.compute-sci-digits(info)
      if e > threshold.at(0) and e < threshold.at(1) {
        return info
      }
      e
    }
  } else if exponent == "eng" {
    parsing.compute-eng-digits(info)
  } else if exponent == "sci" {
    parsing.compute-sci-digits(info)
  }

  let e = if info.e == none { 0 } else { int(info.e) }

  let shift = utility.shift-decimal-left.with(digits: new-exponent - e)

  info.e = str(new-exponent).replace("−", "-")
  (info.int, info.frac) = shift(info.int, info.frac)

  if info.pm != none {
    if type(info.pm.first()) != array {
      info.pm = shift(..info.pm)
    } else {
      info.pm = info.pm.map(x => shift(..x))
    }
  }

  info
}


#let process-input(number) = {
  let info
  if type(number) == dictionary {
    info = number
    if "mantissa" in info {
      let mantissa = info.mantissa
      if type(mantissa) in (int, float) {
        mantissa = str(mantissa).replace("−", "-")
      }
      let (sign, int, frac) = parsing.decompose-signed-float-numeral(mantissa)
      info += (sign: sign, int: int, frac: frac)
    }
    if "sign" not in info { info.sign = "" }
  } else {
    info = parse-numeral(number)
  }
  return info
}

#let show-num(it) = {
  // Process input
  let info = it.info

  if it.exponent != auto {
    info = process-exponent(info, it.exponent)
    if "prefixed-eng" in it {
      info.e = none
    }
  }
  if info.e in (0, "0") and it.omit-zero-exponent {
    info.e = none
  }
  if it.trim-zeros {
    info.frac = info.frac.trim("0", at: end)
  }

  /// Round number and uncertainty
  if info.pm != none and it.round.follow-uncertainty {
    (info.int, info.frac, info.pm) = round-to-uncertainty(
      info.int,
      info.frac,
      info.pm,
      sign: info.sign,
      ..it.round,
      precision: it.round.uncertainty-precision,
    )
  } else {
    if it.round.precision != none {
      (info.int, info.frac) = round(
        info.int,
        info.frac,
        sign: info.sign,
        ..it.round,
      )
    }
  }

  let digits = if it.digits == auto { info.frac.len() } else { it.digits }
  if digits < 0 {
    assert(false, message: "`digits` needs to be positive, got " + str(digits))
  }
  it.digits = digits

  // Format number
  let components = show-num-impl(info + it)

  let description
  if it.alt == auto {
    it.alt = generate-num-alt-description
  }
  if type(it.alt) == dictionary {
    assert(
      "times" in it.alt
        and "power" in it.alt
        and "plus" in it.alt
        and "minus" in it.alt
        and "decimal-separator" in it.alt,
      message: "Expected keys \"times\", \"power\", \"plus\", \"minus\", and \"decimal-marker\" got " + repr(it.alt),
    )
    it.alt = generate-num-alt-description.with(translation: it.alt)
  }
  if type(it.alt) == function {
    description = (it.alt)(
      (
        sign: info.sign,
        int: info.int,
        frac: info.frac,
        pm: info.pm,
        e: info.e,
        base: it.base,
      ),
    )
  } else {
    description = it.alt
  }
  let collect = if it.math { equation-from-items.with(alt: description) } else { it => it.join() }

  if it.align == none {
    set text(dir: ltr)
    it.prefix + collect(components.join()) + it.suffix
  } else if it.align == "components" {
    components.map(c => {
      set text(dir: ltr)
      collect(c)
    })
  } else {
    set text(dir: ltr)

    let (col-widths, col) = it.align
    let components = components.map(x => if x == () { none } else {
      collect(x)
    })
    components.at(0) = it.prefix + components.at(0)
    if it.suffix != none {
      if components.at(2) == none and components.at(3) == none {
        components.at(1) += it.suffix
      } else {
        components.at(3) += it.suffix
      }
    }
    let widths = components.map(x => if x == none { 0pt } else {
      measure(x).width
    })

    if col-widths != auto {
      for i in range(4) {
        let alignment = if i == 0 { right } else { left }
        let content = align(alignment, components.at(i))
        components.at(i) = box(width: col-widths.at(i), content)
      }
    }

    [#components.join()#metadata((col,) + widths)<__pillar-num__>]
  }
}


#let num(
  number,
  align: none,
  state: auto,
  prefix: none,
  suffix: none,
  force-parentheses-around-uncertainty: false,
  ..args,
) = {
  assert-no-fixed(args)

  let inline-args = (
    align: align,
    prefix: prefix,
    suffix: suffix,
    fpau: force-parentheses-around-uncertainty,
  )

  if type(number) == array {
    let named = args.named()
    let num-state = if state == auto { num-state.get() } else { state }
    let it = num-state + inline-args + args.named()

    return number.map(n => {
      let info = process-input(n)
      utility.create-num-metadata(info, n, args)
      show-num(it + (info: info))
    })
  }

  let info = process-input(number)
  let metadata = utility.create-num-metadata(info, number, args)

  if state != auto {
    let it = (
      update-num-state(state, args.named()) + inline-args + (info: info)
    )
    if align == "components" {
      (metadata,) + show-num(it)
    } else {
      metadata
      show-num(it)
    }
  } else {
    metadata
    context {
      let it = (
        update-num-state(num-state.get(), args.named()) + inline-args + (info: info)
      )
      show-num(it)
    }
  }
}









/*

- Mantissa (value or uncertainty): Doesn't really need a show rule?
- Power: A rule would be beneficial. Does the multiplier need to be included?


Question: How to pass values on to the nested types

#set num.power(base: [5])
and then
#num(power: (base: [4]), "1.23e4")


show num.power: it => {
  - it.exponent [2.3]
  - it.base [10]
  - it.multiplier [×] ??

  math.attach([#it.base], t: [#it.exponent])

  or

  (
    box(),
    it.multiplier,
    math.attach([#it.base], t: [#it.exponent])
  )
}


show num.exponent: it => {
  - it.sign
  - it.integer
  - it.fractional

  it.sign + format-integer(it.integer) + format-fractional(it.fractional).join()
}


show num.uncertainty: it => {
  - it.value ([0.2, 0.4])
  - it.mode
  - it.symmetric false
  if it.mode == ...

  if it.symmetric {
    return (
      math.class("normal", none),
      math.class(if state.tight {"normal"} else {"binary"}, sym.plus.minus),
      it.value
    )
  } else {
    math.attach(none, t: sym.plus + it.value.at(0), b: sym.minus + it.value.at(1)),
  }
}

show num.num: it => {

}



*/

