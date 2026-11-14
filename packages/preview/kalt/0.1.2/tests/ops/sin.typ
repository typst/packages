// Tests complex sine for scalars and matrix entries.

#import "../utils.typ": unary_operation

#unary_operation(
  "Sine",
  [Complex sine, applied element-wise],
  c1 => { $sin(#c1)$ },
  (v: $0$, e: $0$),
  (v: $pi$, e: $0$),
  (v: $mat(0, pi; pi, 0)$, e: $mat(0, 0; 0, 0)$),
)
