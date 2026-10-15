// Cross Product tests for kalt bindings

#import "../../lib.typ": comp, map
#import "../utils.typ": binary_operation

#binary_operation(
  "Cross Product",
  [Binary cross product],
  (c1, c2) => { $ #c1 times #c2 $ },
  // cross product
  (v1: $vec(1i, 2, -3)$, v2: $vec(4, 5, 6)$, e: $vec(27, -12-6i, 5i - 8)$),
  (v1: $vec(1, 0, 0)$, v2: $vec(0, 1, 0)$, e: $vec(0, 0, 1)$),
  (v1: $vec(0, 0, 0)$, v2: $vec(1, 2, 3)$, e: $vec(0, 0, 0)$),
  (v1: $vec(1+i, 2, 3)$, v2: $vec(4, 5-i, 6)$, e: $vec(-3+3i, 6-6i, -2+4i)$),
)
