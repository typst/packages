// =========================================================================
// CAS Integer Math Helpers
// =========================================================================
// Shared integer helpers for candidate generation and coefficient cleanup.
// =========================================================================

/// Public helper `int-factors`.
#let int-factors(n) = {
  let a = int(calc.abs(n))
  if a == 0 { return (1,) }
  let f = ()
  for i in range(1, a + 1) {
    if calc.rem(a, i) == 0 { f.push(i) }
  }
  f
}

/// Public helper `int-gcd-array`.
#let int-gcd-array(vals) = {
  let g = 0
  for v in vals {
    let a = int(calc.abs(v))
    if a == 0 { continue }
    if g == 0 {
      g = a
    } else {
      g = calc.gcd(g, a)
    }
  }
  if g == 0 { 1 } else { g }
}

/// Public helper `int-lcm`.
#let int-lcm(a, b) = {
  let aa = int(calc.abs(a))
  let bb = int(calc.abs(b))
  if aa == 0 or bb == 0 { return 0 }
  int(aa / calc.gcd(aa, bb) * bb)
}
