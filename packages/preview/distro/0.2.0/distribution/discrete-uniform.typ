#import calc: floor, pow

/// Discrete Uniform distribution
///
/// - a (int): Lower bound of the distribution
/// - b (int): Upper bound of the distribution
/// -> dictionary
#let new(a, b) = {
  assert(a < b, message: "Lower bound " + str(a) + " must be less than upper bound " + str(b) + ".")
  (
    a: a,
    b: b,
    mean: (a + b) / 2,
    variance: (pow((b - a + 1), 2) - 1) / 12,
  )
}

/// Discrete Uniform distribution PMF
///
/// - `(a: a, b: b)` (dictionary): A Discrete Uniform distribution.
/// -> function
#let pmf((a: a, b: b)) = {
  x => if x >= a and x <= b {
    1.0 / (b - a + 1)
  } else {
    0.0
  }
}

/// Discrete Uniform distribution CDF
/// $
/// F(x) = (floor(x) - a + 1) / (b - a + 1)
/// $
/// on $k$ in ${a, a+1, ..., b}$
/// - `(a: a, b: b)` (dictionary): A Discrete Uniform distribution.
/// -> function
#let cdf((a: a, b: b)) = {
  x => if x < a {
    0.0
  } else if x >= b {
    1.0
  } else {
    (floor(x) - a + 1) / (b - a + 1)
  }
}

/// Sample from the Discrete Uniform distribution using inverse transform sampling
///
/// - `(a: a, b: b)` (dictionary): A Discrete Uniform distribution.
/// - `u` (float): A uniform random variate in the range [0, 1).
/// -> int
#let sample((a: a, b: b), u) = {
  assert(u >= 0.0 and u < 1.0, message: "Uniform random variate " + str(u) + " must be in the range [0, 1).")
  a + floor(u * (b - a + 1))
}
