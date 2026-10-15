// Power tests for kalt bindings

#import "../../lib.typ": comp
#import "../utils.typ": binary_operation, unary_operation

#binary_operation(
  "Power",
  [Binary power (element-wise)],
  (c1, c2) => { $ #c1^#c2 $ },
  (v1: $3$, v2: $5$, e: $243.0$),
  (v1: $3$, v2: $mat(1, 2; 3, 4)$, e: $mat(3, 9; 27, 81)$),
  (v1: $mat(1, 2; 3, 4)$, v2: $5$, e: $mat(1069, 1558; 2337, 3406)$),
  (v1: $mat(1, 2; 3, 4)$, v2: $mat(5, 6; 7, 8)$, e: $mat(1, 64; 2187, 65536)$),
  (v1: $0$, v2: $3$, e: $0$),
  (v1: $5$, v2: $0$, e: $1$),
  (v1: $1$, v2: $-7$, e: $1$),
  (v1: $(-1)$, v2: $4$, e: $1$),
  (v1: $2+3i$, v2: $2$, e: $-5+12i$),
)

#unary_operation(
  "Transpose for matrices",
  [Unary transpose],
  c1 => { $ #c1^T $ },
  (v: $mat(1, 2; 3, 4)$, e: $mat(1, 3; 2, 4)$),
  (v: $mat(1, 2, 3; 4, 5, 6)$, e: $mat(1, 4; 2, 5; 3, 6)$),
  (v: $mat(7)$, e: $mat(7)$),
)
