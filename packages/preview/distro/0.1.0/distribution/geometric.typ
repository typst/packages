#import calc: ceil, ln, pow, floor

/// Geometric distribution
///
/// - p (float): The probability of success in each trial, $p in (0,1]$
/// -> dictionary
#let new(p) = {
  assert(p > 0 and p <= 1, message: "The probability of success " + str(p) + " must be in the interval (0, 1].")
  (
    p: p,
    mean: 1 / p,
    variance: (1 - p) / pow(p, 2),
  )
}

/// Geometric distribution PMF
///
/// $
/// f(x; p) = (1-p)^(x-1)p
/// $
/// - `(p: p)` (dictionary): A dictionary representing the Geometric distribution
/// -> function
#let pmf((p: p)) = {
  x => if x == 0.0 {
    0.0
  } else {
    pow(1 - p, x - 1) * p
  }
}

/// Geometric distribution CDF
///
/// $
/// F(x; p) = 1 - (1-p)^x
/// $
/// - `(p: p)` (dictionary): A dictionary representing the Geometric distribution
/// -> function
#let cdf((p: p)) = {
  x => if x == 0.0 {
    0.0
  } else {
    1 - pow(1 - p, floor(x))
  }
}

/// Sample from the Geometric distribution using inverse transform sampling
/// - `(p: p)` (dictionary): A dictionary representing the Geometric distribution
/// - u (float): A uniform random variate in the range [0, 1)
/// -> float
#let sample((p: p), u) = {
  assert(u >= 0.0 and u < 1.0, message: "Uniform random variate " + str(u) + " must be in the range [0, 1).")
  ceil(ln(1 - u) / ln(1 - p))
}
