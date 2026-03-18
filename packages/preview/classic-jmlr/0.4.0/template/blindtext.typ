/**
 * blindtext.typ
 *
 * This module is motivated by its LaTeX counterpart `blindtext`. It is used as
 * a slightly advanced alternative to common `lorem` routine.
 *
 * [1]:https://ctan.org/tex-archive/macros/latex/contrib/blindtext
 */

#let blindtext = [Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
Etiam lobortis facilisis sem. Nullam nec mi et neque pharetra sollicitudin.
Praesent imperdiet mi nec ante. Donec ullamcorper, felis non sodales commodo,
lectus velit ultrices augue, a dignissim nibh lectus placerat pede. Vivamus
nunc nunc, molestie ut, ultricies vel, semper in, velit. Ut porttitor. Praesent
in sapien. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Duis
fringilla tristique neque. Sed interdum libero ut metus. Pellentesque placerat.
Nam rutrum augue a leo. Morbi sed elit sit amet ante lobortis sollicitudin.
Praesent blandit blandit mauris. Praesent lectus tellus, aliquet aliquam,
luctus a, egestas a, turpis. Mauris lacinia lorem sit amet ipsum. Nunc quis
urna dictum turpis accumsan semper.]

#let formulas = (
  $ accent(x, macron) 
    = 1 / n sum_(i = 1)^(i = n) x_i
    = (x_1 + x_2 + dots + x_n) / n $,
  $ integral_0^infinity e^(-alpha x^2) dif x
    = 1/2 sqrt(integral_(-infinity)^infinity e^(-alpha x^2))
      dif x integral_(-infinity)^infinity e^(-alpha y^2) dif y
    = 1/ 2 sqrt(pi / alpha) $,
  $ sum_(k = 0)^infinity a_0 q^k 
    = lim_(n arrow.r infinity) sum_(k = 0)^n a_0 q^k
    = lim_(n arrow.r infinity) a_0 (1-q^(n + 1)) / (1-q)
    = a_0 / (1-q) $,
  $ x_(1,2)
    = (-b plus.minus sqrt(b^2 - 4 a c )) / ( 2 a)
    = (-p plus.minus sqrt(p^2 - 4 q)) / 2 $,
  $ (diff^2 Phi) / (diff x^2)
    + (diff^2 Phi) / (diff y^2)
    + (diff^2 Phi) / (diff z^2)
    = 1 / c^2 (diff^2 Phi) / (diff t^2) $,
  $ root(n, a) dot.c root(n, b) = root(n, a b) $,
  $ root(n, a) / root(n, b) =  root(n, a / b) $,
  $ a root(n, b) = root(n, a^n b) $,
)

#let blindmathpaper = {
  parbreak()
  blindtext
  formulas.slice(0, 5).join(blindtext)
  blindtext
}
