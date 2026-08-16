#import calc: abs, exp, pow, sqrt

/// #link("https://personal.math.ubc.ca/%7Ecbm/aands/page_299.htm")[Abramowitz-Stegun approximation (¶7.1.26)] for the error function. Also see #link("https://en.wikipedia.org/wiki/Error_function#Approximation_with_elementary_functions").
/// - x (int, float): The input value $x in RR$ to evaluate the error function at.
///
/// The approximation is 
/// $
/// Phi(x) approx 1 - (a_1 t + a_2 t^2 + a_3 t^3 + a_4 t^4 + a_5 t^5)e^(-x^2)
/// $ 
/// where $t=1 / (1 + p x)$ and $p, a_1, ..., a_5$ are constants.
/// We apply Horner's method to the polynomial for computational efficiency and use the odd symmetry of the error function to handle negative $x$ values: $Phi(x) = -Phi(-x)$.
#let erf(x) = {
  let (p, a1, a2, a3, a4, a5) = (
    0.3275911,
    0.254829592,
    -0.284496736,
    1.421413741,
    -1.453152027,
    1.061405429,
  )
  let t = 1.0 / (1.0 + p * abs(x))
  let poly = ((((a5 * t + a4) * t + a3) * t + a2) * t + a1) * t
  x.signum() * (1.0 - poly * exp(-pow(x, 2)))
}
