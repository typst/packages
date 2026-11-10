// =========================================================================
// typcas v2 AST
// =========================================================================
// Canonical expression layer for v2.
// This reuses the archived v1 node model and extends it with a native
// complex node.
// =========================================================================

#import "../expr.typ": *

/// Internal helper `_wrap`.
#let _wrap(x) = if type(x) == int or type(x) == float { num(x) } else { x }

/// Construct a native complex expression node.
#let complex(re, im) = (type: "complex", re: _wrap(re), im: _wrap(im))

/// Alias for complex constructor.
#let cplx(re, im) = complex(re, im)

/// True if expression is native complex node.
#let is-complex(expr) = is-type(expr, "complex")

/// Complex zero node.
#let complex-zero = complex(num(0), num(0))

/// Imaginary unit node.
#let complex-i = complex(num(0), num(1))

/// Lift a real expression to complex expression.
#let complex-real(x) = complex(_wrap(x), num(0))

/// Complex conjugate (symbolic node-level only).
#let complex-conj(z) = {
  if not is-complex(z) { return z }
  complex(z.re, neg(z.im))
}
