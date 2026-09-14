#import "../../../utils.typ": build-option-flags
#import "init.typ": to-bytes
#let math-utils-wasm = plugin("../../../math-utils.wasm")

#let /*pub*/ repr(n) = {
  let buffer = to-bytes(n)
  str(math-utils-wasm.mpz_repr(buffer))
}

#let /*pub*/ to-str(
  n,
  plus-sign: false,
  signed-zero: false,
  signed-inf: false,
  hyphen-minus: false,
) = {
  let buffer = to-bytes(n)
  let flags = build-option-flags(plus-sign, signed-zero, signed-inf, hyphen-minus)
  str(math-utils-wasm.mpz_to_string(buffer, flags))
}