// Tests principal inverse sine notation and its arcsin and asin aliases.

#import "../utils.typ": unary_operation

#unary_operation(
  "Inverse Sine",
  [Principal inverse sine using the existing exponent-attach parser],
  c1 => { $sin^(-1)(#c1)$ },
  (v: $0$, e: $0$),
  (v: $1 / 2$, e: $pi / 6$),
)

#unary_operation(
  "Inverse Sine Alias",
  [The arcsin function name is an alias for inverse sine],
  c1 => { $arcsin(#c1)$ },
  (v: $0$, e: $0$),
)

#unary_operation(
  "Inverse Sine Short Alias",
  [The asin operator spelling is accepted too],
  c1 => { $op("asin")(#c1)$ },
  (v: $0$, e: $0$),
)
