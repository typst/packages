#import "./lib.typ": *


Examples in README:

$
Lim(x, +0) x ln(sin x)
  = cLim ln(sin x) / x^(-1)
  = cLim x / (sin x) cos x
  = 0
$

$
Sum(n, 0, oo) 1 / sqrt(n + 1)
  = Sum(#none, 0, #none) 1 / sqrt(n)
  = cSum 1 / n^(1 / 2)
$

$
Integral(0, pi / 3, sqrt(1 + tan^2 x))
  = cIntegral(1 / (cos x))
  = cIntegrated(ln (cos x / 2 + sin x / 2) / (cos x / 2 - sin x / 2))
  = ln (2 + sqrt(3))
$


Calculate the area of the region bounded by the curves $y = e^(x / 2) sin sqrt(3) / 2 x$ and $x$ axis:

$
S =& Lim(alpha, -oo) Integral(alpha, 0, e^(x / 2) abs(sin sqrt(3) / 2 x)) \
  =& Lim(n, oo) Sum(k, 0, n) (-1)^(k - 1)
    Integral(
      -(2 (k + 1)) / sqrt(3) pi,
      -(2 k) / sqrt(3) pi,
      e^(x / 2) sin sqrt(3) / 2 x
    ) \
  =& cLim cSum (-1)^(k - 1) cIntegrated(e^(x / 2) sin(sqrt(3) / 2 x - pi / 3)) \
  =& Fac(sqrt(3) / 2) cLim cSum (e^(-k / sqrt(3) pi) + e^(-(k + 1) / sqrt(3) pi))
  = cFac cLim cSum (1 + e^(-pi / sqrt(3))) e^(-k / sqrt(3) pi) \
  =& cFac cLim
    (1 + e^(-pi / sqrt(3)))
    (1 - (e^(-pi / sqrt(3)))^n) / (1 - e^(-pi / sqrt(3))) = cFac
$

Calculate the surface area of an ellipse:

$
S =& Fac(2 pi) Integral(-a, a, abs(y) sqrt(1 - (|y|')^2)) \
  =& cFac cIntegral(b / a cancel(sqrt(a^2 - x^2)) sqrt((a^4 - (a^2 - b^2) x^2) / (a^2 cancel(a^2 - x^2)))) \
  =& cFac cIntegral(b / a sqrt(a^2 - (a^2 - b^2) / a^2 x^2)) \
  =& Fac(4 pi b) Integral(0, a, sqrt(1 - e^2 / a^2 x^2))
    quad (e^2 = (a^2 - b^2) / a^2)\
  =& Fac(4 pi (a b) / e) Integral(0, arcsin e, sqrt(1 - sin^2 theta) cos theta, dif: theta)
    quad (theta = arcsin e / a x)\
  =& cFac cIntegral(cos^2 theta) = Fac(2 pi (a b) / e) cIntegral(1 + cos 2 theta) \
  =& cFac cIntegrated(theta + 1 / 2 sin 2 theta)
    = cFac cIntegrated(theta + sin theta sqrt(1 - sin^2 theta)) \
  =& cFac (arcsin e + e sqrt(1 - e^2)) \
$
