// =========================================================================
// CAS Steps Model
// =========================================================================
// Step dictionary constructors used by tracing/rendering.
// =========================================================================

// =========================================================================
// 1. STEP DEFINITIONS
// =========================================================================

// Common structure for all steps:
// { type: "step", kind: string, ... }

/// Header: Main derivation line. "= expr  (rule)"
#let _s-header(expr, rule) = (
  type: "step",
  kind: "header",
  expr: expr,
  rule: rule,
)

/// Note: Textual annotation or intermediate simplification. "= expr (text)"
#let _s-note(text, expr: none) = (
  type: "step",
  kind: "note",
  text: text,
  expr: expr,
)

/// Define: Sidebar variable definition. "where u = expr"
#let _s-define(name, val, prefix: "where") = (
  type: "step",
  kind: "define",
  name: name,
  val: val,
  prefix: prefix,
)

/// Apply: Sidebar operation result. "du/dx = result (rule)"
/// Can contain nested sub-steps.
#let _s-apply(lhs, result, rule, sub-steps: ()) = (
  type: "step",
  kind: "apply",
  lhs: lhs,
  result: result,
  rule: rule,
  sub-steps: sub-steps,
)
