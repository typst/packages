// Binomial coefficient tests for kalt bindings

#import "../../lib.typ": comp, map
#import "../utils.typ": binary_operation

#binary_operation(
  "Binomial Coefficient",
  [Binary binomial coefficient],
  (c1, c2) => { $ binom(#c1, #c2) $ },
  // binomial coefficient
  (v1: $3$, v2: $1+2i$, e: $12.783877012273047+12.783877012273047i$),
  (v1: $3$, v2: $2+1i$, e: $4.411293492449991-2.205646746224995i$),
  (v1: $2 - 3.2i$, v2: $-2 + 0.5i$, e: $0.035137193905676184+0.022513773816639663i$),
  (v1: $3$, v2: $mat(1, 2; 3, 4)$, e: $comp(mat(binom(3, 1), binom(3, 2); binom(3, 3), binom(3, 4)))$),
  (v1: $mat(1, 2; 3, 4)$, v2: $3$, e: $comp(mat(binom(1, 3), binom(2, 3); binom(3, 3), binom(4, 3)))$),
  (v1: $mat(1, 2; 3, -4)$, v2: $mat(1i, 2 + 1i; -3, 4)$, e: $comp(mat(binom(1, 1i), binom(2, 2+1i); binom(3, -3), binom(-4, 4)))$),
  (v1: $0$, v2: $0$, e: $1$),
  (v1: $7$, v2: $0$, e: $1$),
  (v1: $7$, v2: $7$, e: $1$),
  (v1: $7$, v2: $1$, e: $7$),
)
