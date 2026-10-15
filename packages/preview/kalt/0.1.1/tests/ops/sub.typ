// Subtraction tests for kalt bindings

#import "../../lib.typ": comp, map
#import "../utils.typ": binary_operation

#binary_operation(
  "Subtraction",
  [Binary subtraction (element-wise)],
  (c1, c2) => { $ #c1 - #c2 $ },
  (v1: $3$, v2: $5$, e: $-2$),
  (v1: $7.3i$, v2: $4+6i$, e: $-4 + 1.3i$),
  (v1: $mat(1, 2; 3, 4)$, v2: $mat(5, 6; 7, 8)$, e: $mat(-4, -4; -4, -4)$),
  (v1: $0$, v2: $-3+2i$, e: $3-2i$),
  (v1: $5$, v2: $5$, e: $0$),
  (v1: $mat(1, -2; 3, -4)$, v2: $2$, e: $mat(-1, -4; 1, -6)$),
)
