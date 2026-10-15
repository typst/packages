// Root tests for kalt bindings

#import "../../lib.typ": comp
#import "../utils.typ": binary_operation, unary_operation

#binary_operation(
  "Root",
  [Binary root (element-wise)],
  (c1, c2) => { $ root(#c1, #c2) $ },
  (v1: $3$, v2: $pi^3$, e: $pi$),
  (v1: $3$, v2: $mat(1, 27; 8, 64)$, e: $mat(1, 3; 2, 4)$),
  (v1: $mat(1, 2; 3, 4)$, v2: $4096$, e: $mat(4096, 64; 16, 8)$),
  (v1: $mat(1, 2; 3, 4)$, v2: $mat(5, 9; 27, 16)$, e: $mat(5, 3; 3, 2)$),
)

#unary_operation(
  "Square Root",
  [Unary square root],
  c1 => { $ sqrt(#c1) $ },
  (v: $4$, e: $2$),
  (v: $pi^2$, e: $pi$),
  (v: $-3-4i$, e: $1-2i$),
  (v: $mat(1, -1; 4, 16)$, e: $mat(1, i; 2, 4)$),
)
