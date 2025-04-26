//==============================================================================
// Maximally equidistributed combined Tausworthe generator
//
// The period of this generator is about 2^88.
// Part of algorithm implementations reference to
// GSL (https://www.gnu.org/software/gsl)
//==============================================================================


// Tausworthe operator
#let _tausworthe(s, a, b, c, d) = {
  let s1 = s.bit-and(c).bit-lshift(d).bit-and(0xFFFFFFFF)
  let s2 = s.bit-lshift(a).bit-and(0xFFFFFFFF).bit-xor(s).bit-rshift(b)
  return s1.bit-xor(s2)
}


// Get a new random integer from [0, 2^32) by update state
#let taus-get(st) = {
  let s1 = _tausworthe(st.at(0), 13, 19, 4294967294, 12)
  let s2 = _tausworthe(st.at(1), 2, 25, 4294967288, 4)
  let s3 = _tausworthe(st.at(2), 3, 11, 4294967280, 17)
  let val = s1.bit-xor(s2).bit-xor(s3)
  return ((s1, s2, s3), val)
}


// Get a new random float from [0, 1) by update state
#let taus-get-float(st) = {
  let (st, val) = taus-get(st)
  return (st, val / 4294967296.0)
}


// Construct a new random number generator with a seed
#let taus-set(seed) = {
  let s = seed.bit-and(0xFFFFFFFF)
  if s == 0 {s = 1}

  let s1 = (69069 * s).bit-and(0xFFFFFFFF)
  if (s1 < 2) {s1 += 2}
  let s2 = (69069 * s1).bit-and(0xFFFFFFFF)
  if (s2 < 8) {s2 += 8}
  let s3 = (69069 * s2).bit-and(0xFFFFFFFF)
  if (s3 < 16) {s3 += 16}
  let st = (s1, s2, s3)

  // Warm it up
  (st, _) = taus-get(st)
  (st, _) = taus-get(st)
  (st, _) = taus-get(st)
  (st, _) = taus-get(st)
  (st, _) = taus-get(st)
  (st, _) = taus-get(st)
  return st
}
