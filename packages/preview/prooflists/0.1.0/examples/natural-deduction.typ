#import "@preview/prooflists:0.1.0": prooflist
#set document(date: none)
#set page(width: auto, height: auto, margin: 0.5cm, fill: white)

#let ax(conclusion) = prooflist[/ ax: #conclusion]
#let ax-1 = ax($Gamma tack p -> q$)
#let ax-2 = ax($Gamma tack p and not q$)

#prooflist[
  / $scripts(->)_i$: $tack (p -> q) -> not (p and not q)$
    / $not_i$: $p -> q tack  not (p and not q)$
      / $not_e$: $ underbrace(p -> q\, p and not q, Gamma) tack bot $
        / $scripts(->)_e$: $Gamma tack q$
          #ax-1
          / $and_e^ell$: $Gamma tack p$
            #ax-2
        / $and_e^r$: $Gamma tack not q$
          #ax-2
]
