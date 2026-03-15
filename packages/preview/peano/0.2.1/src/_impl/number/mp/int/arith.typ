#import "init.typ": to-bytes, mp-int
#let math-utils-wasm = plugin("../../../math-utils.wasm")

#let /*pub*/ add(..args) = {
  mp-int(
    buffer: math-utils-wasm.mpz_add(
      cbor.encode(args.pos().map(it => cbor(to-bytes((it)))))
    )
  )
}

#let /*pub*/ sub(m, n) = {
  mp-int(buffer: math-utils-wasm.mpz_sub(to-bytes(m), to-bytes(n)))
}

#let /*pub*/ mul(..args) = {
  mp-int(
    buffer: math-utils-wasm.mpz_mul(
      cbor.encode(args.pos().map(it => cbor(to-bytes((it)))))
    )
  )
}

#let /*pub*/ div(m, n) = {
  mp-int(buffer: math-utils-wasm.mpz_div(to-bytes(m), to-bytes(n)))
}

#let /*pub*/ neg(n) = {
  mp-int(buffer: math-utils-wasm.mpz_neg(to-bytes(n)))
}

#let /*pub*/ abs(n) = {
  mp-int(buffer: math-utils-wasm.mpz_abs(to-bytes(n)))
}

#let /*pub*/ pow(n, p) = {
  mp-int(buffer: math-utils-wasm.mpz_pow(to-bytes(n), int(p).to-bytes()))
}

#let /*pub*/ fact(n) = {
  mp-int(buffer: math-utils-wasm.mpz_fact(int(n).to-bytes()))
}

#let /*pub*/ binom(n, k) = {
  mp-int(buffer: math-utils-wasm.mpz_binom(to-bytes(n), to-bytes(k)))
}

#let /*pub*/ cmp(m, n) = {
  int.from-bytes(math-utils-wasm.mpz_cmp(to-bytes(m), to-bytes(n)))
}

#let /*pub*/ sign(n) = {
  int.from-bytes(math-utils-wasm.mpz_sign(to-bytes(n)))
}
