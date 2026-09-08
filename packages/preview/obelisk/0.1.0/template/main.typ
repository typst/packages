#import "@preview/obelisk:0.1.0": *

#show: init

= Obelisk Template

#definition[
  *Obelisk* is a note template inspired by Bauhaus aesthetics.
]

== Second Level Header

All texts are by default aligned to a baseline grid.

$ integral_0^(+oo) "e"^(-x^2) dif x=sqrt(pi)/2 $

Math blocks are also automatically aligned.

=== Third Level Header

The template includes several theorem environments by default. #sidenote[inline sidenotes can be added] Theorems can have titles and referenced.

#theorem[mean inequality][
  One of the mean inequalities is $n/(sum_(i=1)^n 1/x_i)<=root(n, product_(i=1)^n x_i).$
]<thm:mean-ineq>

Theorems can be referenced by numbering (@thm:mean-ineq) or by title (@thm:mean-ineq[!]).
