// Tests hyperbolic cosine and inverse-hyperbolic-cosine aliases.

#import "../utils.typ": unary_operation

#unary_operation(
  "Hyperbolic Cosine",
  [Hyperbolic cosine, applied element-wise],
  c1 => { $cosh(#c1)$ },
  (v: $0$, e: $1$),
  (v: $1$, e: $1.5430806348152437$),
)

#unary_operation(
  "Inverse Hyperbolic Cosine",
  [Principal inverse hyperbolic cosine using the exponent-attach parser],
  c1 => { $cosh^(-1)(#c1)$ },
  (v: $1$, e: $0$),
)

#unary_operation(
  "Inverse Hyperbolic Cosine Alias",
  [The arccosh function spelling is accepted],
  c1 => { $op("arccosh")(#c1)$ },
  (v: $1$, e: $0$),
)

#unary_operation(
  "Inverse Hyperbolic Cosine Short Alias",
  [The acosh operator spelling is accepted],
  c1 => { $op("acosh")(#c1)$ },
  (v: $1$, e: $0$),
)
