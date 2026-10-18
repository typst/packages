// Empty path renders as "<root>" so a top-level type error reads
// `"<root>: expected object, got …"`.
#let _format-path(parts) = {
  if parts.len() == 0 { return "<root>" }
  parts.enumerate().map(((i, part)) => {
    if type(part) == int { "[" + str(part) + "]" }
    else if i == 0 { part }
    else { "." + part }
  }).join("")
}

// Typst's `repr(type(...))` renders as `"int"` / `"dictionary"` /
// `"type(none)"` — accurate but jarring. Translate to JSON-shaped
// names for user-facing messages; unknown reprs fall through.
#let _type-names = (
  str: "string",
  int: "integer",
  float: "number",
  bool: "boolean",
  array: "array",
  dictionary: "object",
)

// The `none` branch is defensive: the validator's null-as-absent rule
// means _type-error never sees a null value today, but _type-name-of is
// a general helper that may be reused by future code paths.
#let _type-name-of(value) = {
  if value == none { return "null" }
  let raw = repr(type(value))
  _type-names.at(raw, default: raw)
}

#let _format-report(errors) = {
  let n = errors.len()
  let noun = if n == 1 { "problem" } else { "problems" }
  let lines = errors.map(e => "  - " + _format-path(e.path) + ": " + e.message)
  "gairm-import: found " + str(n) + " " + noun + " in the input:\n" + lines.join("\n")
}

// Classic two-row Levenshtein edit distance. We fold over the
// characters of `a`, carrying the previous DP row and producing the
// next. Each new row is itself built by folding over the characters
// of `b`, since cell `(i, j)` depends on `(i-1, j)`, `(i, j-1)` and
// `(i-1, j-1)`. The base row is `0..n` (cost of deleting `j` chars
// from `b` to reach the empty prefix of `a`).
#let _edit-distance(a, b) = {
  let ac = a.clusters()
  let bc = b.clusters()
  let n = bc.len()
  let final-row = ac.enumerate().fold(range(0, n + 1), (prev, (i, ca)) => {
    bc.enumerate().fold((i + 1,), (row, (j, cb)) => {
      let cost = if ca == cb { 0 } else { 1 }
      row + (calc.min(
        prev.at(j + 1) + 1,  // deletion
        row.at(j) + 1,       // insertion
        prev.at(j) + cost,   // substitution
      ),)
    })
  })
  final-row.at(n)
}

// Pure: pick the candidate closest to `target` by edit distance, or
// `none` if the best is outside `max-distance` (inclusive) or
// `candidates` is empty. Single-pass fold — strict `<` keeps the
// first-seen winner on ties, so the schema's declaration order
// decides equidistant matches.
#let _closest-match(target, candidates, max-distance) = {
  let best = candidates.fold(none, (acc, c) => {
    let d = _edit-distance(target, c)
    if acc == none or d < acc.distance { (key: c, distance: d) } else { acc }
  })
  if best != none and best.distance <= max-distance { best.key } else { none }
}
