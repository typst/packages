#import "./minienvs.typ": minienvs, envlabel
#show: minienvs

#set par(justify: true)
#show "~": $tilde.op$
#let KL = math.op("KL")

#let dist = math.upright("d")

= My heading

#v(5em)

/ Theorem (Ville's inequality):
  Let $X_0, ...$ be a non-negative supermartingale. Then, for any real number $a > 0$,

  $ PP[sup_(n>=0) X_n >= a] <= EE[X_0]/a. $

Let us now prove it:

/ Proof:
  Consider the stopping time $N = inf {t >= 1 : X_t >= a}$.
  By the optional stopping theorem and the supermartingale convergence theorem, we have that

  $
    EE[X_0] >= EE[X_N]
    &= EE[X_N | N < oo] PP[N < oo] + EE[X_oo | N = oo] PP[N = oo] \
    &>= EE[X_N | N < oo] PP[N < oo]
    = EE[X_N/a | N < oo] a PP[N < oo]. \
  $

  And, therefore,

  $ PP[N < oo] <= EE[X_0] \/ a EE[X_N/a | N < oo] <= EE[X_0] \/ a. $

#v(5em)

/ Lemma (Donsker and Varadhan's variational formula) #envlabel(<change-of-measure>):
  For any measureable, bounded function $h : Theta -> RR$ we have:

  $ log EE_(theta ~ pi)[exp h(theta)] = sup_(rho in cal(P)(Theta)) [ EE_(theta~rho)[h(theta)] - KL(rho || pi) ]. $

As we will see, @change-of-measure is a fundamental building block of PAC-Bayes bounds.

#v(10em)

Hello World!

/ Definition (metric space):
  A metric space $(X, dist_X)$ is a set $X$ along with a metric $dist_X : X times X -> RR$ satisfying, for all $x, y, z in X$:

  1. *Positivity:* $dist_X (x, y) >= 0$, with $dist_X (x, y) = 0 <==> x = y$
  2. *Symmetry:* $dist_X (x, y) = dist_X (y, x)$
  3. *Triangle inequality:* $dist_X (x, z) <= dist_X (x, y) + dist_X (y, z)$

/ Example:
  Consider the set $RR$ with $dist_RR (x, y) = abs(x - y)$. $(RR, dist_RR)$ is a metric space:

  1. Positivity: $dist_RR (x, y) = abs(x - y) >= 0$; $abs(x - y) = 0 <==> x = y$
  2. Symmetry: $dist_RR (x, y) = abs(x - y) = abs(-(y - x)) = abs(y - x) = dist_RR (y, x)$
  3. Triangle inequality: $ dist_RR (x, z) = abs(x - z) = abs(x - z + y - y) = abs((x - y) - (z - y)) <= abs(x - y) + abs(z - y) = dist_RR (x, y) + dist_RR (y, z). $

/ Definition (Cauchy sequence):
  TODO

/ Theorem:
  foo

  bar

/ Theorem #envlabel(<theorem-a>):
  foo

/ Proof:
  asdf

/ Proof:
  foo bar

/ Proof (of @theorem-a):
  ...
