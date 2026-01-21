//==============================================================================
// Linear congruential generator
//
// The period of this generator is 2^31.
// The generator is not very good -- the low bits of successive numbers
// are correlated.
//==============================================================================


// Get a new random integer from [0, 2^31) by update state
#let lcg-get(st) = {
  return (st * 1103515245 + 12345).bit-and(0x7FFFFFFF)
}


// Get a new random float from [0, 1) by update state
#let lcg-get-float(st) = {
  st = lcg-get(st)
  return (st, st / 2147483648.0)
}


// Construct a new random number generator with a seed
#let lcg-set(seed) = {
  return seed.bit-and(0xFFFFFFFF)
}
