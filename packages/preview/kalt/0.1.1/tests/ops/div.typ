// Division tests for kalt bindings

#import "../../lib.typ": comp, map
#import "../utils.typ": binary_operation

#binary_operation(
  "Division",
  [Binary division (element-wise)],
  (c1, c2) => { $ #c1 / #c2 $ },
  (v1: $6+3i$, v2: $3-9i$, e: $-0.1+0.7i$),
  (v1: $4$, v2: $mat(2, -1; 5, -2)$, e: $mat(2, -4; 0.8, -2)$),
  (v1: $mat(6.3, -7.9; 8.3, -9.7)$, v2: $-3$, e: $mat(-2.1, 79/30; -83/30, 97/30)$),
  (
    v1: $mat(1, -2i; 3, -4)$,
    v2: $mat(2i, 3; 1, 2)$,
    e: $mat(-0.5i, -2/3i; 3, -2)$,
  ),
  (v1: $0$, v2: $3$, e: $0$),
  (v1: $-6$, v2: $-2$, e: $3$),
  (v1: $mat(2, -4; 6, -8)$, v2: $2$, e: $mat(1, -2; 3, -4)$),
)
