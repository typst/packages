// Dot Product tests for kalt bindings

#import "../../lib.typ": comp, map
#import "../utils.typ": binary_operation

#binary_operation(
  "Dot Product",
  [Binary dot product],
  (c1, c2) => { $ #c1 dot #c2 $ },
  // dot product
  (v1: $3$, v2: $(1+2i)$, e: $3 + 6i$),
  (v1: $(2 - 3.2i)$, v2: $(-2 + 0.5i)$, e: $-2.4 + 7.4i$),
  (
    v1: $3$,
    v2: $mat(1, 2; 3, 4)$,
    e: $comp(mat(3, 6; 9, 12))$,
  ),
  (
    v1: $mat(1, 2; 3, 4)$,
    v2: $3$,
    e: $comp(mat(3, 6; 9, 12))$,
  ),
  (
    v1: $mat(1, 2; 3, -4)$,
    v2: $mat(1i, 2 + 1i; -3, 4)$,
    e: $comp(mat(1i - 6, 10 + i; 12 + 3i, -10 + 3i))$,
  ),
  // expected failure: incompatible matrix dimensions
  (
    v1: $mat(1, 2)$,
    v2: $mat(1, 2)$,
    error: "compatible shapes",
  ),
)
