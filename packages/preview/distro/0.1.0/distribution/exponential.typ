#import calc: exp, ln, pow

/// Exponential distribution
/// - rate (float): Rate parameter $lambda>0$
/// -> dictionary
#let new(rate) = {
  assert(rate > 0, message: "Rate parameter " + str(rate) + " must be positive.")
  
  (
    λ: rate,
    mean: 1 / rate,
    variance: 1 / pow(rate, 2),
  )
}

/// Exponential distribution PDF
/// $
/// f(x; lambda) = lambda e^(-lambda x),  x >= 0
/// $
/// - `(λ: λ)` (dictionary): A dictionary representing the Exponential distribution
/// -> function
#let pdf((λ: λ)) = {
  x => if x < 0.0 {
    0.0
  } else {
    λ * exp(-λ * x)
  }
}

/// Exponential distribution CDF
/// $
/// F(x; lambda) = 1 - e^(-lambda x),  x >= 0
/// $
/// - `(λ: λ)` (dictionary): A dictionary representing the Exponential distribution
/// -> function
#let cdf((λ: λ)) = {
  x => if x < 0.0 {
    0.0
  } else {
    1.0 - exp(-λ * x)
  }
}

/// Sample from the Exponential distribution using inverse transform sampling
/// - `(λ: λ)` (dictionary): A dictionary representing the Exponential distribution
/// - u (float): A uniform random variate in the range [0, 1)
/// -> float
#let sample((λ: λ), u) = {
  assert(u >= 0.0 and u < 1.0, message: "Uniform random variate " + str(u) + " must be in the range [0, 1).")

  -ln(1 - u) / λ
}
