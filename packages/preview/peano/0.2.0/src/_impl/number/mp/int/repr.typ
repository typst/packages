#import "init.typ": to-bytes
#let math-utils-wasm = plugin("../../../math-utils.wasm")

#let /*pub*/ to-str(n) = {
  let buffer = to-bytes(n)
  str(math-utils-wasm.mpz_to_string(buffer))
}