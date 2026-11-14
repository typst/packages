// Tests hyperbolic sine and inverse-hyperbolic-sine aliases.

#import "../utils.typ": unary_operation

#unary_operation(
  "Hyperbolic Sine",
  [Hyperbolic sine, applied element-wise],
  c1 => { $sinh(#c1)$ },
  (v: $0$, e: $0$),
  (v: $1$, e: $1.1752011936438014$),
)

#unary_operation(
  "Inverse Hyperbolic Sine",
  [Principal inverse hyperbolic sine using the exponent-attach parser],
  c1 => { $sinh^(-1)(#c1)$ },
  (v: $0$, e: $0$),
)

#unary_operation(
  "Inverse Hyperbolic Sine Alias",
  [The arcsinh function spelling is accepted],
  c1 => { $op("arcsinh")(#c1)$ },
  (v: $0$, e: $0$),
)

#unary_operation(
  "Inverse Hyperbolic Sine Short Alias",
  [The asinh operator spelling is accepted],
  c1 => { $op("asinh")(#c1)$ },
  (v: $0$, e: $0$),
)
