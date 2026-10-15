// Floor tests for kalt bindings

#import "../../lib.typ": comp, map
#import "../utils.typ": unary_operation

#unary_operation(
  "Floor",
  [Unary floor],
  c1 => { $ floor(#c1) $ },
  // floor
  (v: $3$, e: $3$),
  (v: $0$, e: $0$),
  (v: $-3$, e: $-3$),
  (v: $2-1i$, e: $2-1i$),
  (v: $3.5$, e: $3$),
  (v: $-3.5 - 7.25i$, e: $-4 -8i$),
  (
    v: $mat(-1.23, 4.56; 3.2i, 5.78)$,
    e: $comp(mat(-2, 4; 3i, 5))$,
  ),
)
