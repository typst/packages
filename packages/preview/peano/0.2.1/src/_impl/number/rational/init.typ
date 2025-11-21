// -> number/rational/init.typ

#import "@preview/elembic:1.1.1" as e
#let math-utils-wasm = plugin("../../math-utils.wasm")

#let rational = e.types.declare(
  "rational",
  prefix: "peano.number",
  fields: (
    e.field(
      "sign",
      bool,
      doc: "SIgn of the rational number. `true` for non-negative and `false` for negative."
    ),
    e.field(
      "num",
      int,
      doc: "Numerator. Always positive.",
    ),
    e.field(
      "den",
      int,
      doc: "Denominator. Always positive.",
    ),
  ),
  doc: "Representation of a rational number in the form of fraction.",
)

#let make-rational(sign, n, d) = {
  rational(
    sign: sign,
    num: n,
    den: d,
  )
}

#let /*pub*/ from-bytes(buffer) = {
  let (sign, num, den) = cbor(buffer)
  make-rational(sign, num, den)
}

#let /*pub*/ to-bytes(n) = {
  cbor.encode((sign: n.sign, num: n.num, den: n.den))
}

#let /*pub*/ is_(obj) = {
  e.tid(obj) == e.tid(rational)
}

#let encode-rational-seq(obj) = {
  cbor.encode(obj.map(((sign, num, den)) => (sign: sign, num: num, den: den)))
}

#let decode-rational-seq(buffer) = {
  cbor(buffer).map(args => (rational.new)(..args))
}

#let fraction-from-ratio(n, d) = {
  let sign = (n >= 0 and d >= 0) or (n < 0 and d < 0)
  let n = calc.abs(n)
  let d = calc.abs(d)
  make-rational(sign, n, d)
}

#let /*pub*/ from(..args) = {
  let args = args.pos()
  if args.len() == 1 {
    let (src,) = args
    if is_(src) {
      return src
    }
    if type(src) == decimal {
      src = str(src)
    }
    if type(src) == str {
      from-bytes(math-utils-wasm.parse_fraction(bytes(src)))
    } else if type(src) == float {
      from-bytes(math-utils-wasm.fraction_from_float(src.to-bytes()))
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

#let /*pub*/ cmp(m, n) = {
  let m = from(m)
  let n = from(n)
  int.from-bytes(math-utils-wasm.fraction_cmp(to-bytes(m), to-bytes(n)))
}

#let /*pub*/ to-float(n) = {
  let n = from(n)
  let (sign, num, den) = n
  if den == 0 {
    if num == 0 {
      float.nan
    } else if sign {
      float.inf
    } else {
      -float.inf
    }
  } else if n.sign {
    num / den
  } else {
    (-num) / den
  }
}
