// Tests principal inverse cosine notation and its arccos and acos aliases.

#import "../utils.typ": unary_operation

#unary_operation(
  "Inverse Cosine",
  [Principal inverse cosine using the existing exponent-attach parser],
  c1 => { $cos^(-1)(#c1)$ },
  (v: $1$, e: $0$),
  (v: $0$, e: $pi / 2$),
)

#unary_operation(
  "Inverse Cosine Alias",
  [The arccos function name is an alias for inverse cosine],
  c1 => { $arccos(#c1)$ },
  (v: $1$, e: $0$),
)

#unary_operation(
  "Inverse Cosine Short Alias",
  [The acos operator spelling is accepted too],
  c1 => { $op("acos")(#c1)$ },
  (v: $1$, e: $0$),
)
