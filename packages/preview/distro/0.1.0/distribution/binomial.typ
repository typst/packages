#import calc: binom, pow
#import "../function/beta.typ": beta-reg

/// The binomial distribution models the number of successes in a fixed number of independent Bernoulli trials, each with the same probability of success.
///
/// - n (int): The number of trials $n>=0$
/// - p (float): The probability of success $p in [0,1]$
/// -> dictionary
#let new(n, p) = {
  assert(n >= 0, message: "Number of trials " + str(n) + " must be non-negative.")
  assert(p >= 0.0 and p <= 1.0, message: "Probability of success " + str(p) + " must be in the range [0, 1].")
  (
    n: n,
    p: p,
    mean: n * p,
    variance: n * p * (1 - p),
  )
}

/// The PMF of the binomial distribution gives the probability of observing exactly $k$ successes in $n$ trials, where each trial has a success probability of $p$.
///
/// $
/// p(k) = binom(n, k) p^k (1-p)^(n-k)
/// $
/// for $k in {0, 1, ..., n}$.
///
/// *WARNING*: `calc.binom` will overflow for moderately sized $n$: #link("https://github.com/typst/typst/issues/4993").
///
/// - `(n: n, p: p)` (dictionary): A dictionary representing the Binomial distribution
/// -> function
#let pmf((n: n, p: p)) = {
  k => {
    assert(
      type(k) == int and k >= 0 and k <= n,
      message: "The number of successes $k$ must be an integer in {0, 1, ..., " + str(n) + "}",
    )
    binom(n, k) * pow(p, k) * pow(1 - p, n - k)
  }
}

/// Binomial CDF
/// $
/// I_(1 - p)(n - k, 1 + k)
/// $
/// where $I_(x)(a, b)$ is the regularised incomplete beta function.
///
/// - `(n: n, p: p)` (dictionary): A dictionary representing the Binomial distribution
/// -> function
#let cdf((n: n, p: p)) = {
  k => if k >= n { 1.0 } else { beta-reg(n - k, k + 1)(1 - p) }
}

/// Generates a random variate from the binomial distribution using inverse transform sampling.
///
/// - `(n: n, p: p)` (dictionary): A dictionary representing the Binomial distribution
/// - u (float): A uniform random variate in the range [0, 1)
/// -> int
#let sample((n: n, p: p), u) = {
  assert(u >= 0.0 and u < 1.0, message: "Uniform random variate " + str(u) + " must be in the range [0, 1).")
  let k = 0
  let cumulative = cdf((n: n, p: p))(k)
  while cumulative <= u {
    k += 1
    cumulative = cdf((n: n, p: p))(k)
  }
  k
}

