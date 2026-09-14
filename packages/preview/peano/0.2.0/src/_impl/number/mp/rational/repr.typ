#import "init.typ": num, den, from, to-bytes
#import "../int/repr.typ": to-str as int_to-str
#let math-utils-wasm = plugin("../../../math-utils.wasm")

#let /*pub*/ repr(n) = {
  str(math-utils-wasm.mpq_repr(to-bytes(n)))
}

#let build-option-flags(..args) = {
  let args = args.pos()
  let flags = 0
  let digit = 1
  for b in args {
    if b { flags = flags.bit-or(digit) }
    digit = digit.bit-lshift(1)
  }
  flags
}

#let /*pub*/ to-str(
  n,
  plus-sign: false,
  signed-zero: false,
  signed-infinity: false,
  denom-one: false,
  hyphen-minus: false,
) = {
  let option-flags = build-option-flags(
    plus-sign,
    signed-zero,
    signed-infinity,
    denom-one,
    hyphen-minus,
  )
  option-flags = bytes((option-flags,))
  str(math-utils-wasm.mpq_to_str(to-bytes(n), option-flags))
}

#let /*pub*/ to-math(
  n,
  plus-sign: false,
  signed-zero: false,
  signed-infinity: false,
  denom-one: false,
  sign-on-num: false,
  fmt: none,
) = {
  let option-flags = build-option-flags(
    plus-sign,
    signed-zero,
    signed-infinity,
    denom-one,
    false,
  )
  let option-flags = bytes((option-flags,))
  let (sign, num, den) = cbor(math-utils-wasm.mpq_to_math(to-bytes(n), option-flags))

  if type(fmt) == dictionary {
    if "num" in fmt {
      let fmt = fmt.num
      assert.eq(type(fmt), function)
      num = fmt(num)
    }
    if "den" in fmt {
      let fmt = fmt.num
      assert.eq(type(fmt), function)
      den = fmt(num)
    }
  } else if type(fmt) == function {
    num = fmt(num)
    den = fmt(den)
  } else if fmt != none {
    panic("`number-formatter` should be one of: `none`, `function` or `dictionary`.")
  }
  // [TODO] formatting by string?

  if den == none { $#sign#num$ }
  else if sign-on-num { $#math.frac($#sign#num$, den)$ }
  else { $#sign#math.frac(num, den)$ }
}
