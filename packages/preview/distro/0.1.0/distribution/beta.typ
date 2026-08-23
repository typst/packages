#import calc: exp, ln, pow
#import "../function/gamma.typ": gamma, ln-gamma
#import "../function/beta.typ": beta-reg

/// Beta distribution
/// - alpha (int, float): The alpha parameter of the Beta distribution $alpha > 0$
/// - beta (int, float): The beta parameter of the Beta distribution $beta > 0$
/// -> dictionary
#let new(alpha: 1.0, beta: 1.0) = {
  let (α, β) = (alpha, beta)
  assert(α > 0, message: "Alpha parameter " + str(α) + " must be positive.")
  assert(β > 0, message: "Beta parameter " + str(β) + " must be positive.")
  (
    α: α,
    β: β,
    mean: α / (α + β),
    variance: (α * β) / (pow(α + β, 2) * (α + β + 1)),
  )
}

/// Beta distribution PDF
/// $
/// f(x) = Gamma(alpha + beta) / (Gamma(alpha) Gamma(beta)) x^(alpha - 1) (1 - x)^(beta - 1)
/// $
/// - `(α: α, β: β)` (dictionary): A dictionary representing the Beta distribution
/// -> function
#let pdf((α: α, β: β)) = {
  x => if x < 0.0 or x > 1.0 {
    0.0
  } else if α == 1.0 and β == 1.0 {
    1.0
  } else if α > 80.0 or β > 80.0 {
    exp(ln_pdf((α: α, β: β))(x))
  } else {
    gamma(α + β) / (gamma(α) * gamma(β)) * pow(x, α - 1.0) * pow(1.0 - x, β - 1.0)
  }
}

/// The natural logarithm of the PDF of the Beta distribution.
///
/// - `(α: α, β: β)` (dictionary): A dictionary representing the Beta distribution
/// -> function
#let ln_pdf((α: α, β: β)) = {
  x => if x < 0.0 or x > 1.0 {
    -float.inf
  } else if α == 1.0 and β == 1.0 {
    0.0
  } else {
    let aa = ln-gamma(α + β) - ln-gamma(α) - ln-gamma(β)
    let bb = if α == 1.0 and x == 0.0 {
      0.0
    } else if x == 0.0 {
      -float.inf
    } else {
      (α - 1.0) * ln(x)
    }
    let cc = if β == 1.0 and x == 1.0 {
      0.0
    } else if x == 1.0 {
      -float.inf
    } else {
      (β - 1.0) * ln(1.0 - x)
    }
    aa + bb + cc
  }
}

/// Beta distribution CDF
///
/// - `(α: α, β: β)` (dictionary): A dictionary representing the Beta distribution
/// -> function
#let cdf((α: α, β: β)) = {
  x => if x < 0.0 {
    0.0
  } else if x >= 1.0 {
    1.0
  } else if α == 1.0 and β == 1.0 {
    x
  } else {
    beta-reg(α, β)(x)
  }
}
