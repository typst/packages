// =========================================================================
// typcas v2 Integer Math Utilities
// =========================================================================

/// Positive divisors of integer `n`.
#let int-factors(n) = {
  let a = int(calc.abs(n))
  if a == 0 { return (1,) }

  let small = ()
  let large = ()
  let i = 1
  while i * i <= a {
    if calc.rem(a, i) == 0 {
      small.push(i)
      let j = int(a / i)
      if j != i { large.push(j) }
    }
    i += 1
  }

  let out = ()
  for s in small { out.push(s) }
  let k = large.len() - 1
  while k >= 0 {
    out.push(large.at(k))
    k -= 1
  }
  out
}

/// GCD of an integer collection (zeros ignored).
#let int-gcd-array(vals) = {
  let g = 0
  for v in vals {
    let a = int(calc.abs(v))
    if a == 0 { continue }
    g = if g == 0 { a } else { calc.gcd(g, a) }
  }
  if g == 0 { 1 } else { g }
}

/// LCM of two integers (0 if either input is 0).
#let int-lcm(a, b) = {
  let aa = int(calc.abs(a))
  let bb = int(calc.abs(b))
  if aa == 0 or bb == 0 { return 0 }
  int((aa / calc.gcd(aa, bb)) * bb)
}
