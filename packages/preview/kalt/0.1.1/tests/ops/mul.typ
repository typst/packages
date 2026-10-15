// Multiplication tests for kalt bindings

#import "../../lib.typ": comp, map
#import "../utils.typ": binary_operation

#binary_operation(
  "Multiplication",
  [Binary multiplication (element-wise)],
  (c1, c2) => { $ #c1 * #c2 $ },
  (v1: $3$, v2: $4i$, e: $(0+12i)$),
  (v1: $-5.7+8.9i$, v2: $6.3-7.4i$, e: $29.95 + 98.25i$),
  (v1: $2$, v2: $mat(1, 3; -4, 0)$, e: $mat(2, 6; -8, 0)$),
  (v1: $mat(5.5, -7.9; 8.3, -9.7)$, v2: $-3i$, e: $mat(-16.5i, 23.7i; -24.9i, 29.1i)$),
  (v1: $mat(1, -2i; 3, -4)$, v2: $mat(5-6i, -7-8i; 9-10i, -11-12i)$, e: $mat(5-6i, -16+14i; 27-30i, 44+48i)$),
  (v1: $0$, v2: $mat(1, -2; 3, 4)$, e: $mat(0, 0; 0, 0)$),
  (v1: $1$, v2: $mat(-2i, 3; 4i, -5)$, e: $mat(-2i, 3; 4i, -5)$),
)
