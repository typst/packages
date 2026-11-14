// Tests principal inverse tangent notation and its arctan and atan aliases.

#import "../utils.typ": unary_operation

#unary_operation(
  "Inverse Tangent",
  [Principal inverse tangent using the existing exponent-attach parser],
  c1 => { $tan^(-1)(#c1)$ },
  (v: $0$, e: $0$),
  (v: $1$, e: $pi / 4$),
)

#unary_operation(
  "Inverse Tangent Alias",
  [The arctan function name is an alias for inverse tangent],
  c1 => { $arctan(#c1)$ },
  (v: $0$, e: $0$),
)

#unary_operation(
  "Inverse Tangent Short Alias",
  [The atan operator spelling is accepted too],
  c1 => { $op("atan")(#c1)$ },
  (v: $0$, e: $0$),
)
