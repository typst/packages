#import "lib.typ": * // replace with the relevant import

= Examples
\
#let de-morgan = [

== De Morgan: $not(p and q) tack (not p or not q)$
Proof (`dynamic-single` mode): 

#proof(assumption-mode: "dynamic-single", (
$not(p and q)$,
assume,
open,
  $not(not p or not q)$,
  assume,
  open,
    $not p$,
    assume,
    ($(not p or not q)$, $or I quad 3$),
    ($tack.t$, $tack.t I quad 2,4$),
  close,
  ($not not p$, $not I quad 3-5$),
  ($p$, $not E quad 6$),
  open,
    $not q$,
    assume,
    ($(not p or not q)$, $or I quad 8$),
    ($tack.t$, $tack.t I quad 2,9$),
  close,
  ($not not q$, $not I quad 8-10$),
  ($q$, $not E quad 11$),
  ($(p and q)$, $and I quad 7,12$),
  ($tack.t$, $tack.t I quad 1,13$),
close,
($not not(not p or not q)$, $not I quad 2,14$),
($(not p or not q)$, $not E quad 15$),
))
]

#let ex-middle = [

== Excluded Middle: $tack (p or not p)$
Proof (`fixed` mode to `60pt`): 
#proof(assumption-mode: "fixed", (
open,
  $not (p or not p)$,
  assume,
  open,
    $p$,
    assume,
    ($(p or not p)$, $or I quad 2$),
    ($tack.t$, $tack.t I quad 1,3$),
  close,
  ($not p$, $not I quad 2-4$),
  ($(p or not p)$, $or I quad 5$),
  ($tack.t$, $tack.t I quad 1,6$),
close,
($not not (p or not p)$, $not I quad 1-7$),
($p or not p$, $not E quad 8$)
))
]


#let non-contra =  [
== Non-Contradiction: $tack.r not (p and not p)$
Proof (`fixed` mode to the default `2.25em`): 
#proof((
open,
  $(p and not p)$,
  assume,
  ($p$, $and E  quad 1$),
  ($not p$, $and E  quad 2$),
  ($tack.t$, $tack.t I quad 1,2$),
close,
($not (p and not p)$, $not I quad 1-4$)
))
]

#context stack(
  dir: ltr,
  spacing: 6em,
  de-morgan, 
  stack(
    dir: ttb,
    spacing: measure(de-morgan).height - measure(ex-middle).height - measure(non-contra).height,
    ex-middle,
    non-contra
  )
)




#pagebreak()

== Some Natural Deduction Rules

#let and-intro = proof((
  ($m$, $p$, $$),
  ($n$, $q$, $$),
  ($o$, $(p and q)$, $and I quad m,n$)
))

#let and-elim = proof((
  ($m$, $(p and q)$, $$),
  ($n_1$, $p$, $and E quad m$),
  ($n_2$, $q$, $and E quad m$),
))

#let or-intro = proof((
  ($m$, $p$, $$),
  ($n$, $(p or q)$, $or I quad m$)
))

#let or-elim = proof(indexation: "a", (
  $(p or q)$,
  open,
    $p$,
    assume,
    $r$,
  close,
  open,
    $q$,
    assume,
    $r$,
  close,
  ($r$, $or E quad a, b-c, d-e$)
))

#stack(
  dir: ttb,
  spacing: 5em,
  stack(dir: ltr, spacing: 15em, and-intro, and-elim),
  stack(dir: ltr, spacing: 15em, or-intro, or-elim)
)

// note how (it seems as) the ones with paren. are further to the right. Idk if true, but consider.