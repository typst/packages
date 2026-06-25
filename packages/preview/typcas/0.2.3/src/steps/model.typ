// =========================================================================
// typcas v2 Step Model
// =========================================================================
// Canonical step nodes:
// - header
// - equation(before -> after)
// - define(lhs = rhs)
// - note
// - group(subtrace container)
// =========================================================================

#import "../expr.typ": *

#let _s-header(title, expr: none, level: 0) = (
  kind: "header",
  title: title,
  expr: expr,
  level: level,
)

#let _s-equation(before, after, rule: none, level: 0, kind: "transform") = (
  kind: "equation",
  before: before,
  after: after,
  rule: rule,
  level: level,
  eq-kind: kind,
)

#let _s-define(lhs, rhs, label: none, level: 0, prefix: none) = {
  // Backward-compatible behavior:
  // - legacy calls: _s-define("u_1", expr, prefix: "where")
  // - new calls:    _s-define(cvar("u_1"), expr, label: "let")
  if type(lhs) == str {
    let shown = cvar(lhs)
    let lbl = if prefix != none { prefix } else { label }
    return (
      kind: "define",
      lhs: shown,
      rhs: rhs,
      label: lbl,
      level: level,
    )
  }
  (
    kind: "define",
    lhs: lhs,
    rhs: rhs,
    label: label,
    level: level,
  )
}

#let _s-note(text, expr: none, tone: "note", level: 0) = (
  kind: "note",
  text: text,
  expr: expr,
  tone: tone,
  level: level,
)

#let _s-group(items, title: none, level: 0, branch: false, branch-label: none) = (
  kind: "group",
  items: items,
  title: title,
  level: level,
  branch: branch,
  branch-label: branch-label,
)

#let _s-branch(label, items, level: 0) = (
  kind: "group",
  items: items,
  title: none,
  level: level,
  branch: true,
  branch-label: label,
)

// -------------------------------------------------------------------------
// Compatibility wrappers (kept to avoid breaking imports)
// -------------------------------------------------------------------------

// IMPORTANT: sub-steps are rendered before result to avoid spoiler effect.
#let _s-apply(lhs, result, rule, sub-steps: ()) = (
  kind: "apply",
  lhs: lhs,
  result: result,
  rule: rule,
  sub-steps: sub-steps,
)
