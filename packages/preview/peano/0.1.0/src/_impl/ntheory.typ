// -> ntheory.typ
/// number theory operations

#let math-utils-wasm = plugin("math-utils.wasm")

#let /*pub*/ prime-fac(num) = {
  cbor(math-utils-wasm.prime_factors(num.to-bytes(endian: "little")))
}

/// Execute the extended Euclidean algorithm to find the greatest common devisor $d = gcd(a, b)$ for $a$ and $b$ with coefficients $u$, $v$ in Bézout's identity such that $d = u a + v b$. The return value is a triple $(d, u, v)$.
#let /*pub*/ egcd(a, b) = {
  cbor(
    math-utils-wasm.extended_gcd(
      a.to-bytes(endian: "little"),
      b.to-bytes(endian: "little"),
    )
  )
}
