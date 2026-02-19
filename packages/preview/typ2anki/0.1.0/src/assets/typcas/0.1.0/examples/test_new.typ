// =========================================================================
// typcas Unified One-Equation Demo
// =========================================================================
#import "../lib.typ": *

#set page(margin: 1.5cm)
#set text(font: "New Computer Modern", size: 11pt)

#align(center)[
  #text(size: 18pt, weight: "bold")[typcas Unified One-Equation Demo]
  #v(0.3em)
  #text(size: 10pt, fill: gray)[All features driven from one master equation]
]

#line(length: 100%, stroke: 0.5pt + gray)

/// Parser shorthand.
#let p = cas-parse

/// Assumptions used throughout the unified workflow.
#let x-pos = assume("x", real: true, positive: true)

/// One master expression combining identities, exact rationals, expansion,
/// logs, trig, and assumption-sensitive terms.
#let master = p("(x + 1)/(x + 1) + ln(exp(x)) + sin(x)^2 + cos(x)^2 + sqrt(x^2) + (2/5 + 7/15 - 13/15) + ((x + 4)(x - 4) - (x^2 - 16)) - (3 + abs(x))")

/// Simplified master expression under assumptions.
#let master-s = simplify(master, expand: true, assumptions: x-pos)

/// Derivative of the master expression under assumptions.
#let master-d = simplify(diff(master, "x", assumptions: x-pos), assumptions: x-pos)

/// Integral of the derivative (consistency check path).
#let master-i = simplify(integrate(master-d, "x", assumptions: x-pos), assumptions: x-pos)

/// Solutions for the simplified master equation `master-s = 0`.
#let master-sol = solve(master-s, 0, "x", assumptions: x-pos)

/// Root metadata for the same simplified equation.
#let master-meta = solve-meta(master-s, 0, "x", assumptions: x-pos)

/// Substitution check at the first root (if one exists).
#let root-check = if master-sol.len() == 0 {
  none
} else {
  simplify(substitute(master-s, "x", master-sol.at(0)), assumptions: x-pos)
}

// =========================================================================
= 1. Master Equation
// =========================================================================

#block(below: 0.6em)[
  *Master equation:*
  $ #cas-display(master) = 0 $
]

#block(below: 0.6em)[
  *Assumption:* $x > 0$
]

#block(below: 0.6em)[
  *Simplify (expand + assumptions):*
  $ #cas-display(master) $
  $ arrow.r.double #cas-display(master-s) $
]

// =========================================================================
= 2. Calculus from the Same Equation
// =========================================================================

#block(below: 0.6em)[
  *Differentiate master:*
  $ (dif)/(dif x) (#cas-display(master)) $
  $ = #cas-display(master-d) $
]

#block(below: 0.6em)[
  *Integrate the derivative:* 
  $ integral #cas-display(master-d) thin d x $
  $ = #cas-display(master-i) $
]

// =========================================================================
= 3. Solving the Same Equation
// =========================================================================

#block(below: 0.6em)[
  *Solve simplified equation:*
  $ #cas-display(master-s) = 0 arrow.r.double #cas-display(cvar("x")) = #master-sol.map(s => cas-display(s)).join(" or ") $
]

#if master-meta != none [
  #block(below: 0.6em)[
    *Metadata:*
    #if master-meta.factor-form != none [
      $ "factor:" #h(0.5em) #cas-display(master-meta.factor-form) $
    ] else [
      $ "factor:" #h(0.5em) "none" $
    ]
    #for (i, r) in master-meta.roots.enumerate() [
      $ r_(#(i + 1)) = #cas-display(r.expr), #h(0.5em) "mult=" #r.multiplicity, #h(0.5em) "exact=" #r.exact, #h(0.5em) "complex=" #r.complex $
    ]
  ]
]

#if root-check != none [
  #block(below: 0.6em)[
    *Substitute first root back:*
    $ #cas-display(master-s) #h(0.5em) "at" #h(0.5em) #cas-display(cvar("x")) = #cas-display(master-sol.at(0)) #h(0.8em) arrow.r.double #cas-display(root-check) $
  ]
]

// =========================================================================
= 4. Step-by-Step (Same Equation)
// =========================================================================

#block(below: 0.3em)[*Step-by-step simplify of master:*]
 #{
  let steps = step-simplify(master)
  display-steps(master, steps)
}

#block(below: 0.3em)[*Step-by-step differentiate of master:*]
 #{
  let steps = step-diff(master, "x")
  display-steps(master, steps, operation: "diff", var: "x")
}

#block(below: 0.3em)[*Step-by-step solve of simplified master:*]
 #{
  let steps = step-solve(master-s, 0, "x")
  display-steps(master-s, steps, operation: "solve", var: "x", rhs: 0)
}
