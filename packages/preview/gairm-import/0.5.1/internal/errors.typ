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
