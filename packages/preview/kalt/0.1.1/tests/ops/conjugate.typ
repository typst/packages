// Conjugate tests for kalt bindings

#import "../../lib.typ": comp, map
#import "../utils.typ": unary_operation

#unary_operation(
  "Conjugate",
  [Unary conjugate $x^*$],
  c1 => { $ #c1^* $ },
  // conjugate
  (v: $3$, e: $3$),
  (v: $(2-1i)$, e: $2+1i$),
  (v: $-3.5i$, e: $3.5i$),
  (v: $(-3.5i)$, e: $3.5i$),
  (
    v: $mat(-1.23, 4.56 + i; 2-3.2i, 5.78)$,
    e: $comp(mat(-1.23, 4.56 - i; 2+3.2i, 5.78))$,
  ),
  (v: $0$, e: $0$),
  (v: $1+i$, e: $1-i$),
)

#unary_operation(
  "Hermitian",
  [Unary hermitian $x^H$ for matrices only],
  c1 => { $ #c1^H $ },
  (
    v: $mat(-1.23, 4.56 + i; 2-3.2i, 5.78)$,
    e: $comp(mat(-1.23, 4.56 - i; 2+3.2i, 5.78))$,
  ),
)
