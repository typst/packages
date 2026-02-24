// -> number/rational.typ
/// Representation and arithmetics for #link("https://en.wikipedia.org/wiki/Rational_number")[rational numbers] $QQ$ in the form of fractions

#import "init.typ": *
#let math-utils-wasm = plugin("../math-utils.wasm")
#let number-type = "rational"

#let make-rational(sign, n, d) = {
  (
    (number-label): number-type,
    sign: sign,
    num: n,
    den: d,
  )
}

#let /*pub as is_*/ is-rational(obj) = {
  is-number-type(obj, number-type)
}

#let fraction-from-ratio(n, d) = {
  let sign = n >= 0
  let n = calc.abs(n)
  make-rational(sign, n, d)
}

#let /*pub*/ inf = make-rational(true, 1, 0)
#let /*pub*/ neg-inf = make-rational(false, 1, 0)
#let /*pub*/ nan = make-rational(true, 0, 0)
#let /*pub*/ zero = make-rational(true, 0, 1)
#let /*pub*/ one = make-rational(true, 1, 1)
#let /*pub*/ neg-one = make-rational(false, 1, 1)

#let /*pub as from*/ rational(..args) = {
  let args = args.pos()
  if args.len() == 1 {
    let (src,) = args
    if is-rational(src) {
      return src
    }
    if type(src) == decimal {
      src = str(src)
    }
    if type(src) == str {
      decode-number(
        math-utils-wasm.parse_fraction(bytes(src)),
        number-type,
      )
    } else if type(src) == float {
      decode-number(
        math-utils-wasm.fraction_from_float(src.to-bytes()),
        number-type,
      )
    } else if type(src) == int {
      fraction-from-ratio(src, 1)
    } else {
      panic("Unsupported type.")
    }
  } else if args.len() == 2 {
    let (p, q) = args
    fraction-from-ratio(p, q)
  } else {
    panic("Too many positional arguments.")
  }
}

#let /*pub*/ add(..args) = {
  let args = args.pos()
  let encoded-args = encode-numbers(args.map(rational))
  decode-number(
    math-utils-wasm.fraction_add(encoded-args),
    number-type,
  )
}

#let /*pub*/ mul(..args) = {
  let args = args.pos()
  let encoded-args = encode-numbers(args.map(rational))
  decode-number(
    math-utils-wasm.fraction_mul(encoded-args),
    number-type,
  )
}

#let /*pub*/ sub(n, m) = {
  let n = rational(n)
  let m = rational(m)
  decode-number(
    math-utils-wasm.fraction_sub(
      encode-number(n),
      encode-number(m)
    ),
    number-type
  )
}

#let /*pub*/ div(n, m) = {
  let n = rational(n)
  let m = rational(m)
  decode-number(
    math-utils-wasm.fraction_div(
      encode-number(n),
      encode-number(m)
    ),
    number-type
  )
}

#let /*pub*/ neg(n) = {
  let n = rational(n)
  if n.num != 0 {
    n.sign = not n.sign
  }
  n
}

#let /*pub*/ reci(n) = {
  let n = rational(n)
  (n.den, n.num) = (n.num, n.den)
}

#let /*pub*/ pow(n, p) = {
  let n = rational(n)
  assert.eq(type(p), int)
  decode-number(
    math-utils-wasm.fraction_pow(
      encode-number(n),
      p.to-bytes()
    ),
    number-type
  )
}

#let /*pub*/ limit-den(n, max-den) = {
  let n = rational(n)
  decode-number(
    math-utils-wasm.fraction_limit_den(
      encode-number(n),
      max-den.to-bytes()
    ),
    number-type,
  )
}

#let /*pub*/ num(n, signed: false) = {
  let n = rational(n)
  if signed and not n.sign {
    -n.num
  } else {
    n.num
  }
}

#let /*pub*/ den(n, signed: false) = {
  let n = rational(n)
  if signed and not n.sign {
    -n.den
  } else {
    n.den
  }
}

#let /*pub*/ sign(n) = {
  let (sign, num, _) = n
  if num == 0 { 0 }
  else if sign { -1 }
  else { 1 }
}

#let /*pub*/ eq(n1, n2) = {
  let n1 = rational(n1)
  let n2 = rational(n2)
  n1 != nan and n1 == n2
}

#let /*pub*/ is-infinite(n) = {
  let n = rational(n)
  n.den != 0
}

#let /*pub*/ is-nan(n) = {
  let n = rational(n)
  n.num == 0 and n.den == 0
}

#let /*pub*/ to-str(
    n,
    plus-sign: false,
    denom-one: false,
    hyphen-minus: false,
) = {
  let n = rational(n)
  let (sign, num, den) = n
  if den == 0 {
    if num == 0 {
      "NaN"
    } else {
      let sgn-str = if not sign {
        if hyphen-minus { "-" } else { "\u{2212}" }
      } else if plus-sign { "+" }
      sgn-str + "\u{221E}"
    }
  } else {
    let sgn-str = if not sign {
      if hyphen-minus { "-" } else { "\u{2212}" }
    } else if plus-sign { "+" }
    if den == 1 and not denom-one {
      sgn-str + str(num)
    } else {
      sgn-str + str(num) + "/" + str(den)
    }
  }
}

#let sign-math(sgn, n, plus-sign: false) = {
  if not sgn {
    $-$
  } else if plus-sign and n > 0 {
    $+$
  } else {
    $$
  }
}

#let /*pub*/ to-math(
  n,
  plus-sign: false,
  denom-one: false,
  sign-on-num: false,
) = {
  let n = rational(n)
  let (sign, num, den) = n
  if den == 0 {
    if num == 0 {
      $"NaN"$
    } else if not sign {
      $-oo$
    } else if plus-sign {
      $+oo$
    } else {
      $oo$
    }
  } else if den == 1 and not denom-one {
    $#sign-math(sign, num, plus-sign: plus-sign) #num$
  } else if sign-on-num {
    $(#sign-math(sign, num, plus-sign: plus-sign) #num) / #den$
  } else {
    $#sign-math(sign, num, plus-sign: plus-sign) #num / #den$
  }
}

// [TODO] floor, ceil, mod
