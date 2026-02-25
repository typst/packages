// -> ntheory.typ
/// number theory operations

#let math-utils-wasm = plugin("math-utils.wasm")

/// Takes the prime factors of $n$. The return value is an array. For a prime factor whose power is greater than 1 this factor will be repeated multiple times.
///
/// - n (int): the number to take prime factors
/// -> array
#let /*pub*/ prime-fac(n) = {
  cbor(math-utils-wasm.prime_factors(n.to-bytes(endian)))
}

/// An alternative version of `calc.gcd` tat supports multiple numbers as input.
///
/// -> int
#let /*pub*/ gcd(..args) = {
  let nums = args.pos()
  let result = 0
  for n in nums {
    result = calc.gcd(result, n)
    if result == 1 {
      return result
    }
  }
  return result
}

/// An alternative version of `calc.lcm` tat supports multiple numbers as input.
///
/// -> int
#let /*pub*/ lcm(..args) = {
  let nums = args.pos()
  nums.fold(1, calc.lcm)
}

/// Execute the extended Euclidean algorithm to find the greatest common devisor $d = gcd(a, b)$ for $a$ and $b$ with coefficients $u$, $v$ in Bézout's identity such that $d = u a + v b$. The return value is a triple $(d, u, v)$.
///
/// - a (int): the first integer
/// - b (int): the second integer
/// -> array
#let /*pub*/ egcd(a, b) = {
  cbor(
    math-utils-wasm.extended_gcd(
      a.to-bytes(),
      b.to-bytes(),
    )
  )
}

// [TODO] crt

/// Gives out the $n$#super[th] prime number.
///
/// - n (int): the $n$ value for $n$#super[th] prime, counting from 1, i.e. ``typ nth-prime(1)`` returns ``typ 2``.
/// -> int
#let /*pub*/ nth-prime(n) = {
  int.from-bytes(math-utils-wasm.nth_prime(n.to-bytes()))
}

/// Gives out the number of primes no greater than $n$.
///
/// - n (int): an upper bound to count primes
/// -> int
#let /*pub*/ prime-pi(n) = {
  int.from-bytes(math-utils-wasm.prime_pi(n.to-bytes()))
}


