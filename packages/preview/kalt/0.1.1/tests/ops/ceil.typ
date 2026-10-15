// Ceil tests for kalt bindings

#import "../../lib.typ": comp, map
#import "../utils.typ": unary_operation

#unary_operation(
  "Ceil",
  [Unary ceil],
  c1 => { $ ceil(#c1) $ },
  // ceil
  (v: $3$, e: $3$),
  (v: $0$, e: $0$),
  (v: $-3$, e: $-3$),
  (v: $2-1i$, e: $2-1i$),
  (v: $3.5$, e: $4$),
  (v: $-3.5 - 7.25i$, e: $-3 -7i$),
  (
    v: $mat(-1.23, 4.56; 3.2i, 5.78)$,
    e: $mat(-1, 5; 4i, 6)$,
  ),
)
