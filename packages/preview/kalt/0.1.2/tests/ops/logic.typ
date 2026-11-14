// Tests direct Typst Boolean inputs and logical NOT behavior.

#import "../../lib.typ": comp
#import "../utils.typ": assert-eq, assert-typst-eq, unary_operation

#assert-typst-eq("Typst true becomes numeric one", comp(true), 1.0)
#assert-typst-eq("Typst false becomes numeric zero", comp(false), 0.0)
#assert-eq("true in a math call", $comp(#true)$, $1$)
#assert-eq("false in a math call", $comp(#false)$, $0$)

#unary_operation(
  "Logical NOT",
  [¬ maps 0 to 1 and 1 to 0; non-Boolean indicators are rejected.],
  a => { $ ¬ #a $ },
  (v: $0$, e: $1$),
  (v: $1$, e: $0$),
  (v: $2$, error: "{0, 1}"),
  (v: $6.5$, error: "{0, 1}"),
  (v: $1+i$, error: "ℂ"),
)
