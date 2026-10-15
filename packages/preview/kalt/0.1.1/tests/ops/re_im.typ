// Real and imaginary part tests for kalt bindings

#import "../../lib.typ": comp
#import "../utils.typ": unary_operation

#unary_operation(
  "Real Part",
  [Real part, returned as a real complex scalar],
  c1 => { $ Re(#c1) $ },
  (v: $3+4i$, e: $3$),
  (v: $-2-5i$, e: $-2$),
  (v: $4i$, e: $0$),
  (v: $-7$, e: $-7$),
  (v: $mat(1+i, 2-3i; 4i, -5)$, e: $mat(1, 2; 0, -5)$),
)

#unary_operation(
  "Imaginary Part",
  [Imaginary part, returned as a real complex scalar],
  c1 => { $ Im(#c1) $ },
  (v: $3+4i$, e: $4$),
  (v: $-2-5i$, e: $-5$),
  (v: $4i$, e: $4$),
  (v: $-7$, e: $0$),
  (v: $mat(1+i, 2-3i; 4i, -5)$, e: $mat(1, -3; 4, 0)$),
)
