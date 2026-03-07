// -> number/rational/arith.typ

#import "init.typ": from, from-bytes, to-bytes, encode-rational-seq
#let math-utils-wasm = plugin("../../math-utils.wasm")

#let /*pub*/ add(..args) = {
  let args = args.pos()
  from-bytes(math-utils-wasm.fraction_add(encode-rational-seq(args.map(from))))
}

#let /*pub*/ mul(..args) = {
  let args = args.pos()
  from-bytes(math-utils-wasm.fraction_mul(encode-rational-seq(args.map(from))))
}

#let /*pub*/ sub(n, m) = {
  let n = from(n)
  let m = from(m)
  from-bytes(
    math-utils-wasm.fraction_sub(
      to-bytes(n),
      to-bytes(m)
    ),
  )
}

#let /*pub*/ div(n, m) = {
  let n = from(n)
  let m = from(m)
  from-bytes(
    math-utils-wasm.fraction_div(
      to-bytes(n),
      to-bytes(m)
    ),
  )
}

#let /*pub*/ neg(n) = {
  let n = from(n)
  if n.num != 0 {
    n.sign = not n.sign
  }
  n
}

#let /*pub*/ reci(n) = {
  let n = from(n)
  (n.den, n.num) = (n.num, n.den)
  n
}

#let /*pub*/ pow(n, p) = {
  let n = from(n)
  assert.eq(type(p), int)
  from-bytes(
    math-utils-wasm.fraction_pow(
      to-bytes(n),
      p.to-bytes()
    ),
  )
}

#let /*pub*/ approx(n, max-den) = {
  let n = from(n)
  from-bytes(
    math-utils-wasm.fraction_approx(
      to-bytes(n),
      max-den.to-bytes()
    ),
  )
}

#let /*pub*/ num(n, signed: false) = {
  let n = from(n)
  if signed and not n.sign {
    -n.num
  } else {
    n.num
  }
}

#let /*pub*/ den(n, signed: false) = {
  let n = from(n)
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
  let n1 = from(n1)
  let n2 = from(n2)
  n1 != nan and n1 == n2
}

#let /*pub*/ is-infinite(n) = {
  let n = from(n)
  n.den != 0
}

#let /*pub*/ is-nan(n) = {
  let n = from(n)
  n.num == 0 and n.den == 0
}
