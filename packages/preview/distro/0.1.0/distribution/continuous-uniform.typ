#import calc: pow

/// Continuous Uniform distribution
///
/// - a (float): Lower bound of the distribution
/// - b (float): Upper bound of the distribution
/// -> dictionary
#let new(a, b) = {
  assert(a < b, message: "Lower bound " + str(a) + " must be less than upper bound " + str(b) + ".")
  (
    a: a,
    b: b,
    mean: (a + b) / 2,
    variance: pow(b - a, 2) / 12,
  )
}

/// Continuous Uniform distribution PDF
///
/// - `(a: a, b: b)` (dictionary): A Continuous Uniform distribution.
/// -> function
#let pdf((a: a, b: b)) = {
  x => if x < a or x > b {
    0.0
  } else {
    1 / (b - a)
  }
}

/// Continuous Uniform distribution CDF
///
/// - `(a: a, b: b)` (dictionary): A Continuous Uniform distribution.
/// -> function
#let cdf((a: a, b: b)) = {
  x => if x < a {
    0.0
  } else if x > b {
    1.0
  } else {
    (x - a) / (b - a)
  }
}

/// Sample from the Continuous Uniform distribution using inverse transform sampling
///
/// - `(a: a, b: b)` (dictionary): A dictionary representing the Continuous Uniform distribution
/// - u (float): A uniform random variate in the range [0, 1)
/// -> float
#let sample((a: a, b: b), u) = {
  assert(u >= 0.0 and u < 1.0, message: "Uniform random variate " + str(u) + " must be in the range [0, 1).")
  a + u * (b - a)
}
