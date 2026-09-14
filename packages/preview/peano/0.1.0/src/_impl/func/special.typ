// -> func/special.typ
/// Special mathematic functions.

#import "init.typ": define-func-with-complex, define-func-2-with-complex

/// The #link("https://en.wikipedia.org/wiki/Gamma_function")[$Gamma$ function],
/// defined by $Gamma(z) = integral_0^oo t^(z - 1) upright(e)^(-t) dif t$.
#let /*pub*/ gamma = define-func-with-complex("gamma")

/// The #link("https://en.wikipedia.org/wiki/Digamma_function")[digamma function],
/// which is the derivative of the logarithm of $Gamma$ function
/// $psi(z) = dif/(dif z) ln Gamma(z) = (Gamma'(z))/(Gamma(z))$.
#let /*pub*/ digamma = define-func-with-complex("digamma")

/// same as `digamma`
#let /*pub*/ psi = digamma

/// The #link("https://en.wikipedia.org/wiki/Error_function")[Gauss error function],
/// defined by $erf z = 2/sqrt(pi) integral_0^z e^(-t^2) dif t$
#let /*pub*/ erf = define-func-with-complex("erf")

/// #link("https://en.wikipedia.org/wiki/Riemann_zeta_function")[Riemann's $zeta$ function]
/// defined by $zeta(s) = sum_(n = 1)^oo 1/(n^s)$ for $Re s > 1$ and its analytic continuation otherwise.
#let /*pub*/ zeta = define-func-with-complex("zeta")

/// The #link("https://en.wikipedia.org/wiki/Beta_function")[$Beta$ function],
/// defined by $Beta(z_1, z_2) = integral_0^1 t^(z_1 - 1) (1 - t)^(z_2 - 1) dif t$.
/// Equals to $(Gamma(z_1) Gamma(z_2))/(Gamma(z_1 + z_2))$
#let /*pub*/ beta = define-func-2-with-complex("beta")

// Euler's $gamma$ constant. Equals to $lim_(n -> oo) ((sum_(k = 1)^(n) 1/n) - ln n)$
#let /*pub*/ euler-gamma = -digamma(1)
