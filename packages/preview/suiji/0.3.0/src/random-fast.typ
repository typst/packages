//==============================================================================
// Random number generator (fast version)
//
// Public functions:
//     gen-rng-f
//     randi-f, integers-f, random-f, uniform-f, normal-f
//     discrete-preproc-f, discrete-f
//     shuffle-f, choice-f
//==============================================================================


#import "lcg.typ": lcg-get, lcg-get-float, lcg-set


//----------------------------------------------------------
// Private functions
//----------------------------------------------------------

// Return random integers from [0, n), 1 <= n <= 0x80000000
#let _uniform-int(rng, n) = {
  let scale = calc.quo(0x80000000, n)

  while true {
    rng = lcg-get(rng)
    let k = calc.quo(rng, scale)
    if k < n {return (rng, k)}
  }
}


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

  lcg-set(seed)
}


// Return a raw random integer from [0, 2^31)
//
// Arguments:
//     rng: object of random number generator
//
// Returns:
//     rng-out: updated object of random number generator (random integer from the interval [0, 2^31-1])
#let randi-f = lcg-get


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
  assert((size == none) or (type(size) == int and size >= 0), message: "`size` should be non-negative")
  assert(type(endpoint) == bool, message: "`endpoint` should be bool")

  let n = if size == none {1} else {size}
  let gap = high - low
  if endpoint {gap += 1}
  assert(gap >= 1 and gap <= 0x80000000, message: "invalid range between `low` and `high`")

  let val = 0
  let a = ()
  for i in range(n) {
    (rng, val) = _uniform-int(rng, gap)
    a.push(val + low)
  }

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
  let val = 0
  let a = ()
  for i in range(n) {
    (rng, val) = lcg-get-float(rng)
    a.push(val)
  }

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
  assert((size == none) or (type(size) == int and size >= 0), message: "`size` should be non-negative")

  let n = if size == none {1} else {size}
  let val = 0
  let a = ()
  for i in range(n) {
    (rng, val) = lcg-get-float(rng)
    a.push(low * (1 - val) + high * val)
  }

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
  assert((size == none) or (type(size) == int and size >= 0), message: "`size` should be non-negative")
  assert(scale >= 0, message: "`scale` should be non-negative")

  let n = if size == none {1} else {size}
  let x = 0
  let y = 0
  let r2 = 0
  let val = 0
  let a = ()
  for i in range(n) {
    while true {
      // Choose x and y in uniform square (-1,-1) to (+1,+1)
      (rng, val) = lcg-get-float(rng)
      x = -1 + 2 * val
      (rng, val) = lcg-get-float(rng)
      y = -1 + 2 * val

      // See if it is in the unit circle
      r2 = x * x + y * y
      if r2 <= 1.0 and r2 != 0 {break}
    }

    // Box-Muller transform
    a.push(loc + scale * y * calc.sqrt(-2.0 * calc.ln(r2) / r2));
  }

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

  let p-tot = 0.0;
  for k in range(k-event) {
    assert(p.at(k) >= 0, message: "probalilities must be non-negative")
    p-tot += p.at(k)
  }
  if p-tot == 0 {p-tot = 2.22e-16}
  for k in range(k-event) {p.at(k) /= p-tot}

  let a = (0,) * k-event
  let f = (0,) * k-event
  let mean = 1.0 / k-event
  let n-small = 0
  let n-big = 0
  for k in range(k-event) {
    if p.at(k) < mean {
      n-small += 1
      a.at(k) = 0
    } else {
      n-big += 1
      a.at(k) = 1
    }
  }

  let bigs = ()
  let smalls = ()
  for k in range(k-event) {
    if a.at(k) == 1 {
      bigs.push(k)
    } else {
      smalls.push(k)
    }
  }
  while smalls.len() > 0 {
    let s = smalls.pop()
    if bigs.len() == 0 {
      a.at(s) = s
      f.at(s) = 1.0
      continue
    }
    let b = bigs.pop()
    a.at(s) = b
    f.at(s) = k-event * p.at(s)
    let d = mean - p.at(s)
    p.at(s) += d
    p.at(b) -= d
    if p.at(b) < mean {
      smalls.push(b)
    } else if p.at(b) > mean {
      bigs.push(b)
    } else {
      a.at(b) = b
      f.at(b) = 1.0
    }
  }
  while bigs.len() > 0 {
    let b = bigs.pop()
    a.at(b) = b
    f.at(b) = 1.0
  }

  for k in range(k-event) {
    f.at(k) += k
    f.at(k) /= k-event
  }

  return (K: k-event, A: a, F: f)
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
  let u = 0
  let a = ()

  for i in range(n) {
    (rng, u) = lcg-get-float(rng)
    let c = calc.floor(u * g.K)
    let f = g.F.at(c)
    if f == 1.0 {
      a.push(c)
    } else if u < f {
      a.push(c)
    } else {
      a.push(g.A.at(c))
    }
  }

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
  let j = 0
  for i in range(n - 1, 0, step: -1) {
    (rng, j) = _uniform-int(rng, i + 1)
    if i != j {
      (arr.at(i), arr.at(j)) = (arr.at(j), arr.at(i))
    }
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

  let val = 0
  let a = ()

  if replacement {    // sample with replacement
    for i in range(n-out) {
      (rng, val) = _uniform-int(rng, n)
      a.push(arr.at(val))
    }
  } else {    // sample without replacement
    assert(n-out <= n, message: "`size` should be no more than input array size when `replacement` is false")

    let i = 0
    let j = 0
    while i < n and j < n-out {
      (rng, val) = lcg-get-float(rng)
      if (n - i) * val < n-out - j {
        a.push(arr.at(i))
        j += 1
      }
      i += 1
    }
    if permutation {
      (rng, a) = shuffle-f(rng, a)
    }
  }

  if size == none {
    return (rng, a.at(0))
  } else {
    return (rng, a)
  }
}
