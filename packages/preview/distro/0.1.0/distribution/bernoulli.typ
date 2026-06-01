/// Bernoulli distribution
/// - p (float): The probability of success $p$ in $[0, 1]$
/// -> dictionary
#let new(p) = {
  assert(p >= 0.0 and p <= 1.0, message: "Probability p=" + str(p) + " must be in the range $[0, 1]$")

  (
    p: p,
    mean: p,
    variance: p * (1 - p),
  )
}

/// Bernoulli distribution PMF
/// $
/// p(k) = cases(1-p &"if" k = 0, p &"if" k = 1)
/// $
/// - `(p: p)` (dictionary): A dictionary representing the Bernoulli distribution
/// -> function
#let pmf((p: p)) = {
  x => {
    assert(x == 0.0 or x == 1.0, message: "Bernoulli distribution is only defined for $x=0$ and $x=1$, got x=" + str(x))

    if x == 0.0 { 1 - p } else { p }
  }
}

/// Bernoulli distribution CDF
/// $
/// F(x) = cases(0 &"if" x < 0, 1-p &"if" 0 <= x < 1, 1 &"if" x >= 1)
/// $
/// - `(p: p)` (dictionary): A dictionary representing the Bernoulli distribution
/// -> function
#let cdf((p: p)) = {
  x => if x < 0.0 {
    0.0
  } else if x < 1.0 {
    1 - p
  } else {
    1.0
  }
}

/// Sample from the Bernoulli distribution using inverse transform sampling
/// - `(p: p)` (dictionary): A dictionary representing the Bernoulli distribution
/// - u (float): A uniform random variate in the range [0, 1)
/// -> int
#let sample((p: p), u) = {
  assert(u >= 0.0 and u < 1.0, message: "Uniform random variate " + str(u) + " must be in the range [0, 1).")

  if u < p { 1 } else { 0 }
}
