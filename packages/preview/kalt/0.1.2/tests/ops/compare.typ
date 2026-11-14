// Tests numeric comparisons, Unicode aliases, complex equality, and invalid ordering.

#import "../utils.typ": binary_operation, assert-error
#import "../../lib.typ": comp

#binary_operation(
  "Less than",
  [Returns 1 when the real left operand is smaller, otherwise 0.],
  (a, b) => { $ #a < #b $ },
  (v1: $2$, v2: $3$, e: $1$),
  (v1: $3$, v2: $2$, e: $0$),
  (v1: $3$, v2: $3$, e: $0$),
  (v1: $mat(1, 4; 5, 2)$, v2: $mat(2, 3; 5, 8)$, e: $mat(1, 0; 0, 1)$),
)

#binary_operation(
  "Less than or equal",
  [Accepts both smaller and equal real operands. ASCII <= is also accepted.],
  (a, b) => { $ #a <= #b $ },
  (v1: $2$, v2: $3$, e: $1$),
  (v1: $3$, v2: $3$, e: $1$),
  (v1: $4$, v2: $3$, e: $0$),
)

#binary_operation(
  "Greater than",
  [Returns 1 when the real left operand is larger, otherwise 0.],
  (a, b) => { $ #a > #b $ },
  (v1: $3$, v2: $2$, e: $1$),
  (v1: $2$, v2: $2$, e: $0$),
)

#binary_operation(
  "Greater than or equal",
  [Accepts both greater and equal real operands. ASCII >= is also accepted.],
  (a, b) => { $ #a >= #b $ },
  (v1: $3$, v2: $2$, e: $1$),
  (v1: $3$, v2: $3$, e: $1$),
  (v1: $2$, v2: $3$, e: $0$),
)

#binary_operation(
  "Equality",
  [Exact equality of evaluated real or complex values.],
  (a, b) => { $ #a = #b $ },
  (v1: $3$, v2: $3$, e: $1$),
  (v1: $3$, v2: $4$, e: $0$),
  (v1: $1+2i$, v2: $1+2i$, e: $1$),
  (v1: $1+2i$, v2: $1-2i$, e: $0$),
)

#binary_operation(
  "Inequality",
  [Returns 1 when operands are not exactly equal.],
  (a, b) => { $ #a ≠ #b $ },
  (v1: $3$, v2: $4$, e: $1$),
  (v1: $3$, v2: $3$, e: $0$),
  (v1: $1+2i$, v2: $1-2i$, e: $1$),
)

#binary_operation(
  "Ordering rejects non-real values",
  [Ordered comparisons are undefined for complex values with nonzero imaginary parts.],
  (a, b) => { $ #a < #b $ },
  (v1: $1+2i$, v2: $3$, error: "ℝ"),
)

#binary_operation(
  "Unicode less-than-or-equal alias",
  [The mathematical ≤ symbol is an alias for <=.],
  (a, b) => { $ #a ≤ #b $ },
  (v1: $2$, v2: $3$, e: $1$),
  (v1: $3$, v2: $2$, e: $0$),
)

#binary_operation(
  "Unicode greater-than-or-equal alias",
  [The mathematical ≥ symbol is an alias for >=.],
  (a, b) => { $ #a ≥ #b $ },
  (v1: $3$, v2: $2$, e: $1$),
  (v1: $2$, v2: $3$, e: $0$),
)

#assert-error("Comparison chains are non-associative", comp($1 < 2 < 3$))
