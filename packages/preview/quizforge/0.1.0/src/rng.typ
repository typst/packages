// Deterministic PRNG for reproducible exam sets.
//
// Pure 64-bit integer arithmetic (no packages, no clocks): results are identical
// across machines, platforms, and Typst versions. All randomness in the system
// derives from fnv1a() hashes of explicit seed strings — see SPEC.md §2.

// FNV-1a 32-bit hash of a string. Intermediate products stay well below 2^63.
#let fnv1a(s) = {
  let h = 2166136261
  for b in bytes(s) {
    h = h.bit-xor(b)
    h = (h * 16777619).bit-and(0xFFFFFFFF)
  }
  h
}

// xorshift32 step. State must be a nonzero 32-bit integer.
#let xorshift32(state) = {
  let x = state
  x = x.bit-xor(x.bit-lshift(13).bit-and(0xFFFFFFFF))
  x = x.bit-xor(x.bit-rshift(17))
  x = x.bit-xor(x.bit-lshift(5).bit-and(0xFFFFFFFF))
  x.bit-and(0xFFFFFFFF)
}

// Seed from a string; warm up so that similar seed strings (which FNV maps to
// similar integers) diverge before the first draw is used.
#let seed-from(s) = {
  let x = fnv1a(s)
  if x == 0 { x = 0x9E3779B9 }
  for _ in range(3) { x = xorshift32(x) }
  x
}

// Fisher-Yates shuffle, seeded by a string. Returns the permuted array.
#let shuffle(arr, seed-str) = {
  let a = arr
  let s = seed-from(seed-str)
  let i = a.len() - 1
  while i > 0 {
    s = xorshift32(s)
    let j = calc.rem(s, i + 1)
    let tmp = a.at(i)
    a.at(i) = a.at(j)
    a.at(j) = tmp
    i -= 1
  }
  a
}

// Sample n items without replacement (deterministic for a given seed string).
#let sample(arr, n, seed-str) = shuffle(arr, seed-str).slice(0, n)
