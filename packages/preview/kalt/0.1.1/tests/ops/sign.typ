// Sign/negation tests for bindings

#import "../../lib.typ": comp
#import "../utils.typ": unary_operation

#unary_operation(
  "Negation",
  [Unary negation],
  c1 => { $ -#c1 $ },
  (v: $3$, e: $-3$),
  (v: $(4-5i)$, e: $-4+5i$),
  (v: $mat(1, -2; 3, -4)$, e: $mat(-1, 2; -3, 4)$),
  (v: $0$, e: $0$),
  (v: $-7$, e: $7$),
  (v: $1+i$, e: $-1-i$),
  (v: $mat(0, 0; 0, 0)$, e: $mat(0, 0; 0, 0)$),
)
