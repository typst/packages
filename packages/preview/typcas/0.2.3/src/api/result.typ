// =========================================================================
// typcas v2 Result Contract
// =========================================================================

#let mk-error(code, message, details: none) = (
  code: code,
  message: message,
  details: details,
)

#let mk-result(
  op,
  field,
  strict,
  ok: true,
  expr: none,
  value: none,
  roots: none,
  steps: none,
  restrictions: (),
  satisfied: (),
  conflicts: (),
  residual: (),
  variable-domains: (:),
  warnings: (),
  errors: (),
  diagnostics: (:),
) = (
  ok: ok,
  op: op,
  field: field,
  strict: strict,
  expr: expr,
  value: value,
  roots: roots,
  steps: steps,
  restrictions: restrictions,
  satisfied: satisfied,
  conflicts: conflicts,
  residual: residual,
  variable-domains: variable-domains,
  warnings: warnings,
  errors: errors,
  diagnostics: diagnostics,
)
