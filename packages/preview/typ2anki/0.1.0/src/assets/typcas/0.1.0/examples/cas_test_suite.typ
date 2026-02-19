#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 1cm)

= CAS System Test Suite

This document contains a series of complex functions to test the step-by-step differentiation engine, specifically checking for:
- Variable shadowing issues (reused $u$)
- Spoiler effects (answers appearing before rules)
- Formatting of complex nested rules

== Test Case 1: Nested Exponential and Trigonometric
Function: $f(x) = e^{sin(x^2)}$

#{
  let expr = exp-of(sin-of(pow(cvar("x"), num(2))))
  let steps = step-diff(expr, "x")
  display-steps(expr, steps, operation: "diff", var: "x")
}

== Test Case 2: Product of Three Terms
Function: $f(x) = x^2 dot e^x dot sin(x)$
*Note: This tests nested product rules and variable naming depth.*

#{
  let expr = mul(pow(cvar("x"), num(2)), mul(exp-of(cvar("x")), sin-of(cvar("x"))))
  let steps = step-diff(expr, "x")
  display-steps(expr, steps, operation: "diff", var: "x")
}

== Test Case 3: Quotient with Logarithm Chain
Function: $f(x) = (ln(x^2 + 1)) / (x + 1)$

#{
  let expr = cdiv(
    ln-of(add(pow(cvar("x"), num(2)), num(1))),
    add(cvar("x"), num(1))
  )
  let steps = step-diff(expr, "x")
  display-steps(expr, steps, operation: "diff", var: "x")
}

== Test Case 4: Deeply Nested Powers (Chain Rule Stress Test)
Function: $f(x) = ((x^2 + 1)^3 + x)^2$

#{
  let inner_poly = add(pow(cvar("x"), num(2)), num(1))
  let term1 = pow(inner_poly, num(3))
  let base = add(term1, cvar("x"))
  let expr = pow(base, num(2))
  
  let steps = step-diff(expr, "x")
  display-steps(expr, steps, operation: "diff", var: "x")
}

== Test Case 5: Rational Function
Function: $f(x) = (x^3 + 2x - 5) / (x^2 - 1)$

#{
  let num_expr = sub(add(pow(cvar("x"), num(3)), mul(num(2), cvar("x"))), num(5))
  let den_expr = sub(pow(cvar("x"), num(2)), num(1))
  let expr = cdiv(num_expr, den_expr)
  
  let steps = step-diff(expr, "x")
  display-steps(expr, steps, operation: "diff", var: "x")
}
