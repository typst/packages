// =========================================================================
// typcas v2 Step Detail Helpers
// =========================================================================
// Numeric detail contract:
// - 0: no steps
// - 1: concise, depth 1
// - 2: concise, depth 2
// - 3: pedagogical, depth 3
// - 4: pedagogical, full recursion (depth none)
// =========================================================================

#let detail-valid(detail) = type(detail) == int and detail >= 0 and detail <= 4

#let normalize-detail(detail, default: 0) = {
  let d = if detail == none { default } else { detail }
  if detail-valid(d) { return d }
  none
}

#let detail-mode(detail) = if detail >= 3 { "pedagogical" } else { "concise" }

#let detail-depth(detail) = {
  if detail <= 0 { return none }
  if detail == 1 { return 1 }
  if detail == 2 { return 2 }
  if detail == 3 { return 3 }
  none
}

#let resolve-detail-depth(detail, depth: none) = if depth != none { depth } else { detail-depth(detail) }
