//==============================================================================
// Random number generator (fast version)
//
// Public functions:
//     gen-rng-f
//     integers-f, random-f, uniform-f, normal-f
//     discrete-preproc-f, discrete-f
//     shuffle-f, choice-f
//==============================================================================


#let plg = plugin("core.wasm")


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Construct a new random number generator with a seed
//
// Arguments:
//     seed: value of seed, effective value is an integer from [0, 2^32-1]
//
// Returns:
//     rng: generated object of random number generator
#let gen-rng-f(seed) = {
  assert(type(seed) == int, message: "`seed` should be an integer")

  let enc = cbor.encode(seed.bit-and(0xFFFFFFFF))
  let dec = cbor(plg.gen_rng_fn(enc))
  dec
}


// Return random integers from low (inclusive) to high (exclusive)
//
// Arguments:
//     rng: object of random number generator
//     low: lowest (signed) integers to be drawn from the distribution, optional
//     high: one above the largest (signed) integer to be drawn from the distribution, optional
//     size: returned array size, must be none or non-negative integer, optional
//     endpoint: if true, sample from the interval [low, high] instead of the default [low, high), optional
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random numbers
#let integers-f(rng, low: 0, high: 100, size: none, endpoint: false) = {
  assert(type(low) == int, message: "`low` should be integer")
  assert(type(high) == int, message: "`high` should be integer")
  assert((size == none) or (type(size) == int and size >= 0), message: "`size` should be non-negative")
  assert(type(endpoint) == bool, message: "`endpoint` should be bool")

  let n = if size == none {1} else {size}
  let gap = high - low
  if endpoint {gap += 1}
  assert(gap >= 1 and gap <= 0x80000000, message: "invalid range between `low` and `high`")

  let enc = cbor.encode((rng, n, low, gap))
  let a
  (rng, a) = cbor(plg.integers_fn(enc))

  if size == none {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}


// Return random floats in the half-open interval [0.0, 1.0)
//
// Arguments:
//     rng: object of random number generator
//     size: returned array size, must be none or non-negative integer, optional
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random numbers
#let random-f(rng, size: none) = {
  assert((size == none) or (type(size) == int and size >= 0), message: "`size` should be non-negative")

  let n = if size == none {1} else {size}

  let enc = cbor.encode((rng, n))
  let a
  (rng, a) = cbor(plg.random_fn(enc))

  if size == none {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}


// Draw samples from a uniform distribution of half-open interval [low, high) (includes low, but excludes high)
//
// Arguments:
//     rng: object of random number generator
//     low: lower boundary of the output interval, optional
//     high: upper boundary of the output interval, optional
//     size: returned array size, must be none or non-negative integer, optional
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random numbers
#let uniform-f(rng, low: 0.0, high: 1.0, size: none) = {
  assert(type(low) == int or type(low) == float, message: "`low` should be numeric")
  assert(type(high) == int or type(high) == float, message: "`high` should be numeric")
  assert((size == none) or (type(size) == int and size >= 0), message: "`size` should be non-negative")

  let n = if size == none {1} else {size}

  let enc = cbor.encode((rng, n, float(low), float(high)))
  let a
  (rng, a) = cbor(plg.uniform_fn(enc))

  if size == none {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}


// Draw random samples from a normal (Gaussian) distribution
//
// Arguments:
//     rng: object of random number generator
//     loc: float, mean (centre) of the distribution, optional
//     scale: float, standard deviation (spread or width) of the distribution, must be non-negative, optional
//     size: returned array size, must be none or non-negative integer, optional
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random numbers
#let normal-f(rng, loc: 0.0, scale: 1.0, size: none) = {
  assert(type(loc) == int or type(loc) == float, message: "`loc` should be numeric")
  assert((type(scale) == int or type(scale) == float) and scale >= 0, message: "`scale` should be non-negative")
  assert((size == none) or (type(size) == int and size >= 0), message: "`size` should be non-negative")

  let n = if size == none {1} else {size}

  let enc = cbor.encode((rng, n, float(loc), float(scale)))
  let a
  (rng, a) = cbor(plg.normal_fn(enc))

  if size == none {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}


// Preprocess the given probalilities of the discrete events and return a object that contains the lookup table for the discrete random number generator
//
// Arguments:
//     p: the array of probalilities of the discrete events, probalilities must be non-negative
//
// Returns:
//     g: generated object that contains the lookup table
#let discrete-preproc-f(p) = {
  assert(type(p) == array, message: "`p` should be arrry type")
  let k-event = p.len()
  assert(k-event >= 1, message: "`k-event` should be positive")
  p = p.map(it => calc.max(0.0, float(it)))

  let enc = cbor.encode(p)
  let dec = cbor(plg.discrete_preproc_fn(enc))

  return (K: dec.at(0), A: dec.at(1), F: dec.at(2))
}


// Return random indices from the given probalilities of the discrete events
// Require preprocessed probalilities of the discrete events
//
// Arguments:
//     rng: object of random number generator
//     g: generated object that contains the lookup table by `discrete-preproc` function
//     size: returned array size, must be none or non-negative integer, optional
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: array of random indices
#let discrete-f(rng, g, size: none) = {
  assert((size == none) or (type(size) == int and size >= 0), message: "`size` should be non-negative")

  let n = if size == none {1} else {size}

  let enc = cbor.encode((rng, n, (g.K, g.A, g.F)))
  let a
  (rng, a) = cbor(plg.discrete_fn(enc))

  if size == none {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}


// Randomly shuffle a given array
//
// Arguments:
//     rng: object of random number generator
//     arr: the array to be shuffled
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: shuffled array
#let shuffle-f(rng, arr) = {
  assert(type(arr) == array, message: "`arr` should be arrry type")

  let n = arr.len()

  if n > 0 {
    let enc = cbor.encode((rng, n))
    let ai
    (rng, ai) = cbor(plg.shuffle_fn(enc))
    arr = ai.map(it => arr.at(it))
  }

  return (rng, arr)
}


// Generate random samples from a given array
// The sample assumes a uniform distribution over all entries in the array
//
// Arguments:
//     rng: object of random number generator
//     arr: the array to be sampled
//     size: returned array size, must be non-negative integer, optional
//     replacement: whether the sample is with or without replacement, optional; default is true, meaning that a value of arr can be selected multiple times.
//     permutation: whether the sample is permuted when sampling without replacement, optional; default is true, false provides a speedup.
//
// Returns:
//     array of (rng, arr)
//         rng: updated object of random number generator
//         arr: generated random samples
#let choice-f(rng, arr, size: none, replacement: true, permutation: true) = {
  assert(type(arr) == array, message: "`arr` should be arrry type")
  assert((size == none) or (type(size) == int and size >= 0), message: "`size` should be non-negative")
  assert(type(replacement) == bool, message: "`replacement` should be boolean")
  assert(type(permutation) == bool, message: "`permutation` should be boolean")

  let n = arr.len()
  assert(n >= 1, message: "size of `arr` should be positive")
  let n-out = if size == none {1} else {size}
  if not replacement {    // sample without replacement
    assert(n-out <= n, message: "`size` should be no more than input array size when `replacement` is false")
  }

  let enc = cbor.encode((rng, n-out, n, replacement, permutation))
  let ai
  (rng, ai) = cbor(plg.choice_fn(enc))
  let a = ai.map(it => arr.at(it))

  if size == none {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}
