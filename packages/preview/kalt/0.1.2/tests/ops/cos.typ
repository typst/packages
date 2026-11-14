// Tests complex cosine for scalars and matrix entries.

#import "../utils.typ": unary_operation

#unary_operation(
  "Cosine",
  [Complex cosine, applied element-wise],
  c1 => { $cos(#c1)$ },
  (v: $0$, e: $1$),
  (v: $pi$, e: $-1$),
  (v: $mat(0, pi)$, e: $mat(1, -1)$),
)
