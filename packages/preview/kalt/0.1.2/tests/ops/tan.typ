// Tests complex tangent for scalar values.

#import "../utils.typ": unary_operation

#unary_operation(
  "Tangent",
  [Complex tangent, applied element-wise],
  c1 => { $tan(#c1)$ },
  (v: $0$, e: $0$),
  (v: $pi / 4$, e: $1$),
)
