// Addition tests for kalt bindings

#import "../utils.typ": binary_operation

#binary_operation(
  "Addition",
  [Binary addition (element-wise)],
  (c1, c2) => { $ #c1 + #c2 $ },
  (v1: $3$, v2: $5$, e: $8.0$),
  (v1: $3$, v2: $mat(1, 2; 3, 4)$, e: $mat(4, 5; 6, 7)$),
  (v1: $mat(1, 2; 3, 4)$, v2: $5$, e: $mat(6, 7; 8, 9)$),
  (v1: $mat(1, 2; 3, 4)$, v2: $mat(5, 6; 7, 8)$, e: $mat(6, 8; 10, 12)$),
  (v1: $0$, v2: $-3+4i$, e: $-3+4i$),
  (v1: $-2.5$, v2: $2.5$, e: $0$),
  (v1: $mat(0, 0; 0, 0)$, v2: $mat(1i, -2i; 3i, -4i)$, e: $mat(1i, -2i; 3i, -4i)$),
)
