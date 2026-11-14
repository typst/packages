// Tests hyperbolic tangent and inverse-hyperbolic-tangent aliases.

#import "../utils.typ": unary_operation

#unary_operation(
  "Hyperbolic Tangent",
  [Hyperbolic tangent, applied element-wise],
  c1 => { $tanh(#c1)$ },
  (v: $0$, e: $0$),
  (v: $1$, e: $0.7615941559557649$),
)

#unary_operation(
  "Inverse Hyperbolic Tangent",
  [Principal inverse hyperbolic tangent using the exponent-attach parser],
  c1 => { $tanh^(-1)(#c1)$ },
  (v: $0$, e: $0$),
)

#unary_operation(
  "Inverse Hyperbolic Tangent Alias",
  [The arctanh function spelling is accepted],
  c1 => { $op("arctanh")(#c1)$ },
  (v: $0$, e: $0$),
)

#unary_operation(
  "Inverse Hyperbolic Tangent Short Alias",
  [The atanh operator spelling is accepted],
  c1 => { $op("atanh")(#c1)$ },
  (v: $0$, e: $0$),
)
