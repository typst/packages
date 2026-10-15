// Natural logarithm tests for kalt bindings

#import "../../lib.typ": comp
#import "../utils.typ": unary_operation

#unary_operation(
  "Natural Logarithm",
  [Natural logarithm],
  c1 => { $ ln(#c1) $ },
  (v: $1$, e: $0$),
  (v: $e^2$, e: $2$),
  (
    v: $e^(3+4i)$,
    e: $3 - 2.28318530717958647i$,
  ),
  (v: $mat(1, e; e^2, e^3)$, e: $mat(0, 1; 2, 3)$),
  (v: $-1$, e: $-3.141592653589793i$),
  (v: $-e$, e: $1 - 3.141592653589793i$),
)
