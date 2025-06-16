//==============================================================================
// Random number generator
//
// Public functions are:
//     gen-rng
//     integers, random, uniform, normal
//     shuffle, choice
//==============================================================================


#import "taus.typ": taus-get, taus-get-float, taus-set


//----------------------------------------------------------
// Private functions
//----------------------------------------------------------

// Return random integers from [0, n), 1 <= n <= 0xFFFFFFFF
#let _uniform-int(rng, n) = {
  let scale = calc.quo(0xFFFFFFFF, n)
  let val = 0

  while true {
    (rng, val) = taus-get(rng)
    let k = calc.quo(val, scale)
    if k < n {return (rng, k)}
  }
}


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Construct a new random number generator with a seed
//
// Arguments:
//     seed: value of seed, effective value is an integer from [1, 2^32-1]
//
// Returns:
//     rng: generated object of random number generator
#let gen-rng(seed) = {
  assert(type(seed) == int, message: "`seed` should be an integer")

  taus-set(seed)
}


// Return random integers from low (inclusive) to high (exclusive).
//
// Arguments:
//     rng: object of random number generator
//     low: lowest (signed) integers to be drawn from the distribution, optional
//     high: one above the largest (signed) integer to be drawn from the distribution, optional
//     size: returned array size, must be positive integer, optional
//     endpoint: if true, sample from the interval [low, high] instead of the default [low, high), optional
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random numbers
#let integers(rng, low: 0, high: 100, size: 1, endpoint: false) = {
  assert(type(size) == int and size >= 1, message: "`size` should be positive")

  let gap = high - low
  if endpoint {gap += 1}
  assert(gap >= 1 and gap <= 0xFFFFFFFF, message: "invalid range between `low` and `high`")

  let val = 0
  let a = ()
  for i in range(size) {
    (rng, val) = _uniform-int(rng, gap)
    a.push(val + low)
  }

  if size == 1 {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}


// Return random floats in the half-open interval [0.0, 1.0).
//
// Arguments:
//     rng: object of random number generator
//     size: returned array size, must be positive integer, optional
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random numbers
#let random(rng, size: 1) = {
  assert(type(size) == int and size >= 1, message: "`size` should be positive")

  let val = 0
  let a = ()
  for i in range(size) {
    (rng, val) = taus-get-float(rng)
    a.push(val)
  }

  if size == 1 {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}


// Draw samples from a uniform distribution of half-open interval [low, high) (includes low, but excludes high).
//
// Arguments:
//     rng: object of random number generator
//     low: lower boundary of the output interval, optional
//     high: upper boundary of the output interval, optional
//     size: returned array size, must be positive integer, optional
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random numbers
#let uniform(rng, low: 0.0, high: 1.0, size: 1) = {
  assert(type(size) == int and size >= 1, message: "`size` should be positive")

  let val = 0
  let a = ()
  for i in range(size) {
    (rng, val) = taus-get-float(rng)
    a.push(low * (1 - val) + high * val)
  }

  if size == 1 {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}


// Draw random samples from a normal (Gaussian) distribution.
//
// Arguments:
//     rng: object of random number generator
//     loc: float, mean (centre) of the distribution, optional
//     scale: float, standard deviation (spread or width) of the distribution, must be non-negative, optional
//     size: returned array size, must be positive integer, optional
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random numbers
#let normal(rng, loc: 0.0, scale: 1.0, size: 1) = {
  assert(type(size) == int and size >= 1, message: "`size` should be positive")
  assert(scale >= 0, message: "`scale` should be non-negative")

  let x = 0
  let y = 0
  let r2 = 0
  let val = 0
  let a = ()
  for i in range(size) {
    while true {
      // Choose x and y in uniform square (-1,-1) to (+1,+1)
      (rng, val) = taus-get-float(rng)
      x = -1 + 2 * val
      (rng, val) = taus-get-float(rng)
      y = -1 + 2 * val

      // See if it is in the unit circle
      r2 = x * x + y * y
      if r2 <= 1.0 and r2 != 0 {break}
    }

    // Box-Muller transform
    a.push(loc + scale * y * calc.sqrt(-2.0 * calc.ln(r2) / r2));
  }

  if size == 1 {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}


// Randomly shuffle a given array.
//
// Arguments:
//     rng: object of random number generator
//     arr: the array to be shuffled
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: shuffled array
#let shuffle(rng, arr) = {
  assert(type(arr) == array, message: "`arr` should be arrry type")

  let size = arr.len()
  assert(size >= 1, message: "size of `arr` should be positive")
  if size == 1 {return (rng, arr)}

  let j = 0
  for i in range(size - 1, 0, step: -1) {
    (rng, j) = _uniform-int(rng, i + 1)
    if i != j {
      (arr.at(i), arr.at(j)) = (arr.at(j), arr.at(i))
    }
  }
  return (rng, arr)
}


// Generates random samples from a given array.
// The sample assumes a uniform distribution over all entries in the array.
//
// Arguments:
//     rng: object of random number generator
//     arr: the array to be sampled
//     size: returned array size, must be positive integer, optional
//     replacement: whether the sample is with or without replacement, optional; default is true, meaning that a value of arr can be selected multiple times.
//     permutation: whether the sample is permuted when sampling without replacement, optional; default is true, false provides a speedup.
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: generated random samples
#let choice(rng, arr, size: 1, replacement: true, permutation: true) = {
  assert(type(arr) == array, message: "`arr` should be arrry type")
  assert(type(size) == int and size >= 1, message: "`size` should be positive")
  assert(type(replacement) == bool, message: "`replacement` should be boolean")
  assert(type(permutation) == bool, message: "`permutation` should be boolean")

  let n = arr.len()
  assert(n >= 1, message: "size of `arr` should be positive")

  let val = 0
  let a = ()

  if replacement { // Sample with replacement
    for i in range(size) {
      (rng, val) = _uniform-int(rng, n)
      a.push(arr.at(val))
    }
  } else { // Sample without replacement
    assert(size <= n, message: "`size` should be no more than input array size when `replacement` is false")

    let i = 0
    let j = 0
    while i < n and j < size {
      (rng, val) = taus-get-float(rng)
      if (n - i) * val < size - j {
        a.push(arr.at(i))
        j += 1
      }
      i += 1
    }
    if permutation {
      (rng, a) = shuffle(rng, a)
    }
  }

  if size == 1 {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}
