// #import "lib.typ": flushl, flushr, intertext, tag, eqref, intertext-rule
#import "@preview/intextual:0.1.0": flushl, flushr, intertext, tag, eqref, intertext-rule

// intertext-rule show-set rule is required to display properly.
#show: intertext-rule

Without grid:
$
  #flushl[(left)] forall epsilon > 0, thick exists delta > 0, quad abs(P(x) - P(delta)) &< epsilon #flushr[(right)] \
  #intertext[Thus, this is intertext, keeping alignment]
  lim_(t -> 0) f(t) &= f(x) #flushr[(blah blah)]
$

#line(length: 100%)

#grid(columns: (1fr, 0.6fr), column-gutter: 0.7em, stroke: 0.5pt, inset: 0.5em)[
  Inside grid, #lorem(20)
  $
    #flushl[left aligned] x(2x - 1) &= 0 #flushr[(factorize $x$)] \
    therefore x &= 0, thick 1/2 #flushr[$qed$] \
    #intertext[intertext,]
    Q_t (a) = (sum_(i=1)^(t-1) bb(1)_(A_i = a) X_i) / (sum_(i=1)^(t-1) bb(1)_(A_i = a)) &= hat(mu)_a (t-1) #tag[(abc)] \
    #flushl[for $cal(E)_"SG"^2$:] 1/2 PP(abs(X) - EE[X] >= epsilon) &<= exp(-epsilon^2/(2 sigma^2)) #flushr[#tag[(sgc)]] \
  $
][
  $
    A_t &= op("arg max", limits: #true)_(a in cal(A)) Q_t (a) \
    #intertext[thus, this is a very long multiline intertext that is auto spaced #lorem(8):]
    A_t &= 2 #flushr[(2nd arm in $cal(A)$)] \
    #flushr(overlap: false)[I can right flush text that takes up vertical space too]
    therefore t &= 5
  $

  From @eq-sgc, we know that...
]

As per #eqref(<eq-abc>) above,

For all $a in cal(A)$,
$
  Q_t (a) --> mu_a #tag[(abc)]
$
Now, #eqref(<eq-abc>) refers to the equation right above this paragraph, instead of the first one.
$
  Q_t (a) --> 0 #tag(label-str: "eq-abc-new")[(abc)]
$
Now I can refer to both the new #eqref(<eq-abc-new>) and the old #eqref(<eq-abc>). I can also link to my equation using a #eqref(<eq-abc-new>)[*custom reference text*]