// Tests logarithms with arbitrary bases for real, complex, and matrix values.

#import "../utils.typ": binary_operation

#binary_operation(
  "Logarithm",
  [Logarithm with arbitrary complex base and value],
  (c1, c2) => { $ log_#c1 (#c2) $ },
  (v1: $2$, v2: $8$, e: $3$),
  (v1: $10$, v2: $1000$, e: $3$),
  (v1: $e$, v2: $e^(2+3i)$, e: $2+3i$),
  (v1: $2$, v2: $mat(2, 4; 8, 16)$, e: $mat(1, 2; 3, 4)$),
  (v1: $mat(2, 4; 8, 16)$, v2: $16$, e: $mat(4, 2; 4/3, 1)$),
  (v1: $0$, v2: $8$, error: "logarithm base cannot be zero"),
)
