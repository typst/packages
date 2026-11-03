#import calc: exp, fact, floor, pow, ln
#import "../function/gamma.typ": gamma-ur, ln-gamma

/// Poisson distribution
/// - rate (float): Rate parameter $lambda>0$
/// -> dictionary
#let new(rate) = {
  assert(rate > 0.0, message: "Rate parameter " + str(rate) + " must be positive.")
  (λ: rate, mean: rate, variance: rate)
}

/// Poisson distribution PMF
/// $
/// p(k; lambda) = lambda^k e^(-lambda) / k! = exp(k ln(lambda) - lambda - ln(Gamma(k + 1)))
/// $
/// - `(λ: λ)` (dictionary): A dictionary representing the Poisson distribution
/// -> function
#let pmf((λ: λ)) = {
  k => {
    assert(k >= 0.0, message: "Poisson distribution is only defined for non-negative integers")

    exp(k * ln(λ) - λ - ln-gamma(k + 1))
  }
}

/// Poisson distribution CDF
/// $
/// F(k; lambda) = Q(k + 1, lambda)
/// $
/// - `(λ: λ)` (dictionary): A dictionary representing the Poisson distribution
/// -> function
#let cdf((λ: λ)) = {
  k => {
    assert(k >= 0.0, message: "Poisson distribution is only defined for non-negative integers")

    gamma-ur(k + 1.0, λ)
  }
}

/// Sample from the Poisson distribution using #link("https://en.wikipedia.org/wiki/Poisson_distribution#Random_variate_generation")[inverse transform sampling]
///
/// - `(λ: λ)` (dictionary): A dictionary representing the Poisson distribution
/// - u (float): A uniform random variate in the range [0, 1)
/// -> int
#let sample((λ: λ), u) = {
  assert(u >= 0.0 and u < 1.0, message: "Uniform random variate " + str(u) + " must be in the range [0, 1).")

  let x = 0
  let p = exp(-λ)
  let s = p

  while u > s {
    x = x + 1
    p = p * λ / x
    s = s + p
  }
  x
}
