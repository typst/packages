#import calc: abs, exp, pi, pow, sqrt, erf

/// Normal distribution
/// - mean (int, float): The mean parameter $μ in (-∞, ∞)$
/// - std (int, float): The standard deviation $σ>0$
/// -> dictionary
#let new(mean: 0.0, std: 1.0) = {
  let (μ, σ) = (mean, std)
  assert(σ > 0, message: "The standard deviation " + str(σ) + " must be positive.")
  (μ: μ, σ: σ, mean: μ, variance: pow(σ, 2))
}

/// Normal distribution PDF
/// $
/// f(x; mu, sigma) = phi(x) = 1 / (sqrt(2 pi) sigma) e^(-1/2 ((x - mu) / sigma)^2)
/// $
/// - `(μ: μ, σ: σ)` (dictionary): A dictionary representing the Normal distribution
/// -> function
#let pdf((μ: μ, σ: σ)) = {
  x => 1.0 / (sqrt(2.0 * pi) * σ) * exp(-0.5 * pow((x - μ) / σ, 2))
}

/// Normal distribution CDF
/// $
/// F(x; mu, sigma) = 1/2 (1 + op("erf")((x - mu) / (sigma sqrt(2))))
/// $
/// - `(μ: μ, σ: σ)` (dictionary): A dictionary representing the Normal distribution
/// -> function
#let cdf((μ: μ, σ: σ)) = {
  x => {
    let z = (x - μ) / σ
    0.5 * (1 + erf(z / sqrt(2)))
  }
}

