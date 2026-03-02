#import "../src/main.typ": prooflist
#import "@preview/curryst:0.6.0": rule-set
#set document(date: none)
#set page(width: 500pt, height: auto, margin: 0.5cm, fill: white)

#let variable = prooflist[
  / Variable: $Gamma, x : A tack x : A$
]

#let abstraction = prooflist[
  / Abstraction: $Gamma tack lambda x . P : A => B$
    + $Gamma, x: A tack P : B$
]

#let application = prooflist[
  / Application: $Gamma, Delta tack P Q : B$
    + $Gamma tack P : A => B$
    + $Delta tack Q : B$
]

#let weakening = prooflist[
  / Weakening: $Gamma, x : A tack P : B$
    + $Gamma tack P : B$
]

#let contraction = prooflist(label-dir: left)[
  / Contraction: $Gamma, z : A tack P[x, y <- z]: B$
    + $Gamma, x : A, y : A tack P : B$
]

#let exchange = prooflist(label-dir: left)[
  / Exchange: $Gamma, y : B, x: A, Delta tack P : B$
    + $Gamma, x : A, y: B, Delta tack P : B$
]

#align(center, rule-set(
  variable,
  abstraction,
  application,
  weakening,
  contraction,
  exchange
))
