// citrus - Compiler Runtime: Conditions

#import "../../data/variables.typ": has-variable as _has-variable

/// Check if a variable has a non-empty value (matches interpreter semantics)
#let has-variable(ctx, var-name) = {
  _has-variable(ctx, var-name)
}
