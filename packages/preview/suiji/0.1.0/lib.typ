//==============================================================================
// Random number generator
//==============================================================================


//----------------------------------------------------------
// Internal parameters and functions
//----------------------------------------------------------

// Maximally equidistributed combined Tausworthe generator
// The period of this generator is about 2^88.
// Part of algorithm implementations reference to GSL (https://www.gnu.org/software/gsl)
#let _rand-max = 0xFFFFFFFF
#let _rand-min = 0
#let _mask = 0xFFFFFFFF


#let _tausworthe(s, a, b, c, d) = {
  let s1 = s.bit-and(c).bit-lshift(d).bit-and(_mask)
  let s2 = s.bit-lshift(a).bit-and(_mask).bit-xor(s).bit-rshift(b)
  return s1.bit-xor(s2)
}


#let _lcg(n) = {
  return (69069 * n).bit-and(_mask)
}


#let _get(state) = {
  let s1 = _tausworthe(state.at(0), 13, 19, 4294967294, 12)
  let s2 = _tausworthe(state.at(1), 2, 25, 4294967288, 4)
  let s3 = _tausworthe(state.at(2), 3, 11, 4294967280, 17)
  let val = s1.bit-xor(s2).bit-xor(s3)
  return ((s1, s2, s3), val)
}


#let _uniform(state) = {
  let (state-new, val) = _get(state)
  return (state-new, val / 4294967296.0)
}


#let _uniform-int(state, n) = {
  let gap = _rand-max - _rand-min
  let scale = calc.quo(gap, n)

  while true {
    let (state-new, val) = _get(state)
    let k = calc.quo(val, scale)
    if k < n {return (state-new, k)}
  }
}


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Initialized the random number generator (Tausworthe)
// Arguments:
//     seed: value of seed (integer)
// Returns:
//     rng: generated object of random number generator
#let gen-rng(seed) = {
  let s = int(seed).bit-and(_mask)
  if s == 0 {s = 1}

  let s1 = _lcg(s)
  if (s1 < 2) {s1 = s1 + 2}
  let s2 = _lcg(s1)
  if (s2 < 8) {s2 = s2 + 8}
  let s3 = _lcg(s2)
  if (s3 < 16) {s3 = s3 + 16}
  let state = (s1, s2, s3)

  // Warm it up
  (state, _) = _get(state)
  (state, _) = _get(state)
  (state, _) = _get(state)
  (state, _) = _get(state)
  (state, _) = _get(state)
  (state, _) = _get(state)
  return state
}


// Return random integers from low (inclusive) to high (exclusive).
// Arguments:
//     rng: object of random number generator
//     low: lowest (signed) integers to be drawn from the distribution, optional
//     high: one above the largest (signed) integer to be drawn from the distribution, optional
//     size: returned array size, optional
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: returned array of random number(s)
#let integers(rng, low: 0, high: 100, size: 1) = {
  assert(type(size) == int and size >= 1, message: "`size` should be positive")
  assert(high - low >= 1 and high - low <= 0xFFFFFFFF, message: "invalid range between `low` and `high`")

  let gap = high - low
  let state = rng
  let val = 0
  let a = ()
  for i in range(size) {
    (state, val) = _uniform-int(state, gap)
    a.push(val + low)
  }

  if size == 1 {
    return (state, a.at(0))
  } else {
    return (state, a)
  }
}


// Return random floats in the half-open interval [0.0, 1.0).
// Arguments:
//     rng: object of random number generator
//     size: returned array size, optional
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random number(s)
#let random(rng, size: 1) = {
  assert(type(size) == int and size >= 1, message: "`size` should be positive")

  let state = rng
  let val = 0
  let a = ()
  for i in range(size) {
    (state, val) = _uniform(state)
    a.push(val)
  }

  if size == 1 {
    return (state, a.at(0))
  } else {
    return (state, a)
  }
}


// Draw samples from a uniform distribution.
// Samples are uniformly distributed over the half-open interval [low, high) (includes low, but excludes high).
// Arguments:
//     rng: object of random number generator
//     low: lower boundary of the output interval, optional
//     high: upper boundary of the output interval, optional
//     size: returned array size, optional
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random number(s)
#let uniform(rng, low: 0.0, high: 1.0, size: 1) = {
  assert(type(size) == int and size >= 1, message: "`size` should be positive")

  let state = rng
  let val = 0
  let a = ()
  for i in range(size) {
    (state, val) = _uniform(state)
    a.push(low * (1 - val) + high * val)
  }

  if size == 1 {
    return (state, a.at(0))
  } else {
    return (state, a)
  }
}


// Draw random samples from a normal (Gaussian) distribution.
// Arguments:
//     rng: object of random number generator
//     loc: float, mean (centre) of the distribution, optional
//     scale: float, standard deviation (spread or width) of the distribution, must be non-negative, optional
//     size: returned array size, optional
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random number(s)
#let normal(rng, loc: 0.0, scale: 1.0, size: 1) = {
  assert(type(size) == int and size >= 1, message: "`size` should be positive")
  assert(scale >= 0, message: "`scale` must be non-negative")

  let x = 0
  let y = 0
  let r2 = 0
  let state = rng
  let val = 0
  let a = ()
  for i in range(size) {
    while true {
      // Choose x and y in uniform square (-1,-1) to (+1,+1)
      (state, val) = _uniform(state)
      x = -1 + 2 * val
      (state, val) = _uniform(state)
      y = -1 + 2 * val

      // See if it is in the unit circle
      r2 = x * x + y * y
      if r2 <= 1.0 and r2 != 0 {break}
    }

    // Box-Muller transform
    a.push(loc + scale * y * calc.sqrt(-2.0 * calc.ln(r2) / r2));
  }

  if size == 1 {
    return (state, a.at(0))
  } else {
    return (state, a)
  }
}


// Return a new sequence by shuffling its contents.
// Arguments:
//     rng: object of random number generator
//     arr: the array to be shuffled
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: shuffled array
#let shuffle(rng, arr) = {
  assert(type(arr) == array, message: "`arr` should be arrry type")

  let size = arr.len()
  if size <= 1 {return (rng, arr)}

  let state = rng
  let j = 0
  for i in range(size - 1, 0, step: -1) {
    (state, j) = _uniform-int(state, i + 1)
    (arr.at(i), arr.at(j)) = (arr.at(j), arr.at(i))
  }
  return (state, arr)
}
