// Tests Boolean matrix products and distinguishes them from arithmetic dot products.

#import "../utils.typ": binary_operation

#binary_operation(
  "Boolean dot product",
  [For vectors, returns 1 if at least one aligned pair contains two 1s; unlike ordinary dot, it does not count matches.],
  (a, b) => { $ #a ⊙ #b $ },
  (v1: $mat(1, 1)$, v2: $mat(1; 1)$, e: $1$),
  (v1: $mat(1, 1)$, v2: $mat(1; 0)$, e: $1$),
  (v1: $mat(1, 0)$, v2: $mat(0; 1)$, e: $0$),
  (
    v1: $mat(1, 0; 0, 1)$,
    v2: $mat(1, 1; 0, 1)$,
    e: $mat(1, 1; 0, 1)$,
  ),
  (v1: $mat(1, 1)$, v2: $mat(1, 1)$, error: "Matrix Product Shape Error"),
  (v1: $mat(1, 2)$, v2: $mat(1; 1)$, error: "{0, 1}"),
  (v1: $mat(1, i)$, v2: $mat(1; 1)$, error: "ℂ"),
  (v1: $0$, v2: $2$, error: "{0, 1}"),
)

#binary_operation(
  "Ordinary dot remains arithmetic",
  [The ordinary dot product counts matches in a numeric 0/1 vector.],
  (a, b) => { $ #a dot #b $ },
  (v1: $mat(1, 1)$, v2: $mat(1; 1)$, e: $2$),
)
