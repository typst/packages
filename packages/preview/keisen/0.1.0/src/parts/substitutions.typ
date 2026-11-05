///! Substitutions for values a formatter should not be handed.
///!
///! A gap is not a number, so it never reaches format-number: the substitution
///! runs first and replaces the cell outright.

#let substitute-missing(columns, rows: auto, replacement: [--]) = (
  kind: "substitute",
  test: "missing",
  columns: columns,
  rows: rows,
  replacement: replacement,
)

#let substitute-zero(columns, rows: auto, replacement: [--]) = (
  kind: "substitute",
  test: "zero",
  columns: columns,
  rows: rows,
  replacement: replacement,
)

// A missing value is `none`, an empty string, or the one float that differs
// from itself.
#let is-missing(value) = {
  if value == none { return true }
  if type(value) == str and value.trim() == "" { return true }
  if type(value) == float and value != value { return true }
  false
}

#let is-zero(value) = {
  if type(value) in (int, float) { return value == 0 }
  if type(value) == decimal { return value == decimal(0) }
  false
}
