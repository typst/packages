#import "init.typ": mp-rational, to-bytes
#import "../int/init.typ": mp-int, to-bytes as mpz_to-bytes
#let math-utils-wasm = plugin("../../../math-utils.wasm")
#let zero-byte = bytes((0,))

#let /*pub*/ add(..args) = {
  mp-rational(
    buffer: math-utils-wasm.mpq_add(
      cbor.encode(args.pos().map(it => cbor(to-bytes((it)))))
    )
  )
}

#let /*pub*/ mul(..args) = {
  mp-rational(
    buffer: math-utils-wasm.mpq_mul(
      cbor.encode(args.pos().map(it => cbor(to-bytes((it)))))
    )
  )
}

#let /*pub*/ sub(m, n) = {
  mp-rational(buffer: math-utils-wasm.mpq_sub(to-bytes(m), to-bytes(n)))
}

#let /*pub*/ div(m, n) = {
  mp-rational(buffer: math-utils-wasm.mpq_div(to-bytes(m), to-bytes(n)))
}

#let /*pub*/ neg(n) = {
  mp-rational(buffer: math-utils-wasm.mpq_neg(to-bytes(n)))
}

#let /*pub*/ pow(n, p) = {
  mp-rational(buffer: math-utils-wasm.mpq_pow(to-bytes(n), int(p).to-bytes()))
}

#let /*pub*/ reci(n) = {
  mp-rational(buffer: math-utils-wasm.mpq_reci(to-bytes(n)))
}

#let /*pub*/ abs(n) = {
  mp-rational(buffer: math-utils-wasm.mpq_abs(to-bytes(n)))
}

#let /*pub*/ sign(n, strict: false) = {
  int.from-bytes(
    (
      if strict { math-utils-wasm.mpq_sign_strict }
      else { math-utils-wasm.mpq_sign }
    )(to-bytes(n))
  )
}

#let /*pub*/ cmp(m, n, strict: false, nan-eq: false) = {
  let result-byte = (
    if strict { math-utils-wasm.mpq_cmp_strict }
    else { math-utils-wasm.mpq_cmp }
  )(to-bytes(m), to-bytes(n))
  if result-byte.len() == 0 {
    if nan-eq { 0 } else { none }
  }
  else { int.from-bytes(result-byte) }
}

#let /*pub*/ eq(m, n, strict: false, nan-eq: false) = {
  cmp(m, n, strict: strict, nan-eq: nan-eq) == 0
}

#let /*pub*/ is-nan(n) = {
  math-utils-wasm.mpq_is_nan(to-bytes(n)) != zero-byte
}

#let /*pub*/ is-finite(n) = {
  math-utils-wasm.mpq_is_finite(to-bytes(n)) != zero-byte
}

#let /*pub*/ is-infinite(n) = {
  math-utils-wasm.mpq_is_infinite(to-bytes(n)) != zero-byte
}

#let /*pub*/ approx(n, max-den) = {
  mp-rational(buffer: math-utils-wasm.mpq_approx(to-bytes(n), mpz_to-bytes(max-den)))
}

#let /*pub*/ floor(n) = {
  mp-int(buffer: math-utils-wasm.mpq_floor(to-bytes(n)))
}

#let /*pub*/ ceil(n) = {
  mp-int(buffer: math-utils-wasm.mpq_ceil(to-bytes(n)))
}
