#import "../curryst.typ": rule, proof-tree
#set document(date: none)
#set page(width: auto, height: auto, margin: 0.5cm, fill: white)

#let ax = rule.with(name: [ax])
#let and-el = rule.with(name: $and_e^ell$)
#let and-er = rule.with(name: $and_e^r$)
#let impl-i = rule.with(name: $scripts(->)_i$)
#let impl-e = rule.with(name: $scripts(->)_e$)
#let not-i = rule.with(name: $not_i$)
#let not-e = rule.with(name: $not_e$)

#proof-tree(
  impl-i(
    $tack (p -> q) -> not (p and not q)$,
    not-i(
      $p -> q tack  not (p and not q)$,
      not-e(
        $ underbrace(p -> q\, p and not q, Gamma) tack bot $,
        impl-e(
          $Gamma tack q$,
          ax($Gamma tack p -> q$),
          and-el(
            $Gamma tack p$,
            ax($Gamma tack p and not q$),
          ),
        ),
        and-er(
          $Gamma tack not q$,
          ax($Gamma tack p and not q$),
        ),
      ),
    ),
  )
)
