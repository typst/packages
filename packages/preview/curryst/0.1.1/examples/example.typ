#import "../curryst.typ" : *

#set page(margin : 30pt)

= Example 1


#let r = rule(
  name: "Rule name", 
  "Conclusion", 
  "Premise 1", 
  "Premise 2", 
  "Premise 3"
  )
#proof-tree(r)


= Example 2
#let ax(ccl) = rule(name: "ax", ccl)
#let and_el(ccl, p) = rule(name: $and_e^l$, ccl, p)
#let and_er(ccl, p) = rule(name: $and_e^r$, ccl, p)
#let impl_i(ccl, p) = rule(name: $attach(->, br: i)$, ccl, p)
#let impl_e(ccl, pi, p1) = rule(name: $attach(->, br: e)$, ccl, pi, p1)
#let not_i(ccl, p) = rule(name: $not_i$, ccl, p)
#let not_e(ccl, pf, pt) = rule(name: $not_e$, ccl, pf, pt)

#proof-tree(
  impl_i(
    $tack (p -> q) -> not (p and not q)$,
    not_i(
      $p -> q tack  not (p and not q)$,
      not_e(
        $p -> q, p and not q tack bot$,
        impl_e(
          $Gamma tack q$,
          ax($Gamma tack p -> q$),
          and_el(
            $Gamma tack p$,
            ax($Gamma tack p and not q$)
          )
        ),
        and_er(
          $Gamma tack not q$,
          ax($Gamma tack p and not q$)
        )
      )
    )
  )
)

= Example 3
$
#proof-tree(rule(
  name : "Rule",
  $Gamma$,
  $"Premisse" 1$
))
$

#proof-tree(rule(
  name : "Rule",
  $Gamma$,
  $"Premisse Premisse Premisse Premisse"$
))

#proof-tree(rule(
  name : "Rule",
  $"Conclusion Conclusion Conclusion Conclusion Conclusion"$,
  $"Premisse"$
))


= Example 4

#proof-tree(rule(
  name : "Rule",
  $Gamma a / b$,
  $"Premisse " a / b / c$
))

= Example 5 : without names

#proof-tree(rule(
  $Gamma a $,
  $"Premisse " a$
))

#proof-tree(rule(
  $Gamma$,
  $"Premisse Premisse Premisse Premisse"$
))

#proof-tree(rule(
  $"Conclusion Conclusion Conclusion Conclusion Conclusion"$,
  $"Premisse"$
))

= Example 6 : long names

#let ax(ccl) = rule(name: "aaaaaaaa", ccl)
#let and_el(ccl, p) = rule(name: "aaaaaaaaaaaaaaaaaaaaaaaa", ccl, p)
#let and_er(ccl, p) = rule(name: "aaaaaaaa", ccl, p)
#let impl_i(ccl, p) = rule(name: "aaaaaaaa", ccl, p)
#let impl_e(ccl, pi, p1) = rule(name: "aaaaaaaaaaaaaaaaa", ccl, pi, p1)
#let not_i(ccl, p) = rule(name: "aaaaaaaa", ccl, p)
#let not_e(ccl, pf, pt) = rule(name: "aaaaaaaa", ccl, pf, pt)


#proof-tree(
  prem-min-spacing: 2pt,
  impl_i(
    $tack (p -> q) -> not (p and not q)$,
    not_i(
      $p -> q tack  not (p and not q)$,
      not_e(
        $p -> q, p and not q tack bot$,
        impl_e(
          $Gamma tack q$,
          ax($Gamma tack p -> q$),
          and_el(
            $Gamma tack p$,
            ax($Gamma tack p and not q$)
          )
        ),
        and_er(
          $Gamma tack not q$,
          ax($Gamma tack p and not q$)
        )
      )
    )
  )
)

#let r = rule(
  name: "Rule name Rule name Rule name", 
  "Conclusion", 
  "Premise 1", 
  "Premise 2", 
  "Premise 3"
  )
#proof-tree(r)

= Differente Stroke

#let r = rule(
  name: "Rule name", 
  "Conclusion", 
  "Premise 1",
  "Premise 2",
  "Premise 3"
)
#proof-tree(
  stroke: 3pt,
  r
)

#proof-tree(
  stroke: 1pt + red,
  r
)

#proof-tree(
  stroke : stroke(cap :"round", dash : "dashed", paint : blue),
  r
)