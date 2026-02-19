// =========================================================================
// typcas Test & Demo — Complete Function Coverage
// =========================================================================
#import "../lib.typ": *

#set page(margin: 1.5cm)
#set text(font: "New Computer Modern", size: 11pt)

#align(center)[
  #text(size: 18pt, weight: "bold")[typcas Test Suite]
  #v(0.3em)
  #text(size: 10pt, fill: gray)[A Lightweight Computer Algebra System for Typst]
]

#line(length: 100%, stroke: 0.5pt + gray)

// === Helpers ===
/// Public helper `test-row`.
#let test-row(label, input-expr, result-expr) = {
  block(below: 0.6em)[
    *#label:* $ #cas-display(input-expr) arrow.r.double #cas-display(result-expr) $
  ]
}
/// Public helper `show-fn`.
#let show-fn(expr) = { $ #cas-display(expr) $ }
/// Public helper `p`.
#let p = cas-parse  // shorthand

// =====================================================================
= 1. Expression Construction
// =====================================================================

// Parsed expressions
#table(
  columns: (auto, auto),
  stroke: none,
  inset: (x: 1em, y: 0.4em),
  [*Variable*], show-fn(p("x")),
  [*Number*], show-fn(p("42")),
  [*Pi*], show-fn(p("pi")),
  [*Euler*], show-fn(p("e")),
  [*Reserved i*], show-fn(p("i")),
  [*Sum*], show-fn(p("x + 3")),
  [*Product*], show-fn(p("2x")),
  [*Power*], show-fn(p("x^2")),
  [*Fraction*], show-fn(p("x / 3")),
  [*Composed*], show-fn(p("3x^2 - 2x + 5")),
  [*Abs*], show-fn(p("abs(x)")),
  [*Log*], show-fn(p("log_2(x)")),
  [*Log Impl*], show-fn(p("log_2 x")),
  [*Log2 Fn*], show-fn(p("log2(x)")),
  [*Log10 Fn*], show-fn(p("log10(x)")),
  [*Log(a,b)*], show-fn(p("log(2, 8)")),
)


=== Trig (6)
#grid(
  columns: 6,
  gutter: 1em,
  show-fn(p("sin(x)")),
  show-fn(p("cos(x)")),
  show-fn(p("tan(x)")),
  show-fn(p("csc(x)")),
  show-fn(p("sec(x)")),
  show-fn(p("cot(x)")),
)

=== Inverse Trig (6)
#grid(
  columns: 6,
  gutter: 1em,
  show-fn(p("arcsin(x)")),
  show-fn(p("arccos(x)")),
  show-fn(p("arctan(x)")),
  show-fn(p("arccsc(x)")),
  show-fn(p("arcsec(x)")),
  show-fn(p("arccot(x)")),
)

=== Alias Spot Checks
#grid(
  columns: 4,
  gutter: 1em,
  show-fn(p("asin(x)")),
  show-fn(p("asec(x)")),
  show-fn(p("asinh(x)")),
  show-fn(p("acosh(x)")),
)

=== Hyperbolic (6)
#grid(
  columns: 6,
  gutter: 1em,
  show-fn(p("sinh(x)")),
  show-fn(p("cosh(x)")),
  show-fn(p("tanh(x)")),
  show-fn(p("csch(x)")),
  show-fn(p("sech(x)")),
  show-fn(p("coth(x)")),
)

=== Inverse Hyperbolic (6)
#grid(
  columns: 6,
  gutter: 1em,
  show-fn(p("arcsinh(x)")),
  show-fn(p("arccosh(x)")),
  show-fn(p("arctanh(x)")),
  show-fn(p("arccsch(x)")),
  show-fn(p("arcsech(x)")),
  show-fn(p("arccoth(x)")),
)

=== Other
#grid(
  columns: 3,
  gutter: 1em,
  show-fn(p("ln(x)")), show-fn(p("exp(x)")), show-fn(p("sqrt(x)")),
)

=== Summation & Product
#grid(
  columns: 2,
  gutter: 2em,
  show-fn(p("sum_(k=1)^n k^2")), show-fn(p("product_(k=1)^n k")),
)

=== Matrix
$ #cas-display(cmat(((1, 2), (3, 4)))) #h(2em) #cas-display(mat-id(3)) $

=== Piecewise
#{
  let f = piecewise(((cvar("x"), "x > 0"), (neg(cvar("x")), "x < 0"), (num(0), none)))
  block(below: 0.6em)[
    *Piecewise function:* $ f(x) = #cas-display(f) $
  ]
}

=== cas-equation
#{
  block(below: 0.6em)[
    *Formatted equation:* #cas-equation(p("x^2 + 1"), p("y"))
  ]
}

// =====================================================================
= 2. Simplification
// =====================================================================

#{
  let x = p("x")
  test-row("x + 0", p("x + 0"), simplify(p("x + 0")))
  test-row("x × 1", p("x * 1"), simplify(p("x * 1")))
  test-row("x × 0", p("x * 0"), simplify(p("x * 0")))
  test-row("x^1", p("x^1"), simplify(p("x^1")))
  test-row("x^0", p("x^0"), simplify(p("x^0")))
  test-row("2 + 3", p("2 + 3"), simplify(p("2 + 3")))
  test-row("4 × 5", p("4 * 5"), simplify(p("4 * 5")))
  test-row("2^3", p("2^3"), simplify(p("2^3")))
  test-row("−(−x)", neg(neg(cvar("x"))), simplify(neg(neg(cvar("x")))))
  test-row("x + x", p("x + x"), simplify(p("x + x")))
  test-row("3x + 2x", p("3x + 2x"), simplify(p("3x + 2x")))
  test-row("x × x", p("x * x"), simplify(p("x * x")))
  test-row("x / x", p("x / x"), simplify(p("x / x")))
  test-row("6 / 4", p("6 / 4"), simplify(p("6 / 4")))
}

=== Function identities
#test-row("ln(e)", ln-of(const-e), simplify(ln-of(const-e)))
#test-row("exp(0)", exp-of(num(0)), simplify(exp-of(num(0))))
#test-row("sinh(0)", sinh-of(num(0)), simplify(sinh-of(num(0))))
#test-row("cosh(0)", cosh-of(num(0)), simplify(cosh-of(num(0))))
#test-row("tanh(0)", tanh-of(num(0)), simplify(tanh-of(num(0))))

=== Identity Table Rewrites
#{
  test-row("sin²(x)+cos²(x)", p("sin(x)^2 + cos(x)^2"), simplify(p("sin(x)^2 + cos(x)^2")))
  test-row("1/sin(x)", p("1/sin(x)"), simplify(p("1/sin(x)")))
  test-row("1/cos(x)", p("1/cos(x)"), simplify(p("1/cos(x)")))
  test-row("sin(x)/cos(x)", p("sin(x)/cos(x)"), simplify(p("sin(x)/cos(x)")))
  test-row("cos(x)/sin(x)", p("cos(x)/sin(x)"), simplify(p("cos(x)/sin(x)")))
  test-row("exp(ln(x))", p("exp(ln(x))"), simplify(p("exp(ln(x))")))
  test-row("ln(exp(x))", p("ln(exp(x))"), simplify(p("ln(exp(x))")))
}

=== Logarithm rules
#{
  let x = cvar("x")
  let y = cvar("y")
  test-row("ln(x·y)", ln-of(mul(x, y)), simplify(ln-of(mul(x, y))))
  test-row("ln(x/y)", ln-of(cdiv(x, y)), simplify(ln-of(cdiv(x, y))))
  test-row("ln(x²)", p("ln(x^2)"), simplify(p("ln(x^2)")))
}

=== Absolute value
#test-row("|−5|", abs-of(num(-5)), simplify(abs-of(num(-5))))
#test-row("|3|", abs-of(num(3)), simplify(abs-of(num(3))))
#test-row("|−x|", abs-of(neg(cvar("x"))), simplify(abs-of(neg(cvar("x")))))

// =====================================================================
= 3. Expansion
// =====================================================================

=== expand()
#{
  let expr = p("(x + 1)^2")
  let expanded = expand(expr)
  let simplified = simplify(expanded)
  block(below: 0.6em)[
    *Expand $(x+1)^2$:*
    $ #cas-display(expr) arrow.r.double #cas-display(expanded) $
    $ arrow.r.double #cas-display(simplified) #h(0.5em) "(simplified)" $
  ]
}

#{
  let expr = mul(add(cvar("x"), num(1)), add(cvar("x"), num(2)))
  let expanded = expand(expr)
  let simplified = simplify(expanded)
  block(below: 0.6em)[
    *Expand $(x+1)(x+2)$:*
    $ #cas-display(expr) arrow.r.double #cas-display(expanded) $
    $ arrow.r.double #cas-display(simplified) #h(0.5em) "(simplified)" $
  ]
}

// =====================================================================
= 4. Substitution
// =====================================================================

#{
  let expr = p("x^2 + 3x")
  let repl = p("y + 1")
  let sub-expr = substitute(expr, "x", repl)
  let expanded = simplify(sub-expr, expand: true)
  block(below: 0.6em)[
    *Substitute $x = #cas-display(repl)$ into $#cas-display(expr)$:*
    $ arrow.r.double #cas-display(sub-expr) $
    $ arrow.r.double #cas-display(expanded) #h(0.5em) "(expanded)" $
  ]
}

// =====================================================================
= 5. Differentiation
// =====================================================================

#{
  let all = (
    ("d/dx (x³)", p("x^3")),
    ("d/dx (sin x)", p("sin(x)")),
    ("d/dx (cos x)", p("cos(x)")),
    ("d/dx (tan x)", p("tan(x)")),
    ("d/dx (csc x)", p("csc(x)")),
    ("d/dx (sec x)", p("sec(x)")),
    ("d/dx (cot x)", p("cot(x)")),
    ("d/dx (ln x)", p("ln(x)")),
    ("d/dx (eˣ)", p("exp(x)")),
    // Inverse trig
    ("d/dx (arcsin x)", p("arcsin(x)")),
    ("d/dx (arccos x)", p("arccos(x)")),
    ("d/dx (arctan x)", p("arctan(x)")),
    ("d/dx (arccsc x)", p("arccsc(x)")),
    ("d/dx (arcsec x)", p("arcsec(x)")),
    ("d/dx (arccot x)", p("arccot(x)")),
    // Hyperbolic
    ("d/dx (sinh x)", p("sinh(x)")),
    ("d/dx (cosh x)", p("cosh(x)")),
    ("d/dx (tanh x)", p("tanh(x)")),
    ("d/dx (csch x)", p("csch(x)")),
    ("d/dx (sech x)", p("sech(x)")),
    ("d/dx (coth x)", p("coth(x)")),
    // Inverse Hyperbolic
    ("d/dx (arcsinh x)", p("arcsinh(x)")),
    ("d/dx (arccosh x)", p("arccosh(x)")),
    ("d/dx (arctanh x)", p("arctanh(x)")),
    ("d/dx (arccsch x)", p("arccsch(x)")),
    ("d/dx (arcsech x)", p("arcsech(x)")),
    ("d/dx (arccoth x)", p("arccoth(x)")),
    // Other functions
    ("d/dx (|x|)", p("abs(x)")),
    ("d/dx (√x)", p("sqrt(x)")),
    ("d/dx (log₂x)", p("log_2(x)")),
    ("d/dx (log2 x)", p("log2(x)")),
    ("d/dx (log10 x)", p("log10(x)")),
  )
  for (label, expr) in all {
    test-row(label, expr, simplify(diff(expr, "x")))
  }
}

#block(below: 0.6em)[
  *Domain notes:*
  $ (dif)/(dif x) abs(x) = x / abs(x) #h(0.6em) "for" #h(0.4em) x != 0 $ (undefined at $x = 0$).
  $ (dif)/(dif x) arccosh(x) = 1 / sqrt(x^2 - 1) #h(0.6em) "for real domain" #h(0.4em) x > 1 $.
]

=== Higher-Order Derivatives
#{
  let expr = p("x^4")
  block(below: 0.6em)[
    *d²/dx² (x⁴):* $ #cas-display(expr) arrow.r.double #cas-display(diff-n(expr, "x", 2)) $
  ]
}
#{
  let expr = p("sin(x)")
  block(below: 0.6em)[
    *d³/dx³ (sin x):* $ #cas-display(expr) arrow.r.double #cas-display(diff-n(expr, "x", 3)) $
  ]
}

=== Implicit Differentiation
#{
  let expr = p("x^2 + y^2 - 1")
  let result = implicit-diff(expr, "x", "y")
  block(below: 0.6em)[
    *Implicit: $x^2 + y^2 = 1$, find $dif y \/ dif x$:*
    $ (dif y) / (dif x) = #cas-display(simplify(result)) $
  ]
}
#{
  let expr = add(mul(cvar("x"), cvar("y")), sub(pow(cvar("y"), num(2)), num(4)))
  let result = implicit-diff(expr, "x", "y")
  block(below: 0.6em)[
    *Implicit: $x y + y^2 = 4$, find $dif y \/ dif x$:*
    $ (dif y) / (dif x) = #cas-display(simplify(result)) $
  ]
}

// =====================================================================
= 6. Integration
// =====================================================================

#{
  let all = (
    ("∫ x² dx", p("x^2")),
    ("∫ sin(x) dx", p("sin(x)")),
    ("∫ cos(x) dx", p("cos(x)")),
    ("∫ eˣ dx", p("exp(x)")),
    ("∫ 1/x dx", p("1 / x")),
    ("∫ sec(x) dx", p("sec(x)")),
    ("∫ csc(x) dx", p("csc(x)")),
    ("∫ tan(x) dx", p("tan(x)")),
    ("∫ cot(x) dx", p("cot(x)")),
    ("∫ sec²(x) dx", pow(sec-of(cvar("x")), num(2))),
    ("∫ csc²(x) dx", pow(csc-of(cvar("x")), num(2))),
    ("∫ (sec²(x) + csc²(x)) dx", p("sec(x)^2 + csc(x)^2")),
    ("∫ (sec²x + csc²x) dx", p("sec^2 x + csc^2 x")),
    ("∫ sinh(x) dx", p("sinh(x)")),
    ("∫ cosh(x) dx", p("cosh(x)")),
    ("∫ tanh(x) dx", p("tanh(x)")),
    ("∫ csch(x) dx", p("csch(x)")),
    ("∫ sech(x) dx", p("sech(x)")),
    ("∫ coth(x) dx", p("coth(x)")),
  )
  for (label, expr) in all {
    test-row(label, expr, simplify(integrate(expr, "x")))
  }
}

=== Definite Integrals
#{
  let result = definite-integral(p("x^2"), "x", 0, 1)
  block(below: 0.6em)[
    *∫₀¹ x² dx:* $ #cas-display(result) $
  ]
}

#{
  let result = definite-integral(p("2x"), "x", 1, 3)
  block(below: 0.6em)[
    *∫₁³ 2x dx:* $ #cas-display(result) $
  ]
}

#{
  let result = definite-integral(p("sin(x)"), "x", 0, p("pi"))
  block(below: 0.6em)[
    *∫₀^π sin(x) dx:* $ #cas-display(result) $
  ]
}

// =====================================================================
= 7. Taylor Series
// =====================================================================

#{
  let result = taylor(p("exp(x)"), "x", 0, 4)
  block(below: 0.6em)[
    *Taylor of eˣ at x=0 (order 4):*
    $ #cas-display(result) $
  ]
}

#{
  let result = taylor(p("sin(x)"), "x", 0, 5)
  block(below: 0.6em)[
    *Taylor of sin(x) at x=0 (order 5):*
    $ #cas-display(result) $
  ]
}

#{
  let result = taylor(p("cos(x)"), "x", 0, 4)
  block(below: 0.6em)[
    *Taylor of cos(x) at x=0 (order 4):*
    $ #cas-display(result) $
  ]
}

#{
  let result = taylor(p("ln(x)"), "x", 1, 4)
  block(below: 0.6em)[
    *Taylor of ln(x) at x=1 (order 4):*
    $ #cas-display(result) $
  ]
}

// =====================================================================
= 8. Limits
// =====================================================================

#{
  let expr = p("sin(x) / x")
  let result = limit(expr, "x", 0)
  block(below: 0.6em)[
    *lim(x→0) sin(x)/x:* $ #cas-display(result) $
  ]
}

#{
  let expr = p("(x^2 - 4) / (x - 2)")
  let result = limit(expr, "x", 2)
  block(below: 0.6em)[
    *lim(x→2) (x²−4)/(x−2):* $ #cas-display(result) $
  ]
}

#{
  let expr = p("(exp(x) - 1) / x")
  let result = limit(expr, "x", 0)
  block(below: 0.6em)[
    *lim(x→0) (eˣ−1)/x:* $ #cas-display(result) $
  ]
}

// =====================================================================
= 9. Equation Solving
// =====================================================================

#{
  let lhs = p("2x + 6")
  let solutions = solve(lhs, 0, "x")
  test-row("Linear: 2x + 6 = 0", lhs, solutions.at(0))
}

#{
  let lhs = p("3x - 9")
  let solutions = solve(lhs, 0, "x")
  test-row("Linear: 3x − 9 = 0", lhs, solutions.at(0))
}

#{
  let lhs = p("x^2 - 4")
  let solutions = solve(lhs, 0, "x")
  block(below: 0.6em)[
    *Quadratic: x² − 4 = 0:* $ #cas-display(lhs) = 0 arrow.r.double x = #cas-display(solutions.at(0)) "or" x = #cas-display(solutions.at(1)) $
  ]
}

#{
  let lhs = p("x^2 - 5x + 6")
  let solutions = solve(lhs, 0, "x")
  block(below: 0.6em)[
    *Quadratic: x² − 5x + 6 = 0:* $ #cas-display(lhs) = 0 arrow.r.double x = #solutions.map(s => cas-display(s)).join(" or ") $
  ]
}

#{
  let lhs = p("x^3 + 2x^2 + 3x + 1")
  let solutions = solve(lhs, 0, "x")
  block(below: 0.6em)[
    *Cubic (numeric fallback): x³ + 2x² + 3x + 1 = 0:*
    $ #cas-display(lhs) = 0 arrow.r.double x = #solutions.map(s => cas-display(s)).join(", ") $
  ]
}

// =====================================================================
= 10. Polynomial Factoring
// =====================================================================

#{
  let expr = p("x^2 - 5x + 6")
  let factored = factor(expr, "x")
  test-row("x² − 5x + 6", expr, factored)
}

#{
  let expr = p("x^2 - 4")
  let factored = factor(expr, "x")
  test-row("x² − 4", expr, factored)
}

#{
  let expr = p("x^3 - 6x^2 + 11x - 6")
  let factored = factor(expr, "x")
  test-row("x³ − 6x² + 11x − 6", expr, factored)
}

// =====================================================================
= 11. Polynomial Operations
// =====================================================================

=== Polynomial Long Division
#{
  let dividend = p("x^3 - 1")
  let divisor = p("x - 1")
  let result = poly-div(dividend, divisor, "x")
  if result != none {
    let (q, r) = result
    block(below: 0.6em)[
      *$(x^3 - 1) div (x - 1)$:*
      $ "quotient" = #cas-display(q), #h(1em) "remainder" = #cas-display(r) $
    ]
  }
}

#{
  let dividend = p("x^3 + 2x^2 - x - 2")
  let divisor = p("x + 2")
  let result = poly-div(dividend, divisor, "x")
  if result != none {
    let (q, r) = result
    block(below: 0.6em)[
      *$(x^3 + 2x^2 - x - 2) div (x + 2)$:*
      $ "quotient" = #cas-display(q), #h(1em) "remainder" = #cas-display(r) $
    ]
  }
}

=== Partial Fraction Decomposition
#{
  let expr = cdiv(add(mul(num(2), cvar("x")), num(3)), p("x^2 - 1"))
  let result = partial-fractions(expr, "x")
  block(below: 0.6em)[
    *Partial fractions of $(2x + 3)/(x^2 - 1)$:*
    $ #cas-display(expr) = #cas-display(result) $
  ]
}

#{
  let expr = cdiv(num(1), p("x^2 - 5x + 6"))
  let result = partial-fractions(expr, "x")
  block(below: 0.6em)[
    *Partial fractions of $1/(x^2 - 5x + 6)$:*
    $ #cas-display(expr) = #cas-display(result) $
  ]
}

// =====================================================================
= 12. Numeric Evaluation
// =====================================================================

#{
  let expr = p("3x^2 + 2x + 1")
  let result = eval-expr(expr, (x: 2))
  block(below: 0.6em)[
    *Evaluate at x = 2:* $ #cas-display(expr) = #result $
  ]
}

#{
  let expr = sin-of(cdiv(const-pi, num(2)))
  let result = eval-expr(expr, (:))
  block(below: 0.6em)[
    *Evaluate:* $ #cas-display(expr) = #calc.round(result, digits: 6) $
  ]
}

#{
  let expr = p("abs(-7)")
  let result = eval-expr(expr, (:))
  block(below: 0.6em)[
    *Evaluate:* $ #cas-display(expr) = #result $
  ]
}

#{
  let expr = log-of(num(2), num(8))
  let result = eval-expr(expr, (:))
  block(below: 0.6em)[
    *Evaluate:* $ #cas-display(expr) = #calc.round(result, digits: 6) $
  ]
}

#{
  let expr = p("log10(1000)")
  let result = eval-expr(expr, (:))
  block(below: 0.6em)[
    *Evaluate:* $ #cas-display(expr) = #calc.round(result, digits: 6) $
  ]
}

#{
  let expr = p("hypot2(3, 4)")
  let result = eval-expr(expr, (:))
  block(below: 0.6em)[
    *Registry multi-arg function:* $ #cas-display(expr) = #result $
  ]
}

=== Summation Evaluation
#{
  // Σ_{k=1}^{10} k² = 385
  let expr = p("sum_(k=1)^10 k^2")
  let result = eval-expr(expr, (:))
  block(below: 0.6em)[
    *Evaluate:* $ #cas-display(expr) = #result $
  ]
}

#{
  // Π_{k=1}^{5} k = 120
  let expr = p("product_(k=1)^5 k")
  let result = eval-expr(expr, (:))
  block(below: 0.6em)[
    *Evaluate:* $ #cas-display(expr) = #result $
  ]
}

// =====================================================================
= 13. Matrix Algebra
// =====================================================================

#{
  let a = cmat(((1, 2), (3, 4)))
  let b = cmat(((5, 6), (7, 8)))

  block(below: 0.6em)[
    *A + B:*
    $ #cas-display(a) + #cas-display(b) = #cas-display(mat-add(a, b)) $
  ]

  block(below: 0.6em)[
    *A − B:*
    $ #cas-display(a) - #cas-display(b) = #cas-display(mat-sub(a, b)) $
  ]

  block(below: 0.6em)[
    *A × B:*
    $ #cas-display(a) dot.op #cas-display(b) = #cas-display(mat-mul(a, b)) $
  ]

  block(below: 0.6em)[
    *3 · A (scalar multiply):*
    $ 3 dot.op #cas-display(a) = #cas-display(mat-scale(num(3), a)) $
  ]

  block(below: 0.6em)[
    *det(A):* $ det #cas-display(a) = #cas-display(mat-det(a)) $
  ]

  block(below: 0.6em)[
    *Aᵀ:* $ #cas-display(a)^top = #cas-display(mat-transpose(a)) $
  ]

  block(below: 0.6em)[
    *A⁻¹:* $ #cas-display(a)^(-1) = #cas-display(mat-inv(a)) $
  ]
}

=== Eigenvalues & Eigenvectors
#{
  let m = cmat(((2, 1), (1, 2)))
  let eigenvals = mat-eigenvalues(m)
  block(below: 0.6em)[
    *Eigenvalues of $mat(2, 1; 1, 2)$:*
    $ lambda = #eigenvals.map(e => cas-display(e)).join(", ") $
  ]
  let eigenvecs = mat-eigenvectors(m)
  block(below: 0.6em)[
    *Eigenvectors:*
    #for (val, evec) in eigenvecs [
      $ lambda = #cas-display(val): #h(0.5em) vec(#cas-display(evec.at(0)), #cas-display(evec.at(1))) $
    ]
  ]
}

=== System of Equations (Cramer's Rule)
#{
  let a = cmat(((1, 2), (3, 4)))
  let b-vec = (num(5), num(6))
  let solutions = mat-solve(a, b-vec)
  block(below: 0.6em)[
    *Solve Ax = b:*
    $ #cas-display(a) vec(x, y) = vec(5, 6) $
    $ x = #cas-display(solutions.at(0)), #h(0.5em) y = #cas-display(solutions.at(1)) $
  ]
}


// =====================================================================
= 14. Step-by-Step Mode
// =====================================================================

=== Step-by-Step Simplification
#{
  let expr = p("0 * x + 5")
  let steps = step-simplify(expr)
  display-steps(expr, steps)
}

=== Step-by-Step Differentiation
#{
  let expr = p("x^2 * sin(x)")
  let steps = step-diff(expr, "x")
  display-steps(expr, steps, operation: "diff", var: "x")
}

#{
  let expr = exp-of(sin-of(cvar("x")))
  let steps = step-diff(expr, "x")
  display-steps(expr, steps, operation: "diff", var: "x")
}

=== Step-by-Step Integration
#{
  let expr = p("x^2 + 3x + 1")
  let steps = step-integrate(expr, "x")
  display-steps(expr, steps, operation: "integrate", var: "x")
}

=== Step-by-Step Solving
#{
  let lhs = p("x^2 - 4")
  let steps = step-solve(lhs, 0, "x")
  display-steps(lhs, steps, operation: "solve", var: "x", rhs: 0)
}
#{
  let lhs = p("x^3 + 2x^2 + 3x + 1")
  let steps = step-solve(lhs, 0, "x")
  display-steps(lhs, steps, operation: "solve", var: "x", rhs: 0)
}

#{
  let lhs = p("2x + 6")
  let steps = step-solve(lhs, 0, "x")
  display-steps(lhs, steps, operation: "solve", var: "x", rhs: 0)
}

// =====================================================================
= 15. Content Parsing
// =====================================================================

#{
  let expr1 = cas-parse($x^2 + frac(1, 2)$)
  let expr2 = cas-parse($sqrt(x) + root(3, y)$)
  let expr3 = cas-parse($sum_(k=1)^n k^2$)
  let expr4 = cas-parse($sin(x) + cos(x)$)
  let expr5 = cas-parse($product_(i=1)^n i$)
  let expr6 = cas-parse("log2(x) + log10(x)")
  let expr7 = cas-parse($i$)

  block(below: 0.6em)[
    *Content `$x^2 + frac(1, 2)$`:* $ #cas-display(expr1) $
    *Content `$sqrt(x) + root(3, y)$`:* $ #cas-display(expr2) $
    *Content `$sum_(k=1)^n k^2$`:* $ #cas-display(expr3) $
    *Content `$sin(x) + cos(x)$`:* $ #cas-display(expr4) $
    *Content Product* $ #cas-display(expr5) $
    *Content `$log2(x) + log10(x)$`:* $ #cas-display(expr6) $
    *Content reserved `$i$` constant:* $ #cas-display(expr7) $
    *Policy:* lowercase `i` is reserved for imaginary-unit support and cannot be used as a free variable in solve/diff/integrate APIs.
  ]
}

// =====================================================================
= 16. Parser Round-Trip
// =====================================================================

#{
  let expr = p("x^3 + 2x^2 - x + 5")
  let simplified = simplify(expr)
  let deriv = simplify(diff(simplified, "x"))
  block(below: 0.6em)[
    *Parse, simplify, differentiate `"x^3 + 2x^2 - x + 5"`*
    $ "parsed:" #h(0.5em) #cas-display(expr) $
    $ "simplified:" #h(0.5em) #cas-display(simplified) $
    $ "d/dx:" #h(0.5em) #cas-display(deriv) $
  ]
}

#{
  let expr = p("x^2 - 5x + 6")
  let solutions = solve(expr, 0, "x")
  block(below: 0.6em)[
    *Parse and solve `"x^2 - 5x + 6 = 0"`*
    $ #cas-display(expr) = 0 arrow.r.double x = #solutions.map(s => cas-display(s)).join(" or ") $
  ]
}

// =====================================================================
= 17. Exact Rational Arithmetic
// =====================================================================

#{
  let expr = p("1/3 + 1/6")
  let out = simplify(expr)
  test-row("1/3 + 1/6", expr, out)
}

#{
  let expr = p("2/3 * 9/10")
  let out = simplify(expr)
  test-row("2/3 × 9/10", expr, out)
}

#{
  let expr = p("y + x + 2x + 3")
  let out = simplify(expr)
  test-row("Canonical collect/order", expr, out)
}

// =====================================================================
= 18. Polynomial Metadata + Complex Roots
// =====================================================================

#{
  let expr = p("x^2 + 1")
  let meta = solve-meta(expr, 0, "x")
  block(below: 0.6em)[
    *x² + 1 = 0 metadata*
    $ "factor:" #h(0.5em) #cas-display(meta.factor-form) $
    $ "square-free gcd:" #h(0.5em) #cas-display(meta.square-free-gcd) $
    #for (i, r) in meta.roots.enumerate() [
      $ r_(#(i + 1)) = #cas-display(r.expr), #h(0.5em) "mult=" #r.multiplicity, #h(0.5em) "exact=" #r.exact, #h(0.5em) "complex=" #r.complex $
    ]
  ]
}

#{
  let expr = p("x^2 * (x - 1)^2")
  let meta = solve-meta(expr, 0, "x")
  block(below: 0.6em)[
    *Repeated roots + square-free preprocessing*
    $ "f(x)=" #cas-display(expr) $
    $ "gcd(f,f')" = #cas-display(meta.square-free-gcd) $
    $ "square-free part" = #cas-display(meta.square-free-part) $
    #for (i, r) in meta.roots.enumerate() [
      $ r_(#(i + 1)) = #cas-display(r.expr), #h(0.5em) "mult=" #r.multiplicity $
    ]
  ]
}

// =====================================================================
= 19. Integration Engine Upgrades
// =====================================================================

#{
  let expr = p("2x * cos(x^2)")
  let out = integrate(expr, "x")
  test-row("u-sub detection: ∫2x cos(x²) dx", expr, out)
}

#{
  let expr = p("x * exp(x)")
  let out = simplify(integrate(expr, "x"))
  test-row("By parts: ∫x e^x dx", expr, out)
}

#{
  let expr = p("1 / (x^2 - 1)")
  let out = simplify(integrate(expr, "x"))
  test-row("Partial fractions workflow", expr, out)
}

// =====================================================================
= 20. Assumptions
// =====================================================================

#{
  let pos-x = assume("x", real: true, positive: true)
  let expr = p("abs(x) + sqrt(x^2)")
  let out = simplify(expr, assumptions: pos-x)
  block(below: 0.6em)[
    *Assume x > 0:* $ #cas-display(expr) arrow.r.double #cas-display(out) $
  ]
}

#{
  let real-x = assume("x", real: true)
  let expr = p("sqrt(x^2)")
  let out = simplify(expr, assumptions: real-x)
  block(below: 0.6em)[
    *Assume x is real:* $ #cas-display(expr) arrow.r.double #cas-display(out) $
  ]
}

// =====================================================================
= 21. Systems of Equations
// =====================================================================

#{
  let lin = solve-linear-system(
    (
      (p("2x + y"), 5),
      (p("x - y"), 1),
    ),
    ("x", "y"),
  )
  block(below: 0.6em)[
    *Linear system:*
    $2x + y = 5, #h(1em) x - y = 1$
    $x = #cas-display(lin.at("x")), #h(0.8em) y = #cas-display(lin.at("y"))$
  ]
}

#{
  let nl = solve-nonlinear-system(
    (
      (p("x^2 + y^2"), 5),
      (p("x - y"), 1),
    ),
    ("x", "y"),
    (x: 2.0, y: 1.0),
  )
  block(below: 0.6em)[
    *Nonlinear numeric system (Newton):*
    $x^2 + y^2 = 5, #h(1em) x - y = 1$
    $ "converged:" #nl.converged, #h(0.8em) "iters:" #nl.iterations $
    $x approx #cas-display(nl.solution.at("x")), #h(0.8em) y approx #cas-display(nl.solution.at("y"))$
  ]
}

// =====================================================================
= 22. Canonical Simplifier Normalization
// =====================================================================

#{
  let expr = p("y + x + 2y + x + 1/2 + 1/2")
  let s1 = simplify(expr)
  let s2 = simplify(s1)
  block(below: 0.6em)[
    *Normalization & idempotence check:*
    $ "s1 =" #cas-display(s1) $
    $ "s2 =" #cas-display(s2), #h(0.6em) "idempotent:" #expr-eq(s1, s2) $
  ]
}

#{
  let loop1 = p("sin(x)^2 + cos(x)^2 + sin(x)^2 + cos(x)^2")
  let l1s1 = simplify(loop1)
  let l1s2 = simplify(l1s1)
  block(below: 0.6em)[
    *Loop-safety check (trig repeat):*
    $ "s1 =" #cas-display(l1s1) $
    $ "s2 =" #cas-display(l1s2), #h(0.6em) "idempotent:" #expr-eq(l1s1, l1s2) $
  ]
}

#{
  let loop2 = p("ln((x*y)/z)")
  let l2s1 = simplify(loop2)
  let l2s2 = simplify(l2s1)
  block(below: 0.6em)[
    *Loop-safety check (log decomposition):*
    $ "s1 =" #cas-display(l2s1) $
    $ "s2 =" #cas-display(l2s2), #h(0.6em) "idempotent:" #expr-eq(l2s1, l2s2) $
  ]
}

// =====================================================================
= 23. Property-Style Harness
// =====================================================================

#{
  let samples = (
    p("x^3 + 2x^2 - x + 5"),
    p("(x + 1)^2"),
    p("sin(x)^2 + cos(x)^2"),
    p("1/3 + 1/6 + x + x"),
  )

  let equivalent-on-x(e1, e2, samples: (-2, -1, 0, 1, 2), tol: 1e-6) = {
    let seen = false
    for xv in samples {
      let v1 = eval-expr(e1, (x: xv))
      let v2 = eval-expr(e2, (x: xv))
      if v1 == none or v2 == none { continue }
      seen = true
      if calc.abs(v1 - v2) > tol { return false }
    }
    if seen { return true }
    expr-eq(simplify(e1), simplify(e2))
  }

  let pass-idem = true
  let pass-roundtrip = true
  let pass-diff-int = true
  let pass-solve-sub = true

  for e in samples {
    let s = simplify(e)
    if not expr-eq(simplify(s), s) { pass-idem = false }

    let rt = cas-parse(cas-display(e))
    if not expr-eq(simplify(rt), simplify(e)) and not equivalent-on-x(rt, e) {
      pass-roundtrip = false
    }
  }

  // d/dx(∫f dx) == f for a polynomial sample
  {
    let f = p("3x^2 + 2x + 1")
    let recovered = simplify(diff(integrate(f, "x"), "x"))
    if not expr-eq(recovered, simplify(f)) and not equivalent-on-x(recovered, f) {
      pass-diff-int = false
    }
  }

  // Solver substitution check for real roots.
  {
    let f = p("x^3 - 6x^2 + 11x - 6")
    let roots = solve(f, 0, "x")
    for r in roots {
      let rv = eval-expr(r, (:))
      if rv != none {
        let val = eval-expr(substitute(f, "x", r), (:))
        if val == none or calc.abs(val) > 1e-6 { pass-solve-sub = false }
      }
    }
  }

  block(below: 0.6em)[
    *Property checks:*
    $ "simplify idempotence:" #pass-idem $
    $ "parse↔display round-trip:" #pass-roundtrip $
    $ "diff/integral consistency:" #pass-diff-int $
    $ "solver substitution:" #pass-solve-sub $
  ]
}
