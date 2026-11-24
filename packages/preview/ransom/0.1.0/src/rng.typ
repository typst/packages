// Deterministic pseudo-randomness.
//
// Typst has no random-number function, and a document has to compile to the
// very same result every time. Randomness here is therefore a pure function of
// a seed: a *state* is just an integer, and every helper takes one in and
// hands values back out. Nothing is stored between calls, which is also what
// lets editing one word leave the look of every other word untouched.
//
// The generator is Park–Miller "MINSTD". All intermediate products stay below
// 2^63, so Typst's 64-bit integers never overflow.

#let _modulus = 2147483647 // 2^31 - 1, a prime
#let _factor = 48271

// Scrambles any integer into a valid generator state (1 … modulus - 1).
//
// Squaring modulo a prime is non-linear, which breaks up the regular patterns
// that neighbouring seeds (1, 2, 3 …) would otherwise produce.
#let _mix(n) = {
  let s = calc.rem(calc.abs(n), _modulus - 1) + 1
  for _ in range(4) { s = calc.rem(s * s + 1013904223, _modulus) }
  if s == 0 { 1 } else { s }
}

#let _hash(s) = {
  let h = 5381
  for c in s.codepoints() {
    h = calc.rem(h * 33 + str.to-unicode(c), _modulus)
  }
  h
}

/// Creates a state from an integer, a string, or anything with a `repr`.
#let seed(value) = {
  if type(value) == int { _mix(value) }
  else if type(value) == str { _mix(_hash(value)) }
  else { _mix(_hash(repr(value))) }
}

/// Derives an independent child state, e.g. one per word or per letter.
#let fork(state, index) = _mix(state * 1000003 + index)

/// Returns `n` numbers in the range [0, 1) drawn from `state`.
#let draws(state, n) = {
  let out = ()
  for _ in range(n) {
    state = calc.rem(state * _factor, _modulus)
    out.push(state / _modulus)
  }
  out
}

/// Maps a number `u` in [0, 1) onto the range [lo, hi).
#let between(u, lo, hi) = lo + (hi - lo) * u

/// Picks one of `items`, uniformly.
#let pick(items, u) = items.at(calc.min(calc.floor(u * items.len()), items.len() - 1))

/// Picks one of `items`, favouring those with a larger `weight` entry.
#let pick-weighted(items, u) = {
  let weight(item) = item.at("weight", default: 1)
  let target = u * items.map(weight).sum()
  for item in items {
    target -= weight(item)
    if target < 0 { return item }
  }
  items.last()
}
