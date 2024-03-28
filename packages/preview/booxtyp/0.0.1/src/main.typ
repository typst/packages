#import "lib.typ": *

#show figure.where(kind: "Theorem"): it => it.body
#show figure.where(kind: "Proposition"): it => it.body
#show figure.where(kind: "Definition"): it => it.body
#show: book

= Introduction

@thm:5 is a very important theorem.

@def:1 is the definition of the exponential function.

@def:2 is the definition of the exponential function.

@pro:1 is a very important proposition.

== First Section

#definition[
  The exponential function, denoted by $exp(x)$, is defined as
  $ exp(x) := sum_(n = 0)^oo x^n / n! $
]<def:1>

@eq:1 is a very important equation.

#theorem(title: "Important theorem")[
  This is a theorem.
  $ e^x = lim_(n -> oo) a $
]

#proof[
  #lorem(1000)
]

#note[
  Hmmm... I wonder if this is true.
]

#exercise[

  This is an exercise.]

#exercise[
  This is an exercise.
]

#exercise[
  This is an exercise.
]

#solution[
  This is the solution.
]

#proposition(title: "Important theorem ")[
  This is a theorem.
  $ e^x = lim_(n -> oo) a $
]<pro:1>

#definition[
  The exponential function, denoted by $exp(x)$, is defined as
  $ exp(x) := sum_(n = 0)^oo x^n / n! $
]<def:2>

#theorem(title: "Important theorem ")[
  This is a theorem.
  $ e^x = lim_(n -> oo) a $
]<thm:5>

@eq:1 is a very important equation.

== Second Section

$ T: V -> W $

$ T: V -> W $<eq:1>

#definition[
  The exponential function, denoted by $exp(x)$, is defined as
  $ exp(x) := sum_(n = 0)^oo x^n / n! $
]

