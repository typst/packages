// Tests the inline error diagnostics returned for invalid expressions.

#import "../lib.typ": comp
#import "utils.typ": assert-error

#assert-error(
  "incompatible dot-product shapes",
  comp($mat(1, 2) dot mat(1, 2)$),
  contains: "compatible shapes",
)
