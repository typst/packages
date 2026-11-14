// Tests integer bitwise AND, OR, XOR, and NOT, including matrix and invalid-input cases.

#import "../utils.typ": binary_operation, unary_operation

#binary_operation(
  "Bitwise AND",
  [∧ computes bitwise AND of two real safe integers.],
  (a, b) => { $ #a ∧ #b $ },
  (v1: $6$, v2: $3$, e: $2$),
  (v1: $6$, v2: $2$, e: $2$),
  (v1: $5$, v2: $2$, e: $0$),
  (v1: $-6$, v2: $3$, e: $2$),
  (v1: $9007199254740991$, v2: $1$, e: $1$),
  (v1: $9007199254740992$, v2: $1$, error: "Integer Range Error"),
  (v1: $mat(6, 2)$, v2: $mat(3, 1)$, e: $mat(2, 0)$),
  (v1: $mat(1, 2)$, v2: $mat(1; 2)$, error: "same shape"),
  (v1: $6.5$, v2: $3$, error: "Integer Error"),
  (v1: $1+i$, v2: $3$, error: "Real Value Error"),
)

#binary_operation(
  "Bitwise OR",
  [∨ computes bitwise OR of two real safe integers.],
  (a, b) => { $ #a ∨ #b $ },
  (v1: $6$, v2: $3$, e: $7$),
  (v1: $4$, v2: $1$, e: $5$),
  (v1: $-6$, v2: $3$, e: $-5$),
  (v1: $mat(6, 2)$, v2: $mat(3, 1)$, e: $mat(7, 3)$),
  (v1: $6.5$, v2: $3$, error: "Integer Error"),
  (v1: $1+i$, v2: $3$, error: "Real Value Error"),
)

#binary_operation(
  "Bitwise XOR",
  [⊕ computes bitwise exclusive OR of two real safe integers.],
  (a, b) => { $ #a ⊕ #b $ },
  (v1: $6$, v2: $3$, e: $5$),
  (v1: $7$, v2: $7$, e: $0$),
  (v1: $-6$, v2: $3$, e: $-7$),
  (v1: $9007199254740992$, v2: $1$, error: "Integer Range Error"),
)

#unary_operation(
  "Bitwise NOT",
  [~ applies two's-complement bitwise NOT to a real safe integer.],
  a => { $ ~ #a $ },
  (v: $0$, e: $-1$),
  (v: $1$, e: $-2$),
  (v: $2$, e: $-3$),
  (v: $-6$, e: $5$),
  (v: $6.5$, error: "Integer Error"),
  (v: $1+i$, error: "Real Value Error"),
  (v: $9007199254740992$, error: "Integer Range Error"),
)
